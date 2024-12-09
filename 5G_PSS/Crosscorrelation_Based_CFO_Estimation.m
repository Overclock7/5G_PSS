
N_IFFT = 256;
N_CP = 18;

%% PSS
pss = PSS(0);

%% Tx Signal
tx_pss = sqrt(N_IFFT) * ifft(ifftshift(pss),N_IFFT);
Eavg = sum(abs(tx_pss).^2)/N_IFFT;

%% CFO
Max_Freq_Offset = 1.5;
epsilon = Max_Freq_Offset * rand() * (-1)^randi([0,1],1,1);
cfo = CFO(epsilon,N_IFFT,N_IFFT+N_CP);

%% Rx Signal
rx_pss = [tx_pss(N_IFFT-(N_CP-1):N_IFFT) tx_pss] .* cfo;

%% CFO Compensation (CFO Hypothesis)
rx_pss_comp_1 = rx_pss .* conj(CFO(-2,N_IFFT,N_IFFT+N_CP));
rx_pss_comp_2 = rx_pss .* conj(CFO(-1,N_IFFT,N_IFFT+N_CP));
rx_pss_comp_3 = rx_pss;
rx_pss_comp_4 = rx_pss .* conj(CFO(1,N_IFFT,N_IFFT+N_CP));
rx_pss_comp_5 = rx_pss .* conj(CFO(2,N_IFFT,N_IFFT+N_CP));


%% Perfect Symbol Timing Estimation
corr = [
    abs(xcorr(rx_pss_comp_1(1+N_CP:1+N_CP+N_IFFT-1),tx_pss,0)) ...
    abs(xcorr(rx_pss_comp_2(1+N_CP:1+N_CP+N_IFFT-1),tx_pss,0)) ...
    abs(xcorr(rx_pss_comp_3(1+N_CP:1+N_CP+N_IFFT-1),tx_pss,0)) ...
    abs(xcorr(rx_pss_comp_4(1+N_CP:1+N_CP+N_IFFT-1),tx_pss,0)) ...
    abs(xcorr(rx_pss_comp_5(1+N_CP:1+N_CP+N_IFFT-1),tx_pss,0)) ...
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

%% Crosscorrelation Based Fraction CFO Estimation (-0.5 ~ +0.5)
corr_est_cfo = conj(sum(comp_rx_pss(1+N_CP:1+N_CP+N_IFFT/2-1).*conj(tx_pss(1:1+N_IFFT/2-1)))) * sum(comp_rx_pss(1+N_CP+N_IFFT/2:1+N_CP+N_IFFT-1).*conj(tx_pss(1+N_IFFT/2:1+N_IFFT-1)));
est_epsilon_f = (1/(pi)) * angle(corr_est_cfo);

%% Estimation CFO
est_epsilon = est_epsilon_i + est_epsilon_f;
fprintf("Epsilon : %+1.5f || Estimation Epsilon : %+1.5f || Error : %1.5f\n",[epsilon est_epsilon abs(epsilon-est_epsilon)]);

%% TEST
% figure;
% test_comp_rx_pss = rx_pss .* conj(CFO(est_epsilon,N_IFFT,N_IFFT+N_CP));
% test_fft_rx_pss = 1 / sqrt(N_IFFT) * fftshift(fft(test_comp_rx_pss(19:end),N_IFFT));
% 
% scatter(real(test_fft_rx_pss(65:191)),imag(test_fft_rx_pss(65:191)));
% xlim([-1.5 1.5]);
% ylim([-1.5 1.5]);
% grid on;