function stroop_analysis(EEG, evn_typ, evn_idcs, restm, pth) 

    evn_split = cellfun(@(x) strsplit(x, '-'), evn_typ, 'UniformOutput', false);
    
    color_idx = 3;
    space_idx = 4;
    
    cong_pth = [pth 'Congruency Sorted Data/'];
    if ~exist(cong_pth, 'dir')
        mkdir(cong_pth)
    end
    
%     for N = 1:4
%         c_beg = {}; c_end = {}; 
%         s_beg = {}; s_end = {};
%         c_beg_idcs = []; c_end_idcs = [];
%         s_beg_idcs = []; s_end_idcs = [];
%         c_beg_resp = []; c_end_resp = []; 
%         s_beg_resp = []; s_end_resp = [];
%         switch N
%             case 1
%                 stroop_idx = color_idx;
%                 cong = 'C';
%                 stp = 'c';
%             case 2
%                 stroop_idx = color_idx;
%                 cong = 'I';
%                 stp = 'c';
%             case 3
%                 stroop_idx = space_idx;
%                 cong = 'C';
%                 stp = 's';
%             case 4
%                 stroop_idx = space_idx;
%                 cong = 'I';
%                 stp = 's';
%         end
% 
%         
%         for ii = 2:str2double(evn_typ{end}(1))
%             blk_msk = cellfun(@(x) str2double(x(1)) == ii, evn_split);
%             block_evns = evn_typ(blk_msk);
%             block_idcs = evn_idcs(blk_msk);
%             block_resp = restm(blk_msk);
%             if mod(ii,2)
%                 [beg_msk,end_msk] = split_stroop_evns(block_evns, stroop_idx, cong, ii);
%                 c_beg = [c_beg; block_evns(beg_msk)];
%                 c_end = [c_end; block_evns(end_msk)];
%                 c_beg_idcs = [c_beg_idcs; block_idcs(beg_msk)];
%                 c_end_idcs = [c_end_idcs; block_idcs(end_msk)];
%                 c_beg_resp = [c_beg_resp; block_resp(beg_msk)];
%                 c_end_resp = [c_end_resp; block_resp(end_msk)];
%             else
%                 [beg_msk,end_msk] = split_stroop_evns(block_evns, stroop_idx, cong, ii);
%                 s_beg = [s_beg; block_evns(beg_msk)];
%                 s_end = [s_end; block_evns(end_msk)];
%                 s_beg_idcs = [s_beg_idcs; block_idcs(beg_msk)];
%                 s_end_idcs = [s_end_idcs; block_idcs(end_msk)];
%                 s_beg_resp = [s_beg_resp; block_resp(beg_msk)];
%                 s_end_resp = [s_end_resp; block_resp(end_msk)];
%             end
%         end
%         
%         event_prep(EEG, c_beg_idcs, c_beg, c_beg_resp, cong_pth, ['c' cong stp 'Beg'])
%         event_prep(EEG, c_end_idcs, c_end, c_end_resp, cong_pth, ['c' cong stp 'End'])
%         event_prep(EEG, s_beg_idcs, s_beg, s_beg_resp, cong_pth, ['s' cong stp 'Beg'])
%         event_prep(EEG, s_end_idcs, s_end, s_end_resp, cong_pth, ['s' cong stp 'End'])
%         
%     end
    
    sig_chans = {EEG.chanlocs.labels};
    cd(cong_pth)
    
    for ii = 1%:length(sig_chans)
        chan_mats_struc = dir(['*' sig_chans{ii} '*']);
        channel_mats = {chan_mats_struc.name};
        plot_stroop(channel_mats, restm, cong_pth, EEG.srate, EEG.info.lock{end});
    end
    
end