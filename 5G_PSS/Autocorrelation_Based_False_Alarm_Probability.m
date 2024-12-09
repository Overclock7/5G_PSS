
function auto_corr_based_false_alarm_probability = Autocorrelation_Based_False_Alarm_Probability(SNR_dB)

%% Parameter
% SNR_dB = 0;
N_ITER = 1e5;
N_THRE = 127;
N_IFFT = 256;

%% Create List
corr_result = zeros(N_THRE,N_ITER);
auto_corr_based_false_alarm_probability = zeros(1,N_THRE);

%% Do
for k = 1:N_THRE

    for m = 1:N_ITER

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

        % Auto-correlation
        corr_result(k,m) = abs(sum(rx_random_signal(1+1:1:1+(N_IFFT/2-1)) .* rx_random_signal(1+(N_IFFT-1):-1:1+N_IFFT-(N_IFFT/2-1))));

        % False Alarm Test
        if corr_result(k,m) > k
            auto_corr_based_false_alarm_probability(k) = auto_corr_based_false_alarm_probability(k) + 1;
        end

    end
    
end

%% from Count to Probability
auto_corr_based_false_alarm_probability = auto_corr_based_false_alarm_probability / N_ITER;

% %% Plot
% semilogy(auto_corr_based_false_alarm_probability);
% grid on;



% %% For Fast Do
% for m = 1:N_ITER
% 
%     % Create Random Signal Block (Same Power Signal as PSS)
%     random_signal = [zeros(1,64) complex(1/sqrt(2)*(-1).^randi([0 1],1,N_THRE),1/sqrt(2)*(-1).^randi([0 1],1,N_THRE)) zeros(1,65)];
% 
%     % IFFT
%     tx_random_signal = sqrt(N_IFFT) .* ifft(ifftshift(random_signal),N_IFFT);
% 
%     % Energy Per Symbol(Bit)
%     Eavg = sum(abs(tx_random_signal).^2)/N_IFFT;
% 
%     % AWGN
%     awgn_complex = AWGN_Complex(SNR_dB,Eavg,N_IFFT);
% 
%     % CFO
%     epsilon = 2/3 * rand();
%     cfo = CFO(epsilon,N_IFFT,N_IFFT);
% 
%     % Make Rx Random Signal
%     rx_random_signal = tx_random_signal .* cfo + awgn_complex;
% 
%     % Auto-correlation
%     corr_result(m) = abs(sum(rx_random_signal(1+1:1:1+(N_IFFT/2-1)) .* rx_random_signal(1+(N_IFFT-1):-1:1+N_IFFT-(N_IFFT/2-1))));
% 
%     % False Alarm Test
%     threshold = floor(corr_result(m));
%     if threshold >= N_THRE
%         threshold = 127;
%     end
%     if threshold > 0
%         auto_corr_based_false_alarm_probability(1:threshold) = auto_corr_based_false_alarm_probability(1:threshold) + 1;
%     end
% 
% end
