function [ndat, nlab, removed] = remove_channels(dat, lab, chans, removed)    
    ret_orig = 0;
    for n = chans
        if n > 0 && n <= length(lab)
            chan = lab{n};
            lab{n} = 'x';
            if isempty(removed)
                removed = chan;
            else
                removed = [removed ',' chan];
            end
        else
            msg = sprintf('Channel #%d is not in range of channel numbers', n);
            disp(msg)
            ret_orig = 1;
            break
        end
    end
    ndat = dat;
    nlab = lab;
    if ~ret_orig
        ndat(chans,:) = [];
        nlab = {lab{~strcmp(lab, 'x')}};

        rmvd_disp = strsplit(removed, ',');
        if ~isempty(removed)
            disp('  ')
            disp('Removed the following channels:')
            disp(char(rmvd_disp))
        end
    end