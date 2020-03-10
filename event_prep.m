function event_prep(EEG, evn_idc, restm, pth, foc_nm)

    fs = EEG.srate; 
    lock = EEG.lock{end};
    band = EEG.band{end};
    rsp_idc = round(restm./1000 *fs);
    
    switch lock 
        case 'Response Locked'
            t_st = -1250;
            t_en = 750;
            t_bl_st = -1250;
            t_bl_en = -750;
            lidc = evn_idc + rsp_idc;
        case 'Stimulus Locked'           
            t_st = -1000;
            t_en = 1600;
            t_bl_st = -500;
            t_bl_en = 0;
            lidc = evn_idc;
    end
    
    tot_t = t_en - t_st;
    
    an_st = lidc + round(t_st./1000 *fs); % Idx of lock + (-) analysis window st time
    an_en = lidc + round(t_en./1000 *fs); % Idx of lock +  analysis window end time
    bl_st  = lidc + round(t_bl_st./1000 *fs); % Idx of lock + (-) baseline window st time
    bl_en  = lidc + round(t_bl_en./1000 *fs); % Idx of lock + (-) baseline window end time
            
    lock_tm = an_st:an_en;
 
    labs = {EEG.chanlocs.labels};
    dat = [EEG.data];
    pt_id = strsplit(EEG.setname, '_');
    pt_nm = pt_id{1};
    task = pt_id{2};

    for kk = 1:size(dat,1)        
        if strcmp(band, 'HFB') 
            dat_bp = bandpass(dat(kk,:), [70, 150], fs);
            datT(kk,:) = abs(hilbert(dat_bp));
        elseif strcmp(band, 'LFP')
            [b,a] = butter(4, 30/(fs/2), 'low');
            datT(kk,:) = filtfilt(b,a,dat(kk,:));
            % alternative to isolate the LFP and remove very low frequency components
%             [b,a] = butter(4, [0.1 30]/(fs/2), 'bandpass');
%             data = filtfilt(b,a,data);
        end
        
        windatT = datT(kk,:);
        chnl_evnt = zeros(length(lidc), round(tot_t/1000 *fs)+1);
        for jj = 1:length(lidc)
            chnl_evnt(jj,:) = (windatT(an_st(jj):an_en(jj)) - mean(windatT(bl_st(jj):bl_en(jj))))./mean(windatT(bl_st(jj):bl_en(jj))) *100;
        end     
        
        save(sprintf('%s/%s_%s_%s_%s.mat', pth, foc_nm, pt_nm, labs{kk}, EEG.ref), 'chnl_evnt', 'lock_tm');

    end    
end