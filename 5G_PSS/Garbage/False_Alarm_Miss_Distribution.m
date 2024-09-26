
N_IFFT = 256;
N_CP = 18;
N_ITER = 2^15;

% Generate PSS
pss_0 = PSS(0);

% Time Domain (IFFT)
tx_pss_0 = ifft(pss_0,N_IFFT);

% Add Cyclic Prefix
tx_pss_0_cp = [tx_pss_0(end-(N_CP-1):end),tx_pss_0];

% Calculation Everage Symbol Energy
Eavg_cp = mean(abs(tx_pss_0_cp).^2);

% False Alarm & Missing Detection
peak_corr_noise = zeros(1,N_ITER);
peak_corr_rx = zeros(1,N_ITER);

for k=1:N_ITER

    % AWGN
    SNR_dB = 0;
    SNR = 10^(SNR_dB/10);

    rand_real = randn(1,N_IFFT+N_CP);
    rand_imag = randn(1,N_IFFT+N_CP);

    N0_cp = Eavg_cp/SNR;
    sigma_cp = sqrt(N0_cp/2);
    noise_cp = complex(sigma_cp.*rand_real,sigma_cp.*rand_imag);

    % Rx Signal
    rx_pss_0_cp = tx_pss_0_cp + noise_cp;

    % Correlation
    [noise_corr_result,noise_corr_index] = xcorr(noise_cp,tx_pss_0,N_IFFT+N_CP);
    [rx_corr_result,rx_corr_index] = xcorr(rx_pss_0_cp,tx_pss_0,N_IFFT+N_CP);

    % Take Peak Correlation Result
    peak_corr_noise(k) = max(abs(noise_corr_result));
    peak_corr_rx(k) = max(abs(rx_corr_result));

end

% % Standard Deviation
% peak_corr_rx_sd = sqrt(var(peak_corr_rx));
% peak_corr_noise_sd = sqrt(var(peak_corr_noise));
% 
% % Rayleigh Distribution
% x = 0:0.001:1;
% f_rx = (x ./ (peak_corr_rx_sd^2)) .* exp((-x.^2) ./ (2*peak_corr_rx_sd^2));

grid on;
subplot(211);
hold on;
histogram(peak_corr_noise,"Normalization","pdf");
histogram(peak_corr_rx,"Normalization","pdf");
hold off;
subplot(212);
hold on;
histogram(peak_corr_noise,"Normalization","cdf");
histogram(peak_corr_rx,"Normalization","cdf");
hold off;




