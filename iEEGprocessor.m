%%
%   A user friendly command line interface program for loading iEEG data
%   and preparing data for further analysis.
%   User may
%       - Load iEEG data that may be stored in a variety of formats
%       - Annotate data by patient, patient task, reference type, etc.
%       - Trim large amounts of unnecessary data for faster anaylsis
%       - Find the indicies of Stimuls Onset events from subject task
%       - Remove superfluous electrode channels data
%       - Remove noisy or damaged channels from data
%       - Reject Stimulus events based on known errors or noisy data
%       - Notch filter line noise from data
%       - Save all data, progress and annotations
%
%
%   VARIABLE GUIDE:
%
%       PATH VARIABLES:
%
%           pth - path to the subject directory (./Subjs/"SUBID"/)
%           df_dir - path to the ./Subjs/"SUBID"/Data Files directory
%   
%  
%       SUBJECT/TASK VARIABLES:
%
%           SUBID - subject ID (i.e. SD16)
%           task - task code name (i.e Naming)
%
%        
%       OUTPUT FILES           
%           
%           gdat_r - all good electrode matrix (Channel x Time), in bipolar
%                    unipolar format
%           glab_r - channel labels corresponding to good channel data
%           EEG - Contains all necessary information about the iEEG
%                 recording in structure format including gdat_r and glab_r
%
%
%       OUTSIDE SCRIPTS USED
%
%           eegplot - eeglab script for viewing data
%

warning('off')
close all
addpath('L:/iEEG_San_Diego/Functions/');
subjs_dir = 'L:/iEEG_San_Diego/Subjs/';
%subjs_pth = '/Users/connor-home/Desktop/LBDL/';
cd(subjs_dir)

d = dir;
pts = {d.name};
pts = pts(cellfun(@(x) contains(x,'SD'), pts));

SUBID = prompt('define subject', subjs_dir, pts);

subj_num = str2double(SUBID(regexp(SUBID,'\d')));

pth = [subjs_dir SUBID '/'];

% assigns data directory
df_dir = [pth 'Data Files/'];                  
   

%% Load Rec/Hdr files & Patient Info table

cd(df_dir);

rec_files = dir('*REC.mat');
hdr_files = dir('*HDR.mat');
eeg_files = dir('*dat.mat');
edf_files = dir('*.EDF');
full_files = [{rec_files.name} {eeg_files.name}];
rec_files = char({rec_files.name});
hdr_files = char({hdr_files.name});
eeg_files = char({eeg_files.name});
full_files = char(full_files);

% Files found in df_dir are written to lists (rec_files, etc.). If it
% didnt find any files, warning is thrown and user has option to place
% files in df_dir
if (isempty(rec_files) || size(hdr_files,1) ~= size(rec_files,1)) && isempty(eeg_files)
    while true
        [ufile,upath] = uigetfile;
        if isequal(ufile, 0)
            if user_yn('exit prog? 1')
                return
            end
        elseif contains(ufile, 'REC.mat')
            load([upath erase(ufile,'REC.mat') 'HDR.mat']);
            load([upath ufile]);
            eeg = false;
            break
        elseif contains(ufile, '.EDF') || contains(ufile, '.edf')
            [Hdr, Rec] = edfread([upath ufile]);
            save([df_dir erase(ufile, ".EDF") 'REC.mat'], 'Rec', '-v7.3');
            save([df_dir erase(ufile, ".EDF") 'HDR.mat'], 'Hdr');    
            break
        end
    end
else
    file_idx = prompt('choose file', full_files);
end


% Option to load in file. Saves user time if file already exists in ws
if user_yn('load file?')
    if contains(full_files(file_idx,:),'REC')
        load([strtrim(erase(full_files(file_idx,:),'REC.mat')) 'HDR.mat']);
        load(full_files(file_idx,:));
        eeg = false;
    elseif contains(full_files(file_idx,:),'dat')
        load(full_files(file_idx,:));
        eeg = true;
    end
end



%% Prep Data

