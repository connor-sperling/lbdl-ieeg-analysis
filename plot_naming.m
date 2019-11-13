function ax = plot_naming(dat_files, gsize, resp, pth, fs, lock)

    plt_pth = [pth 'Channel Plots by Position in Category/Group Size ' gsize '/'];
    if ~exist(plt_pth, 'dir')
        mkdir(plt_pth)
    end
    
    
        
    switch lock
        case 'Response Locked' 
            st_tm = -1250;
            en_tm = 250;
            second_mrk = -mean(resp(resp > 0));
        case 'Stimulus Locked'
            st_tm = -500;
            en_tm = 1000;
            second_mrk = mean(resp(resp > 0));
    end
    
    figure('visible', 'off')
    %figure
    hold on
    sd_shade = [176 176 176]./255;
    rst = 40; gst = 30; bst = 0;
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
        
        file_id = strsplit(dat_files{1}, '_');
        subj = file_id{2};
        ch_lab = file_id{3};
        ref = erase(file_id{4}, ".mat");
        
        cat_typ = file_id{1};
        cat_nm = cat_typ(isletter(cat_typ));
        cat_no_s = cat_typ(~isletter(cat_typ));
        if isnan(str2double(cat_typ(~isletter(cat_typ))))
            grp_stsp = cellfun(@str2double, strsplit(cat_no_s, '-'));
            cats = [cats grp_stsp(1):grp_stsp(2)];
        else
            cats = [cats str2double(cat_no_s)];
        end


        %dat = smoothdata(mean(chnl_evnt,1), 'gaussian', round(50/1000*fs));
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
        
        X(:,ii) = plot(st_tm:1000/fs:en_tm, dat, 'color', c, 'Linewidth', 2, 'DisplayName', ['Pos. in Cat.: ' cat_no_s]);

    end
    
    plot([0 0] ,[minplot-20 maxplot+20], 'LineWidth', 2, 'Color', 'k');
    plot([st_tm en_tm], [0 0],'k','LineWidth',1);
    if second_mrk > en_tm
        line([en_tm en_tm], [minplot-10 maxplot+10], 'LineStyle', '--', 'Color', 'y')
    elseif second_mrk < st_tm
        line([st_tm st_tm], [minplot-10 maxplot+10], 'LineStyle', '--', 'Color', 'y')
    else
        plot([second_mrk second_mrk], [minplot-10 maxplot+10], '--', 'color', [.549, .549, .549])
    end

    
    grid on
    title(sprintf('%s - %s - Naming Task - %s ref. - %s', subj, ch_lab, ref, lock))
    xlim([st_tm en_tm])
    ylim([minplot-10 maxplot+10])
    legend(X, 'Location', 'northwest')
 
    plt_fname = sprintf('%s%s_%s_%s.jpg',plt_pth, subj, ch_lab, ref);
    saveas(gca, plt_fname)
    
    ax = gca;
    ax.Title.String = ch_lab;
end