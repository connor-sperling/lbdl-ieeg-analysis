function plot_stroop(dat_files, resp, pth, subj, fs, lock, ref)
    
    plt_pth = [pth 'Channel Plots by Stroop Task'];
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
    
    
    ch_lab = strsplit(dat_files{1}, '_');
    ch_lab = ch_lab{3};
        
    fcCc_beg = dat_files{cellfun(@(x) contains(x,'cCcBeg'), dat_files)};
    cCc_beg = load(fcCc_beg);
    
    fcCc_end = dat_files{cellfun(@(x) contains(x,'cCcEnd'), dat_files)};
    cCc_end = load(fcCc_end);
    
    fcIc_beg = dat_files{cellfun(@(x) contains(x,'cIcBeg'), dat_files)};
    cIc_beg = load(fcIc_beg);
    
    fcIc_end = dat_files{cellfun(@(x) contains(x,'cIcEnd'), dat_files)};
    cIc_end = load(fcIc_end);
    
    fcCs_beg = dat_files{cellfun(@(x) contains(x,'cCsBeg'), dat_files)};
    cCs_beg = load(fcCs_beg);
    
    fcCs_end = dat_files{cellfun(@(x) contains(x,'cCsEnd'), dat_files)};
    cCs_end = load(fcCs_end);
    
    fcIs_beg = dat_files{cellfun(@(x) contains(x,'cIsBeg'), dat_files)};
    cIs_beg = load(fcIs_beg);
    
    fcIs_end = dat_files{cellfun(@(x) contains(x,'cIsEnd'), dat_files)};
    cIs_end = load(fcIs_end);
    
    
    
    fsCc_beg = dat_files{cellfun(@(x) contains(x,'sCcBeg'), dat_files)};
    sCc_beg = load(fsCc_beg);
    
    fsCc_end = dat_files{cellfun(@(x) contains(x,'sCcEnd'), dat_files)};
    sCc_end = load(fsCc_end);
    
    fsIc_beg = dat_files{cellfun(@(x) contains(x,'sIcBeg'), dat_files)};
    sIc_beg = load(fsIc_beg);
    
    fsIc_end = dat_files{cellfun(@(x) contains(x,'sIcEnd'), dat_files)};
    sIc_end = load(fsIc_end);
    
    fsCs_beg = dat_files{cellfun(@(x) contains(x,'sCsBeg'), dat_files)};
    sCs_beg = load(fsCs_beg);
    
    fsCs_end = dat_files{cellfun(@(x) contains(x,'sCsEnd'), dat_files)};
    sCs_end = load(fsCs_end);
    
    fsIs_beg = dat_files{cellfun(@(x) contains(x,'sIsBeg'), dat_files)};
    sIs_beg = load(fsIs_beg);
    
    fsIs_end = dat_files{cellfun(@(x) contains(x,'sIsEnd'), dat_files)};
    sIs_end = load(fsIs_end);
    
    figure('visible', 'off')
    %figure
    set(gcf, 'Units','pixels','Position',[0 0 1920 1116])
    
    c1 = [186, 153, 128]/255;
    c2 = [255, 153, 51]/255; % Creamy Orange
    c3 = [204, 204, 0]/255; % Yellow
    c4 = [121, 96, 72]/255; % Dark Brown
    delt = 10;
    fc = 20;
    [bb,aa] = butter(6,fc/(fs/2)); % Butterworth filter of order 6
    cCcB_dat = filter(bb,aa,mean(cCc_beg.chnl_evnt,1));
    cIcB_dat = filter(bb,aa,mean(cIc_beg.chnl_evnt,1));
    cCsB_dat = filter(bb,aa,mean(cCs_beg.chnl_evnt,1));
    cIsB_dat = filter(bb,aa,mean(cIs_beg.chnl_evnt,1));
    max_cb = max(max([cCcB_dat,cIcB_dat,cCsB_dat,cIsB_dat]))+delt;
    min_cb = min(min([cCcB_dat,cIcB_dat,cCsB_dat,cIsB_dat]))-delt;
    
    cCcE_dat = filter(bb,aa,mean(cCc_end.chnl_evnt,1));
    cIcE_dat = filter(bb,aa,mean(cIc_end.chnl_evnt,1));
    cCsE_dat = filter(bb,aa,mean(cCs_end.chnl_evnt,1));
    cIsE_dat = filter(bb,aa,mean(cIs_end.chnl_evnt,1));
    max_ce = max(max([cCcE_dat,cIcE_dat,cCsE_dat,cIsE_dat]))+delt;
    min_ce = min(min([cCcE_dat,cIcE_dat,cCsE_dat,cIsE_dat]))-delt;
    
    sCcB_dat = filter(bb,aa,mean(sCc_beg.chnl_evnt,1));
    sIcB_dat = filter(bb,aa,mean(sIc_beg.chnl_evnt,1));
    sCsB_dat = filter(bb,aa,mean(sCs_beg.chnl_evnt,1));
    sIsB_dat = filter(bb,aa,mean(sIs_beg.chnl_evnt,1));
    max_sb = max(max([sCcB_dat,sIcB_dat,sCsB_dat,sIsB_dat]))+delt;
    min_sb = min(min([sCcB_dat,sIcB_dat,sCsB_dat,sIsB_dat]))-delt;
    
    sCcE_dat = filter(bb,aa,mean(sCc_end.chnl_evnt,1));
    sIcE_dat = filter(bb,aa,mean(sIc_end.chnl_evnt,1));
    sCsE_dat = filter(bb,aa,mean(sCs_end.chnl_evnt,1));
    sIsE_dat = filter(bb,aa,mean(sIs_end.chnl_evnt,1));
    max_se = max(max([sCcE_dat,sIcE_dat,sCsE_dat,sIsE_dat]))+delt;
    min_se = min(min([sCcE_dat,sIcE_dat,sCsE_dat,sIsE_dat]))-delt;
    
    
    subplot(2,2,1); hold on;
    X(:,1) = plot(st_tm:1000/fs:en_tm, cCcB_dat, 'color', c1, 'Linewidth', 2, 'DisplayName', 'cCc');
    X(:,2) = plot(st_tm:1000/fs:en_tm, cIcB_dat, 'color', c2, 'Linewidth', 2, 'DisplayName', 'cIc');
    X(:,3) = plot(st_tm:1000/fs:en_tm, cCsB_dat, 'color', c3, 'Linewidth', 2, 'DisplayName', 'cCs');
    X(:,4) = plot(st_tm:1000/fs:en_tm, cIsB_dat, 'color', c4, 'Linewidth', 2, 'DisplayName', 'cIs');
    plot([st_tm en_tm], [0 0],'k','LineWidth',1);
    plot([0 0], [min_cb max_cb], 'k', 'LineWidth', 1)
    plot([second_mrk second_mrk], [min_cb max_cb], 'k', 'LineWidth', 1)
    title([subj ' ' ch_lab ' - ' lock ' - Color Stroop (first 20 stimuli)'])
    legend(X, 'Location', 'northwest')
    xlabel('Time (ms)')
    ylim([min_cb max_cb])
    hold off;
    
    subplot(2,2,2); hold on;
    X(:,1) = plot(st_tm:1000/fs:en_tm, cCcE_dat, 'color', c1, 'Linewidth', 2, 'DisplayName', 'cCc');
    X(:,2) = plot(st_tm:1000/fs:en_tm, cIcE_dat, 'color', c2, 'Linewidth', 2, 'DisplayName', 'cIc');
    X(:,3) = plot(st_tm:1000/fs:en_tm, cCsE_dat, 'color', c3, 'Linewidth', 2, 'DisplayName', 'cCs');
    X(:,4) = plot(st_tm:1000/fs:en_tm, cIsE_dat, 'color', c4, 'Linewidth', 2, 'DisplayName', 'cIs');
    plot([st_tm en_tm], [0 0],'k','LineWidth',1);
    plot([0 0], [min_ce max_ce], 'k', 'LineWidth', 1)
    plot([second_mrk second_mrk], [min_cb max_cb], 'k', 'LineWidth', 1)
    title([subj ' ' ch_lab ' - ' lock ' - Color Stroop (second 20 stimuli)'])
    legend(X, 'Location', 'northwest')
    xlabel('Time (ms)')
    ylim([min_ce max_ce])
    hold off;
    
    subplot(2,2,3); hold on;
    X(:,1) = plot(st_tm:1000/fs:en_tm, sCcB_dat, 'color', c1, 'Linewidth', 2, 'DisplayName', 'sCc');
    X(:,2) = plot(st_tm:1000/fs:en_tm, sIcB_dat, 'color', c2, 'Linewidth', 2, 'DisplayName', 'sIc');
    X(:,3) = plot(st_tm:1000/fs:en_tm, sCsB_dat, 'color', c3, 'Linewidth', 2, 'DisplayName', 'sCs');
    X(:,4) = plot(st_tm:1000/fs:en_tm, sIsB_dat, 'color', c4, 'Linewidth', 2, 'DisplayName', 'sIs');
    plot([st_tm en_tm], [0 0],'k','LineWidth',1);
    plot([0 0], [min_sb max_sb], 'k', 'LineWidth', 1)
    plot([second_mrk second_mrk], [min_cb max_cb], 'k', 'LineWidth', 1)
    title([subj ' ' ch_lab ' - ' lock ' - Spatial Stroop (first 20 stimuli)'])
    legend(X, 'Location', 'northwest')
    xlabel('Time (ms)')
    ylim([min_sb max_sb])
    hold off;
    
    subplot(2,2,4); hold on;
    X(:,1) = plot(st_tm:1000/fs:en_tm, sCcE_dat, 'color', c1, 'Linewidth', 2, 'DisplayName', 'sCc');
    X(:,2) = plot(st_tm:1000/fs:en_tm, sIcE_dat, 'color', c2, 'Linewidth', 2, 'DisplayName', 'sIc');
    X(:,3) = plot(st_tm:1000/fs:en_tm, sCsE_dat, 'color', c3, 'Linewidth', 2, 'DisplayName', 'sCs');
    X(:,4) = plot(st_tm:1000/fs:en_tm, sIsE_dat, 'color', c4, 'Linewidth', 2, 'DisplayName', 'sIs');
    plot([st_tm en_tm], [0 0],'k','LineWidth',1);
    plot([0 0], [min_se max_se], 'k', 'LineWidth', 1)
    plot([second_mrk second_mrk], [min_cb max_cb], 'k', 'LineWidth', 1)
    title([subj ' ' ch_lab ' - ' lock ' - Spatial Stroop (second 20 stimuli)'])
    legend(X, 'Location', 'northwest')
    xlabel('Time (ms)')
    ylim([min_se max_se])
    hold off;
    
    plt_fname = sprintf('%s%s_%s_%s.jpg', plt_pth, subj, ch_lab, ref);
    saveas(gca, plt_fname)
    












end