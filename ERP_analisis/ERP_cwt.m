% Compute time frecuency power over all trials (ERSP)
% (1) Compute cwt over epoch 
% (2) Sum to time-freq array
% (3) Repeat for all trials for all volunteers
% (4) Divide over total number of trials
% (5) Convert complex to absolute value
% (6) Store at summary ERSP [times,freq,chns]

% Compute ITC over all trials
% (1) Compute cwt over epoch 
% (2) Sum to time-freq array
% (3) Repeat for all trials for all volunteers
% (4) Divide over total number of trials
% (5) Convert complex to angle value
% (6) Store at summary ITC [times,freq,chns]
summary = ns_freqpow(ERPsAll_Theta,ERPsAll_Beta,summary, 250);
%% Plot values ITC ga
plot_ITC(summary.ITC_theta_if,5)
plot_ITC(summary.ITC_beta_if,6)
%% Compute time frequeny power over grand averaged ERPs (ERSP)
% (1) Compute cwt over subject
% (2) Sum to time-freq array
% (3) Repeat for for all volunteers
% (4) Divide over total number of volunteers
% (5) Convert complex to absolute value
% (6) Store at summary ERSP [times,freq,chns]

% Compute ITC over averaged data
% (1) Compute cwt over subject
% (2) Sum to time-freq array
% (3) Repeat for for all volunteers
% (4) Divide over total number of volunteers
% (5) Convert complex to angle value
% (6) Store at summary ERSP [times,freq,chns]
summary = ns_freqpow_ga(ERPsAll_Theta,ERPsAll_Beta,summary,250)
%% Plot values ITC ga
plot_ITC(summary.ITC_theta_if_ga,7)
plot_ITC(summary.ITC_beta_if_ga,8)
%% Compute time frequency power over gran grand averaed ERPs 
% (1) Compute cwt   
% (2) Convert complex to absolute value
summary =  ns_freqpow_gga(summary,250);
%%
ERPsAll_Beta = ns_allcwt(ERPsAll_Beta,250);
ERPsAll_Theta = ns_allcwt(ERPsAll_Theta,250);
%%
summary = ns_gacwt(ERPsAll_Beta,ERPsAll_Theta,summary,250);
%% Perform statistical analysis using CircStat Toolbox
addpath('D:\Kevin_Cepeda\shared_git\neuro\erp_data\CircStat')
p_vals = zeros(22,50,225);
Beta_rads = reshape([ERPsAll_Beta.ITC_if],22,50,225,[]) + pi;
Theta_rads = reshape([ERPsAll_Theta.ITC_if],22,50,225,[]) + pi;
for ch = 1:22
    for f = 1:50
        for t = 1:225
            Beta_rad = squeeze(Beta_rads(ch,f,t,:));
            Theta_rad = squeeze(Theta_rads(ch,f,t,:));
            p_vals(ch,f,t) = circ_wwtest(Theta_rad,Beta_rad);
        end
    end
end

%%
summary = ns_ggacwt(summary,250);
times = linspace(-200,700,225);
freq = [92.0701114612480;85.9044515278156;80.1516873953264;74.7841686671844;...
        69.7760966111363;65.1034001588498;60.7436202094295;56.6758016807796;52.8803927899647;...
        49.3391510784621;46.0350557306240;42.9522257639078;40.0758436976632;37.3920843335922;...
        34.8880483055682;32.5517000794249;30.3718101047147;28.3379008403898;26.4401963949823;...
        24.6695755392311;23.0175278653120;21.4761128819539;20.0379218488316;18.6960421667961;...
        17.4440241527841;16.2758500397125;15.1859050523574;14.1689504201949;13.2200981974912;...
        12.3347877696155;11.5087639326560;10.7380564409770;10.0189609244158;9.34802108339806;...
        8.72201207639204;8.13792501985623;7.59295252617869;7.08447521009746;6.61004909874559;...
        6.16739388480777;5.75438196632801;5.36902822048848;5.00948046220791;4.67401054169903;...
        4.36100603819602;4.06896250992812;3.79647626308935;3.54223760504873;3.30502454937280;3.08369694240389];

% specify baseline periods for dB-normalization
baseline_windows = [ -200 0];
% convert baseline time into indices
f = figure(2); f.Name = 'Wavelet Plot'; 
f.Color ='white'; pause(1); f.Position; 
%set(gcf, 'Position', [100 100 1500, 700]); %<- Set size
set(gcf, 'renderer', 'painters')
    
