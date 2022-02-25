function preproEEG_SB_3decom(pathSET,nameSET,pathOUT)
%%By Alma Socorro Torres Torres modificado por Luis Kevin Cepeda
[ALLEEG,~,CURRENTSET]=eeglab;
%(1.1) Cargar datos .gdf
          %EEG = pop_loadset('filename', nameSET, 'filepath', pathSET);
        EEG = pop_biosig(strcat(pathSET,'\',nameSET,'.gdf'));

          %nameSET=replace(nameSET,'.set','');
%(1.2) Editar ubicacion de canales
        EEG = pop_chanedit(EEG, 'lookup','C:\Users\lkcep\Documents\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\SonidosBinaurales\\mBrain_24ch_locations.elp');
%(1.3) Recortar datos
        EEG = pop_select( EEG, 'notime',[0 1170] );
%(1.4) Re-referenciación
        EEG = pop_reref( EEG, [20 21] ); 
%(2) Quitar la linea base
        EEG.data = rmbase(EEG.data);
% (2.1) Quitar componentes baja frecuencia 
        FiltEEG = designfilt('bandpassiir','FilterOrder',4, ...
        'HalfPowerFrequency1',0.1,'HalfPowerFrequency2',100, ...
        'DesignMethod','butter','SampleRate',EEG.srate); 
        EEG.data = single(filtfilt(FiltEEG, double(EEG.data')))';
%(3)Line noise
        EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist', 1:EEG.nbchan,...
        'computepower',1,'linefreqs',60,'normSpectrum',0,'p',0.05,...
        'pad',2,'plotfigures',0,'scanforlines',1,'sigtype',...
        'Channels','tau',100,'verb',1,'winsize',4,'winstep',1); 
          %pop_saveset(EEG, 'filename', [nameSET '_raw' '.set'], 'filepath', pathOUT); 
%(5)Remove occasional large-amplitude noise/artifacts
          [EEG,~,EEGbur] = clean_artifacts(EEG,'ChannelCriterion',0.65);
%(2.1)ASR CLEAN RAW DATA 
          %EEGbur.setname = [nameSET '_bur'];
          %pop_saveset(EEGbur, 'filename', [nameSET '_bur' '.set'], 'filepath', pathOUT); 
%(5.1) Interpolate
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
                EEG.setname = [nameSET 'ica'];
                pop_saveset(EEG, 'filename', [nameSET, '_ica','.set'], 'filepath', pathOUT); 
%(8)Remove ICs artifacts(ICA) 
% Lo modifique para obtener componentes de descomposición

%     EEG_MARA = pop_loadset('filename', [nameSET, '_ica','.set'], 'filepath', pathOUT);
%     [~,EEGf_MARA,~] =processMARA( ALLEEG,EEG_MARA,CURRENTSET);
%     EEGf_MARA = pop_subcomp(EEGf_MARA,find(EEGf_MARA.reject.gcompreject), 0,0); 
%     EEGf_MARA.setname = [nameSET '_MARA' '_clean'];
%     pop_saveset(EEGf_MARA, 'filename', [nameSET,'_','MARA','_clean','.set'], 'filepath', pathOUT);
      
    EEG_IClabel = pop_loadset('filename', [nameSET, '_ica','.set'], 'filepath', pathOUT);
    EEGf_IClabel= iclabel(EEG_IClabel);
    EEGf_IClabel = pop_icflag(EEGf_IClabel, [NaN NaN;0.6 1;0.6 1;0.6 1;0.6 1;0.6 1;0.6 1]);
    EEGf_IClabel = pop_subcomp(EEGf_IClabel,find(EEGf_IClabel.reject.gcompreject), 0,0);
    EEGf_IClabel.setname = [nameSET '_IClabel' '_clean'];
    pop_saveset(EEGf_IClabel, 'filename', [nameSET,'_','IClabel','_clean','.set'], 'filepath', pathOUT);
    
%     EEG_WICA = pop_loadset('filename', [nameSET, '_ica','.set'], 'filepath', pathOUT);
%     channs = 1:EEG_WICA.nbchan;
%     [wIC,A,~,~] = wICA(EEG_WICA.data(channs,:), [], 1, 0, EEG_WICA.srate);
%                 artifacts = A*wIC; 
%                 EEGf_WICA = EEG_WICA;
%                 EEGf_WICA.data(channs,:) = EEG_WICA.data(channs,:)-artifacts;
%     EEGf_WICA.setname = [nameSET '_WICA' '_clean'];
%     pop_saveset(EEGf_WICA, 'filename', [nameSET,'_','WICA','_clean','.set'], 'filepath', pathOUT);

end
