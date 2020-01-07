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
%       AUXILIARY SCRIPTS
%           
%           frequency_band_analysis
%           event_prep
%           sig_freq_band
%           naming_analysis
%           stroop_analysis 
% 
%           plot_naming
%           plot_stroop
%           subplot_all
%           shade_plot
%           rgb_grad 
% 
%           bipolar_referencing
%           event_locator
%           remove_channels
%           make_EEG
% 
%           loadbar
%           prompt
%           usr_yn
% 
%
%       OUTSIDE SCRIPTS USED
%
%           eegplot - eeglab script for viewing data
%           edfread

warning('off')
close all
clearvars -except Rec Hdr EEG

if ispc
    addpath('L:/iEEG_San_Diego/Functions/');
    subjs_dir = 'L:/iEEG_San_Diego/Subjs/';
elseif isunix
    addpath('~/Desktop/Functions/');
    subjs_dir = '~/Desktop/Subjs/';
end

cd(subjs_dir)

d = dir;
pts = {d.name};
pts = pts(cellfun(@(x) contains(x,'SD'), pts));

subj = prompt('define subject', subjs_dir, pts);

subj_num = str2double(subj(regexp(subj,'\d')));

pth = [subjs_dir subj '/'];

% assigns data directory
df_dir = [pth 'Data Files/'];                  
   

%% Load Rec/Hdr files & Patient Info table

cd(df_dir);

rec_files = dir('*REC.mat');
hdr_files = dir('*HDR.mat');
eeg_files = dir('*dat.mat');
edf_files = dir('*.EDF');
full_files = [{rec_files.name} {eeg_files.name} {edf_files.name}];
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
    elseif contains(full_files(file_idx,:),'edf') || contains(full_files(file_idx,:),'EDF')
        [Hdr, Rec] = edfread(full_files(file_idx,:));
        save([df_dir strtrim(erase(full_files(file_idx,:), ".EDF")) 'REC.mat'], 'Rec', '-v7.3');
        save([df_dir strtrim(erase(full_files(file_idx,:), ".EDF")) 'HDR.mat'], 'Hdr');
    elseif contains(full_files(file_idx,:),'dat')
        load(strtrim(full_files(file_idx,:)));
    end
end

if contains(full_files(file_idx,:),'REC') || contains(full_files(file_idx,:),'edf') || contains(full_files(file_idx,:),'EDF')
    eeg = false;
    clear EEG
elseif contains(full_files(file_idx,:),'dat')
    eeg = true;
end


%% Define parameters

if eeg  % For data in EEG format
    gdat = EEG.data;
    glab = {EEG.chanlocs.labels};
    
    % Confirms with user whether or not the data has already been
    % re-referenced. Necessary to load in the correct XL file.
    prompt('disp channel labels', glab);
    if user_yn('bipolar referenced?') 
        bp = 0;
        ref = 'bipolar';
    else
        bp = user_yn('rereference?');
        if bp
            ref = 'bipolar';
        else
            ref = 'unipolar';
        end
    end
    
    task = strsplit(EEG.setname, '_');
    task = char(task(end));
    fs = EEG.srate;
    
    rtm = [EEG.event.resp]';
    evn = {EEG.event.type}';
    evn_idc = [EEG.event.latency]';
        
else  % For data in Hdr/Rec format
    gdat = Rec;
    glab = Hdr.label;
    fs = prompt('fs');
    task = prompt('task name', 'StroopNamingVerbGenStroop1Stroop2');
    
    bp = user_yn('rereference?');
    if bp
        ref = 'bipolar';
    else
        ref = 'unipolar';
    end
    
    raw_txt = sprintf('%s_%s_stims.txt', subj, task);
    rawfid = fopen(raw_txt, 'r');
    raw_cell = textscan(rawfid, '%f %s');
    fclose(rawfid);

    rtm = raw_cell{1}; % full list of response times
    evn = raw_cell{2}; % full list of stimulus event names
    
    [gdat, evn_idc, ~, xrng, yrng] = event_locater(gdat, glab, Rec, 0);
    evnx = xrng;
    evny = yrng;

end

%% Read in supplementary data from Excel

% if exist('event_info.mat', 'file') && eeg
%     load event_info.mat pro_evn_inf
%     rtm = pro_evn_inf{1};
%     evn = pro_evn_inf{2};
%     evn_idc = pro_evn_inf{3};
% else
%     raw_txt = sprintf('%s_%s_stims.txt', subj, task);
%     rawfid = fopen(raw_txt, 'r');
%     raw_cell = textscan(rawfid, '%d %s');
%     fclose(rawfid);
% 
%     rtm = raw_cell{1}; % full list of response times
%     evn = raw_cell{2}; % full list of stimulus event names
% end



