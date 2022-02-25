function EEG=preproEEG_SB(pathSET,nameSET,pathOUT,ICAname)
%%By Alma Socorro Torres Torres
%ICAname 'MARA'  or 'IClabel'
%
[ALLEEG,~,CURRENTSET]=eeglab;
%(1)Load .set
          %EEG = pop_loadset('filename', nameSET, 'filepath', pathSET);
          EEG = pop_biosig(strcat(pathSET,'\',nameSET,'.gdf'));

          nameSET=replace(nameSET,'.set','');
%(1.2) 
          EEG = pop_chanedit(EEG, 'lookup','D:\\Kevin_Cepeda\\Matlab\\NewMatLabData\\Neuroengineering\\SonidosBinaurales\\mBrain_24ch_locations.elp');
%(1.3)
          EEG = pop_select( EEG, 'time',[1170 floor(size(EEG.times,2)/EEG.srate)] );
%(1.4)
          EEG = pop_reref( EEG, [20 21] );
%(2)Remove baseline
          EEG.data = rmbase(EEG.data);
%(3)Line noise
          EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:EEG.nbchan] ,...
              'computepower',1,'linefreqs',60,'normSpectrum',0,'p',0.05...
              ,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype',...
              'Channels','tau',100,'verb',1,'winsize',4,'winstep',1);
          EEG.setname = [nameSET '_raw'];
          pop_saveset(EEG, 'filename', [nameSET 'raw'], 'filepath', pathOUT); 
%(5)Remove occasional large-amplitude noise/artifacts
          [EEG,~,EEGbur] = clean_artifacts(EEG,'ChannelCriterion',0.65);
          EEGbur.setname = [nameSET '_bur'];
          pop_saveset(EEGbur, 'filename', [nameSET '_bur'], 'filepath', pathOUT); 
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
                EEG = pop_saveset(EEG, 'filename', [nameSET, '_ica','.set'], 'filepath', pathOUT); 
%(8)Remove ICs artifacts(ICA)
ICApp=ICAname;
if strcmp(ICApp,'MARA')
    pop_loadset('filename', [nameSET, '_ica','.set'], 'filepath', pathOUT);
    [~,EEGf,~] =processMARA( ALLEEG,EEG,CURRENTSET);
    EEGf = pop_subcomp(EEGf); 
elseif strcmp(ICApp,'IClabel')
    EEG = pop_loadset('filename', [nameSET, '_ica','.set'], 'filepath', pathOUT);
    EEGf= iclabel(EEG);
    EEGf = pop_icflag(EEGf, [NaN NaN;0.6 1;0.6 1;0.6 1;0.6 1;0.6 1;0.6 1]);
    EEGf = pop_subcomp(EEGf);
elseif strcmp(ICApp,'WICA')
    ICApp='WICA';
    EEG = pop_loadset('filename', [nameSET, '_ica','.set'], 'filepath', pathOUT);
    channs = 1:EEG.nbchan;
    [wIC,A,~,~] = wICA(EEG.data(channs,:), [], 1, 0, EEG.srate);
                artifacts = A*wIC; 
                EEGf = EEG;
                EEGf.data(channs,:) = EEG.data(channs,:)-artifacts;
end
     EEGf.setname = [nameSET ICApp 'clean'];
     EEGf = pop_saveset(EEGf, 'filename', [nameSET,'_',ICAname,'_clean','.set'], 'filepath', pathOUT);
     EEG = EEGf;
end
