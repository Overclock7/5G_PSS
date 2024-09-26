
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

%% Average Symbol Energy
Eavg = sum(abs(tx_pss_0).^2)/length(tx_pss_0); 
Eavg_cp = sum(abs(tx_pss_0_cp).^2)/length(tx_pss_0_cp);

%% AWGN
SNR_dB = 10;
SNR = 10^(SNR_dB/10);

rand_real = randn(1,N_IFFT+N_CP);
rand_imag = randn(1,N_IFFT+N_CP);

N0 = Eavg/SNR;
sigma = sqrt(N0/2);
noise = complex(sigma.*rand_real(N_CP+1:end),sigma.*rand_imag(N_CP+1:end));

N0_cp = Eavg_cp/SNR;
sigma_cp = sqrt(N0_cp/2);
noise_cp = complex(sigma_cp.*rand_real,sigma_cp.*rand_imag);

%% Add AWGN (Neglect CFO)
rx_pss_0 = tx_pss_0 + noise;
rx_pss_0_cp = tx_pss_0_cp + noise_cp;

%% Correlation ( Rx signal (with/without CP) is a PSS signal with Sector ID 0. )
[pss_0_corr_result,pss_0_corr_index] = xcorr(tx_pss_0,tx_pss_0,255);
[pss_1_corr_result,pss_1_corr_index] = xcorr(rx_pss_0,tx_pss_1,255);
[pss_2_corr_result,pss_2_corr_index] = xcorr(rx_pss_0,tx_pss_2,255);
[pss_0_cp_corr_result,pss_0_cp_corr_index] = xcorr(rx_pss_0_cp,tx_pss_0,255);
[pss_1_cp_corr_result,pss_1_cp_corr_index] = xcorr(rx_pss_0_cp,tx_pss_1,255);
[pss_2_cp_corr_result,pss_2_cp_corr_index] = xcorr(rx_pss_0_cp,tx_pss_2,255);

%% Freq Domain
fft_rx_pss_0 = fft(rx_pss_0);
fft_rx_pss_0_cp = fft(rx_pss_0_cp(N_CP+1:end));

%% For Constellation
part_fft_rx_pss_0 = fft_rx_pss_0(57:183);
part_fft_rx_pss_0_cp = fft_rx_pss_0_cp(57:183);

%% Plot
f1 = figure;
figure(f1);

subplot(311);
stem(pss_0_corr_index, N_IFFT * abs(pss_0_corr_result));
title("TX and Rx signal Correlation");
ylim([0,140]);
ylabel("R[\tau]");
subplot(312);
stem(pss_1_corr_index, N_IFFT * abs(pss_1_corr_result));
ylim([0,140]);
ylabel("R[\tau]");
subplot(313);
stem(pss_2_corr_index, N_IFFT * abs(pss_2_corr_result));
ylim([0,140]);
ylabel("R[\tau]");
xlabel("\tau");

f2 = figure;
figure(f2);

subplot(311);
stem(pss_0_cp_corr_index, N_IFFT * abs(pss_0_cp_corr_result));
title("TX and Rx signal with CP Correlation");
ylim([0,140]);
ylabel("R[\tau]");
subplot(312);
stem(pss_1_cp_corr_index, N_IFFT * abs(pss_1_cp_corr_result));
ylim([0,140]);
ylabel("R[\tau]");
subplot(313);
stem(pss_2_cp_corr_index, N_IFFT * abs(pss_2_cp_corr_result));
ylim([0,140]);
ylabel("R[\tau]");
xlabel("\tau");

f3 = figure;
figure(f3);
grid on;
scatter(real(part_fft_rx_pss_0),imag(part_fft_rx_pss_0));
title("PSS Constellation");
text(0,0,"SNR = 10dB",'HorizontalAlignment',"center");
xlabel("Real");
ylabel("Imag")

