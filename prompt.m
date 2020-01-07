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
                ipt = input('\nEnter the task name: ', 's');
                iptchk = ipt;
                iptchk(regexp(iptchk,'\d*')) = [];
                if contains(taskbank, iptchk)
                    break
                end
            end
            
            
        case 'remove channels'
            glab_r = varargin{1};
            disp('  ')
            disp('------------------------------------')
            disp([num2str(transpose(1:length(glab_r))) char(ones(length(glab_r),1) * '.  ') char(glab_r)])
            msg = sprintf('\nEnter numbers of any channels you wish to remove\n   Format: array format - i.e. 1:10 or [1:5 19 20:23]\n   Type - 0 to continue\n\nWarning - This cannot be undone.');
            disp(msg)
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
            evn = varargin{1};
            evn_idc = varargin{2};
            evn_rej = varargin{3};
            chan_rej = varargin{4};
            
            len_et = length(evn);
            len_er = length(evn_rej);
            len_cr = length(chan_rej);
            
            disp('  ')
            disp('    Events      Event idx')
            disp([char(ones(len_et,1) * '     ')  char(evn) char(ones(len_et,1) * '     ') num2str(evn_idc)])
            if ~isempty(evn_rej)
                disp('  ')
                disp('The following events have already been marked to reject:')
                disp('  ')
                disp(' Event name')
                disp([char(ones(len_er,1) * '     ') char(evn_rej)])
                disp('  ')
            end
            if ~isempty(chan_rej)
                disp('  ')
                disp('The following channels have been rejected:')
                disp('  ')
                disp([char(ones(len_cr,1) * '     ') char(chan_rej)])
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
            evn = varargin{1};
            msg = sprintf('\nEvent %s has already been selected for rejection. Skipping...', evn);
            disp(msg)
            
            
        case 'notch filt freq'
            if nargin == 2
                filts = varargin{1};
                msg = sprintf('\nThese are the notch filters that have been placed on your data:\n');
                for n = 1:length(filts)
                    msg = sprintf('%s  %d Hz', msg, filts(n));
                end
                msg = sprintf('%s\nWould you like to filter again? Enter frequency in Hz: (-1 for None)\n--> ', msg);
            else
                msg = sprintf('\nApply notch filter? Enter frequency in Hz: (-1 for None)\n--> ');
            end
            ipt = input(msg);
            
            
        case 'pick subjs'
            subjs = varargin{1};
            len_s = length(subjs);
            disp('  ')
            disp('Here are all of the subjects in your directory:')
            disp([char(ones(len_s,1) * '     ')  char(subjs)])
            msg = sprintf('\nChoose which subjects you would like to analyze. (All - to analyze every possible subject)\n--> ');
            ipt = upper(input(msg, 's'));
            
            
        case 'pick task'
            tasks = varargin{1};
            tdisp = sprintf('\nHere are the available Language Tasks to study:\n  %s,', tasks{1});
            for ii = 2:length(tasks)
                if ii == length(tasks)
                    tdisp = sprintf('%s %s', tdisp, tasks{ii});
                else
                    tdisp = sprintf('%s %s,', tdisp, tasks{ii});
                end
            end
            disp(tdisp)
%             chk = 1;
%             
%             while chk
%                 chk = 0;
                msg = sprintf('\nChoose any number of tasks (All - to analyze all tasks where applicable)\n--> ');
                ipt = input(msg, 's');
%                 iptchk = strsplit(ipt);
%                 for ii = 1:length(iptchk)
                    
            
            
            
        case 'pick study'
            ipt = '';
            while true   
                msg = sprintf('\nWould you like to study High Gamma (HG) activity, Local Field Potential (LFP) activity, or both?\n--> ');
                ipt = upper(input(msg, 's'));
                if ~strcmpi(ipt, 'HG') && ~strcmpi(ipt, 'LFP') && ~strcmpi(ipt, 'both')
                    disp(' ')
                    disp('Enter HG for High Gamma, LFP for Local Field Potential, or both for both')
                else
                    break
                end
            end
            
            
        case 'percent chan/evn'
            msg = sprintf('\nAnalysis will include %d channels over %.2f%% of the original stimulus events', varargin{1}, 100*varargin{2}/varargin{3});
            disp(msg)
            
            
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
            
            
        case 'naming fba'
            msg = sprintf('\nGrouping stimulus events by position in category\nData will be analyzed and plotted over groups of 2 positions then groups of 3 poistions\ni.e. Pos. Cat. 1-2, 3-4, etc. then Pos. Cat. 1-3, 4-6');
            disp(msg)
            
            
        case 'stroop fba'
            msg = sprintf('\nGrouping stimulus events by congruency with respect to Stroop task.\nData will be analyzed and plotted over events that are in one of 8 conditions.\ni.e. Congruent in color while in Color stroop task (cCc), Incongruent in color while in Color Stroop task (cIc), Congruent in space while in Spatial Stroop task (sCs), etc.');
            disp(msg)

            
        case 'stroop evn prep'
            pos = '';
            if isequal(varargin{2}, 'Beg')
                pos = '1st';
            elseif isequal(varargin{2}, 'End')
                pos = '2nd';
            end
            msg = sprintf('\n(%d/16) Processing %s%s%s events within the %s 20 events of each block:\n', varargin{1}, varargin{3}, varargin{4}, varargin{5}, pos);
            disp(msg)
            
            
        case 'stroop plot'
            disp(' ')
            disp('Plotting...')
            
            
        case 'plot by chan'
            disp(' ')
            disp('  Grouping plots by channel')
            disp(' ---------------------------')
            
            
        case 'naming evn analyaia'
            msg = sprintf('\nGrouping stimulus events in groups of %s', varargin{1});
            disp(msg)
            
            
        case 'naming evn prep'
            msg = sprintf('\n  Processing events with position in category %s\n', varargin{1});
            disp(msg)
    end
end
