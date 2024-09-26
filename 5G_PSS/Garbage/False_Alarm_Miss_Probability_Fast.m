
function [false_alarm_probability, missing_probability] = False_Alarm_Miss_Probability_Fast(SNR_dB)

% SNR_dB = 9.6;
N_ZERO = 20;
N_IFFT = 256;
N_ITER = 10000;
N_THRE = 127; % 0.05

%% Generate PSS Sector ID 0
pss_0 = PSS(0);

%% Time Domain (IFFT)
tx_matrix = ifft(pss_0,N_IFFT);

%% Calculation Everage Symbol Energy
Eavg = mean(abs(tx_matrix).^2);

%% Declare List
missing_probability = zeros(1,N_THRE);
false_alarm_probability = zeros(1,N_THRE);
noise_matrix = zeros(N_ITER,N_IFFT+2*N_ZERO);
corr_matrix = zeros(N_ITER,2*N_ZERO+1);

%% Make Noise Matrix
SNR = 10^(SNR_dB/10);
N0 = Eavg/SNR;
sigma = sqrt(N0/2);
for i = 1:N_ITER 
    noise_matrix(i,:) = complex(sigma.*randn(1,N_IFFT+2*N_ZERO),sigma.*randn(1,N_IFFT+2*N_ZERO));
end

%% Make Rx Matrix
rx_matrix = repmat([zeros(1,N_ZERO) tx_matrix zeros(1,N_ZERO)],N_ITER,1) + noise_matrix;

%% Correlation ( 1/tx_corr for normalization)
for i = 1:N_ITER
    for j = 1:1+2*N_ZERO
        corr_matrix(i,j) = N_IFFT * abs(xcorr(rx_matrix(i,j:j+N_IFFT-1),tx_matrix,0));
    end
end

%% Find Probabilty
for i = 1:N_THRE

    count_false = 0;
    count_missing = 0;
    
    for j = 1:N_ITER
        
        flag_false = 0;
        flag_missing = 0;

        for k = 1:1+2*N_ZERO

            temp = corr_matrix(j,k);

            % False Condition
            if k ~= N_ZERO+1 && i <= temp
                flag_false = 1;
            % Missing Condition
            elseif k == N_ZERO+1 && i >= temp
                flag_missing = 1;
            end
        
            % Break Condition
            if flag_false == 1 && flag_missing == 1
                break
            end

        end
        
        count_false = count_false + flag_false;
        count_missing = count_missing + flag_missing;

    end

    false_alarm_probability(i) = count_false / N_ITER;
    missing_probability(i) = count_missing / N_ITER;

end