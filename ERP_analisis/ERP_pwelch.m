[ERPsAll_Beta, freqs] = ERP_ns_pwelch(ERPsAll_Beta);
[ERPsAll_Theta,~] = ERP_ns_pwelch(ERPsAll_Theta);
%%
[pxx_if_Beta,pxxc_if_Beta,pxx_f_Beta,pxxc_f_Beta] = ERP_ns_pwelch_GA(ERPsAll_Beta);
[pxx_if_Theta,pxxc_if_Theta,pxx_f_Theta,pxxc_f_Theta] = ERP_ns_pwelch_GA(ERPsAll_Theta);
%%
ch = 1
plot(freqs,10*log10(pxx_f_Beta(:,ch)))
hold on
plot(freqs,10*log10(pxxc_f_Beta(:,:,ch)),'-.')

plot(freqs,10*log10(pxx_f_Theta(:,ch)))
plot(freqs,10*log10(pxxc_f_Theta(:,:,ch)),'-.')
hold off

xlim([0 65])
xlabel('Frequency (Hz)')
ylabel('PSD (dB/Hz)')
title('Welch Estimate with 95%-Confidence Bounds')

%%
subposition = [2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14,...
    15, 18, 21, 22, 23, 24, 25, 27, 28, 29];
f =  freqs;
% AvgByVol_R = mean(pxxr_Reposo,1);    %potencias en v^2
% AvgByVol_R = reshape(AvgByVol_R , [22,126]);
% AvgByVol_R = pow2db(AvgByVol_R);    %potencias en dB
% AvgByVol_R = AvgByVol_R(:,1:31);

AvgByVol_T = pxx_f_Theta'    %potencias en v^2
%AvgByVol_T = reshape(AvgByVol_T , [22,126]);
AvgByVol_T = pow2db(AvgByVol_T);    %potencias en dB
AvgByVol_T = AvgByVol_T(:,1:60);

AvgByVol_B = pxx_f_Beta'%mean(pxxr_Beta,1);    %potencias en v^2
%AvgByVol_B = reshape(AvgByVol_B , [22,126]);
AvgByVol_B = pow2db(AvgByVol_B);    %potencias en dB
AvgByVol_B = AvgByVol_B(:,1:60);

max_lim = max(max([AvgByVol_T AvgByVol_B]));
min_lim = min(min([AvgByVol_T AvgByVol_B]));
figure (1)
clf

for i = 1:22
    if (i <= 20) 
        subplot(6,5,subposition(i)); 
        %plot(f(1:31),AvgByVol_R(i,:),'--k','LineWidth',1.5); hold on
        plot(f(1:60),AvgByVol_T(i,:),'r','LineWidth',1.5); hold on 
        plot(f(1:60),AvgByVol_B(i,:),'b','LineWidth',1.5); hold on 
        plot(f(1:60),zeros(60),'--black','LineWidth',1); grid on
        %txt = num2str(char(locations(i).labels));
        %text(2,6,txt,'FontSize',16)
        ax = gca; 
        ax.YTick = linspace(2,21,3); ylim([floor(min_lim),ceil(max_lim)]);
        ax.XTick = 0:3:30; xlim([0,32]);
        ax.XTickLabelRotation = 45;
        a = get(gca,'XTickLabel');
        set(gca,'XTickLabel',a,'fontsize',11)
        if i == 9
            ylabel('Decibels (dB)','FontSize',16,'FontWeight','bold',...
                'Position', [-7, -4]);            
        end
    else                    % Movimiento de los subplots inferiores
        subplot(6,5,subposition(i)); 
        %plot(f(1:31),AvgByVol_R(i,:),'--k','LineWidth',1.5); hold on
        plot(f(1:60),AvgByVol_T(i,:),'r','LineWidth',1.5); hold on 
        plot(f(1:60),AvgByVol_B(i,:),'b','LineWidth',1.5); hold on 
        plot(f(1:60),zeros(60),'--black','LineWidth',1); grid on
         %txt = num2str(char(locations(i).labels));
         %text(2,6,txt,'FontSize',16)
         ax = gca; 
         ax.YTick = linspace(2,22,3); ylim([floor(min_lim),ceil(max_lim)+1]);
         ax.XTick = 0:3:30; xlim([0,32]);
         ax.XTickLabelRotation = 45;     
         a = get(gca,'XTickLabel');
         set(gca,'XTickLabel',a,'fontsize',11)
    end
    patch([4, 8, 8, 4], [2, 2, 22, 22], 'blue',...
        'LineStyle','none','FaceAlpha', 0.12); hold on
    patch([8, 13, 13, 8], [2, 2, 22, 22], 'green',...
        'LineStyle','none','FaceAlpha', 0.12); hold on
    patch([13, 30, 30, 13], [2, 2, 22, 22], 'red',...
        'LineStyle','none','FaceAlpha', 0.12); 
