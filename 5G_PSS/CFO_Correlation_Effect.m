
N_IFFT = 256;
epsilon = -2.5:0.05:2.5;

%% PSS
pss_0 = PSS(0);

%% Time Domain
tx_pss = sqrt(N_IFFT) .* ifft(ifftshift(pss_0),N_IFFT);

%% CFO
for i = 1:length(epsilon)
    cfo(i,:) = CFO(epsilon(i),N_IFFT,N_IFFT);
end

%% Rx
rx_pss_0 = tx_pss .* cfo;

%% Correlation
for i = 1:length(epsilon)
    cross_correlation(i) = abs(xcorr(rx_pss_0(i,:),tx_pss,0)); 
    auto_correlation(i) = abs(sum(rx_pss_0(i,1+1:1+(N_IFFT/2 -1)) .* rx_pss_0(i,1+(N_IFFT-1):-1:1+N_IFFT-(N_IFFT/2 - 1))));
end

%% Plot
f1 = figure();
figure(f1);

plot(epsilon,cross_correlation);
grid on;
title("Cross-Correlation Based PSS Detection");
xlabel("Normalized Frequency Offset \epsilon");
ylabel("\midc_i[0]\mid");
xlim([-2.5,2.5]);
ylim([0,130]);

f2 = figure();
plot(epsilon,auto_correlation);
grid on;
title("Auto-Correlation Based PSS Detection");
xlabel("Normalized Frequency Offset \epsilon");
ylabel("\midc_i[0]\mid");
xlim([-2.5,2.5]);
ylim([0,130]);

