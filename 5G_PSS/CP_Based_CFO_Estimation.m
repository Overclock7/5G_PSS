
N_IFFT = 256;
N_CP = 18;
SNR_dB = -10;

%% PSS
pss = PSS(0);

%% Tx Signal
tx_pss = sqrt(N_IFFT) * ifft(pss,N_IFFT);
Eavg = sum(abs(tx_pss).^2)/N_IFFT;

%% CFO
epsilon =  1.33 * rand() * (-1) ^ randi([0 1]);
cfo = CFO(epsilon,N_IFFT,N_IFFT+N_CP);

%% AWGN
awgn_complex = AWGN_Complex(SNR_dB,Eavg,N_IFFT+N_CP);

%% Rx Signal
rx_pss = [tx_pss(N_IFFT-(N_CP-1):N_IFFT) tx_pss] .* cfo + awgn_complex;

%% CFO Compensation (CFO Hypothesis)
rx_pss_comp_1 = rx_pss .* conj(CFO(-4,N_IFFT,N_IFFT+N_CP));
rx_pss_comp_2 = rx_pss .* conj(CFO(-3,N_IFFT,N_IFFT+N_CP));
rx_pss_comp_3 = rx_pss .* conj(CFO(-2,N_IFFT,N_IFFT+N_CP));
rx_pss_comp_4 = rx_pss .* conj(CFO(-1,N_IFFT,N_IFFT+N_CP));
rx_pss_comp_5 = rx_pss;
rx_pss_comp_6 = rx_pss .* conj(CFO(1,N_IFFT,N_IFFT+N_CP));
rx_pss_comp_7 = rx_pss .* conj(CFO(2,N_IFFT,N_IFFT+N_CP));
rx_pss_comp_8 = rx_pss .* conj(CFO(3,N_IFFT,N_IFFT+N_CP));
rx_pss_comp_9 = rx_pss .* conj(CFO(4,N_IFFT,N_IFFT+N_CP));

%% Perfect Symbol Timing Estimation
corr = [
    abs(xcorr(rx_pss_comp_1(19:19+N_IFFT-1),tx_pss,0)) ...
    abs(xcorr(rx_pss_comp_2(19:19+N_IFFT-1),tx_pss,0)) ...
    abs(xcorr(rx_pss_comp_3(19:19+N_IFFT-1),tx_pss,0)) ...
    abs(xcorr(rx_pss_comp_4(19:19+N_IFFT-1),tx_pss,0)) ...
    abs(xcorr(rx_pss_comp_5(19:19+N_IFFT-1),tx_pss,0)) ...
    abs(xcorr(rx_pss_comp_6(19:19+N_IFFT-1),tx_pss,0)) ...
    abs(xcorr(rx_pss_comp_7(19:19+N_IFFT-1),tx_pss,0)) ...
    abs(xcorr(rx_pss_comp_8(19:19+N_IFFT-1),tx_pss,0)) ...
    abs(xcorr(rx_pss_comp_9(19:19+N_IFFT-1),tx_pss,0)) ...
    ];
[corr_max,corr_max_index] = max(corr);

%% CP based Integer CFO Estimation
switch corr_max_index
    case 1
        comp_rx_pss = rx_pss_comp_1;
        est_epsilon_i = -4;
    case 2
        comp_rx_pss = rx_pss_comp_2;
        est_epsilon_i = -3;
    case 3
        comp_rx_pss = rx_pss_comp_3;
        est_epsilon_i = -2;
    case 4
        comp_rx_pss = rx_pss_comp_4;
        est_epsilon_i = -1;
    case 5
        comp_rx_pss = rx_pss_comp_5;
        est_epsilon_i = 0;
    case 6
        comp_rx_pss = rx_pss_comp_6;
        est_epsilon_i = 1;
    case 7
        comp_rx_pss = rx_pss_comp_7;
        est_epsilon_i = 2;
    case 8
        comp_rx_pss = rx_pss_comp_8;
        est_epsilon_i = 3;
    case 9
        comp_rx_pss = rx_pss_comp_9;
        est_epsilon_i = 4;
end
%% CP based Fraction CFO Estimation (-0.5 ~ +0.5)
corr_est_cfo = sum(conj(comp_rx_pss(1:N_CP)).*comp_rx_pss(end-(N_CP-1):end));
est_epsilon_f = (1/(2*pi)) * angle(corr_est_cfo);

est_epsilon = est_epsilon_i + est_epsilon_f;

fprintf("Epsilon : %+1.5f || Estimation Epsilon : %+1.5f || Error : %1.5f\n",[epsilon est_epsilon abs(epsilon-est_epsilon)]);
