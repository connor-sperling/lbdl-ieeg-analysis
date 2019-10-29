function ipt = prompt(pmt, varargin)

    switch pmt
        case 'define subject'
            subjs_dir = varargin{1};
            pts = varargin{2};
            while true  
                ipt = upper(input('\nSubject ID: ', 's'));
                if any(cellfun(@(x) contains(x,ipt), pts))
                    break
                else
                    msg = sprintf('\n%s does not have a folder in the directory: %s\nWould you like to make folders for %s? (y/n)\n--> ', ipt, subjs_dir, ipt);
                    ipt = input(msg, 's');
                    if strcmp(ipt, 'y') || strcmp(ipt, 'yes')
                        mkdir([subjs_dir ipt '/analysis/'])
                        mkdir([subjs_dir ipt '/data/'])
                        mkdir([subjs_dir ipt '/Data Files/'])
                        break
                    end
                end
            end
            
            
        case 'insuff data'
            disp('Looks like there is insufficient data in this patients data files directory')
            disp('Please select an appropriate Rec.mat file or .EDF file for this patient.')
            disp('Loading the patient .EDF file will return a corresponding HDR and REC file.')
            
            
            
        case 'choose file'
            full_files = varargin{1};
            disp('  ')
            disp('Data files found:')
            for ii = 1:size(full_files,1)
                msg = sprintf('\t%d. %s ', ii, full_files(ii,:));
                disp(msg)
            end
            while true
                ipt = input('\nChoose the number of the .mat you would like to proceed with: ');

                if sum(ipt == 1:size(full_files,1)) == 1
                    break
                end
            end
            
         
            
        case 'disp channel labels'
            glab = varargin{1};
            disp('  ')
            disp('Here are some of the channels from this data:')
            glab_abbv_disp = char([glab {'   .', '   .', '   .'}]);
            disp(glab_abbv_disp([1:5, size(glab_abbv_disp,1)-2:size(glab_abbv_disp,1)],:))
            ipt = '';
            
            
        case 'fs'
            ipt = input('\nEnter the sampling rate: ');
            
            
        case 'task name'
            taskbank = varargin{1};
            while true
                task = input('\nEnter the task name: ', 's');
                if contains(taskbank, task)
                    break
                end
            end
            
            
        case 'remove channels'
            glab_r = varargin{1};
            disp('  ')
            disp('------------------------------------')
            disp([num2str(transpose(1:length(glab_r))) char(ones(length(glab_r),1) * '.  ') char(glab_r)])
            disp('\nEnter numbers of any channels you wish to remove\n   Format: array format - i.e. 1:10 or [1:5 19 20:23]\n   Type - 0 to continue\n\nWarning - This cannot be undone.');
            while true
                ipt = input('\n--> ');
                if min(ipt) >= 0 && max(ipt) <= length(glab_r)
                    break
                else
                    disp('  ')
                    disp('Not a valid range. Please try again')
                end

            end
            
            
        case 'rejected event/channel'
            evn_typ = varargin{1};
            stim_evns = varargin{2};
            rej_all_no = varargin{3};
            rej_all = varargin{4};
            chan_rej = varargin{5};
            num_evn_rej = length(rej_all_no);
            
            disp('  ')
            disp('    Events      Event idx')
            disp([char(ones(length(evn_typ),1) * '     ')  char(evn_typ) char(ones(length(evn_typ),1) * '     ') num2str(stim_evns)])
            if ~isempty(rej_all_no)
                disp('  ')
                disp('The following events have already been marked to reject:')
                disp('  ')
                disp(' Event no.   Event name')
                disp([char(ones(num_evn_rej,1) * '     ') num2str(rej_all_no) char(ones(num_evn_rej,1) * '           ') char(rej_all)])
                disp('  ')
            end
            if ~isempty(chan_rej)
                disp('  ')
                disp('The following channels have been rejected:')
                disp('  ')
                chan_rej_disp = char(strsplit(chan_rej, ','));
                disp([char(ones(size(chan_rej_disp,1),1) * '     ') chan_rej_disp])
                disp('  ')
            end
            
            
        case 'channels/events to reject'
            str = ['\nEnter the channels or events that you want to reject\n'...
                   '   Type - Channel followed by any number of channel names listed here.\n'...
                   '        - Event followed by any number of event names listed here.\n'...
                   '        - Event Contains followed by a common name to reject multiple events of the same type.\n'...
                   '        - Replace followed by an EVENT to remove that event from the rejection list.\n'...
                   '        - 0 to stop\n--> '];
            ipt = input(str, 's');
            
            
        case 'skipping event'
            rej_idx = varargin{1};
            evn_typ = varargin{2};
            msg = sprintf('\nEvent %d (%s) has already been selected for rejection. Skipping...', rej_idx, evn_typ{rej_idx});
            disp(msg)
            
            
        case 'notch filt freq'
            if nargin == 2
                msg = sprintf('\nThe last notch filter that was placed on this data was at %d Hz.\nWould you like to filter again? Enter frequency in Hz: (-1 for None)\n--> ', varargin{1});
            else
                msg = input('\nApply notch filter? Enter frequency in Hz: (-1 for None)\n--> ');
            end
            ipt = input(msg);
            
            
        case 'study'
            while true
                ipt = upper(input('\nLFP and HG frequency bands are currently supported for analysis. \nWhich would you like to proceed with? (Q to quit)\n--> ', 's'));
                if strcmp(ipt, 'HG') || strcmp(ipt, 'LFP') || strcmp(ipt, 'Q')
                    break
                end
            end
            
            
        case 'lock type'
            while true
                lt = input('\nEnter S for Stimulus Locked Analysis or R for Response Locked analysis\n--> ', 's');
                if strcmpi(lt, 's')
                    ipt = 'Stimulus Locked';
                    break
                elseif strcmpi(lt, 'r')
                    ipt = 'Response Locked';
                    break
                end
            end
           
            
        case 'running ALL prep'
            disp('  ')
            disp(' Gathering all channel data over all event regions ')
            
            
        case 'running sigchan'
            disp('  ')
            disp(' Running frequency band analysis')
            
            
        case 'no results'
            msg = sprintf('\nFBA for %s - %s produced no results\nMoving on....', varargin{1}, varargin{2});
            disp(msg)
            
            
        case 'focus evns'
            msg = sprintf('Here are all types of focus events for %s task\n %s:', varargin{1}, varargin{2});
            disp('  ')
            disp(msg)
            t = '';
            keyset = varargin{3};
            for k = 1:length(keyset)
                t = sprintf('%s  %s', t, char(keyset(k)));
            end
            disp(t)
            
            
        case 'plot by chan'
            disp(' ')
            disp('  Grouping plots by channel')
            disp(' ---------------------------')
            
    end
end
