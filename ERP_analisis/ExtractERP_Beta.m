%Inclui la interpolacion para que todos tengan el mismo numero de canales
%Call EEGLAB
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
% Interpolate data help
%EEG_INTP = pop_loadset('D:\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\SB_2021\Beta_PreprocesadoTrim\V1BETA-[2019.10.07-12.55.55]_ica.set');

% Define Paths
datapathin = 'D:\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\SB_2021\Beta_PreprocesadoTrim';
binlistrout = 'D:\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\SB_2021\Historials\StatERP1Data\Binlister.txt'
savepath = 'D:\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\SB_2021\Historials\StatERP5Data_Mark'
%Import wica_clean.set datas
Beta_sets = Get_List(datapathin,'*IClabel_3_clean.set');
%Design filter
FiltERP = designfilt('bandpassiir','FilterOrder',4, ...
'HalfPowerFrequency1',0.1,'HalfPowerFrequency2',60, ...
'DesignMethod','butter','SampleRate',250); 
% For Loop
Vol_size = size(Beta_sets,1);
Names = cell(Vol_size,1);
%%
for vol = 1:Vol_size
    nameSET = char(Beta_sets(vol));
    EEG = pop_loadset('filename',nameSET,'filepath',datapathin);
    
    %EEG = pop_interp(EEG, EEG_INTP.chanlocs, 'spherical');
    
    %EEG.data = single(filtfilt(FiltERP, double(EEG.data')))';
    Names(vol) = {nameSET(1:end-20)};
    
    erpname = char(Names(vol));

    % (2) Create EventList
    %Creates the EVENTLIST structure with the event information
    % extracted and reorganized from EEG.event (default) or from an external
    % list (text file). The EVENTLIST structure is attached to the EEG
    % structure.
    % 'AlphanumericCleaning'  - Delete alphabetic character(s) from alphanumeric event codes (if any). 'on'/'off'
    % 'BoundaryNumeric'       - Numeric code that string code is to be converted to
    % 'BoundaryString'        - Name of string code that is to be converted
    %'Eventlist'             - name (and path) of eventlist text file to export.
EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on',...
    'BoundaryNumeric', { -99 },...
    'BoundaryString', { 'boundary' });
    % (3) Assign events to bins
    % 'BDF'         - name of the text file containing your bin descriptions (formulas).
    % 'SendEL2'     - once binlister ends its work, you can send a copy of the resulting EVENTLIST structure to:
    %                   'Text'           - send to text file
    %                    'EEG'            - send to EEG structure
    %                    'EEG&Text'       - send to EEG & text file
    %                    'Workspace'      - send to Matlab workspace,
    %                    'Workspace&Text' - send to Workspace and text file,
    %                    'Workspace&EEG'  - send to workspace and EEG,
    %                    'All'- send to all of them.
    % 'IndexEL'     - EVENTLIST's index (in case of multiple EVENTLISTs)
EEG  = pop_binlister( EEG , 'BDF', binlistrout);
    % (4) Interactively epoch bin-based trials
EEG = pop_epochbin( EEG , [-200.0  700.0],  'pre');
    % (5) remove epochs with 75 uV peak to peak defections
EEG  = pop_artmwppth( EEG , 'Channel',  1:22, 'Flag',  1, 'Threshold',  75, ... 
    'Twindow',[ -200 596], 'Windowsize',  200, 'Windowstep', 100, 'Review', 'no');
    % (5) Averages bin-epoched EEG dataset(s)
ERP = pop_averager( EEG , 'Criterion', 'good',...
    'DQ_flag', 1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
    % (6) Saves ERP dataset
ERP.ref = 'A1 A2'
% pop_savemyerp(ERP, 'erpname', erpname, ...
%     'filename', ['Beta_', erpname , '.erp'], ...
%     'filepath', savepath,...
%     'Warning', 'on');
end
%% Import Study Volunteers names

fs = 250;
FiltERP = designfilt('lowpassiir','FilterOrder',4, ...
'HalfPowerFrequency',60, ...
'DesignMethod','butter','SampleRate',fs); 
Vol_size = size(BetaMark_Sets,1);
AllERP_IFs = zeros(22,Vol_size,225); AllERP_Fs = zeros(22,Vol_size,225);
ALLITC_IFs = zeros(22,Vol_size,225); ALLITC_Fs = zeros(22,Vol_size,225);
AllChanStat_IFs = zeros(22,Vol_size); AllChanStat_Fs = zeros(22,Vol_size);
Names = cell(Vol_size,1);
parfor vol = 1:Vol_size
    nameSET = char(BetaMark_Sets(vol));
    EEG = pop_loadset('filename',nameSET,'filepath',pathin);
    EEG.data = filtfilt(FiltERP, double(EEG.data'))';
    Names(vol) = {nameSET(1:end)};
    [AllERP_IFs(:,vol,:),ALLITC_IFs(:,vol,:),AllChanStat_IFs(:,vol)] = GetERP_ITC10Hz(EEG,'33285');
    [AllERP_Fs(:,vol,:),ALLITC_Fs(:,vol,:),AllChanStat_Fs(:,vol)] = GetERP_ITC10Hz(EEG,'33286');
end
%% Save all data as struct
BetaStruct =  struct;
BetaStruct.Note_ERPITC = '22chanels 25volunteers 225samples';
BetaStruct.Note_AllChanStat = 'Chanels that were not rejected';
BetaStruct.channels = {'FP1','FP2','F3','F4','C3','C4',...
        'P3','P4','O1','O2','F7','F8','T7','T8','P7','P8','Fz','Cz','Pz',...
        'AFz','CPz','POz'};
BetaStruct.Names = Names;
BetaStruct.IFstim.AllERP = AllERP_IFs;
BetaStruct.IFstim.ALLITCP = ALLITC_IFs;
BetaStruct.IFstim.AllChanStat = AllChanStat_IFs;
BetaStruct.Fstim.AllERP = AllERP_Fs;
BetaStruct.Fstim.ALLITCP = ALLITC_Fs;
BetaStruct.Fstim.AllChanStat = AllChanStat_Fs;
