pathSET = 'C:\Users\lkcep\Documents\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\SB_2021\Alpha';
pathOUT = 'C:\Users\lkcep\Documents\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\SB_2021\Alpha_PreprocesadoTrim';
V_Sets = Get_List(pathSET,'*.gdf');

for i = 1:size(V_Sets,1)
    nameSET = char(V_Sets(i));
    nameSET = nameSET(1:end-4);
    preproEEG_SB_3decom(pathSET,nameSET,pathOUT);
    disp("Finished: "+i+"/3")
end
    disp("Finished")