%% Bipolar Reference

if bp
    disp('Working...') 
    [gdat_r, glab_r] = bipolar_referencing(gdat, glab);
else
    gdat_r = gdat;
    glab_r = glab;
end



%% Remove excess channels

% temp
excess_chans = [];

removed = '';
while true
    chans = prompt('remove channels', glab_r);
    if ~sum(chans == 0)
        [gdat_r, glab_r, removed] = remove_channels(gdat_r, glab_r, chans, removed);
    else
        break
    end
end

good_chans = glab_r';
excess_chans = [excess_chans; removed];


%% Filter Line Noise

% NEED TO INSTALL PARALLEL COMPUTING TOOLBOX

% if ~exist('EEG', 'var')
%     EEG = make_EEG(gdat_r, glab_r, fs, evn_idc, evn, rtm, -1, [subj '_' task], ref);
% end
% 
% if ~isempty(EEG.notch)
%     numf = length(EEG.notch);
%     flt = prompt('notch filt freq', EEG.notch);
%     flt = [EEG.notch flt];
% else
%     numf = 0;
%     flt = prompt('notch filt freq');
% end
% 
% if flt(end) > -1
%     p = parpool;
%     for f = numf+1:length(flt)
%             gdat_r = remove_line_noise_par(gdat_r', flt(f), fs, 1)'; %funciton written by Leon in order to notch filter the data.
%     end
% 
%     delete(p)
%     EEG = make_EEG(gdat_r, glab_r, fs, evn_idc, evn, rtm, flt, [subj '_' task], ref);
% end
% 
% if size(gdat_r, 1) > size(gdat_r, 2)
%     gdat_r = gdat_r';
% end


%% Event Rejection & Channel Rejection
rej_typ = '';
rej_chans = {};
evn_rej = {};
% channel/event selection & eegplot
while true
    
    prompt('rejected event/channel', evn, evn_idc, evn_rej, rej_chans)

%     if ~strcmp(rej_typ, 'event')
%         pop_eegplot(EEG);
%     end

    ecrej = prompt('channels/events to reject');
    ecrej = strsplit(ecrej);
    rej_typ = ecrej{1};

    % Reject Events
    if  str2double(ecrej{1}) == 0
        break      
    elseif strcmpi(rej_typ, 'event') 
        if strcmpi(ecrej{2}, 'contains')
            rej_idx = find(cellfun(@(x) contains(x, ecrej{3}), evn) == 1);
        else
            for ii = 2:length(ecrej)
                rej_idx = find(cellfun(@(x) strcmp(x, ecrej{ii}), evn) == 1);
            end
        end

        for ii = 1:length(rej_idx)
            if sum(cellfun(@(x) strcmp(x, evn{rej_idx(ii)}), evn_rej)) > 0
                prompt('skipping event', evn{rej_idx(ii)});
                rej_idx(ii) = -1;
            end
        end
        rej_idx(rej_idx == -1) = [];
        evn_rej = [evn_rej; evn(rej_idx)];


    % Reject Channels
    elseif strcmpi(ecrej{1}, 'channel')
        cnum_rej = [];
        for ii = 2:length(ecrej)
            cnum_rej = [cnum_rej find(cellfun(@(x) strcmp(x,ecrej{ii}), glab_r))];
        end
        [gdat_r, glab_r, chan_rej] = remove_channels(gdat_r, glab_r, cnum_rej, chan_rej);
        rej_chans = [rej_chans; chan_rej];
        good_chans = glab_r';
    else   
        disp('  ')
        disp('Try again');
        continue
    end
    % temp - till I uncomment filt section
    flt = -1;
    EEG = make_EEG(gdat_r, glab_r, fs, evn_idc, evn, rtm, flt, [subj '_' task], ref);
    
end


%% Save Data

evn_msk = ~ismember(evn,evn_rej);
an_evn_idc = evn_idc(evn_msk);
an_evn = evn(evn_msk);
an_rtm = rtm(evn_msk);

EEG = make_EEG(gdat_r, glab_r, fs, an_evn_idc, an_evn, an_rtm, flt, [subj '_' task], ref);

if ~eeg
    raw_evn_inf = {rtm char(evn) evn_idc};
end
pro_evn_inf = {an_rtm char(an_evn) an_evn_idc};

if user_yn('save evn info?')
    save('event_info.mat', 'raw_evn_inf', 'pro_evn_inf');
end

if ~eeg || flt(end) ~= -1
    if user_yn('save EEG?')
        save([df_dir subj '_' task '_' ref '_dat.mat'], 'EEG')
    end
end

close all

if user_yn('go to fba?')
    run('frequency_band_analysis.m')
else
    disp('Good-bye!')
end



















