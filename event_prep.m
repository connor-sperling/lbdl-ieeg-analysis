function event_prep(EEG, evn_idc, restm, pth, foc_nm)

    % MAKE SURE ALL PLOTS ARE CLOSED BEFORE EXECUTING %
    fs = EEG.srate; 
    rsamp = round(restm./1000 *fs);
    rsamp_corr = rsamp(rsamp > 0);
    evn_corr = evn_idc(rsamp > 0);
    
    switch EEG.lock{end} 
        case 'Response Locked'
            st_samp  = round(-1250./1000 *fs);
            en_samp  = round(750./1000 *fs);
            bl_st_samp =  round(-1250./1000 *fs);
            bl_en_samp =  round(-750./1000 *fs);

            an_st = evn_corr + rsamp_corr + st_samp;
            an_en = evn_corr + rsamp_corr + en_samp;
            bl_st  = evn_corr + rsamp_corr + bl_st_samp;
            bl_en  = evn_corr + rsamp_corr + bl_en_samp;

        case 'Stimulus Locked'
            st_samp  = round(-500./1000 *fs);
            en_samp  = round(1250./1000 *fs);
            bl_st_samp =  round(-500./1000 *fs);
            bl_en_samp =  round(0./1000 *fs);
            
            an_st = evn_corr + st_samp;
            an_en = evn_corr + en_samp;
            bl_st  = evn_corr + bl_st_samp;
            bl_en  = evn_corr + bl_en_samp;
    end
  
    lock_tm = an_st:an_en; % This variable is saved
 
    chnl_lbl = {EEG.chanlocs.labels};
    ch_Data = [EEG.data];
    pt_id = strsplit(EEG.setname, '_');
    pt_nm = pt_id{1};
    task = pt_id{2};

    for kk = 1:size(ch_Data,1)
        
        loadbar(kk, size(ch_Data,1))
        
        dat = ch_Data(kk,:);
        if strcmp(EEG.study{end}, 'HG') 
            %datT(kk,:) = abs(my_hilbert2(dat.*hann(length(dat))',fs,70,150,1,'HMFWgauss'));
%             dat_bp = bandpass(dat, [70, 150], fs);
%             datT(kk,:) = abs(hilbert(dat_bp));
            datT(kk,:) = dat;
        elseif strcmp(EEG.study{end}, 'LFP')
            % lowpass to isolate LFP
            %[b,a] = butter(4, 30/(fs/2), 'low');
%             [b,a] = ellip(6,5,50,60/fs);
%             datT(kk,:) = filtfilt(b,a,dat);
            datT(kk,:) = dat;
            % alternative to isolate the LFP and remove very low frequency components
%             [b,a] = butter(4, [0.1 30]/(fs/2), 'bandpass');
%             data = filtfilt(b,a,data);
        end
        
        band = datT(kk,:);
        chnl_evnt = zeros(length(evn_corr), an_en(1)-an_st(1)+1);

        for jj = 1:length(evn_corr)
            chnl_evnt(jj,:) = (band(an_st(jj):an_en(jj)) - mean(band(bl_st(jj):bl_en(jj))))./mean(band(bl_st(jj):bl_en(jj))) *100;
        end
        
        chan_fname = [foc_nm '_' pt_nm '_' chnl_lbl{kk} '_' EEG.ref '.mat']; % File name for each electrode
        save([pth chan_fname], 'chnl_evnt', 'lock_tm');

    end    
end