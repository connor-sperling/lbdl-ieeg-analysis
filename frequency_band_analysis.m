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
if strcmp(an_subjs{1}, 'all')
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
if strcmp(studies{1}, 'both')
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
        eeg_file = sprintf('%s_%s_dat.mat', subj, task);
        xl_name = sprintf('%s_info_%s.xlsx', subj, ref);
        data = dir(df_dir);
        data = {data.name};
        if ~ismember(eeg_file, data)
            continue
        else
            load([df_dir eeg_file], 'EEG')
            [sinf_num,sinf_str,raw] = xlsread(xl_name, task);
            
            evn_typ = sinf_str(:,5);
            evn_typ(cellfun(@(x) isempty(x), evn_typ)) = [];
            evn_typ(1) = [];

            an_evn_idc = raw(:,7);
            an_evn_idc(1) = [];
            an_evn_idc = [an_evn_idc{:}]';
            an_evn_idc = an_evn_idc(~isnan(an_evn_idc));

            an_resp_tm = raw(:,8);
            an_resp_tm(1) = [];
            an_resp_tm = [an_resp_tm{:}]';
            an_resp_tm = an_resp_tm(~isnan(an_resp_tm));

            an_evn_typ = sinf_str(:,9);
            an_evn_typ(cellfun(@(x) isempty(x), an_evn_typ)) = [];
            an_evn_typ(1) = [];
            
            prompt('percent chan/evn', size(EEG.data,1), length(an_evn_idc), length(evn_typ))
        end
        for studcell = studies
            study = char(studcell);
            for lock = {'Stimulus Locked', 'Response Locked'}
            %% Choose Analysis Type    
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

                % Create directories for FBA over ALL good events
                lock_pth = [pth 'analysis/' task '/' ref '/' lock '/'];
                ALL_pth = [lock_pth 'ALL/'];

                if ~exist([ALL_pth 'Channel events/' study], 'dir')
                    mkdir([ALL_pth 'Channel events/' study]);
                    mkdir([ALL_pth 'Plots/' study]);
                    mkdir([ALL_pth 'TvD/']);
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
                    event_prep(EEG, an_evn_idc, an_evn_typ, an_resp_tm, [ALL_pth 'Channel events/' study '/'], 'ALL')
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
                    sig_freq_band(EEG, an_resp_tm, ALL_pth, 'ALL');
                end

            %% Prepare for Focused Analysis
                load(ses_TvD)
            %     if isempty(TvD)
            %         prompt('no results', study, lock)
            %         continue
            %     end

                % find significant channels, make stucture that only contains sig dat
                chansSIG = string(TvD(:,2));
                chansALL = string(glab_r)';
                gdat_SIG = gdat_r(ismember(chansALL, chansSIG), :);
                EEG_sig = make_EEG(gdat_SIG, TvD(:,2), fs, an_evn_idc, cln_evn_typ, -1, [SUBID '_' task], task, study, ref, lock);

                disp('  ')
                disp('Focused FBA:')


            %% Grouping of Frequency Band Analysis by Category

                tsk = task;
                tsk(regexp(tsk,'\d*')) = [];
                switch tsk
                    case 'Naming'
                        prompt('naming fba')
                        naming_analysis(EEG_sig, an_evn_typ, an_evn_idc, an_resp_tm, lock_pth)

                    case 'Stroop'
                        prompt('stroop fba')
                        stroop_analysis(EEG_sig, an_evn_typ, an_evn_idc, an_resp_tm, lock_pth)
                end
            end
        end
    end
end















