

%% Get all good events
%This block is redundant but better than what I had that makes
%analysis_evns/evn_typ
rej_evn_typ = rej_all(~ismissing(rej_all));
all_evn_typ = string(evn_typ);
gd_msk = ~ismember(all_evn_typ, rej_evn_typ);

cln_evn_typ = cellstr(all_evn_typ(gd_msk));
cln_split = cellfun(@(x) strsplit(x, '-'), cln_evn_typ, 'UniformOutput', false);

cln_resp = res_tm(gd_msk);
cln_evns = stim_evns(gd_msk);



    
% DEFINE FOCUS NAMES FOR EACH TASK TYPE
if strcmp(task, 'Naming')
    typ_idx = 2;
    focus_typ = 'poscat';
    id = cellfun(@(x) str2double(x(typ_idx)), cln_split);
    keyset = unique(id);
    
    p12_msk = cellfun(@(x) str2double(x(typ_idx)) < 3, cln_split);
    p12 = cln_evn_typ(p12_msk);
    p12_idcs = cln_evns(p12_msk);
    
    p34_msk = cellfun(@(x) str2double(x(typ_idx)) > 2 & str2double(x(typ_idx)) < 5, cln_split);
    p34 = cln_evn_typ(p34_msk);
    p34_idcs = cln_evns(p34_msk);
    
    p56_msk = cellfun(@(x) str2double(x(typ_idx)) > 4, cln_split);
    p56 = cln_evn_typ(p56_msk);
    p56_idcs = cln_evns(p56_msk);
    
    p13_msk = cellfun(@(x) str2double(x(typ_idx)) < 4, cln_split);
    p13 = cln_evn_typ(p13_msk);
    p13_idcs = cln_evns(p13_msk);
    
    p46_msk = cellfun(@(x) str2double(x(typ_idx)) > 3, cln_split);
    p46 = cln_evn_typ(cellfun(@(x) str2double(x(typ_idx)) > 3, cln_split));
    p46_idcs = cln_evns(p46_msk);
end

% Make a dictionary type structure of all different event groupings?

if strcmp(task, 'Stroop')
    focus_typ = 'congruency';
    color_idx = 3;
    space_idx = 4;

    cCw_beg = {}; cIw_beg = {}; cCs_beg = {}; cIs_beg = {};
    cCw_end = {}; cIw_end = {}; cCs_end = {}; cIs_end = {};
    sCw_beg = {}; sIw_beg = {}; sCs_beg = {}; sIs_beg = {};
    sCw_end = {}; sIw_end = {}; sCs_end = {}; sIs_end = {};
    cCw_beg_idcs = []; cIw_beg_idcs = []; cCs_beg_idcs = []; cIs_beg_idcs = [];
    cCw_end_idcs = []; cIw_end_idcs = []; cCs_end_idcs = []; cIs_end_idcs = [];
    sCw_beg_idcs = []; sIw_beg_idcs = []; sCs_beg_idcs = []; sIs_beg_idcs = [];
    sCw_end_idcs = []; sIw_end_idcs = []; sCs_end_idcs = []; sIs_end_idcs = [];
    
    for ii = 2:str2double(cln_evn_typ{end}(1))
        blk_msk = cellfun(@(x) str2double(x(1)) == ii, cln_split);
        block_evns = cln_evn_typ(blk_msk);
        block_idcs = cln_evns(blk_msk);
        if mod(ii,2)
            [beg_msk,end_msk] = split_stroop_evns(block_evns, color_idx, 'C', ii);
            cCw_beg = [cCw_beg; block_evns(beg_msk)];
            cCw_end = [cCw_end; block_evns(end_msk)];
            cCw_beg_idcs = [cCw_beg_idcs; block_idcs(beg_msk)];
            cCw_end_idcs = [cCw_end_idcs; block_idcs(end_msk)];
            
            [beg_msk,end_msk] = split_stroop_evns(block_evns, color_idx, 'I', ii);
            cIw_beg = [cIw_beg; block_evns(beg_msk)];
            cIw_end = [cIw_end; block_evns(end_msk)];
            cIw_beg_idcs = [cIw_beg_idcs; block_idcs(beg_msk)];
            cIw_end_idcs = [cIw_end_idcs; block_idcs(end_msk)];
            
            [beg_msk,end_msk] = split_stroop_evns(block_evns, space_idx, 'C', ii);
            cCs_beg = [cCs_beg; block_evns(beg_msk)];
            cCs_end = [cCs_end; block_evns(end_msk)];
            cCs_beg_idcs = [cCs_beg_idcs; block_idcs(beg_msk)];
            cCs_end_idcs = [cCs_end_idcs; block_idcs(end_msk)];
            
            [beg_msk,end_msk] = split_stroop_evns(block_evns, space_idx, 'I', ii);
            cIs_beg = [cIs_beg; block_evns(beg_msk)];
            cIs_end = [cIs_end; block_evns(end_msk)];
            cIs_beg_idcs = [cIs_beg_idcs; block_idcs(beg_msk)];
            cIs_end_idcs = [cIs_end_idcs; block_idcs(end_msk)];
          
        else
            [beg_msk,end_msk] = split_stroop_evns(block_evns, color_idx, 'C', ii);
            sCw_beg = [sCw_beg; block_evns(beg_msk)];
            sCw_end = [sCw_end; block_evns(end_msk)];
            sCw_beg_idcs = [sCw_beg_idcs; block_idcs(beg_msk)];
            sCw_end_idcs = [sCw_end_idcs; block_idcs(end_msk)];
            
            [beg_msk,end_msk] = split_stroop_evns(block_evns, color_idx, 'I', ii);
            sIw_beg = [sIw_beg; block_evns(beg_msk)];
            sIw_end = [sIw_end; block_evns(end_msk)];
            sIw_beg_idcs = [sIw_beg_idcs; block_idcs(beg_msk)];
            sIw_end_idcs = [sIw_end_idcs; block_idcs(end_msk)];
            
            [beg_msk,end_msk] = split_stroop_evns(block_evns, space_idx, 'C', ii);
            sCs_beg = [sCs_beg; block_evns(beg_msk)];
            sCs_end = [sCs_end; block_evns(end_msk)];
            sCs_beg_idcs = [sCs_beg_idcs; block_idcs(beg_msk)];
            sCs_end_idcs = [sCs_end_idcs; block_idcs(end_msk)];
            
            [beg_msk,end_msk] = split_stroop_evns(block_evns, space_idx, 'I', ii);
            sIs_beg = [sIs_beg; block_evns(beg_msk)];
            sIs_end = [sIs_end; block_evns(end_msk)];
            sIs_beg_idcs = [sIs_beg_idcs; block_idcs(beg_msk)];
            sIs_end_idcs = [sIs_end_idcs; block_idcs(end_msk)];
        end
    end     

