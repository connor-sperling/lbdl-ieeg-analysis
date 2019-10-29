function EEG = make_EEG(dat, lab, srate, evns, evn_typ, evnid, flt, name, task, study, ref, lock)

    EEG.setname = name;
    EEG.info.task = task;
    if isfield(EEG.info, 'study')
        EEG.info.study = [EEG.info.study {study}];
    else
        EEG.info.study = {study};
    end
    EEG.info.ref = ref;
    if isfield(EEG.info, 'lock')
        EEG.info.lock = [EEG.info.lock {lock}];
    else
        EEG.info.lock = {lock};
    end
    EEG.nbchan = size(dat,1);
    EEG.trials = 1;
    EEG.pnts = size(dat,2);
    EEG.srate = srate;
    EEG.xmin = 0;
    EEG.xmax = size(dat,2)/srate;
    EEG.times = 0:size(dat,2)-1;
    EEG.data = dat;
    EEG.icaat = [];
    EEG.icawinv = [];
    EEG.icasphere = [];
    EEG.icaweights = [];
    EEG.icachansind = []; 
    for ii = 1:length(lab)
       EEG.chanlocs(ii).labels = char(lab(ii));
    end
    EEG.urchanlocs = [];
    EEG.chaninfo.plotrad = [];
    EEG.chaninfo.shrink = [];
    EEG.chaninfo.nosedir = '+X';
    EEG.chaninfo.nodatchans = [];
    EEG.chaninfo.icachansind = [];
    EEG.ref = 'common';
    EEG.event = [];
    for ii = 1:length(evns)
       EEG.event(ii).latency = evns(ii);
       EEG.event(ii).duration = 1;
       EEG.event(ii).channel = 0;
       EEG.event(ii).bytime = [];
       EEG.event(ii).bvmknum = ii;
       if ~isempty(evn_typ{ii})
           EEG.event(ii).type = evn_typ{ii};
           if iscell(evnid)
               EEG.event(ii).id = evnid{ii};
           end
           EEG.event(ii).code = 'Stimulus';
           EEG.event(ii).urevent = ii;
       end
       
    end
    EEG.urevent = EEG.event;
    EEG.eventdescription = cell(1,8);
    EEG.epoch = [];
    EEG.epochdescription = cell(0,0);
    EEG.reject = struct;
    EEG.stats = struct;
    EEG.specdata = [];
    EEG.specicaact = [];
    EEG.splinefile = '';
    EEG.icasplinefile = '';
    EEG.dipfit = [];
    EEG.history = [];
    EEG.saved = 'yes';
    EEG.etc = struct;
    
    if length(flt) > 1 && flt(length(flt)) == -1
        EEG.notch = flt(1:length(flt)-1);
    elseif flt == -1
        EEG.notch = [];
    else
        EEG.notch = flt;     
    end
end

























