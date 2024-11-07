
function cross_corr_based_missing_probability = Crosscorrelation_Based_Missing_Probability(SNR_dB)

%% Parameter
% SNR_dB = -3;
N_ITER = 1e4;
N_THRE = 127;
N_IFFT = 256;

%% Create List
corr_result = zeros(1,N_ITER);
cross_corr_based_missing_probability = zeros(1,N_THRE);

%% Create PSS Resource Block
pss = PSS(0);

%% PSS Reference Signal
tx_pss = sqrt(N_IFFT) .* ifft(ifftshift(pss),N_IFFT);

%% Energy Per Symbol(Bit)
Eavg = sum(abs(tx_pss).^2)/N_IFFT;

%% Do
for i = 1:N_ITER

    % PSS Tx Signal
    tx_random_signal = tx_pss;

    % AWGN
    awgn_complex = AWGN_Complex(SNR_dB,Eavg,N_IFFT);

    % CFO
    epsilon = 2/3 * rand();
    cfo = CFO(epsilon,N_IFFT,N_IFFT);

    % Make Rx Random Signal
    rx_random_signal = tx_random_signal .* cfo + awgn_complex;

    % Cross_correlation
    corr_result(i) = abs(xcorr(rx_random_signal,tx_pss,0));

    % Missing Test
    threshold = ceil(corr_result(i));
    if threshold <= 127
        cross_corr_based_missing_probability(threshold:N_THRE) = cross_corr_based_missing_probability(threshold:N_THRE) + 1;
    end

end

%% from Count to Probability
cross_corr_based_missing_probability = cross_corr_based_missing_probability / N_ITER;

%% Plot
% semilogy(cross_corr_based_missing_probability);