if eeg  % For data in EEG format
    % Set data
    gdat = EEG.data;
    glab = {EEG.chanlocs.labels};
    
    % Confirms with user whether or not the data has already been
    % re-referenced. Necessary to load in the correct XL file.
    prompt('disp channel labels', glab);
    if user_yn('bipolar referenced?')
        xl_name = sprintf('%s_info_bipolar.xlsx', SUBID);
        bp = 0; 
        ref = 'bipolar';
    else
        bp = user_yn('rereference?');
        if bp
            xl_name = sprintf('%s_info_bipolar.xlsx', SUBID);
            ref = 'bipolar';
        else
            xl_name = sprintf('%s_info.xlsx', SUBID);
            ref = 'unipolar';
        end
    end
    
    % Set task
    task = strsplit(EEG.setname, '_');
    task = char(task(end));
   
    % Set sampling rate
    fs = EEG.srate;
    
    % Stimulus events
    stim_evns = [EEG.event.latency]';
    
    % Reads in the appropriate info from pt-info XL file
    patinf = readtable(xl_name, 'Sheet', task);
   
    % Wrap these to string to make matlab happy when appending to these
    patinf.Good_Channels = string(patinf.Good_Channels);
    patinf.Excess_Channels = string(patinf.Excess_Channels);
    patinf.Channel_Reject = string(patinf.Channel_Reject);
    patinf.Event_Reject = string(patinf.Event_Reject);
    patinf.Event_Types = string(patinf.Event_Types);
        
else  % For data in Hdr/Rec format
    gdat = Rec;
    glab = Hdr.label;
    
    % Enter sampling rate
    fs = prompt('fs');
    
    % Define the current task
    task = prompt('task', 'StroopNamingVerbGen');
    
    
    % Prompt to re-reference or not
    bp = user_yn('rereference?');
    if bp
        xl_name = sprintf('%s_info_bipolar.xlsx', SUBID);
        ref = 'bipolar';
    else
        xl_name = sprintf('%s_info.xlsx', SUBID);
        ref = 'unipolar';
    end


    [gdat, stim_evns, ~, trim_save] = event_locater(gdat, glab, Rec, 0);
    
    % Load pt. excel file & clean
    patinf = readtable(xl_name, 'Sheet', task);
    patinf(cellfun(@(x) isempty(x), patinf.Event_Types),:) = [];
    patinf.Data_Start = nan(size(patinf,1),1);
    patinf.Data_Stop = nan(size(patinf,1),1);
    patinf.Data_Start(1) = trim_save(1);
    patinf.Data_Stop(1) = trim_save(2);
    patinf.Good_Channels = string(nan(size(patinf,1),1));
    patinf.Excess_Channels = string(nan(size(patinf,1),1));
    patinf.Channel_Reject = string(nan(size(patinf,1),1));
    patinf.Event_Reject = string(patinf.Event_Reject);
    patinf.Event_Types = string(patinf.Event_Types);
    patinf.Stimulus_Event = [];
    patinf.Stimulus_Event(1:length(stim_evns)) = stim_evns;

end


%% Bipolar Reference & Remove excess channels manually
if bp
    disp('Working...') 
    [gdat_r, glab_r] = bipolar_referencing(gdat, glab);

    removed = '';
    while true
        chans = prompt('remove channels', glab_r);
        if ~sum(chans == 0)
            [gdat_r, glab_r, removed] = remove_channels(gdat_r, glab_r, chans, removed);
        else
            break
        end
    end

    removed = strsplit(removed, ',');
    nadd = size(patinf,1) - length(removed);
    if nadd > 0
        for ii = 1:nadd
            removed = [removed string(nan)];
        end
        patinf.Excess_Channels = removed';
    elseif nadd < 0
        for ii = 1:length(removed)
            if ii > size(patinf,1)
                patinf.Data_Start(ii) = nan;
                patinf.Data_Stop(ii) = nan;
                patinf.Good_Channels(ii) = string(nan);
                patinf.Channel_Reject(ii) = string(nan);
                patinf.Event_Reject_No(ii) = nan;
                patinf.Event_Reject(ii) = string(nan);
                patinf.Event_Types(ii) = string(nan);
                patinf.Response_Time(ii) = nan;
                patinf.Stimulus_Event(ii) = nan;
            end
           patinf.Excess_Channels(ii) = removed{ii};
        end
    else
        patinf.Excess_Channels = removed';
    end