baseidx = reshape( dsearchn(times',baseline_windows(:)), [],2);
Labels = {'FP1','FP2','F3','F4','C3','C4','P3','P4','O1','O2','F7','F8',...
'T7','T8','P7','P8','Fz','Cz','Pz','AFz','CPz','POz'};

subplotchloc = ["FP1","2";"FP2","4";"F3","7";"F4","9";"C3","12";...
        "C4","14";"P3","22";"P4","24";"O1","27";"O2","29";"F7","6";...
        "F8","10";"T7","11";"T8","15";"P7","21";"P8","25";"Fz","8";...
        "Cz","13";"Pz","23";"AFz","3";"CPz","18";"POz","28"];
    ch = 0;
    
for chpltloc = Labels
    ch = ch + 1;
    locplt = str2double(subplotchloc(find(chpltloc == subplotchloc),2));
    subplot(6,5,locplt)

    wtm =  squeeze(abs(summary.Beta_gga_f(ch,:,:)));
    baseline = squeeze(mean(wtm(:,baseidx(1):baseidx(2)),2)); 
    wtm = 10*log10(wtm./repmat(baseline,[1,size(times,2)]));
    contourf(times,freq,squeeze(abs(summary.Beta_gga_if(ch,:,:))),40,'r','linecolor', 'none');
    set(gca,"ylim", [3.1,30], "xlim", [-200 640],'FontUnits','points','FontName','Sans','FontSize',12)
    %xlabel('Time(ms)')
    xline(0,'--r' );
    yline(10,'--b' );set(gca,'YScale', 'log', 'Xtick',[nan])%[-200 , 0 , 400])
    title(Labels(ch))
    ylimu = .8; %max(abs(summary.Beta_gga_f),[],'all')-3*std(summary.Beta_gga_f),[],'all');
    ylimi =0; %min(abs(summary.Beta_gga_f),[],'all')+3*std(abs(summary.Beta_gga_f),[],'all');
    caxis([ylimi,ylimu])
    set(gca,'YScale', 'log')
end 

%New struct grand grand average ERP time frequency cwt
function summary = ns_ggacwt(summary,fs)
    %frecuent
    data = [summary.erp_beta_f];
    ang = zeros(22,50,225);
    for ch = 1:22
        wt = cwt(data(ch,:),'amor',fs);
        ang(ch,:,:) = abs(wt);
        
    end
    summary.Beta_gga_f = ang;
    
        %frecuent
    data = [summary.erp_beta_if];
    ang = zeros(22,50,225);
    for ch = 1:22
        wt = cwt(data(ch,:),'amor',fs);
        ang(ch,:,:) = abs(wt);

    end
    summary.Beta_gga_if = ang;
    
        %frecuent
    data = [summary.erp_theta_f];
    ang = zeros(22,50,225);
    for ch = 1:22
        wt = cwt(data(ch,:),'amor',fs);
        ang(ch,:,:) = abs(wt);

    end
    summary.Theta_gga_f = ang;
    
        %frecuent
    data = [summary.erp_theta_if];
    ang = zeros(22,50,225);
    for ch = 1:22
        wt = cwt(data(ch,:),'amor',fs);
        ang(ch,:,:) = abs(wt);

    end
    summary.Theta_gga_if = ang;
end

