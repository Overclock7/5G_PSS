% function [P_F,P_M] = Cross_Corr_Based_False_Alarm_Missing_Probability(SNR_dB)

close;
clear;
clc;

%% Parameter
SNR_dB = 0;
N_ITER = 1e4;
N_THRE = 127;
N_SAMPLE = 274;
N_IFFT = 256;
N_CP = 18;

%% Create List
threshold = 0:5:40;
P_F = zeros(1,length(threshold));
P_M = zeros(1,length(threshold));

%% Create PSS Tx Symbol
% Make PSS
pss = PSS(0);

% IFFT
ifft_pss = sqrt(N_IFFT) .* ifft(ifftshift(pss),N_IFFT);

% Average Energy per subcarrier (For AWGN)
Eavg = sum(abs(ifft_pss).^2)/N_IFFT;

% Add CP
tx_pss = [ifft_pss(end-(N_CP-1):end) ifft_pss];


%% Do
for k = 1:length(threshold)

    th = threshold(k);

    for m = 1:N_ITER

        % AWGN
        awgn_complex =AWGN_Complex(SNR_dB,Eavg,2*N_SAMPLE);

        % CFO
        epsilon = 2/3 * rand() * (-1) ^ randi([0 1]);
        cfo = CFO(epsilon,N_IFFT,2*N_SAMPLE);

        % Random Signal
        random_signal = [zeros(1,64) complex(1/sqrt(2)*(-1).^randi([0 1],1,N_THRE),1/sqrt(2)*(-1).^randi([0 1],1,N_THRE)) zeros(1,65)];
        shuffle_signal = random_signal(randperm(length(random_signal)));
        ifft_random_signal = sqrt(N_IFFT) * ifft(ifftshift(shuffle_signal),N_IFFT);
        tx_random_signal = [ifft_random_signal(end-(N_IFFT-1):end) ifft_random_signal];

        % Make Rx Random Signal
        % 001 ~ 137 0 || 138 ~ 155 CP || 156 ~ 411 PSS || 412 ~ 548 0
        rx_pss = [tx_random_signal(end-(N_SAMPLE/2-1):end) tx_pss tx_random_signal(1:(N_SAMPLE/2))] .* cfo + awgn_complex;

        % Autocorrelation Based PSS Detect
        for l = 1:length(rx_pss)-(N_IFFT-2)
            % Missing
            if l == 294
                break
            end

            corr_result = abs(xcorr(rx_pss(l:l+N_IFFT-1),ifft_pss,0));

            % Alarm
            if corr_result > th
                break
            end
        end

        % Judge
        if l < 148
            P_F(k) = P_F(k) + 1;
            P_M(k) = P_M(k) + 0;
        elseif l >= 148 && l <=156 %% l = [l_opt - (N_CP/2 - 1), l_opt]
            P_F(k) = P_F(k) + 0;
            P_M(k) = P_M(k) + 0;
        elseif l> 156 && l < 294
            P_F(k) = P_F(k) + 1;
            P_M(k) = P_M(k) + 0;
        elseif l == 294
            P_F(k) = P_F(k) + 0;
            P_M(k) = P_M(k) + 1;
        end

    end

    % from Count to Probability
    P_F(k) = P_F(k) / N_ITER;
    P_M(k) = P_M(k) / N_ITER;

end

%% Plot
semilogy(threshold,P_F);
hold on;
semilogy(threshold,P_M);
grid on;