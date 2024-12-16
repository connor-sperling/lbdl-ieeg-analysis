function naming_analysis


    k = 1;
    % Group by event
    while k <= length(keyset)


        if gsize > 1
            catn = [keyset(k) '-' num2str(k+gsize-1)];
        else
            catn = keyset(k);
        end

        foc_nm = [focus_typ catn];
        cat_pth = [lock_pth foc_nm '/' study '/'];
        if ~exist(cat_pth, 'dir')
            mkdir(cat_pth);
        end
        k = k + gsize;


        focus_evn_typ = {}; focus_evns = []; focus_resp = [];
        for ii = k:k+gsize-1
            temp_typ = cln_evn_typ(ismember(id, keyset(ii)));
            temp_evns = cln_evns(ismember(cln_evn_typ, temp_typ));
            temp_resp = cln_resp(ismember(cln_evn_typ, temp_typ));

            focus_evn_typ = [focus_evn_typ; temp_typ];
            focus_evns = [focus_evns; temp_evns];
            focus_resp = [focus_resp; temp_resp];
        end
        % gather sig channel data over specific events & filter
        event_prep(EEG_sig, focus_evns, focus_evn_typ, focus_resp, cat_pth, foc_nm);

        cd(cat_pth)
        foc_mats = dir('*.mat');
        foc_mats = {foc_mats.name};
        sig_flds = {};

        for ii = 1:length(foc_mats)
            sigchan = strsplit(foc_mats{ii}, '_');
            sigchan = sigchan{3};
            sigchan_fld = {['channel_' sigchan '/']};
            sig_flds = [sig_flds sigchan_fld];

            if ~exist([lock_pth char(sigchan_fld)], 'dir')
                mkdir([lock_pth char(sigchan_fld)])
            end

            copyfile(foc_mats{ii}, [lock_pth 'channel_' sigchan '/' foc_mats{ii}]);
        end

    end

    % Make folder to hold all of the plots about to be made
    if ~exist([lock_pth 'Channel FBA Plots by Category/' study '/Group ' num2str(gsize)], 'dir')
        mkdir([lock_pth 'Channel FBA Plots by Category/' study '/Group ' num2str(gsize)]);
    end


    prompt('plot by chan')
    sig_chans = {EEG_sig.chanlocs.labels};
    handles = {};
    axiis = {};
    for ii = 1:length(sig_chans)

        loadbar(ii, length(sig_chans))

        chan_dir = [lock_pth 'channel_' sig_chans{ii} '/'];
        if strcmp(lock, 'Stimulus Locked')
            axii = plot_by_focus(chan_dir, sigALL_shadow_s(ii,:), cln_resp, task, lock_typ, gsize, fs, 0);
        else
            axii = plot_by_focus(chan_dir, sigALL_shadow_r(ii,:), cln_resp, task, lock_typ, gsize, fs, 0);
        end
        handles{ii} = get(axii, 'children');
        axiis{ii} = axii;

        cd(chan_dir)
        jpgs = dir('*.jpeg');
        jpgft = [jpgs.datenum];
        jpgfile = jpgs(jpgft == max(jpgft)).name;

        % Copy all channel plots into the same folder for easy viewing
        copyfile(jpgfile, [lock_pth 'Channel FBA Plots by Category/' study '/Group ' num2str(gsize) '/' jpgfile]);

    end

    cd(pth)
    for ii = 1:length(sig_flds)
        rmdir([lock_pth sig_flds{ii}], 's')
    end
    subplot_all(handles, axiis, 4, [lock_pth 'Channel FBA Plots by Category/' study '/Group ' num2str(gsize) '/'])
end


% Option
%     typ_idx = 2;
%     focus_typ = 'poscat';
%     id = cellfun(@(x) str2double(x(typ_idx)), cln_split);
%     keyset = unique(id);
%     
%     p12_msk = cellfun(@(x) str2double(x(typ_idx)) < 3, cln_split);
%     p12 = cln_evn_typ(p12_msk);
%     p12_idcs = cln_evns(p12_msk);
%     
%     p34_msk = cellfun(@(x) str2double(x(typ_idx)) > 2 & str2double(x(typ_idx)) < 5, cln_split);
%     p34 = cln_evn_typ(p34_msk);
%     p34_idcs = cln_evns(p34_msk);
%     
%     p56_msk = cellfun(@(x) str2double(x(typ_idx)) > 4, cln_split);
%     p56 = cln_evn_typ(p56_msk);
%     p56_idcs = cln_evns(p56_msk);
%     
%     p13_msk = cellfun(@(x) str2double(x(typ_idx)) < 4, cln_split);
%     p13 = cln_evn_typ(p13_msk);
%     p13_idcs = cln_evns(p13_msk);
%     
%     p46_msk = cellfun(@(x) str2double(x(typ_idx)) > 3, cln_split);
%     p46 = cln_evn_typ(cellfun(@(x) str2double(x(typ_idx)) > 3, cln_split));
%     p46_idcs = cln_evns(p46_msk);
