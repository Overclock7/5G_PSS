
N_IFFT = 256;
N_CP = 18;
SNR_dB = -9:3:15;

%% Generate PSS Symbol
pss_0 = PSS(0);

%% Time Domain
tx_pss_0 = sqrt(N_IFFT) .* ifft(pss_0,N_IFFT);

%% Average Symbol Energy
Pavg = sum(abs(tx_pss_0).^2)/length(tx_pss_0);

%% Add AWGN
for i = 1:length(SNR_dB)
    awgn(i,:) = AWGN_Complex(SNR_dB(i),Pavg,N_IFFT);
    rx_pss_0(i,:) = tx_pss_0 + awgn(i,:);
end

%% Correlation
for i = 1:length(SNR_dB)
    cross_correlation(i) = abs(xcorr(rx_pss_0(i,:),tx_pss_0,0)); 
    auto_correlation(i) = abs(sum(rx_pss_0(i,1+1:1+(N_IFFT/2 -1)) .* rx_pss_0(i,1+(N_IFFT-1):-1:1+N_IFFT-(N_IFFT/2 - 1))));
end

%% Plot
plot(SNR_dB,cross_correlation);
hold on;
plot(SNR_dB,auto_correlation);

