% 1-32 od4
times = linspace(-260,640,225);
summary.times = times;
summary = get_GA_ns_beta(ERPsAll_Beta,summary);
summary = get_GA_ns_theta(ERPsAll_Theta,summary);
%%
summary.P300 = ERP_amp_lat(summary,250,350, "P");
summary.P200 = ERP_amp_lat(summary,150,250, "P");
summary.N100 = ERP_amp_lat(summary,80,120, "N");
summary.N200 = ERP_amp_lat(summary,180,220, "N");

figure(4)
subplot(2,1,1)
plot(times,summary.erp_beta_f', "r", "linewidth", 0.5)
hold on
plot(times,summary.erp_theta_f',"blue")
scatter(summary.P300.lat_beta_f, summary.P300.amp_beta_f,"<g")
scatter(summary.P300.lat_theta_f, summary.P300.amp_theta_f,">k")
hold off
ylim([-5,6])
subplot(2,1,2)
plot(times,summary.erp_beta_if',"r")
hold on
plot(times,summary.erp_theta_if',"blue")
scatter(summary.P300.lat_beta_if, summary.P300.amp_beta_if,"<g")
scatter(summary.P300.lat_theta_if, summary.P300.amp_theta_if,">k")
hold off
ylim([-5,6])
%%
function summary = get_GA_ns_beta(ERP_ns,summary)
     summary.erp_beta_f = mean(reshape([ERP_ns.ga_erp_f],22,225,[]),3);
     summary.erp_beta_if = mean(reshape([ERP_ns.ga_erp_if],22,225,[]),3);
end
function summary = get_GA_ns_theta(ERP_ns,summary)
     summary.erp_theta_f = mean(reshape([ERP_ns.ga_erp_f],22,225,[]),3);
     summary.erp_theta_if = mean(reshape([ERP_ns.ga_erp_if],22,225,[]),3);
end

function comp = ERP_amp_lat(summary,llim,ulim,side)
    comp = struct
    t_full = summary.times;
    [~,s_llim] = min(abs(t_full-llim));
    s_llim = t_full(s_llim);
    [~,s_ulim] = min(abs(t_full-ulim));
    s_ulim = t_full(s_ulim);

    idx_times = (t_full > s_llim) & (t_full <= s_ulim);
    t = linspace(s_llim,s_ulim,sum(idx_times));
    
    erp_ran = summary.erp_beta_f(:,idx_times);
    if(side == "n" || side == "N")
        [comp.amp_beta_f, lat] = min(erp_ran');    
    else
        [comp.amp_beta_f, lat] = max(erp_ran');
    end
    comp.lat_beta_f = t(lat)
    
    erp_ran = summary.erp_beta_if(:,idx_times);
    if(side == "n" || side == "N")
        [comp.amp_beta_if,lat] = min(erp_ran');
    else
        [comp.amp_beta_if,lat] = max(erp_ran');
    end
    comp.lat_beta_if =   t(lat)

    erp_ran = summary.erp_theta_f(:,idx_times);
    if(side == "n" || side == "N")
        [comp.amp_theta_f,lat] = min(erp_ran');
    else
        [comp.amp_theta_f,lat] = max(erp_ran');
    end
    comp.lat_theta_f =  t(lat)

    erp_ran = summary.erp_theta_if(:,idx_times);
    if(side == "n" || side == "N")
        [comp.amp_theta_if,lat] = min(erp_ran');
    else
        [comp.amp_theta_if,lat] = max(erp_ran');
    end
    comp.lat_theta_if =  t(lat)

    
end
        