

%% Get all good events
%This block is redundant but better than what I had that makes
%analysis_evns/evn_typ
rej_evn_typ = rej_all(~ismissing(rej_all));
all_evn_typ = string(evn_typ);
gd_msk = ~ismember(all_evn_typ, rej_evn_typ);

cln_evn_typ = cellstr(all_evn_typ(gd_msk));
cln_resp = res_tm(gd_msk);
cln_evns = stim_evns(gd_msk);

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

    ref = EEG.info.ref;
    
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

    
    %% Frequency band analysis across ALL good events

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
            sig_freq_band(EEG, cln_resp, ALL_pth, 'ALL');
    end
    
    % Load in TvD
    load(ses_TvD)
    if isempty(TvD)
        prompt('no results', study, lock)
        continue
    end

    % find significant channels, make stucture that only contains sig dat
    chansSIG = string(TvD(:,2));
    chansALL = string(glab_r)';
    gdat_SIG = gdat_r(ismember(chansALL, chansSIG), :);
    EEG_sig = make_EEG(gdat_SIG, TvD(:,2), fs, cln_evns, cln_evn_typ, -1, [SUBID '_' task], task, study, ref, lock);

    disp('  ')
    disp('Focused FBA:')
    
    
    %% Grouping of Frequency Band Analysis by Category
    
    % Display event categorys to sort by
    

    switch task
        case 'Naming'
            prompt('naming fba')
            naming_analysis(EEG_sig, cln_evn_typ, cln_evns, cln_resp, lock_pth)
            
        case 'Stroop'
            prompt('stroop fba')
            stroop_analysis(EEG_sig, cln_evn_typ, cln_evns, cln_resp, lock_pth)
    end
    
end

if user_yn('ret iep?')
    run('iEEG_processor.m')
end