else
    gdat_r = gdat;
    glab_r = glab;
end


evn_typ = cellstr(patinf.Event_Types(~ismissing(patinf.Event_Types)));
res_tm = patinf.Response_time;


%% Event Rejection & Channel Rejection
bad_elecs = [];
chan_rej = '';
alph_chk = {};
k = 0;
if sum(~ismissing(patinf.Event_Reject)) == 0
    patinf.Event_Reject = num2cell(patinf.Event_Reject);
    rej_all_no = [];
    rej_all = {};
    num_evn_rej = 0;
else
    num_evn_rej = find(isnan(patinf.Event_Reject_No),1)-1;
    rej_all_no = patinf.Event_Reject_No(1:num_evn_rej);
    rej_all = patinf.Event_Reject(1:num_evn_rej);
end

if exist('EEG', 'var') && ~isempty(EEG.notch) 
    flt = [EEG.notch -1];
else
    flt = -1;
end

EEG = make_EEG(gdat_r, glab_r, fs, stim_evns, evn_typ, -1, flt, [SUBID '_' task], task, '', ref, '');

% channel/event selection & eegplot
while true
    
    prompt('rejected event/channel', evn_typ, stim_evns, rej_all_no, rej_all, chan_rej)

    if k == 0 || ~all(cellfun(@(x) isempty(x), alph_chk))
        pop_eegplot(EEG);
    end

    ecrej = prompt('channels/events to reject');
    ecrej = strsplit(ecrej);
    alph_chk = cellfun(@(x) x(isstrprop(x,'alpha')),ecrej,'uni',0);

    % Reject Events
    rej_idx = cellfun(@(x) str2double(x), ecrej(2:end))';
    if  str2double(ecrej{1}) == 0
        break
        
    elseif strcmpi(ecrej{1}, 'event') 
        if strcmpi(ecrej{2}, 'contains')
            rej_idx = find(cellfun(@(x) contains(x, ecrej{3}), evn_typ) == 1);
        else
            for ii = 2:length(ecrej)
                rej_idx = find(cellfun(@(x) strcmp(x, ecrej{ii}), evn_typ) == 1);
            end
        end

        for ii = 1:length(rej_idx)
            if sum(rej_all_no == rej_idx(ii))
                prompt('skipping event', rej_idx(ii), evn_typ{rej_idx(ii)});
                disp(msg)
                rej_idx(ii) = -1;
            end
        end
        rej_idx(rej_idx == -1) = [];
        evn_rej = evn_typ(rej_idx);

        rej_all_no = [rej_all_no; rej_idx];
        rej_all = [rej_all; evn_rej];


    % Reject Channels
    elseif strcmpi(ecrej{1}, 'channel')
        cnum_rej = [];
        for ii = 2:length(ecrej)
            cnum_rej = [cnum_rej find(cellfun(@(x) strcmp(x,ecrej{ii}), glab_r))];
        end
        [gdat_r, glab_r, chan_rej] = remove_channels(gdat_r, glab_r, cnum_rej, chan_rej);
        
        
    else
        disp('  ')
        disp('Try again');
        continue
    end
    k = k + 1;
    EEG = make_EEG(gdat_r, glab_r, fs, stim_evns, evn_typ, -1, flt, [SUBID '_' task], task, '', ref, '');
end




%% Save all edits to Patient table info
nadd = size(patinf,1) - length(rej_all);
if nadd > 0
    for ii = 1:nadd
        rej_all_no = [rej_all_no; nan];
        rej_all = [rej_all; string(nan)];
    end
    patinf.Event_Reject_No = rej_all_no;
    patinf.Event_Reject = rej_all;
