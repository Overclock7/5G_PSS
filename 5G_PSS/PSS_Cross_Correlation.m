
N_IFFT = 256;
N_CP = 18;

%% Generate PSS Symbol
pss_0 = PSS(0);
pss_1 = PSS(1);
pss_2 = PSS(2);

%% Time Domain
tx_pss_0 = ifft(pss_0,N_IFFT);
tx_pss_0_cp = [tx_pss_0(end-(N_CP-1):end),tx_pss_0];

%% For Comparison
tx_pss_1 = ifft(pss_1,N_IFFT);
tx_pss_2 = ifft(pss_2,N_IFFT);

%% Add AWGN (Neglect CFO)
rx_pss_0 = tx_pss_0;
rx_pss_0_cp = tx_pss_0_cp;

%% Correlation ( Rx signal (with/without CP) is a PSS signal with Sector ID 0. )
[pss_0_cp_corr_result,pss_0_cp_corr_index] = xcorr(rx_pss_0_cp,tx_pss_0,255);
[pss_1_cp_corr_result,pss_1_cp_corr_index] = xcorr(rx_pss_0_cp,tx_pss_1,255);
[pss_2_cp_corr_result,pss_2_cp_corr_index] = xcorr(rx_pss_0_cp,tx_pss_2,255);

%% Freq Domain
fft_rx_pss_0_cp = fft(rx_pss_0_cp(N_CP+1:end));

%% Plot

f1 = figure;
figure(f1);

subplot(311);
stem(pss_0_cp_corr_index, N_IFFT * abs(pss_0_cp_corr_result));
xlim([pss_0_cp_corr_index(1),pss_0_cp_corr_index(end)]);
ylim([0,127]);
title("Rx signal and PSS Reference Signal Correlation Result");
ylabel("|c_0[l]|");
xlabel("l");
grid on;

subplot(312);
stem(pss_1_cp_corr_index, N_IFFT * abs(pss_1_cp_corr_result));
xlim([pss_1_cp_corr_index(1),pss_1_cp_corr_index(end)]);
ylim([0,127]);
ylabel("|c_1[l]|");
xlabel("l");
grid on;

subplot(313);
stem(pss_2_cp_corr_index, N_IFFT * abs(pss_2_cp_corr_result));
xlim([pss_2_cp_corr_index(1),pss_2_cp_corr_index(end)]);
ylim([0,127]);
ylabel("|c_2[l]|");
xlabel("l");
grid on;


