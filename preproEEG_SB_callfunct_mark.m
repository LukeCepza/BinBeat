pathSET = 'D:\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\SB_2021\Theta';
pathOUT = 'D:\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\SB_2021\Theta_PreprocesadoTrim';
V_Sets = Get_List(pathSET,'*.gdf');

tic
parfor i = 1:size(V_Sets,1)
    nameSET = char(V_Sets(i));
    nameSET = nameSET(1:end-4);
    preproEEG_SB_3(pathSET,nameSET,pathOUT);
    disp("Finished: "+i+"/3")
end
    disp("Finished")
toc

%I strongly encorage to use parallel processing as it drastically reduces
%the processing time: Elapsed time was 682.114044 seconds for 25 datasets.