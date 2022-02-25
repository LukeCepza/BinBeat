pathSET = 'D:\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\SB_2021\Beta'
V_Sets = Get_List(pathSET,'*.gdf')
nameSET = char(V_Sets(1))
pathOUT = 'D:\Kevin_Cepeda\Matlab\NewMatLabData\Neuroengineering\SB_2021\Beta_PreprocesadoTrim'
ICAname = 'WICA'
nameSET = nameSET(1:end-4)
EEG = preproEEG_SB(pathSET,nameSET,pathOUT,ICAname)
