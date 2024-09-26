
N_ZERO = 20;
N_IFFT = 256;
N_ITER = 10000;
N_THRE = 127; % 0.05
SNR_dB = 3;

% Generate PSS
pss_0 = PSS(0);

% Time Domain (IFFT)
tx_pss_0 = ifft(pss_0,N_IFFT);

% Calculation Everage Symbol Energy
Eavg = mean(abs(tx_pss_0).^2);

% Declare List
missing_probability = zeros(1,N_THRE);
false_alarm_probability = zeros(1,N_THRE);

%% Calculate
for threshold = 1:127

    fprintf("Now "+threshold+"\n");
    
    % Count
    count_false = 0;
    count_missing = 0;

    for iteration = 1:N_ITER

        % Flags
        flag_false = 0;
        flag_missing = 0;
        
        % AWGN
        SNR = 10^(SNR_dB/10);    
        N0 = Eavg/SNR;
        sigma = sqrt(N0/2);
        noise = complex(sigma.*randn(1,N_IFFT+2*N_ZERO),sigma.*randn(1,N_IFFT+2*N_ZERO));

        % Rx Signal with AWGN
        rx_pss_0 = [zeros(1,N_ZERO) tx_pss_0 zeros(1,N_ZERO)] + noise;

        for i = 1:1+2*N_ZERO
            
            % Correlation
            temp = N_IFFT * abs(xcorr(rx_pss_0(i:i+255),tx_pss_0,0));
            
            % False Condition
            if i ~= N_ZERO+1 && threshold <= temp
                flag_false = 1;
            % Missing Condition
            elseif i == N_ZERO+1 && threshold >= temp 
                flag_missing = 1;
            end
            
            % Break Condition
            if flag_false == 1 && flag_missing == 1
                break
            end

        end
        
        % Add Count
        count_false = count_false + flag_false;
        count_missing = count_missing + flag_missing;

    end
    
    index = int32(threshold * N_THRE);
    missing_probability(index) = count_missing / N_ITER;
    false_alarm_probability(index) = count_false / N_ITER;

end