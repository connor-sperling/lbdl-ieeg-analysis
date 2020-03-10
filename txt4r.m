function txt4r(EEG, TvD, win_ms, lock_pth, subjs_dir)
    
    stinf = strsplit(EEG.setname, '_');
    subj = stinf{1};
    task = stinf{2};
    ref = EEG.ref;
    study = EEG.study{end};
    lock = EEG.lock{end};
    lockt = erase(lock, ' Locked');
    fs = EEG.srate;
    
    
    
    
    ce_pth  = sprintf('%s/ALL/Channel events/%s', lock_pth, study);
    
    switch lock
        case 'Response Locked'
            t_st = -1250;
            an_st_tm = -750;
            t_en = 650; % THIS WAS EDITED (temporarily)
            
        case 'Stimulus Locked'
            t_st = -1000;
            an_st_tm = 0;
            t_en = 1000;
    end

    mat_st = an_st_tm - t_st;
    mat_en = t_en - t_st;
    
    tot_t = mat_en - mat_st;
        
    [win_ms, xdiv] = dividewindow(tot_t, win_ms, 100);
    
    dt = strsplit(datestr(datetime));
    dt = dt{1};
    
    tname = sprintf('%s_average_%s_activity_by_%dms_segments.txt', task, study, win_ms);
    txt_pth = sprintf('%s/txts/%s', subjs_dir, dt);
    fname = sprintf('%s/%s', txt_pth, tname);
    if ~exist(txt_pth, 'dir')
        mkdir(txt_pth);
    end

    
    
    z = zeros(xdiv, floor(win_ms*fs/1000));
    
    for x = 1:xdiv
        ztemp = floor((mat_st + (x-1)*win_ms + 1)*fs/1000):floor((mat_st + x*win_ms)*fs/1000);
        if length(ztemp)-size(z,2) == 1
            ztemp = ztemp(1:end-1);
        end
        z(x,:) = ztemp;
    end
    
    evn_msk = ~ismember({EEG.event.type}', {EEG.analysis.type}');
    
    % Read in xl file containing shaft locations, write txt file and read
    % back in txt format
    allregion = readtable(sprintf('%s/Excel Files/channel_region.xlsx', subjs_dir));
    allregion = allregion(cellfun(@(x) strcmp(x, subj), allregion.subject),:);
    shaftinf = allregion(cellfun(@(x) strcmp(x, lockt), allregion.lock),:);
%     writetable(regions, sprintf('%s/Excel Files/channel_region.txt', subjs_dir), 'Delimiter', 'tab')
%     fid = fopen(sprintf('%s/Excel Files/channel_region.txt', subjs_dir));
%     shaft_reg = textscan(fid, '%s %s %s %s');
%     fclose(fid);
    
    % Read in xl file containing behavioral data, write txt file and read
    % back in txt format
    patdata = readtable(sprintf('%s/%s/Data Files/%s_CV_%s.xlsx', subjs_dir, subj, subj, task));
    patdata(evn_msk, :) = [];
    header = patdata.Properties.VariableNames;
    
    writetable(patdata, sprintf('%s/%s/Data Files/%s_CV_%s.txt', subjs_dir, subj, subj, task), 'Delimiter', 'tab')
    fid = fopen(sprintf('%s/%s/Data Files/%s_CV_%s.txt', subjs_dir, subj, subj, task));
    formspec = '';
    for i = 1:length(header)
        formspec = [formspec ' %s'];
    end
    pred = textscan(fid,formspec);
    fclose(fid);
    
    varmsk = cellfun(@(x) strcmpi(x{1}, 'trial_num'), pred);
    vartemp = pred(varmsk);
    pred(varmsk) = [];
    pred = [vartemp pred];
    
    varmsk = cellfun(@(x) strcmpi(x{1}, 'patient'), pred);
    vartemp = pred(varmsk);
    pred(varmsk) = [];
    pred = [vartemp pred];
    

    elecs = {TvD{:,2}}';
    

    for ii = 1:length(elecs)
        

        lab = elecs{ii};
        reginf = shaftinf(cellfun(@(x) strcmp(x, lab), shaftinf.label),:);
        if ~isempty(reginf)
            region = char(reginf.region);
        else
            region = 'ud';
        end
        
        load(sprintf('%s/ALL_%s_%s_%s.mat', ce_pth, subj, lab, ref), 'chnl_evnt');
       

        y = zeros(size(chnl_evnt,1), xdiv);

        sig_idcs = TvD{ii,5};
    
        for k = 1:size(z,1)
%             if ~isempty(intersect(sig_idcs,z(k,:)))
%                 w = z(k,:); 
%                 y(:,k) = double(mean(chnl_evnt(:,w),2));
%             end
            w = z(k,:); 
            y(:,k) = double(mean(chnl_evnt(:,w),2));
        end
        

        if ~exist(fname, 'file') 
            % Header
            fid = fopen(fname, 'wt');
            sublist = sprintf('%s\t%s\tEvent_Locked\tChannel\tRegion\tSegment\tAvg_%s', pred{1}{1}, pred{2}{1}, study);
            for i = 3:length(pred)
                sublist = sprintf('%s\t%s', sublist, pred{i}{1}); 
            end
            fprintf(fid, '%s', sublist);
            fprintf(fid, '\n');
        else
            % File exists, append
            fid = fopen(fname, 'a');
        end

        for x = 1:xdiv
            for k = 1:size(y,1) 
                sublist = sprintf('%s\t%s\t%s\t%s\t%s\t%d\t%f', pred{1}{k+1}, pred{2}{k+1}, lockt, lab, region, x, y(k,x));
                for l = 3:length(pred) 
                    sublist = sprintf('%s\t%s', sublist, pred{l}{k+1}); 
                end
                fprintf(fid, '%s', sublist);
                fprintf(fid, '\n');
            end
        end

        fclose(fid); % Close the stats file


    end        
end
