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