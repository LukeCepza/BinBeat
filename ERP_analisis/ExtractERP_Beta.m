%Inclui la interpolacion para que todos tengan el mismo numero de canales
%Call EEGLAB
if exist('ALLCOM','var') == 0
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
end
% Define Paths
datapathin = 'D:\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\SB_2021\Beta_PreprocesadoTrim';
binlistrout = 'D:\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\SB_2021\Historials\StatERP1Data\Binlister.txt';
savepath = 'D:\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\SB_2021\Historials\StatERP5Data_Mark';
%Import wica_clean.set datas
Beta_sets = Get_List(datapathin,'*IClabel_3_clean.set');
%Design filter
FiltERP = designfilt('bandpassiir','FilterOrder',4, ...
'HalfPowerFrequency1',0.1,'HalfPowerFrequency2',60, ...
'DesignMethod','butter','SampleRate',250); 
% For Loop
Vol_size = size(Beta_sets,1);
Names = cell(Vol_size,1);
Chanidex = 1:22;
LTM = ["33285","33286"]; %f , IF
ERPsAll_Beta(Vol_size).name = 1
for vol = 1:Vol_size
    nameSET = char(Beta_sets(vol));
    EEG = pop_loadset('filename',nameSET,'filepath',datapathin);
    ERPsAll_Beta(vol).name = nameSET(1:3);
    %EEG = pop_interp(EEG, EEG_INTP.chanlocs, 'spherical');
    %filtering
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
        % (4) Interactively epoch bin-based trials with pre baseline
        % correction
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
    
    %Generate structure with all 

    %Exctract all bins
    bina_all = int16([EEG.EVENTLIST.eventinfo(:).bini]);
    valCount = (1 ~= hist( single([EEG.event(:).bepoch]),unique(single([EEG.event(:).bepoch])-1) ));
    bina = bina_all(bina_all > 0); %Remove borders
    ERPsAll_Beta(vol).total_stim = length(bina); %total of bins (non filt if & f)
    ev_if = (bina == 1);
    ev_f = (bina == 2);
    %filter bins: Remove bins rejected bins 1 or 2
    flags = (int16([EEG.EVENTLIST.eventinfo(:).flag]));
    filt_bina = bina - int16(logical(flags(bina_all > 0))+logical(valCount))*3 ;
    ev_filt_if = (filt_bina == 1);
    ev_filt_f = (filt_bina == 2);
    %Save structures
    ERPsAll_Beta(vol).f = sum(ev_filt_f);
    ERPsAll_Beta(vol).if = sum(ev_filt_if);
    ERPsAll_Beta(vol).rej_f = sum(ev_f) - sum(ev_filt_f);
    ERPsAll_Beta(vol).rej_if = sum(ev_if) - sum(ev_filt_if);
    ERPsAll_Beta(vol).erp_f =  squeeze(EEG.data(:,:,ev_filt_f));
    ERPsAll_Beta(vol).erp_if =  squeeze(EEG.data(:,:,ev_filt_if));
    ERPsAll_Beta(vol).ga_erp_f = ERP.bindata(:,:,1);
    ERPsAll_Beta(vol).ga_erp_if = ERP.bindata(:,:,2);
end