%New struct grand averaged per volunteer ERP 
function summary = ns_gacwt(ERPns1,ERPns2,summary,fs)
    len = size(ERPns1,2);
    %frecuent
    data = reshape([ERPns1.ga_erp_f],22,225,[]);
    ITC = zeros(22,50,225,len);
    for ch = 1:22
        for vol = 1:len
            wt = cwt(data(ch,:,vol),'amor',fs);
            wt = reshape(wt,1,50,225);
            ITC(ch,:,:,vol) = wt./abs(wt);
        end
    end
    summary.Beta_ITC_f = ITC;
    %infrequent
    data = reshape([ERPns1.ga_erp_if],22,225,[]);
    ITC = zeros(22,50,225,len);
    for ch = 1:22
        for vol = 1:len
            wt = cwt(data(ch,:,vol),'amor',fs);
            wt = reshape(wt,1,50,225);
            ITC(ch,:,:,vol) = wt./abs(wt);
        end
    end
    summary.Beta_ITC_if = ITC;
    
    len = size(ERPns2,2);
    %frecuent
    data = reshape([ERPns2.ga_erp_f],22,225,[]);
    ITC = zeros(22,50,225,len);
    for ch = 1:22
        for vol = 1:len
            wt = cwt(data(ch,:,vol),'amor',fs);
            wt = reshape(wt,1,50,225);
            ITC(ch,:,:,vol) = wt./abs(wt);
        end
    end
    summary.Theta_ITC_f = ITC;
    %infrequent
    data = reshape([ERPns2.ga_erp_if],22,225,[]);
    ITC = zeros(22,50,225,len);
    for ch = 1:22
        for vol = 1:len
            wt = cwt(data(ch,:,vol),'amor',fs);
            wt = reshape(wt,1,50,225);
            ITC(ch,:,:,vol) = wt./abs(wt);
        end
    end
    summary.Theta_ITC_if = ITC;
    
end



function ERPns = ns_allcwt(ERPns,fs)
    len = size(ERPns,2);
    parfor vol = 1:len     
        %frecuent
        data = ERPns(vol).erp_f;
        ITC = zeros(22,50,225);
        for ch = 1:22
            for trial = 1:ERPns(vol).f
                wt = cwt(data(ch,:,trial),'amor',fs);
                ITC(ch,:,:) = ITC(ch,:,:) + reshape(wt,1,50,225);
            end
            ITC(ch,:,:) = ITC(ch,:,:)/ERPns(vol).f;
        end
        ERPns(vol).ITC_f = angle([ITC]);
        disp("status: "+vol+ " out of "+ len+ "f")
        %infrequent
        data = ERPns(vol).erp_if;
        ITC = zeros(22,50,225);
        for ch = 1:22
            for trial = 1:ERPns(vol).if
                wt = cwt(data(ch,:,trial),'amor',fs);
                ITC(ch,:,:) = ITC(ch,:,:) + reshape(wt,1,50,225);
            end
            ITC(ch,:,:) = ITC(ch,:,:)/ERPns(vol).if;
        end
        ERPns(vol).ITC_if = angle([ITC]);
        disp("status: "+vol+ " out of "+ len+ "if")
    end 
end

% %%
% % specify baseline periods for dB-normalization
% baseline_windows = [ -200 0];
% baseidx = reshape( dsearchn(times',baseline_windows(:)), [],2);
% 
% function plot_cwt(4DArray, plotname = 'Wavelet Plot')
% 
%     times = linspace(-260,640,225);
%     freq = [92.0701114612480;85.9044515278156;80.1516873953264;74.7841686671844;...
%             69.7760966111363;65.1034001588498;60.7436202094295;56.6758016807796;52.8803927899647;...
%             49.3391510784621;46.0350557306240;42.9522257639078;40.0758436976632;37.3920843335922;...
%             34.8880483055682;32.5517000794249;30.3718101047147;28.3379008403898;26.4401963949823;...
%             24.6695755392311;23.0175278653120;21.4761128819539;20.0379218488316;18.6960421667961;...
%             17.4440241527841;16.2758500397125;15.1859050523574;14.1689504201949;13.2200981974912;...
%             12.3347877696155;11.5087639326560;10.7380564409770;10.0189609244158;9.34802108339806;...
%             8.72201207639204;8.13792501985623;7.59295252617869;7.08447521009746;6.61004909874559;...
%             6.16739388480777;5.75438196632801;5.36902822048848;5.00948046220791;4.67401054169903;...
%             4.36100603819602;4.06896250992812;3.79647626308935;3.54223760504873;3.30502454937280;3.08369694240389];
% 
%     % convert baseline time into indices
%     f = figure(2); f.Name = plotname; 
%     f.Color ='white'; pause(1); f.Position; 
%     %set(gcf, 'Position', [100 100 1500, 700]); %<- Set size
%     set(gcf, 'renderer', 'painters')
% 
%     Labels = {'FP1','FP2','F3','F4','C3','C4','P3','P4','O1','O2','F7','F8',...
%     'T7','T8','P7','P8','Fz','Cz','Pz','AFz','CPz','POz'};
% 
%     subplotchloc = ["FP1","2";"FP2","4";"F3","7";"F4","9";"C3","12";...
%             "C4","14";"P3","22";"P4","24";"O1","27";"O2","29";"F7","6";...
%             "F8","10";"T7","11";"T8","15";"P7","21";"P8","25";"Fz","8";...
%             "Cz","13";"Pz","23";"AFz","3";"CPz","18";"POz","28"];
%         ch = 0;
%     for chpltloc = Labels
%         ch = ch + 1;
%         locplt = str2double(subplotchloc(find(chpltloc == subplotchloc),2));
%         subplot(6,5,locplt)
% 
%         wtm =  squeeze(p_vals(ch,:,:));
%         %baseline = squeeze(mean(wtm(:,baseidx(1):baseidx(2)),2)); 
%         %wtm = 10*log10(wtm./repmat(baseline,[1,size(times,2)]));
%         contourf(times,freq,2-squeeze(p_vals(ch,:,:)));
%         set(gca,"ylim", [3.1,30], "xlim", [-200 640],'FontUnits','points','FontName','Sans','FontSize',12)
%         %xlabel('Time(ms)')
%         xline(0,'--r' );
%         yline(10,'--b' );set(gca,'YScale', 'log', 'Xtick',[nan])%[-200 , 0 , 400])
%         title(Labels(ch))
%         ylimu = .8;%max(abs(summary.Beta_gga_f),[],'all')-3*std(summary.Beta_gga_f),[],'all');
%         ylimi =0;%min(abs(summary.Beta_gga_f),[],'all')+3*std(abs(summary.Beta_gga_f),[],'all');
%         caxis([0,1])
%         set(gca,'YScale', 'log')
%     end 
% en

