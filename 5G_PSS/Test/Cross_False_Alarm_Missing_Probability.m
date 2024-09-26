
SNR_dB = 0;

N_CP = 18;
N_IFFT = 256;
N_ZERO = N_CP+N_IFFT;

N_ITER = 1e4;
N_PWR = 127;

L_opt = N_ZERO + N_CP + 1;

threshold_list = 0:5:125;
threshold_length = length(threshold_list);

%% Generate PSS
pss = PSS(0);

%% Time Domain (IFFT)
tx_pss = sqrt(N_IFFT) * ifft(pss,N_IFFT);

%% Test OFDM Symbol
pss_signal = [zeros(1,N_ZERO) tx_pss(N_IFFT-(N_CP-1):N_IFFT) tx_pss zeros(1,N_ZERO)];
pss_length = length(pss_signal);

%% Everage Power per Sample for AWGN
Pavg = sum(abs(tx_pss).^2)/N_IFFT;

%% Declare List
false_alarm_probability = zeros(1,threshold_length);
missing_probability = zeros(1,threshold_length);

%% Calculate
for k = 1:threshold_length
    
    threshold = threshold_list(k);

    fprintf("Now "+threshold+"\n"); 
    
    % Counts
    count_false = 0;
    count_missing = 0;

    for iteration = 1:N_ITER

        corr_result = zeros(1,1+N_CP+2*N_ZERO);

        % Flags
        flag_false = 0;
        flag_missing = 0;
        
        % AWGN
        awgn_complex = AWGN_Complex(SNR_dB,Pavg,pss_length);

        % CFO
        epsilon = 2/3 * rand();
        cfo = CFO(epsilon,N_IFFT,pss_length);

        % Rx Signal with AWGN
        rx_pss = pss_signal .* cfo + awgn_complex;

        % Cross-correlation
        STO = -1;
        for m = 1:1+N_CP+2*N_ZERO
            corr_result(m) = abs(xcorr(rx_pss(m:m+255),tx_pss,0));
            if corr_result(m) >= threshold
                STO = m;
                break;
            end
        end

        if STO == -1
            flag_missing = 1;
        elseif STO ~= -1
            if (STO < (L_opt - 4)) || (STO > L_opt)
                flag_false = 1;
            end
        end
       
        % Add Count
        count_false = count_false + flag_false;
        count_missing = count_missing + flag_missing;

    end
    
    false_alarm_probability(k) = count_false / N_ITER;
    missing_probability(k) = count_missing / N_ITER;
    
end

semilogy(threshold_list,false_alarm_probability);
hold on;
grid on;
semilogy(threshold_list,missing_probability);
