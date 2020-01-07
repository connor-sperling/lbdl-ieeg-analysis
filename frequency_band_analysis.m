if ispc
    addpath('L:/iEEG_San_Diego/Functions/');
    subjs_dir = 'L:/iEEG_San_Diego/Subjs/';
elseif isunix
    addpath('~/Desktop/Functions/');
    subjs_dir = '~/Desktop/Subjs/';
end
cd(subjs_dir)

subjs = dir('SD*');
subjs = {subjs.name};

an_subjs = prompt('pick subjs', subjs);
an_subjs = strsplit(an_subjs);
if strcmpi(an_subjs{1}, 'all')
    an_subjs = subjs;
end

all_tasks = {'Naming', 'Stroop', 'Verb Gen'};
tasks = prompt('pick task', all_tasks);
tasks = strsplit(tasks);
if strcmpi(tasks{1}, 'all')
    tasks = all_tasks;
end

all_studies = {'HG', 'LFP'};
studies = prompt('pick study');
studies = strsplit(studies);
if strcmpi(studies{1}, 'both')
    studies = all_studies;
end

ref = 'bipolar';

for subjcell = an_subjs
    subj = char(subjcell);
    an_dir = sprintf('%s%s/analysis/', subjs_dir, subj);
    df_dir = sprintf('%s%s/Data Files/', subjs_dir, subj); 
    cd(df_dir);
    for taskcell = tasks
        task = char(taskcell);
        eeg_file = sprintf('%s_%s_%s_dat.mat', subj, task, ref);
        raw_txt = sprintf('%s_%s_stims.txt', subj, task);
        data = dir(df_dir);
        data = {data.name};
        if ~ismember(eeg_file, data)
            continue
        else
            load(eeg_file, 'EEG')
            
            rawfid = fopen(raw_txt, 'r');
            raw_cell = textscan(rawfid, '%f %s');
            fclose(rawfid);
            raw_evn = raw_cell{2};
            
            rtm = [EEG.event.resp]';
            evn = {EEG.event.type}';
            evn_idc = [EEG.event.latency]';
            
            prompt('percent chan/evn', size(EEG.data,1), length(evn), length(raw_evn))
        end
        for studcell = studies
            study = char(studcell);
            for lockcell = {'Stimulus Locked', 'Response Locked'}
                lock = char(lockcell);
   
                if isfield(EEG, 'study')
                    EEG.study = [EEG.study {study}];
                else
                    EEG.study = {study};
                end
                
                if isfield(EEG, 'lock')
                    EEG.lock = [EEG.lock {lock}];
                else
                    EEG.lock = {lock};
                end

                % Create directories for FBA over ALL good events
                lock_pth = [an_dir task '/' ref '/' lock '/'];
                ALL_pth = [lock_pth 'ALL/'];

                if ~exist([ALL_pth 'Channel events/' study], 'dir')
                    mkdir([ALL_pth 'Channel events/' study]);
                    mkdir([ALL_pth 'plots/' study]);
                    mkdir([ALL_pth 'TvD/']);
                end

            % Frequency band analysis across ALL good events

                ep = true; % Manually change to FALSE if package code change does not affect event_prep
                if ep  
                    prompt('running ALL prep');
                    event_prep(EEG, evn_idc, rtm, [ALL_pth 'Channel events/' study '/'], 'ALL')
                end
                
                sfb = true; % Manually change to FALSE if package code change does not affect sig_freq_band
                if sfb 
                    prompt('running sigchan')
                    sig_freq_band(EEG, rtm, ALL_pth, 'ALL');
                end

                ses_TvD = sprintf('%sTvD/%s_TvD.mat', ALL_pth, study);
                load(ses_TvD)

                % find significant channels, make stucture that only contains sig dat
                sig_chans = string(TvD(:,2));
                all_chans = string({EEG.chanlocs.labels}');
                dat = [EEG.data];
                dat(~ismember(chansALLstr, sig_chans), :) = [];
                EEG = make_EEG(dat, TvD(:,2), EEG.srate, evn_idc, evn, rtm, -1, [subj '_' task], ref);
        
                
                if isfield(EEG, 'study')
                    EEG.study = [EEG.study {study}];
                else
                    EEG.study = {study};
                end
                
                if isfield(EEG, 'lock')
                    EEG.lock = [EEG.lock {lock}];
                else
                    EEG.lock = {lock};
                end
                
                disp('  ')
                disp('Focused FBA:')


            % Grouping of Frequency Band Analysis by Category

                tsk = task;
                tsk(regexp(tsk,'\d*')) = [];
                switch tsk
                    case 'Naming'
                        prompt('naming fba')
                        naming_analysis(EEG, evn, evn_idc, rtm, lock_pth)

                    case 'Stroop'
                        prompt('stroop fba')
                        stroop_analysis(EEG, evn, evn_idc, rtm, lock_pth)
                end
            end
        end
    end
end















