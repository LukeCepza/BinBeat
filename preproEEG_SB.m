function preproEEG_SB_2(pathSET,nameSET,pathOUT)
%%By Alma Socorro Torres Torres modificado por Luis Kevin Cepeda
[ALLEEG,~,CURRENTSET]=eeglab;
%(1.1) Cargar datos .gdf
          %EEG = pop_loadset('filename', nameSET, 'filepath', pathSET);
        EEG = pop_biosig(strcat(pathSET,'\',nameSET,'.gdf'));
%(1.2) Editar ubicacion de canales
        EEG = pop_chanedit(EEG, 'lookup','D:\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\\SonidosBinaurales\\mBrain_24ch_locations.elp');
%(1.3) Recortar datos
        EEG = pop_select( EEG, 'notime',[0 1170] );
%(1.4) Re-referenciación
        EEG = pop_reref( EEG, [20 21] ); 
        originalEEG = EEG;
%(2) Quitar la linea base
        EEG.data = rmbase(EEG.data);
%(2.1) Quitar componentes baja frecuencia 
        FiltEEG = designfilt('bandpassiir','FilterOrder',4, ...
            'HalfPowerFrequency1',0.1,'HalfPowerFrequency2',100, ...
            'DesignMethod','butter','SampleRate',EEG.srate); 
        EEG.data = single(filtfilt(FiltEEG, double(EEG.data')))';
%(3)Line noise
        EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist', 1:EEG.nbchan,...
            'computepower',1,'linefreqs',60,'normSpectrum',0,'p',0.05,...
            'pad',2,'plotfigures',0,'scanforlines',1,'sigtype',...
            'Channels','tau',100,'verb',1,'winsize',4,'winstep',1); 
%(4)Quitar artefactos no estacionarios
        EEG= pop_clean_rawdata(EEG, 'FlatlineCriterion',5,...
            'ChannelCriterion',0.7,'LineNoiseCriterion',4,...
            'Highpass',[0.25 0.5] ,'BurstCriterion',20,...
            'WindowCriterion',0.25,'BurstRejection','on',...
            'Distance','Euclidian','WindowCriterionTolerances',[-Inf 7]);
        
%(5)Interpolate
        EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');
%(6)Decomposing constant fixed-source noise/artifacts/signals (ICA)
          % (6.1)High-pass filtering @ 1hz
        EEGff=EEG;
        d = designfilt('highpassiir','FilterOrder',8, ...
            'HalfPowerFrequency',1, ...
            'DesignMethod','butter','SampleRate',EEG.srate);
        EEGff.data = single(filtfilt(d, double(EEG.data')))'; 
        EEGica = pop_runica(EEGff, 'icatype', 'runica', ...
            'extended',1,'interrupt','off');
        EEG.icawinv = EEGica.icawinv;
        EEG.icasphere = EEGica.icasphere;
        EEG.icaweights = EEGica.icaweights;
        EEG.icachansind = EEGica.icachansind;

%(7)Remove ICs artifacts(ICA) 
        EEGf_IClabel_1= iclabel(EEG);
        EEGf_IClabel_1 = pop_icflag(EEGf_IClabel_1, [NaN NaN;0.6 1;0.6 1;0.6 1;0.6 1;0.6 1;0.6 1]);
        EEGf_IClabel_1 = pop_subcomp(EEGf_IClabel_1,find(EEGf_IClabel_1.reject.gcompreject), 0,0);
        EEGf_IClabel_1.setname = [nameSET '_IClabel' '_clean'];
        pop_saveset(EEGf_IClabel_1, 'filename', [nameSET,'_','IClabel_1','_clean','.set'], 'filepath', pathOUT);

        EEGf_IClabel_2= iclabel(EEG);
        EEGf_IClabel_2 = pop_icflag(EEGf_IClabel_2, [0 0.5;0.5 1;0.5 1;0.5 1;0.5 1;0.5 1;0.5 1]);
        EEGf_IClabel_2 = pop_subcomp(EEGf_IClabel_2,find(EEGf_IClabel_2.reject.gcompreject), 0,0);
        EEGf_IClabel_2.setname = [nameSET '_IClabel' '_clean'];
        pop_saveset(EEGf_IClabel_2, 'filename', [nameSET,'_','IClabel_2','_clean','.set'], 'filepath', pathOUT);
        
        % Perform IC rejection using ICLabel scores and r.v. from dipole fitting.
        EEG       = IClabel(EEG, 'default');
        brainIdx  = find(EEG.etc.ic_classification.ICLabel.classifications(:,1) >= 0.7);
        rvList    = [EEG.dipfit.model.rv];
        goodRvIdx = find(rvList < 0.15); 
        goodIcIdx = intersect(brainIdx, goodRvIdx);
        EEG = pop_subcomp(EEG, goodIcIdx, 0, 1);
        EEG.etc.ic_classification.ICLabel.classifications = EEG.etc.ic_classification.ICLabel.classifications(goodIcIdx,:);
end
