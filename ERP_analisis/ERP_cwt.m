%ERPsAll_Beta = ns_allcwt(ERPsAll_Beta,250);
%ERPsAll_Theta = ns_allcwt(ERPsAll_Theta,250);
summary = ns_gacwt(ERPsAll_Beta,ERPsAll_Theta,summary,250);
[PBI,POP,POS] = ITC_tests(summary);
%%
times = linspace(-260,640,225);
freq = [92.0701114612480;85.9044515278156;80.1516873953264;74.7841686671844;...
        69.7760966111363;65.1034001588498;60.7436202094295;56.6758016807796;52.8803927899647;...
        49.3391510784621;46.0350557306240;42.9522257639078;40.0758436976632;37.3920843335922;...
        34.8880483055682;32.5517000794249;30.3718101047147;28.3379008403898;26.4401963949823;...
        24.6695755392311;23.0175278653120;21.4761128819539;20.0379218488316;18.6960421667961;...
        17.4440241527841;16.2758500397125;15.1859050523574;14.1689504201949;13.2200981974912;...
        12.3347877696155;11.5087639326560;10.7380564409770;10.0189609244158;9.34802108339806;...
        8.72201207639204;8.13792501985623;7.59295252617869;7.08447521009746;6.61004909874559;...
        6.16739388480777;5.75438196632801;5.36902822048848;5.00948046220791;4.67401054169903;...
        4.36100603819602;4.06896250992812;3.79647626308935;3.54223760504873;3.30502454937280;3.08369694240389]
for k = 1:22
    subplot(5,5,k)
    contourf(times,freq,squeeze(POS(k,:,:)),40,'r','linecolor', 'none');
    set(gca,"ylim", [3.1,30], "xlim", [-200 640],'FontUnits','points','FontName','Sans','FontSize',12)
    ylimu = max(POS,[],'all')-3*std(POS,[],'all');
    ylimi = min(POS,[],'all')+3*std(POS,[],'all');
    caxis([ylimi,ylimu])
    set(gca,'YScale', 'log')
end 
%%

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
        ERPns(vol).ITC_f = ITC;
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
        ERPns(vol).ITC_if = ITC;
        disp("status: "+vol+ " out of "+ len+ "if")
    end 
end


function [PBI,POP,POS] = ITC_tests(summary)
    itc1_u_if = abs(sum(summary.Beta_ITC_if,4))/19;
    itc2_u_if = abs(sum(summary.Theta_ITC_if,4))/26;
    itc_u_all = abs(sum(summary.Beta_ITC_if,4) + sum(summary.Theta_ITC_if,4))/45;
    PBI = (itc1_u_if-itc_u_all).*(itc2_u_if-itc_u_all);
    POP = itc1_u_if.*itc2_u_if - itc_u_all.*itc_u_all;
    POS = itc1_u_if + itc2_u_if - 2*itc_u_all;
end
