function sig_freq_band(EEG, resp, pth, foc_nm)

    
    warning('off')
    fs = EEG.srate;
    band = EEG.band{end};
    if strcmp(band, 'HFB')
        study_name = 'High Frequency Band';
    else
        study_name = 'LFP';
    end
    mat_pth = sprintf('%s/Channel events/%s', pth, band);
    plot_pth = sprintf('%s/plots/%s', pth, band);
    tvd_pth = sprintf('%s/TvD', pth);

    switch EEG.lock{end}
        case 'Response Locked'        
            st_tm = -1250;
            an_st_tm = -750;
            an_en_tm = 750;
            en_tm = 750;
            second_mrk = -mean(resp);
        case 'Stimulus Locked'
            st_tm = -1000;
            an_st_tm = 0;
            an_en_tm = 1000;
            en_tm = 1600;
            second_mrk = mean(resp);
    end

    an_st = round(abs(an_st_tm-st_tm)*fs/1000);
    an_en = round(abs(an_en_tm-st_tm)*fs/1000);
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
    
    if exist('TvD', 'var')
        clear TvD
    end
    TvD = cell(0,5);
    k = 0;

    for ii = 1:length(chans)
        
        C = load(sprintf('%s/%s_%s_%s_%s.mat', mat_pth, foc_nm, pt_nm, chans{ii}, EEG.ref), 'chnl_evnt');
        chnl_evnt = C.chnl_evnt;
        
        pvals = [];
        hvals = [];
        
        % unpaired ttest at every point
        for N = 1:nchnk
            winN = chunck_block(N, :);
            zmean_pop = zeros(size(chnl_evnt, 1), 1);
            event_popm = mean(chnl_evnt(:,winN),2);
            if strcmp(band, 'HFB')
                ttype = 'left';
            elseif strcmp(band, 'LFP')
                ttype = 'both';
            end
            [h, p] = ttest2(zmean_pop, event_popm, 'Alpha', q, 'Tail', ttype, 'Vartype', 'unequal');

            pvals = [pvals p];
            hvals = [hvals h];
        end
        
        %fdr correct
        [pthr, ~, padj] = fdr2(pvals,q);

        %find starting indicies of significance groups
        hcorr = pvals < pthr;
        
        %identify if electrode is significant (has significant chunk that is >10% baseline)
        sig_idcs = [];
        for n = 1:length(hcorr)
            if hcorr(n)
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
        end
    end

    
    % plot significant electrodes
    sig_chans = TvD(:,2);
    all_sdarea = [];


    for ii = 1:length(sig_chans)
                        
        load(sprintf('%s/%s_%s_%s_%s.mat', mat_pth, foc_nm, pt_nm, sig_chans{ii}, EEG.ref), 'chnl_evnt');
        
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
        fc = 15;
        [bb,aa] = butter(6,fc/(fs/2)); % Butterworth filter of order 6
        dat = filter(bb,aa,mean(chnl_evnt,1));

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
        chan_sidc = TvD{ii,5};
        % Plot horizontal lines
        plot([st_tm     en_tm], [0 0], 'k');
        plot([an_st_tm  an_en_tm], [0 0], 'k', 'LineWidth',2);
 
        
        pidc = sort(chan_sidc(dat(chan_sidc) > 0));
        prngs = [1; find(diff(pidc) > 1)+1; length(pidc)];
        ptm = 1000*(pidc+st_sam)/fs;
        for k = 1:length(prngs)-1
            rzone = ptm(prngs(k)):ptm(prngs(k+1)-1);
            plot(rzone, zeros(1,length(rzone)), 'r', 'linewidth', 2)
        end

        % Edit plot
        set(gcf, 'Units','pixels','Position',[100 100 800 600])
        title(sprintf('Significant %s Activity %s - Channel %s - %s Task', study_name, pt_nm, sig_chans{ii}, task))
        xlabel('Time (ms)')
        ylabel('Change from Baseline (%)')
        xlim(gca, [st_tm en_tm])
        ylim(gca, [sdm_min sdp_max])
        axis tight
        grid on

        % Save
        save(sprintf('%s/%s_TvD.mat', tvd_pth, band), 'TvD');
        print('-dpng',sprintf('%s/%s_%2.2f_%ims.png', plot_pth, sig_chans{ii}, q, 100))
        close
    end
end