end

h = colorbar;
set(h,'Position', [0.22, 0.07, 0.02, 0.1],'FontSize',12,...
    'TicksMode','Manual','TickLength',0.02); 
colorTitleHandle = get(h,'Title');
titleString = strcat(['\bf','EEG Bands']);
set(colorTitleHandle ,'String',titleString);
yourColorMap = colorcube(128);
colormap(yourColorMap([60,48,74],:));
legend({strcat(['\it','Baseline']),strcat(['\it','Theta BB']),...
    strcat(['\it','Beta BB'])},'Box','off',...
    'Position',[0.83 0.87 0.01 0],'FontSize', 11);
figure(1)
% %Eje X: Frequency (Hz)
annotation('textbox',[.46 0 .2 .08],'String',strcat(['\bf','Frequency (Hz)']),...
    'EdgeColor','none','FontSize',16) 
%Barra Colores: 
annotation('textbox',[0.14 0.08 .2 .1],'String',strcat(['\it','Theta (4-8 Hz)']),...
    'EdgeColor','none','FontSize',12) 
annotation('textbox',[0.133 0.045 .2 .1],'String',strcat(['\it','Alpha (8-13 Hz)']),...
    'EdgeColor','none','FontSize',12) 
annotation('textbox',[0.131 0.01 .2 .1],'String',strcat(['\it','Beta (13-30 Hz)']),...
    'EdgeColor','none','FontSize',12) 
annotation('textbox',[0.35 0.9 .8 .1],'String',...
    strcat(['\it','PSD of Baseline, Theta BB and Beta BB']),...
    'EdgeColor','none','FontSize',18)
%% This function uses the new structure format
function [ERP_ns,f] = ERP_ns_pwelch(ERP_ns)
    %prealocate psd data
    pxx_if = zeros(113,22);
    pxx_f = zeros(113,22);
    for vol = 1:length(ERP_ns)
        %concatenate all data into a single array
        data_if = reshape([ERP_ns(vol).erp_if],22,[]);
        data_f = reshape([ERP_ns(vol).erp_f],22,[]);
        for ch = 1:22
            %calculate PSD usign welch method over using a hamming window
            %over the whole data.
            [pxx_if(:,ch),f] = pwelch(data_if(ch,:),225,0,225,250);
            [pxx_f(:,ch),~] = pwelch(data_f(ch,:),225,0,225,250);
        end
    ERP_ns(vol).pwelch_if = pxx_if; 
    ERP_ns(vol).pwelch_f = pxx_f;
    end
end

function [pxx_if,pxxc_if,pxx_f,pxxc_f] = ERP_ns_pwelch_GA(ERP_ns)
    pxx_if = zeros(113,22);
    pxx_f = zeros(113,22);
    pxxc_if = zeros(113,2,22);
    pxxc_f = zeros(113,2,22);
    data_if = reshape([ERP_ns(:).ga_erp_if],22,[]);
    data_f = reshape([ERP_ns(:).ga_erp_f],22,[]);
    for ch = 1:22
        %calculate PSD usign welch method over using a hamming window
        %over the whole data.
        [pxx_if(:,ch),~,pxxc_if(:,:,ch)] = pwelch(data_if(ch,:),225,0,225,250,'ConfidenceLevel',0.95);
        [pxx_f(:,ch),~,pxxc_f(:,:,ch)] = pwelch(data_f(ch,:),225,0,225,250,'ConfidenceLevel',0.95);
    end
end