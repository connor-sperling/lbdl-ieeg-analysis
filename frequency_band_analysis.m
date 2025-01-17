
clc
clear
close all

 
if ispc
    
    addpath('L:/iEEG_San_Diego/Functions');
    subjs_dir = 'L:/iEEG_San_Diego/Subjs';
    
elseif isunix
    
    addpath('~/Desktop/iEEG/Functions');
    subjs_dir = '~/Desktop/iEEG/Subjs';
    
end

dt = strsplit(datestr(datetime));
dt = dt{1};

txtsc = 0;

cd(subjs_dir)

rsearch = prompt('research study');

subjs = dir('SD*');
subjs = {subjs.name};

an_subjs = prompt('pick subjs', subjs);
an_subjs = strsplit(an_subjs);

if strcmpi(an_subjs{1}, 'all')
    
    an_subjs = subjs;
    
elseif strcmpi(an_subjs{1}, 'txt')
    
    txtsc = 1;
    
    if strcmpi(an_subjs{2}, 'all')
    
        an_subjs = subjs;
        
    else
        
        an_subjs(1) = [];
    
    end  
    
end


all_tasks = {'Naming', 'Stroop', 'VerbGen'};

tasks = prompt('pick task', all_tasks);
tasks = strsplit(tasks);

if strcmpi(tasks{1}, 'all')
    
    tasks = all_tasks;
    
end

all_bands = {'HFB', 'LFP'};

bands = prompt('pick band');
bands = strsplit(bands);

if strcmpi(bands{1}, 'both')
    
    bands = all_bands;
    
end


winlen = input('\nSegment length?\n--> ');

ref = 'bipolar';

nbranches = 2*length(an_subjs)*length(tasks)*length(bands);
n = 1;

for subjcell = an_subjs
    
    subj = char(subjcell);
    
    an_dir = sprintf('%s/%s/analysis', subjs_dir, subj);
    df_dir = sprintf('%s/%s/Data Files', subjs_dir, subj); 
    cd(df_dir);
    
    for taskcell = tasks
        
        task = char(taskcell);
        
        study = sprintf('%s_%s', task, rsearch);
        
        eeg_file = sprintf('%s_%s_%s_%s_dat.mat', subj, task, ref, rsearch);
        
        data = dir(df_dir);
        data = {data.name};
        
        if ~ismember(eeg_file, data)
            
            continue
            
        else
            
            load(eeg_file, 'EEGr')
            
            raw_evn = {EEGr.event.type}';
            
            rtm = [EEGr.analysis.resp]';
            evn = {EEGr.analysis.type}';
            evn_idc = [EEGr.analysis.latency]';
            
        end
        
        for studcell = bands
            
            band = char(studcell);
            
            for lockcell = {'Stimulus Locked', 'Response Locked'}
                
                loadbar(n, nbranches)

                lock = char(lockcell);


                if isfield(EEGr, 'band')

                    EEGr.band = [EEGr.band {band}];
                else

                    EEGr.band = {band};

                end

                if isfield(EEGr, 'lock')

                    EEGr.lock = [EEGr.lock {lock}];

                else

                    EEGr.lock = {lock};

                end

                % Create directories for FBA over ALL good events
                lock_pth = sprintf('%s/%s_%s/%s/%s', an_dir, task, rsearch, ref, lock);
                all_pth = sprintf('%s/ALL', lock_pth);

                chan_stud_pth = sprintf('%s/Channel events/%s', all_pth, band);
                plot_stud_pth = sprintf('%s/plots/%s', all_pth, band);
                tvd_pth = sprintf('%s/TvD', all_pth);
                
                if ~txtsc

                    if ~exist(chan_stud_pth, 'dir')

                        mkdir(chan_stud_pth);
                        mkdir(plot_stud_pth);
                        mkdir(tvd_pth);

                    else

                        chan_fp = dir(fullfile(chan_stud_pth, '*.mat'));
                        del_chans = {chan_fp.name};

                        for c = 1:length(del_chans)

                            delete(sprintf('%s/%s', chan_stud_pth, del_chans{c}));

                        end


                        plot_fp = dir(fullfile(plot_stud_pth, '*.png'));
                        del_plots = {plot_fp.name};

                        for p = 1:length(del_plots)

                            delete(sprintf('%s/%s', plot_stud_pth, del_plots{p}));

                        end

                    end
                    
                    prompt('processing info', subj, task, band, lock, size(EEGr.data,1), length(evn), length(raw_evn))

                % Frequency band analysis across ALL good events

                    ep = true; % Manually change to FALSE if package code change does not affect event_prep

                    if ep  

                        event_prep(EEGr, evn_idc, rtm, chan_stud_pth, 'ALL')

                    end

                    sfb = true; % Manually change to FALSE if package code change does not affect sig_freq_band

                    if sfb 

                        sig_freq_band(EEGr, rtm, all_pth, 'ALL');

                    end
                end
                
                ses_TvD = sprintf('%s/%s_TvD.mat', tvd_pth, band);
                if exist(ses_TvD, 'file')
                    load(ses_TvD)
                else
                    continue
                end
                

                % find significant channels, make stucture that only contains sig dat
                sig_chans = string(TvD(:,2));
                all_chans = string({EEGr.chanlocs.labels}');
                ses_dat = [EEGr.data];
                ses_dat(~ismember(all_chans, sig_chans), :) = [];
                
                ses_EEG = make_EEG(EEGr, 'dat', ses_dat, 'labels', TvD(:,2));
        
                
                if isfield(EEGr, 'band')
                    
                    ses_EEG.band = [ses_EEG.band {band}];
                    
                else
                    
                    ses_EEG.band = {band};
                    
                end
                
                if isfield(ses_EEG, 'lock')
                    
                    ses_EEG.lock = [ses_EEG.lock {lock}];
                    
                else
                    
                    ses_EEG.lock = {lock};
                    
                end


            % Grouping of Frequency Band Analysis by Category

                tsk = task;
                tsk(regexp(tsk,'\d*')) = [];
                if  ~txtsc
                    switch tsk

                        case 'Naming'

                            prompt('naming fba', subj)
%                             naming_analysis(ses_EEG, evn, evn_idc, rtm, lock_pth)
                            events_by_density(ses_EEG, lock_pth, study) 

                        case 'Stroop'

                            prompt('stroop fba')
                            stroop_analysis(ses_EEG, evn, evn_idc, rtm, lock_pth)

                    end
                end
                
%                 txt4r(ses_EEG, TvD, winlen, lock_pth, subjs_dir)
                
                n = n + 1;
                
            end
            
        end
        
    end
    
end

% diary off














