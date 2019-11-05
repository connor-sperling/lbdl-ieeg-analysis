function stroop_analysis

     load(ses_TvD)
%     if isempty(TvD)
%         prompt('no results', study, lock)
%         continue
%     end

    disp('  ')
    disp('Focused FBA:')

    % find significant channels, make stucture that only contains sig dat
    chansSIG = string(TvD(:,2));
    chansALL = string(glab_r)';
    gdat_SIG = gdat_r(ismember(chansALL, chansSIG), :);
    EEG_sig = make_EEG(gdat_SIG, TvD(:,2), fs, cln_evns, cln_evn_typ, id, -1, [SUBID '_' task], task, study, ref, lock);
    
    focus_typ = 'congruency';
    color_idx = 3;
    space_idx = 4;
    
    c_beg = {}; c_end = {}; 
    s_beg = {}; s_end = {};
    c_beg_idcs = []; c_end_idcs = [];
    s_beg_idcs = []; s_end_idcs = [];
    
    for N = 1:4
        switch N
            case 1
                stroop_idx = color_idx;
                cong = 'C';
            case 2
                stroop_idx = color_idx;
                cong = 'I';
            case 3
                stroop_idx = space_idx;
                cong = 'C';
            case 4
                stroop_idx = space_idx;
                cong = 'I';
        end
        
        for ii = 2:str2double(cln_evn_typ{end}(1))
            blk_msk = cellfun(@(x) str2double(x(1)) == ii, cln_split);
            block_evns = cln_evn_typ(blk_msk);
            block_idcs = cln_evns(blk_msk);
            if mod(ii,2)
                [beg_msk,end_msk] = split_stroop_evns(block_evns, stroop_idx, cong, ii);
                c_beg = [c_beg; block_evns(beg_msk)];
                c_end = [c_end; block_evns(end_msk)];
                c_beg_idcs = [c_beg_idcs; block_idcs(beg_msk)];
                c_end_idcs = [c_end_idcs; block_idcs(end_msk)];
            else
                [beg_msk,end_msk] = split_stroop_evns(block_evns, stroop_idx, cong, ii);
                s_beg = [s_beg; block_evns(beg_msk)];
                s_end = [s_end; block_evns(end_msk)];
                s_beg_idcs = [s_beg_idcs; block_idcs(beg_msk)];
                s_end_idcs = [s_end_idcs; block_idcs(end_msk)];
            end
        end
        
        % Determine save location for chnl_evns
        
        % event_analysis for spatial stroop beginning
        % event_analysis for spatial stroop end
        
        % event_analysis for color stroop beginning
        % event_analysis for color stroop end
    
    end
    
        % subplot(2,2,1)
        % sCw_beg, sIw_beg, sCs_beg, sIs_beg
        
        % subplot(2,2,2)
        % sCw_end, sIw_end, sCs_end, sIs_end
        
        % subplot(2,2,3)
        % cCw_beg, cIw_beg, cCs_beg, cIs_beg
        
        % subplot(2,2,4)
        % cCw_end, cIw_end, cCs_end, cIs_end
end