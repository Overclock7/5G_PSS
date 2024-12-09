
function rmse = Crosscorrelation_Based_CFO_Estimation_RMSE(SNR_dB)

% SNR_dB = -13;
N_ITER = 1e5;
N_IFFT = 256;
N_CP = 18;
Max_Freq_Offset = 1.33;
Max_Epsilon_Integer = round(Max_Freq_Offset) + 21; % Margin for AWGN

%% Epsilon List
epsilon = zeros(1,N_ITER);
est_epsilon = zeros(1,N_ITER);

for i = 1:N_ITER
    %% Random Sector ID PSS
    % Nid2 = randi([0 2],1);
    Nid2 = 0;
    pss = PSS(Nid2);

    %% Tx Signal
    tx_pss = sqrt(N_IFFT) * ifft(ifftshift(pss),N_IFFT);
    E_avg = sum(abs(tx_pss).^2) / N_IFFT;

    %% CFO
    epsilon(i) = Max_Freq_Offset * rand() * (-1)^randi([0,1],1,1);
    cfo = CFO(epsilon(i),N_IFFT,N_IFFT+N_CP);

    %% AWGN
    awgn_complex = AWGN_Complex(SNR_dB,E_avg,N_IFFT+N_CP);

    %% Rx Signal ( Perfect Symbol Timing )
    rx_pss = [tx_pss(N_IFFT-(N_CP-1):N_IFFT) tx_pss].* cfo + awgn_complex;

    %% CFO Compensation (CFO Hypothesis)
    rx_pss_comp_1 = rx_pss .* conj(CFO(-2,N_IFFT,N_IFFT+N_CP));
    rx_pss_comp_2 = rx_pss .* conj(CFO(-1,N_IFFT,N_IFFT+N_CP));
    rx_pss_comp_3 = rx_pss;
    rx_pss_comp_4 = rx_pss .* conj(CFO(1,N_IFFT,N_IFFT+N_CP));
    rx_pss_comp_5 = rx_pss .* conj(CFO(2,N_IFFT,N_IFFT+N_CP));


    %% Perfect Symbol Timing Estimation
    corr = [
        abs(xcorr(rx_pss_comp_1(19:19+N_IFFT-1),tx_pss,0)) ...
        abs(xcorr(rx_pss_comp_2(19:19+N_IFFT-1),tx_pss,0)) ...
        abs(xcorr(rx_pss_comp_3(19:19+N_IFFT-1),tx_pss,0)) ...
        abs(xcorr(rx_pss_comp_4(19:19+N_IFFT-1),tx_pss,0)) ...
        abs(xcorr(rx_pss_comp_5(19:19+N_IFFT-1),tx_pss,0)) ...
        ];
    [corr_max,corr_max_index] = max(corr);

    %% Cross-Correlation based Integer CFO Estimation
    switch corr_max_index
        case 1
            comp_rx_pss = rx_pss_comp_1;
            est_epsilon_i = -2;
        case 2
            comp_rx_pss = rx_pss_comp_2;
            est_epsilon_i = -1;
        case 3
            comp_rx_pss = rx_pss_comp_3;
            est_epsilon_i = 0;
        case 4
            comp_rx_pss = rx_pss_comp_4;
            est_epsilon_i = 1;
        case 5
            comp_rx_pss = rx_pss_comp_5;
            est_epsilon_i = 2;
    end

    %% Crosscorrelation Based Fraction CFO Estimation (-0.5 ~ 0.5)
    corr_est_cfo = conj(sum(comp_rx_pss(19:19+N_IFFT/2-1).*conj(tx_pss(1:1+N_IFFT/2-1)))) * sum(comp_rx_pss(19+N_IFFT/2:19+N_IFFT-1).*conj(tx_pss(1+N_IFFT/2:1+N_IFFT-1)));
    est_epsilon_f = (1/(pi)) * angle(corr_est_cfo);

    %% Estimation CFO
    est_epsilon(i) = est_epsilon_i + est_epsilon_f;
end

rmse = sqrt(sum((est_epsilon-epsilon).^2) / N_ITER); 
