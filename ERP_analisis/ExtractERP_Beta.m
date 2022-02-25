%Call EEGLAB
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
%%
%Define Paths
datapathin = 'D:\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\SB_2021\Beta_PreprocesadoTrim';
binlistrout = 'D:\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\SB_2021\Historials\StatERP1Data\Binlister.txt'
savepath = 'D:\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\SB_2021\Historials\StatERP1Data'
%Import wica_clean.set datas
BetaWica_Sets = Get_List(datapathin,'*WICA_clean.set');
%Design filter
fs = 250;
FiltERP = designfilt('bandpassiir','FilterOrder',4, ...
'HalfPowerFrequency1',0.1,'HalfPowerFrequency2',60, ...
'DesignMethod','butter','SampleRate',fs); 
% For Loop
Vol_size = size(BetaWica_Sets,1);
Names = cell(Vol_size,1);
for vol = 1:Vol_size
    nameSET = char(BetaWica_Sets(vol));
    EEG = pop_loadset('filename',nameSET,'filepath',datapathin);
    EEG.data = single(filtfilt(FiltERP, double(EEG.data')))';
    Names(vol) = {nameSET(1:end-37)};
    erpname = char(Names(vol))

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
EEG  = pop_binlister( EEG , 'BDF', binlistrout)
    % (4) Interactively epoch bin-based trials
EEG = pop_epochbin( EEG , [-200.0  600.0],  'pre');
    % (5) Averages bin-epoched EEG dataset(s)
ERP = pop_averager( EEG , 'Criterion', 'good',...
    'DQ_flag', 1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
    % (6) Saves ERP dataset
pop_savemyerp(ERP, 'erpname', erpname, ...
    'filename', [erpname , '.erp'], ...
    'filepath', savepath,...
    'Warning', 'on');
end