%% DEPRECATED 
% [PBI,POP,POS] = ITC_tests(summary);
% function [PBI,POP,POS] = ITC_tests(summary)
%     itc1_u_if = abs(sum(summary.Beta_ITC_if,4))/19;
%     itc2_u_if = abs(sum(summary.Theta_ITC_if,4))/26;
%     itc_u_all = abs(sum(summary.Beta_ITC_if,4) + sum(summary.Theta_ITC_if,4))/45;
%     PBI = (itc1_u_if-itc_u_all).*(itc2_u_if-itc_u_all);
%     POP = itc1_u_if.*itc2_u_if - itc_u_all.*itc_u_all;
%     POS = itc1_u_if + itc2_u_if - 2*itc_u_all;
% end
function summary = ns_freqpow_gga(summary,fs)
    wt = zeros(22,50,225);
    summary.cwt_theta_f_ga = wt; 
    summary.cwt_theta_if_ga = wt;
    summary.cwt_beta_f_ga = wt;
    summary.cwt_beta_if_ga = wt;
    for ch = 1:22
        summary.cwt_theta_f_gga(ch,:,:) = cwt(summary.erp_theta_f(ch,:),'amor',fs); 
        summary.cwt_theta_if_gga(ch,:,:) = cwt(summary.erp_theta_if(ch,:),'amor',fs);
        summary.cwt_beta_f_gga(ch,:,:) = cwt(summary.erp_beta_f(ch,:),'amor',fs);
        summary.cwt_beta_if_gga(ch,:,:) = cwt(summary.erp_beta_if(ch,:),'amor',fs);
    end
end
function summary = ns_freqpow_ga(ERPtheta,ERPbeta,summary,fs)
    wt = zeros(22,50,225);
    ITC = zeros(22,50,225);
    wt_temp = zeros(50,225);
    ITC_temp = zeros(50,225);

%Theta
    lvol = size(ERPtheta,2);
    for ch = 1:22
        for vol = 1:lvol 
            wt_val = cwt(ERPtheta(vol).ga_erp_f(ch,:),'amor',fs);
            wt_temp = wt_temp + wt_val;
            ITC_temp = ITC_temp + exp(1i*angle(wt_val));
        end
        wt(ch,:,:) = wt_temp./lvol;
        ITC(ch,:,:) = abs(ITC_temp./lvol);
        ITC_temp = zeros(50,225);
        wt_temp = zeros(50,225);

    end
    summary.cwt_theta_f_ga = wt;
    summary.ITC_theta_f_ga = ITC;
    
    for ch = 1:22    
        for vol = 1:lvol 
            wt_val = cwt(ERPtheta(vol).ga_erp_if(ch,:),'amor',fs);   
            wt_temp = wt_temp + wt_val;     
            ITC_temp = ITC_temp + exp(1i*angle(wt_val));
        end
        wt(ch,:,:) = wt_temp./lvol;
        ITC(ch,:,:) = abs(ITC_temp./lvol);
        ITC_temp = zeros(50,225);
        wt_temp = zeros(50,225);

    end
    summary.cwt_theta_if_ga = wt;
    summary.ITC_theta_if_ga = ITC;

