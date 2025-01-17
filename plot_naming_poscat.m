function ax = plot_naming_poscat(EEG, dat_files, ch_lab, gsize, lock_pth, cnum)

    if ispc
        subjs_dir = 'L:/iEEG_San_Diego/Subjs';
    elseif isunix
        subjs_dir = '/mnt/bdl-raw/iEEG_San_Diego/Subjs';
    end
    
    
    dt = strsplit(datestr(datetime));
    dt = dt{1};

    sid = strsplit(EEG.setname, '_');
    subj = sid{1};  
    task = sid{2};
    fs = EEG.srate;
    resp = [EEG.event.resp]';
    study = EEG.study{end};
    ref = EEG.ref;
    lock = EEG.lock{end};
    
    alph_msk = isstrprop(ch_lab,'alpha');
    alph = ch_lab(alph_msk);
    numr = strsplit(ch_lab(~alph_msk),'-');
    numr = cellfun(@(x) str2double(x),numr);
    if numr(1) > 10
        n = num2str(numr(1));
        alph = [alph n(1)];
    end     
    
    spbr_pth = sprintf('%s/subject plots by region/%s/%s/%s/Group Size %s/%s/%s', subjs_dir, task, ref, study, gsize, lock, alph);
    plt_pth = sprintf('%s/Channel Plots by Position in Category/%s/Group Size %s', lock_pth, study, gsize);
    
    if ~exist(spbr_pth, 'dir')
        mkdir(spbr_pth)
    end
    
    if ~exist(plt_pth, 'dir')
        mkdir(plt_pth)
    elseif cnum == 1
        fp = dir(fullfile(plt_pth, '*.jpg'));
        plts = {fp.name};
        for p = 1:length(plts)
            delete([plt_pth plts{p}]);
        end
    end

    switch lock
        case 'Response Locked'
            begin_tm = -1250;
            st_tm = -1250;
            en_tm = 750;
            second_mrk = -mean(resp);
        case 'Stimulus Locked'
            begin_tm = -1000;
            st_tm = -400;
            en_tm = 1600;
            second_mrk = mean(resp);
    end
    
%     figure('visible', 'off')
    figure
    set(gcf, 'Units','pixels','Position',[100 100 800 600])
    hold on
    
    sd_shade = [176 176 176]./255;
    rst = 236; gst = 233; bst = 152;
    r = rst/255; g = gst/255; b = bst/255;
    
    cats = [];
    sdp_max = 0;
    sdm_min = 0;
    minplot = 0;
    maxplot = 0;

    for ii = 1:length(dat_files)

        [r, g, b] = rgb_grad(r, g, b, rst, gst, bst, length(dat_files));
        c = [r, g, b];
    
        C = load(dat_files{ii}, 'chnl_evnt');
        chnl_evnt = C.chnl_evnt;
        
        file_id = strsplit(dat_files{ii}, '_');
        cat_typ = file_id{1};
        cat_no = cat_typ(~isletter(cat_typ));

%         dat = smoothdata(mean(chnl_evnt,1), 'gaussian', round(50/1000*fs));
        fc = 10;
        [bb,aa] = butter(6,fc/(fs/2)); % Butterworth filter of order 6
        dat = filter(bb,aa,mean(chnl_evnt,1));
        
        mindat = min(dat);
        maxdat = max(dat);
        if mindat < minplot
            minplot = mindat;
        end
        if maxdat > maxplot
            maxplot = maxdat;
        end
        
        tsamp = floor((st_tm-begin_tm)*fs/1000)+1:floor((en_tm-begin_tm)*fs/1000)+1;
        tmesh = st_tm:1000/fs:en_tm;
        datd = dat(tsamp);
        
        X(:,ii) = plot(tmesh, datd, 'color', c, 'Linewidth', 2, 'DisplayName', ['Pos. in Cat.: ' cat_no]);

    end
    
    plot([0 0] ,[minplot-20 maxplot+20], 'LineWidth', 1, 'Color', 'k');
    plot([st_tm en_tm], [0 0],'k','LineWidth',1);
    if second_mrk > en_tm
        line([en_tm en_tm], [minplot-10 maxplot+10], 'LineStyle', '--', 'Color', 'y')
    elseif second_mrk < st_tm
        line([st_tm st_tm], [minplot-10 maxplot+10], 'LineStyle', '--', 'Color', 'y')
    else
        plot([second_mrk second_mrk], [minplot-10 maxplot+10], '--', 'color', [.549, .549, .549])
    end

    
    title(sprintf('%s - %s - Naming Task - %s ref. - %s', subj, ch_lab, ref, lock))
    xlim([st_tm en_tm])
    ylim([minplot-10 maxplot+10])
    xlab = xlabel('Time (ms)');
    ylab = ylabel('Change from Baseline (%)');
    set([xlab ylab], 'FontName', 'AvantGarde')
    set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
        'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', ...
        'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], 'YTick', 0:10:maxplot+10, ...
        'LineWidth', 1)
    
    legend(X, 'Location', 'northwest')
 
    plt_fname = sprintf('%s/%s_%s_%s.tif', plt_pth, subj, ch_lab, ref);
    saveas(gca, plt_fname)
    
    spbr_fname = sprintf('%s/%s_%s_%s.jpg', spbr_pth, subj, ch_lab, ref);
    saveas(gca, spbr_fname)
    
    ax = gca;
    ax.Title.String = ch_lab;
end