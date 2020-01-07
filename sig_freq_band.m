function sig_freq_band(EEG, resp, pth, foc_nm)

    
    warning('off')
    fs = EEG.srate;
    study = EEG.study{end};
    if strcmp(study, 'HG')
        study_name = 'High Gamma';
    else
        study_name = 'LFP';
    end
    mat_pth = [pth 'Channel events/' study '/'];
    plot_pth = [pth 'plots/' study '/'];
    tvd_pth = [pth 'TvD/'];

    switch EEG.lock{end}
    case 'Response Locked'
        an_st = round(500*fs/1000);
        an_en = round(2000*fs/1000);
        st_tm = -1250;
        an_st_tm = -750;
        en_tm = 750;
        
        second_mrk = -mean(resp(resp > 0));
    case 'Stimulus Locked'
        an_st = round(500*fs/1000);
        an_en = round(1750*fs/1000);
        st_tm = -500;
        an_st_tm = 0;
        en_tm = 1250;

        second_mrk = mean(resp(resp > 0));
    end

    st_sam = round(st_tm/1000*fs);
    
    an_win = an_st+1:an_en;
    chunk_len = round((100*fs)/1000);
    nchnk = floor(size(an_win,2)/chunk_len);
    chunck_block = zeros(nchnk,chunk_len); 
    x = 1;
    for w = 1:nchnk
        chunck_block(w,:) = an_win(x):an_win(x+(chunk_len-1));
        x = x + chunk_len;
    end
    
    q = 0.05;

    pt_id = strsplit(EEG.setname, '_');
    pt_nm = pt_id{1};
    task = pt_id{2};

        
%     mats = dir(mat_pth);
%     mats = {mats.name};
%     mats = mats(~cellfun('isempty',strfind(mats,'.mat')));
    
    chans = {EEG.chanlocs.labels};
    
    sig_msk = [];
    if exist('TvD', 'var')
        clear TvD
    end
    TvD = {};
    k = 0;
    disp('  ')
    disp('  Building TvD')
    disp(' --------------')
    for ii = 1:length(chans)
        
        loadbar(ii, length(chans));
        C = load([mat_pth foc_nm '_' pt_nm '_' chans{ii} '_' EEG.ref '.mat'], 'chnl_evnt');
        chnl_evnt = C.chnl_evnt;
        
        pvals = [];
        hvals = [];
        % unpaired ttest at every point
        for N = 1:nchnk
            winN = chunck_block(N, :);
            zmean_pop = zeros(size(chnl_evnt, 1), 1);
            event_popm = mean(chnl_evnt(:,winN),2);
            if strcmp(study, 'HG')
                ttype = 'left';
            elseif strcmp(study, 'LFP')
                ttype = 'both';
            end
            [h, p] = ttest2(zmean_pop, event_popm, 'Alpha', q, 'Tail', ttype, 'Vartype', 'unequal');

            pvals = [pvals p];
            hvals = [hvals h];
        end
        
        %fdr correct
        [pthr, ~, padj] = fdr2(pvals,q);

        %find starting indicies of significance groups
        %H = pvals < pthr;
        H = hvals;
        %identify if electrode is significant (has significant chunk that is >10% baseline)
        sig_idcs = [];
        for n = 1:length(H)
            if H(n)
                sig_idcs = [sig_idcs; chunck_block(n,:)];
            end
        end

        if ~isempty(sig_idcs)
            k = k + 1;
            TvD{k,1} = ii;
            TvD{k,2} = chans{ii};
            TvD{k,3} = pthr; %corrected pvalue threshold
            TvD{k,4} = pvals; %original pvalues
            TvD{k,5} = sig_idcs;
            TvD{k,6} = padj; %adjusted pvalues
            sig_msk = [sig_msk 1];
        else
            sig_msk = [sig_msk 0];
        end
    end
    
    % remove empty rows in TvD
    emptyCells = cellfun('isempty', TvD);
    TvD(all(emptyCells,2),:) = [];

    
    % plot significant electrodes
    sig_chans = chans(logical(sig_msk));
    all_sdarea = [];
    disp('  ')
    disp(['  Plotting ' study])
    disp(' --------------')
    for ii = 1:length(sig_chans)
        
        loadbar(ii, length(sig_chans))
                
        load([mat_pth foc_nm '_' pt_nm '_' sig_chans{ii} '_' EEG.ref '.mat'], 'chnl_evnt');
        
        samp_sd = std(chnl_evnt)/sqrt(size(chnl_evnt,1));
        sdp_max = max(mean(chnl_evnt)+samp_sd);
        sdm_min = min(mean(chnl_evnt)-samp_sd);
        if sdm_min > 0
            sdm_min = -10;
        end
        
        warning('off')
        figure('visible', 'off','color','white');
        %figure
        hold on

        % smooth mean of channel event data
%         fc = 15;
%         [bb,aa] = butter(6,fc/(fs/2)); % Butterworth filter of order 6
%         dat = filter(bb,aa,mean(chnl_evnt,1));
        dat = mean(chnl_evnt,1);

        % Plot data
        sdarea = shade_plot(st_tm:1000/fs:en_tm, dat, samp_sd, rgb('steelblue'), 0.5, 1);      
        all_sdarea = [all_sdarea; sdarea];
        % Plot vertical lines
        plot([0 0] ,[sdm_min sdp_max], 'k', 'LineWidth', 2);
        if second_mrk > en_tm
            line([en_tm en_tm], [sdm_min sdp_max], 'LineStyle', '--', 'Color', 'y')
        elseif second_mrk < st_tm
            line([st_tm st_tm], [sdm_min sdp_max], 'LineStyle', '--', 'Color', 'y')
        else
            plot([second_mrk second_mrk], [sdm_min sdp_max], '--', 'color', [.549, .549, .549])
        end
        
        sigt_adj = 1000*(TvD{ii,5}+st_sam)/fs;
        % Plot horizontal lines
        plot([st_tm     an_st_tm], [0 0], 'k');
        plot([an_st_tm  en_tm], [0 0], 'k', 'LineWidth',3);
        for jj = 1:size(sigt_adj,1)
            plot(sigt_adj(jj,:), zeros(1,102), 'r', 'linewidth', 3)
        end

        % Edit plot
        set(gcf, 'Units','pixels','Position',[100 100 800 600])
        title(sprintf('Significant %s Activity in %s - Channel %s - %s Task', study_name, pt_nm, sig_chans{ii}, task))
        xlabel('Time (ms)')
        ylabel('Change from Baseline (%)')
        xlim(gca, [st_tm en_tm])
        ylim(gca, [sdm_min sdp_max])
        axis tight
        grid on

        % Save
        save([tvd_pth study '_TvD.mat'], 'TvD');
        print('-dpng',sprintf('%s_%2.2f_%ims.png',[plot_pth sig_chans{ii}], q, 100))
        close
    end
end