end

ref = EEG.info.ref;

%% FBA

while true
    
    study = prompt('study');
    if strcmp(study, 'Q')
        break
    end   
    if isfield(EEG.info, 'study')
        EEG.info.study = [EEG.info.study {study}];
    else
        EEG.info.study = {study};
    end
    
    lock = prompt('lock type');
    if isfield(EEG.info, 'lock')
        EEG.info.lock = [EEG.info.lock {lock}];
    else
        EEG.info.lock = {lock};
    end

    %% Frequency band analysis across ALL good events
    
    % Create directories for FBA over ALL good events
    lock_pth = [pth 'analysis/' task '/' ref '/' lock '/'];
    ALL_pth = [lock_pth 'ALL/'];

    if ~exist([ALL_pth 'Channel events/' study], 'dir')
        mkdir([ALL_pth 'Channel events/' study]);
        mkdir([ALL_pth 'plots/' study ' events']);
        mkdir([ALL_pth 'plots/' study ' fba']);
        mkdir([ALL_pth 'TvD/']);
        mkdir([ALL_pth 'figs/' study ' fba']);
    end

    % event data gathering/filtering
    d = dir([ALL_pth 'Channel events/' study]);
    if sum([d.bytes]) > 0
        ce = user_yn('prep ALL again?', study);
    else
        ce = 1;
    end
    
    if ce  
        prompt('running ALL prep');
        event_prep(EEG, cln_evns, cln_evn_typ, cln_resp, [ALL_pth 'Channel events/' study '/'], 'ALL')
    end

    % frequency band analysis
    ses_TvD = sprintf('%sTvD/%s_TvD.mat', ALL_pth, study);
    d = dir(ses_TvD);
    if sum(cellfun(@(x) contains(x, 'mat'), {d.name}))
        hg = user_yn('fba ALL again?', study, SUBID);
    else
        hg = 1;
    end
    
    if hg 
        prompt('running sigchan')
        if strcmp(lock, 'Stimulus Locked')
            sigALL_shadow_s = sig_freq_band(EEG, cln_resp, ALL_pth, 'ALL');
        else
            sigALL_shadow_r = sig_freq_band(EEG, cln_resp, ALL_pth, 'ALL');
        end
    end



    %% Grouping of Frequency Band Analysis by Category

    % Load in TvD
    load(ses_TvD)
    if isempty(TvD)
        prompt('no results', study, lock)
        continue
    end

    disp('  ')
    disp('Focused FBA:')

    % find significant channels, make stucture that only contains sig dat
    chansSIG = string(TvD(:,2));
    chansALL = string(glab_r)';
    gdat_SIG = gdat_r(ismember(chansALL, chansSIG), :);
    EEG_sig = make_EEG(gdat_SIG, TvD(:,2), fs, cln_evns, cln_evn_typ, id, -1, [SUBID '_' task], task, study, ref, lock);

    % Display event categorys to sort by
    prompt('focus evns', task, focus_typ, keyset)

    k = 1;
    % Group by event
    while k <= length(keyset)

        if strcmp(task, 'Naming')
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
        end

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



if user_yn('ret iep?')
    run('iEEG_processor.m')
end















