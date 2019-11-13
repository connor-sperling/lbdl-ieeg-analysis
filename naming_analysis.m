function naming_analysis(EEG, evn_typ, evn_idcs, restm, pth) 

    evn_split = cellfun(@(x) strsplit(x, '-'), evn_typ, 'UniformOutput', false);
    positions = cellfun(@(x) x(2), evn_split);
    keyset = unique(positions);
    
    cat_pth = [pth 'Data by Position in Category/'];
    if ~exist(cat_pth, 'dir')
        mkdir(cat_pth)
    end
    
    k = 1;
    for gsize = [2 3]
%         while k <= length(keyset)
%             pcatn = ['poscat' keyset{k} '-' num2str(k+gsize-1)];
%             focus_evn_typ = {}; focus_evns = []; focus_resp = [];
%             for ii = k:k+gsize-1
%                 temp_typ = evn_typ(ismember(positions, keyset(ii)));
%                 temp_evns = evn_idcs(ismember(evn_typ, temp_typ));
%                 temp_resp = restm(ismember(evn_typ, temp_typ));
% 
%                 focus_evn_typ = [focus_evn_typ; temp_typ];
%                 focus_evns = [focus_evns; temp_evns];
%                 focus_resp = [focus_resp; temp_resp];
%             end
%             
%             event_prep(EEG, focus_evns, focus_evn_typ, focus_resp, cat_pth, pcatn);
%             
%             
%             
%             k = k + gsize;
%         end

       
        sig_chans = {EEG.chanlocs.labels};
        subj = strsplit(EEG.setname, '_');
        subj = subj{1};
        
        handles = {};
        axiis = {};
        cd(cat_pth)
        prompt('plot by chan')
        for ii = 1:length(sig_chans)

            loadbar(ii, length(sig_chans))
            chan_mats_struc = dir(['*' sig_chans{ii} '*']);
            channel_mats = {chan_mats_struc.name};
            
            axii = plot_naming(channel_mats, num2str(gsize), restm, pth, EEG.srate, EEG.info.lock{end});

            handles{ii} = get(axii, 'children');
            axiis{ii} = axii;
        end
        
        %subplot_all(handles, axiis, 4, [lock_pth 'Channel FBA Plots by Category/' study '/Group ' num2str(gsize) '/'])
    end
end