%Beta
    lvol = size(ERPbeta,2);
    for ch = 1:22
        for vol = 1:lvol 
            wt_val = cwt(ERPbeta(vol).ga_erp_f(ch,:),'amor',fs);
            wt_temp = wt_temp + wt_val;
            ITC_temp = ITC_temp + exp(1i*angle(wt_val));
        end
        wt(ch,:,:) = wt_temp./lvol;
        ITC(ch,:,:) = abs(ITC_temp./lvol);
        ITC_temp = zeros(50,225);
        wt_temp = zeros(50,225);
    end
    summary.cwt_beta_f_ga = wt;
    summary.ITC_beta_f_ga = ITC;

    for ch = 1:22    
        for vol = 1:lvol 
            wt_val = cwt(ERPbeta(vol).ga_erp_if(ch,:),'amor',fs);   
            wt_temp = wt_temp + wt_val;     
            ITC_temp = ITC_temp + exp(1i*angle(wt_val));
        end
        wt(ch,:,:) = wt_temp./lvol;
        ITC(ch,:,:) = abs(ITC_temp./lvol);
        ITC_temp = zeros(50,225);
        wt_temp = zeros(50,225);
    end
    summary.cwt_beta_if_ga = wt;
    summary.ITC_beta_if_ga = ITC;
end
function summary = ns_freqpow(ERPtheta,ERPbeta,summary, fs)
    wt = zeros(22,50,225);
    ITC = zeros(22,50,225);
    wt_temp = zeros(50,225);
    ITC_temp = zeros(50,225);
    lvol = size(ERPtheta,2);
    tottrials = 0;
    printer = 0;
    for ch = 1:22
        for vol = 1:lvol 
            ltrials =  size(ERPtheta(vol).erp_f,3);
            for trial = 1:ltrials
                printer = printer+1; disp(printer);
                wt_val = cwt(ERPtheta(vol).erp_f(ch,:,trial),'amor',fs);
                wt_temp = wt_temp + wt_val;
                ITC_temp = ITC_temp + exp(1i*angle(wt_val));
                clc();
            end
        tottrials = tottrials + ltrials; %Total trials
        end
        wt(ch,:,:) = wt_temp./tottrials;
        ITC(ch,:,:) = abs(ITC_temp./tottrials);
        ITC_temp = zeros(50,225);
        wt_temp = zeros(50,225);
        tottrials = 0;
    end
    summary.ERSP_theta_f = wt;
    summary.ITC_theta_f = ITC;
    
    for ch = 1:22
        for vol = 1:lvol 
            ltrials =  size(ERPtheta(vol).erp_if,3);
            for trial = 1:ltrials
                printer = printer+1; disp(printer);
                wt_val = cwt(ERPtheta(vol).erp_if(ch,:,trial),'amor',fs);
                wt_temp = wt_temp + wt_val;
                ITC_temp = ITC_temp + exp(1i*angle(wt_val));
                clc();
            end
        tottrials = tottrials + ltrials; %Total trials
        end
        wt(ch,:,:) = wt_temp./tottrials;
        ITC(ch,:,:) = abs(ITC_temp./tottrials); 
        ITC_temp = zeros(50,225);
        wt_temp = zeros(50,225);
        tottrials = 0;
    end
    summary.ERSP_theta_if = wt;
    summary.ITC_theta_if = ITC;

    lvol = size(ERPbeta,2);
    for ch = 1:22
        for vol = 1:lvol 
            ltrials =  size(ERPbeta(vol).erp_f,3);
            for trial = 1:ltrials
                printer = printer+1; disp(printer);
                wt_val = cwt(ERPbeta(vol).erp_f(ch,:,trial),'amor',fs);
                wt_temp = wt_temp + wt_val;
                ITC_temp = ITC_temp + exp(1i*angle(wt_val));
                clc();
            end
        tottrials = tottrials + ltrials; %Total trials
        end
        wt(ch,:,:) = wt_temp./tottrials;
        ITC(ch,:,:) = abs(ITC_temp./tottrials);
        ITC_temp = zeros(50,225);
        wt_temp = zeros(50,225);
        tottrials = 0;
    end
    summary.ERSP_beta_f = wt;
    summary.ITC_beta_f = ITC;
    
    for ch = 1:22
        for vol = 1:lvol 
            ltrials =  size(ERPbeta(vol).erp_if,3);
            for trial = 1:ltrials
                printer = printer+1; disp(printer);
                wt_val = cwt(ERPbeta(vol).erp_if(ch,:,trial),'amor',fs);
                wt_temp = wt_temp + wt_val;
                ITC_temp = ITC_temp + exp(1i*angle(wt_val));
                clc();
            end
        tottrials = tottrials + ltrials; %Total trials
        end
        wt(ch,:,:) = wt_temp./tottrials;
        ITC(ch,:,:) = abs(ITC_temp./tottrials); 
        ITC_temp = zeros(50,225);
        wt_temp = zeros(50,225);
        tottrials = 0;
    end
    summary.ERSP_beta_if = wt;
    summary.ITC_beta_if = ITC;
