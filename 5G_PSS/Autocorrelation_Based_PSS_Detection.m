
N_IFFT = 256;
N_THRE = 127;
N_CP = 18;
SNR_dB = 0;

%% PSS
pss_0 = PSS(0);

%% Tx Signal
tx_pss_0 = sqrt(N_IFFT) * ifft(pss_0,N_IFFT);
Eavg = sum(abs(tx_pss_0).^2) / N_IFFT;

%% Random Data
random_signal = [zeros(1,56), complex(1/sqrt(2)*(-1).^randi([0 1],1,N_THRE),1/sqrt(2)*(-1).^randi([0 1],1,N_THRE)), zeros(1,57)];
% random_signal = [zeros(1,56) (-1).^randi([0 1],1,N_IFFT) zeros(1,57)];
% random_signal = zeros(1,240);
tx_random_signal = sqrt(N_IFFT) .* ifft(random_signal,N_IFFT);

%% CFO
cfo = CFO(0.5,N_IFFT,N_IFFT*2+N_CP);

%% AWGN
awgn_complex = AWGN_Complex(SNR_dB,Eavg,N_IFFT*2+N_CP);

%% RX Signal
rx_pss_0 = [tx_random_signal(end/2+1:end) tx_pss_0(N_IFFT-(N_CP-1):N_IFFT) tx_pss_0 tx_random_signal(1:end/2)] .* cfo;

%% Auto-correlation Result List
auto_corr_result = zeros(1,N_IFFT+N_CP+1);
cross_corr_result = zeros(1,N_IFFT+N_CP+1);

%% Autocorrelation
for l = 1:N_IFFT+N_CP+1
   part_rx_pss_0 = rx_pss_0(l:l+N_IFFT-1);
   auto_corr_result(l) = abs(sum(part_rx_pss_0(1+1:1+(N_IFFT/2 -1)) .* part_rx_pss_0(1+(N_IFFT-1):-1:1+N_IFFT-(N_IFFT/2 - 1))));
end

%% Crosscorrelation (Conventional)
for l = 1:N_IFFT+N_CP+1
   cross_corr_result(l) = abs(sum(rx_pss_0(l:l+N_IFFT-1).* conj(tx_pss_0)));
end

%% plot
x = -(N_IFFT/2+N_CP):N_IFFT/2;

subplot(211);
stem(x,auto_corr_result);
title("Autocorrelation Based PSS Detection (CFO = 0.5, Neglect AWGN)");
xlabel("Time Index");
xlim([x(1) x(end)]);
grid on;

subplot(212);
stem(x,cross_corr_result);
title("Crosscorrelation Based PSS Detection (CFO = 0.5, Neglect AWGN)");
xlabel("Time Index");
xlim([x(1) x(end)]);
grid on;