elseif nadd < 0
    for ii = 1:length(rej_all)
        if ii > size(patinf,1)
            patinf.Data_Start(ii) = nan;
            patinf.Data_Stop(ii) = nan;
            patinf.Good_Channels(ii) = string(nan);
            patinf.Excess_Channels(ii) = string(nan);
            patinf.Channel_Reject(ii) = string(nan);
            patinf.Event_Types(ii) = string(nan);
            patinf.Response_Time(ii) = nan;
            patinf.Stimulus_Event(ii) = nan;
        end
        patinf.Event_Reject_No(ii) = rej_all_no{ii};
        patinf.Event_Reject(ii) = rej_all{ii};
    end
else
    patinf.Event_Reject_No = rej_all_no;
    patinf.Event_Reject = rej_all;
end

chan_rej = strsplit(chan_rej, ',');
nadd = size(patinf,1) - length(chan_rej);
if nadd > 0
    for ii = 1:nadd
        chan_rej = [chan_rej string(nan)];
    end
    patinf.Channel_Reject = chan_rej';
elseif nadd < 0
    for ii = 1:length(chan_rej)
        if ii > size(patinf,1)
            patinf.Data_Start(ii) = nan;
            patinf.Data_Stop(ii) = nan;
            patinf.Good_Channels(ii) = string(nan);
            patinf.Excess_Channels(ii) = string(nan);
            patinf.Event_Reject_No(ii) = nan;
            patinf.Event_Reject(ii) = string(nan);
            patinf.Event_Types(ii) = string(nan);
            patinf.Response_Time(ii) = nan;
            patinf.Stimulus_Event(ii) = nan;
        end
        patinf.Channel_Reject(ii) = chan_rej{ii};
    end
else
    patinf.Channel_Reject = chan_rej';
end
       
patinf.Good_Channels = string(patinf.Good_Channels);
glab_r_table = glab_r;
nadd = size(patinf,1) - length(glab_r_table);
if nadd > 0
    for ii = 1:nadd
        glab_r_table = [glab_r_table string(nan)];
    end
    patinf.Good_Channels = glab_r_table';
elseif nadd < 0
    for ii = 1:length(glab_r_table)
        if ii > size(patinf,1)
            patinf.Data_Start(ii) = nan;
            patinf.Data_Stop(ii) = nan;
            patinf.Excess_Channels(ii) = string(nan);
            patinf.Channel_Reject(ii) = string(nan);
            patinf.Event_Reject_No(ii) = nan;
            patinf.Event_Reject(ii) = string(nan);
            patinf.Event_Types(ii) = string(nan);
            patinf.Response_Time(ii) = nan;
            patinf.Stimulus_Event(ii) = nan;
        end
        patinf.Good_Channels(ii) = glab_r_table{ii};
    end
else
    patinf.Good_Channels = glab_r_table';
end




%% FILTER OUT 60 Hz LINE NOISE (If needed)
if ~isempty(EEG.notch)
    flt = prompt('notch filt freq', EEG.notch(length(EEG.notch)));
    flt = [EEG.notch flt];
else
    flt = prompt('notch filt freq');
end


if flt(end) > -1
    p = parpool;
    gdat_r = remove_line_noise_par(gdat_r', flt(end), fs, 1)'; %funciton written by Leon in order to notch filter the data.
    delete(p)
end

if size(gdat_r, 1) > size(gdat_r, 2)
    gdat_r = gdat_r';
end
EEG = make_EEG(gdat_r, glab_r, fs, stim_evns, evn_typ, -1, flt, [SUBID '_' task], task, '', ref, '');




%% Save pre-processed data, Save Excel file

system('taskkill /F /IM EXCEL.EXE');
xlswrite([df_dir xl_name],nan(100,100), task)
writetable(patinf, [df_dir xl_name], 'Sheet', task)

if ~eeg || flt(end) ~= -1
    if user_yn('save EEG?')
        save([df_dir SUBID '_' task '_' ref '_dat.mat'], 'EEG')
    end
end

close all

if user_yn('go to fba?')
    run('frequency_band_analysis.m')
else
    disp('Good-bye!')
end
























