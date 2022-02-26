function plotERP_central(ERPStruct,figColor,row,LineW)
%see central_line_mua.xlm
    NumofAvailableChan = squeeze(sum(ERPStruct.AllChanStat,2));
    GrandSumPerChan    = squeeze((sum(ERPStruct.AllERP(:,:,:),2)));
 
    ts = -200:1/250*1000:699;
    
    f = figure(5); f.Name = 'ERP Plot'; 
    f.Color ='white'; pause(1); f.Position; 
    set(gcf, 'Position', [100 100 1500, 700]); %<- Set size
    set(gcf, 'renderer', 'painters');
    
    %Matrix of Mbrain CAp chan locations for subplot locations
    Chanidex = [20,17,18,21,19,22];
    LChNa = ["AFz","Fz","Cz","CPz","Pz","POz"];
    
    ch = 0;
    for chpltloc = LChNa %Plot per chanel
        ch = ch + 1;
        Gav=GrandSumPerChan(Chanidex(ch),:)/NumofAvailableChan(Chanidex(ch));
        subplot(3,6,ch+(row-1)*6)
        %Plot ERP
        hold on
        plot(ts,Gav,'LineWidth',LineW,'Color',cell2mat(figColor))
        set(gca,'Xtick',[-200 , 0 , 400],'Ytick', [-4 0 6])
        set(gca,'FontUnits','points','FontName','Sans','FontSize',10)
        axis([-200 700 -5 6.2])
        line([0 0], [0 2],'Color',[0.1 0.1 0.1],'LineWidth', 0.8);
        yline(0, 'LineWidth', 1,'Color',[0.1 0.1 0.1],'Alpha', 0.4);
%         yline(0);
        title(chpltloc)
%         if drawaxisboold
%             drawaxis(gca, 'x', -5, 'movelabel', 1)
%             drawaxis(gca, 'y', 0, 'movelabel', 1)
%         end
        ax = gca;
        ax.XAxisLocation = 'origin';
        ax.YAxisLocation = 'origin';
        set(gca,'XColor','none','YColor','none','TickDir','in')

    end