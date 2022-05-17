function preproEEG_SB_3(pathSET,nameSET,pathOUT)
%%By Luis Kevin Cepeda Zapata 
if exist('ALLCOM','var') == 0
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
end
%(1.1) Load .gdf data
        EEG = pop_biosig(strcat(pathSET,'\',nameSET,'.gdf'));
%(1.2) Edit channhel locations
        EEG = pop_chanedit(EEG, 'lookup','D:\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\\SonidosBinaurales\\mBrain_24ch_locations.elp');
%(1.3) Eppch data // I selected all epochs -9sec and +9 sec after and
                        %before epochs being. For all data remove this line
        EEG = pop_select( EEG, 'time',[1191 1479] );
%(1.4) Reference % to mastoids in Binaural stimulation
        EEG = pop_reref( EEG, [20 21] ); 
        originalEEG = EEG;
%(2) Remove Base line
        EEG.data = rmbase(EEG.data);
%(3)Line noise // Selected win size and winstep equal to the size of epochs.
                % This was used for binaural stimulation ERPs which last
                % 900ms. Thats why 'winsize',0.9,'winstep',0.9. In other
                % cases 'winsize',4,'winstep',1 could be used. A high pass
                % filter is used to increase the efficiency of the rutine.
        EEG= pop_clean_rawdata(EEG, 'FlatlineCriterion',5,...
            'ChannelCriterion',0.7,'LineNoiseCriterion',4,...
            'Highpass',[0.25 0.5] ,'BurstCriterion',20,...
            'WindowCriterion',0.25,'BurstRejection','on',...
            'Distance','Euclidian','WindowCriterionTolerances',[-Inf 7]);
%(4)Remove flatlined channels, non correlated channels, non stationary
%artifacts (ASR), and contaminated windows.
                %This works well with default settings in all
                %circumstances.       
        EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,...
        'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass',...
        'off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection',...
        'on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );
%(5)Interpolate
        EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');
%(6)Decomposing constant fixed-source noise/artifacts/signals (ICA)
          % (6.1)High-pass filtering @ 1hz
        EEGff=EEG;
        d = designfilt('highpassiir','FilterOrder',8, ...
            'HalfPowerFrequency',1, ...
            'DesignMethod','butter','SampleRate',EEG.srate);
        EEGff.data = filtfilt(d, double(EEG.data'))'; 
        EEGica = pop_runica(EEGff, 'icatype', 'runica', ...
            'extended',1,'interrupt','off');
        EEG.icawinv = EEGica.icawinv;
        EEG.icasphere = EEGica.icasphere;
        EEG.icaweights = EEGica.icaweights;
        EEG.icachansind = EEGica.icachansind;
%(7)Dipole fitting
    EEG = pop_dipfit_settings( EEG, 'hdmfile',...
        'D:\\Kevin_Cepeda\\Matlab\\NewMatLabData\\Neuroengineering\\eeglab2021.0\\plugins\\dipfit\\standard_BEM\\standard_vol.mat',...
        'coordformat','MNI','mrifile',...
        'D:\\Kevin_Cepeda\\Matlab\\NewMatLabData\\Neuroengineering\\eeglab2021.0\\plugins\\dipfit\\standard_BEM\\standard_mri.mat',...
        'chanfile','D:\\Kevin_Cepeda\\Matlab\\NewMatLabData\\Neuroengineering\\eeglab2021.0\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc',...
        'coord_transform',[0 0 0 0 0 0 99.0548 99.0548 99.0548] ,'chansel',1:22); 
%(8) Fit multiple component dipoles using DIPFIT
    EEG = pop_multifit(EEG, 1:22 ,'threshold',100,'plotopt',{'normlen','on'});
%(9) Perform IC rejection using ICLabel scores and r.v. from dipole fitting.
        EEG       = iclabel(EEG, 'default');
        brainIdx  = find(EEG.etc.ic_classification.ICLabel.classifications(:,1) >= 0.7);
        rvList    = [EEG.dipfit.model.rv];
        goodRvIdx = find(rvList < 0.15); 
        goodIcIdx = intersect(brainIdx, goodRvIdx);
        EEG = pop_subcomp(EEG, goodIcIdx, 0, 1);
%(10) Save dataset
        EEG.setname = [nameSET(1:end-22),'_clean_makoto'];
        pop_saveset(EEG, 'filename', [nameSET(1:end-22),'_','_makotos','_clean','.set'], 'filepath', pathOUT);

end
