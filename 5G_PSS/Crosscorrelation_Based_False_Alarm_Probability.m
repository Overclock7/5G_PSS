
function cross_corr_based_false_alarm_probability = Crosscorrelation_Based_False_Alarm_Probability(SNR_dB)

%% Parameter
% SNR_dB = -3;
N_ITER = 1e4;
N_THRE = 127;
N_IFFT = 256;

%% Create List
corr_result = zeros(1,N_ITER);
cross_corr_based_false_alarm_probability = zeros(1,N_THRE);

%% Create PSS Resource Block
pss = PSS(0);

%% PSS Reference Signal
tx_pss = sqrt(N_IFFT) .* ifft(ifftshift(pss),N_IFFT);

%% Do
for i = 1:N_ITER

    % Create Random Signal Block (Same Power Signal as PSS)
    random_signal = [zeros(1,64) complex(1/sqrt(2)*(-1).^randi([0 1],1,N_THRE),1/sqrt(2)*(-1).^randi([0 1],1,N_THRE)) zeros(1,65)];

    % IFFT
    tx_random_signal = sqrt(N_IFFT) .* ifft(ifftshift(random_signal),N_IFFT);

    % Energy Per Symbol(Bit)
    Eavg = sum(abs(tx_random_signal).^2)/N_IFFT;

    % AWGN
    awgn_complex = AWGN_Complex(SNR_dB,Eavg,N_IFFT);

    % CFO
    epsilon = 2/3 * rand();
    cfo = CFO(epsilon,N_IFFT,N_IFFT);

    % Make Rx Random Signal
    rx_random_signal = tx_random_signal .* cfo + awgn_complex;

    % Cross_correlation
    corr_result(i) = abs(xcorr(rx_random_signal,tx_pss,0));

    % False Alarm Test
    threshold = floor(corr_result(i));
    if threshold >= N_THRE
        threshold = 127;
    end
    if threshold > 0
        cross_corr_based_false_alarm_probability(1:threshold) = cross_corr_based_false_alarm_probability(1:threshold) + 1;
    end

end

%% from Count to Probability
cross_corr_based_false_alarm_probability = cross_corr_based_false_alarm_probability / N_ITER;

%% Plot
% semilogy(cross_corr_based_false_alarm_probability);