end
function plot_ITC(data,fig_n) %data has to be 22x50x225
times = linspace(-200,700,225);
freq = [92.0701114612480;85.9044515278156;80.1516873953264;74.7841686671844;...
        69.7760966111363;65.1034001588498;60.7436202094295;56.6758016807796;52.8803927899647;...
        49.3391510784621;46.0350557306240;42.9522257639078;40.0758436976632;37.3920843335922;...
        34.8880483055682;32.5517000794249;30.3718101047147;28.3379008403898;26.4401963949823;...
        24.6695755392311;23.0175278653120;21.4761128819539;20.0379218488316;18.6960421667961;...
        17.4440241527841;16.2758500397125;15.1859050523574;14.1689504201949;13.2200981974912;...
        12.3347877696155;11.5087639326560;10.7380564409770;10.0189609244158;9.34802108339806;...
        8.72201207639204;8.13792501985623;7.59295252617869;7.08447521009746;6.61004909874559;...
        6.16739388480777;5.75438196632801;5.36902822048848;5.00948046220791;4.67401054169903;...
        4.36100603819602;4.06896250992812;3.79647626308935;3.54223760504873;3.30502454937280;3.08369694240389];
% convert baseline time into indices
f = figure(fig_n); f.Name = 'ITPC Plot'; 
f.Color ='white'; pause(1); f.Position; 
set(gcf, 'Position', [100 100 1500, 700]); %<- Set size
set(gcf, 'renderer', 'painters')
    
Labels = {'FP1','FP2','F3','F4','C3','C4','P3','P4','O1','O2','F7','F8',...
'T7','T8','P7','P8','Fz','Cz','Pz','AFz','CPz','POz'};

subplotchloc = ["FP1","2";"FP2","4";"F3","7";"F4","9";"C3","12";...
        "C4","14";"P3","22";"P4","24";"O1","27";"O2","29";"F7","6";...
        "F8","10";"T7","11";"T8","15";"P7","21";"P8","25";"Fz","8";...
        "Cz","13";"Pz","23";"AFz","3";"CPz","18";"POz","28"];
    ch = 0;
    
    for chpltloc = Labels
        ch = ch + 1;
        locplt = str2double(subplotchloc(find(chpltloc == subplotchloc),2));
        subplot(6,5,locplt)
        contourf(times,freq,squeeze((data(ch,:,:))),5,'r','linecolor', 'none');
        set(gca,"ylim", [3.1,12], "xlim", [-200 640],'FontUnits','points','FontName','Sans','FontSize',12)
        %xlabel('Time(ms)')
        xline(0,'--r' );
        xline(200,'--r' );
        yline(10,'--b' );set(gca,'YScale', 'log', 'Xtick',[nan])%[-200 , 0 , 400])
        title(Labels(ch))
        ylimu = 0.8; %max(abs(summary.Beta_gga_f),[],'all')-3*std(summary.Beta_gga_f),[],'all');
        ylimi =0; %min(abs(summary.Beta_gga_f),[],'all')+3*std(abs(summary.Beta_gga_f),[],'all');
        caxis([ylimi,ylimu])
        set(gca,'YScale', 'log')
    end 
end
