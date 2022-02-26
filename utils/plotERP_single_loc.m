function plotERP_single_loc(ERPStruct,figColor,LineW)

    NumofAvailableChan = squeeze(sum(ERPStruct.AllChanStat,2));
    GrandSumPerChan    = squeeze((sum(ERPStruct.AllERP(:,:,:),2)));
 
    ts = -200:1/250*1000:699;
    
    f = figure(5); f.Name = 'ERP Plot'; 
    f.Color ='white'; pause(1); f.Position; 
    set(gcf, 'Position', [100 100 1500, 700]); %<- Set size
    set(gcf, 'renderer', 'painters');

    Labels = {'FP1','FP2','F3','F4','C3','C4','P3','P4','O1','O2','F7','F8',...
    'T7','T8','P7','P8','Fz','Cz','Pz','AFz','CPz','POz'};
    Labels = convertCharsToStrings(Labels);%GEt Labels
    
    %Matrix of Mbrain CAp chan locations for subplot locations
    subplotchloc = ["FP1","2";"FP2","4";"F3","7";"F4","9";"C3","12";...
        "C4","14";"P3","22";"P4","24";"O1","27";"O2","29";"F7","6";...
        "F8","10";"T7","11";"T8","15";"P7","21";"P8","25";"Fz","8";...
        "Cz","13";"Pz","23";"AFz","3";"CPz","18";"POz","28"];
    ch = 0;
    for chpltloc = Labels %Plot per chanel
        ch = ch + 1;
        Gav=GrandSumPerChan(ch,:)/NumofAvailableChan(ch);

        locplt = str2double(subplotchloc(find(chpltloc == subplotchloc),2));
        subplot(6,5,locplt)
        %Plot ERP
        hold on
        plot(ts,Gav,'LineWidth',LineW,'Color',cell2mat(figColor))
        set(gca,'Xtick',[-200 , 0 , 400],'Ytick', [-4 0 6])
        set(gca,'FontUnits','points','FontName','Sans','FontSize',10)
        axis([-200 700 -5 6.2])
        line([0 0], [0 2],'Color',[0.1 0.1 0.1],'LineWidth', 0.8);
        yline(0, 'LineWidth', 1,'Color',[0.1 0.1 0.1],'Alpha', 0.4);
        title(chpltloc)
        
        ax = gca;
        ax.XAxisLocation = 'origin';
        ax.YAxisLocation = 'origin';
        set(gca,'XColor','none','YColor','none','TickDir','in')
        
    end
end