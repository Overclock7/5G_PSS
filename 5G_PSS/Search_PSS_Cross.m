
N_IFFT = 256;
N_CP = 18;
N_THRE = 127;
Nid2 = -1;

epsilon = 4/3;

% Read .mat file
rx = matfile("rx_data_4.mat");
rx_data = rx.xr;

% Reference Signal
tx_pss0 = sqrt(N_IFFT) * ifft(ifftshift(PSS(0)),N_IFFT);
tx_pss1 = sqrt(N_IFFT) * ifft(ifftshift(PSS(1)),N_IFFT);
tx_pss2 = sqrt(N_IFFT) * ifft(ifftshift(PSS(2)),N_IFFT);


% %% For Finding Threshold
% corr = zeros(1,length(rx_data));
% 
% for i = 1+N_CP:length(rx_data)-(N_IFFT-1)
% 
%     selected_data = rx_data(i-N_CP:i+N_IFFT-1).*conj(CFO(1,N_IFFT,N_IFFT+N_CP));
% 
%     corr(i-N_CP) = abs(xcorr(selected_data(1+N_CP:end),tx_pss0,0));
% end
% figure;
% stem(corr);

%% Cross-correlation PSS Detection
for i = 1+N_CP:length(rx_data)-(N_IFFT-1)

    selected_data = rx_data(i-N_CP:i+N_IFFT-1);

    rx_data_comp_M1 = selected_data .* conj(CFO(-1,N_IFFT,N_IFFT+N_CP));
    rx_data_comp_00 = selected_data;
    rx_data_comp_P1 = selected_data .* conj(CFO(1,N_IFFT,N_IFFT+N_CP));

    corr = [
        abs(xcorr(rx_data_comp_M1(1+N_CP:end),tx_pss0,0)) ...
        abs(xcorr(rx_data_comp_00(1+N_CP:end),tx_pss0,0)) ...
        abs(xcorr(rx_data_comp_P1(1+N_CP:end),tx_pss0,0)) ...
        abs(xcorr(rx_data_comp_M1(1+N_CP:end),tx_pss1,0)) ...
        abs(xcorr(rx_data_comp_00(1+N_CP:end),tx_pss1,0)) ...
        abs(xcorr(rx_data_comp_P1(1+N_CP:end),tx_pss1,0)) ...
        abs(xcorr(rx_data_comp_M1(1+N_CP:end),tx_pss2,0)) ...
        abs(xcorr(rx_data_comp_00(1+N_CP:end),tx_pss2,0)) ...
        abs(xcorr(rx_data_comp_P1(1+N_CP:end),tx_pss2,0)) ...
    ];

    [corr_max,corr_max_idx] = max(corr);

    if corr_max > 35000
        break;
    end
end

switch ceil(corr_max_idx/3)
    case 1
        Nid2 = 0;
        tx_pss = tx_pss0;
        switch mod(corr_max_idx,3)
            case 1
                comp_rx_pss = rx_data_comp_M1;
                est_epsilon_i = -1;
            case 2
                comp_rx_pss = rx_data_comp_00;
                est_epsilon_i = 0;
            case 0
                comp_rx_pss = rx_data_comp_P1;
                est_epsilon_i = 1;
        end
    case 2
        Nid2 = 1;
        tx_pss = tx_pss1;
        switch mod(corr_max_idx,3)
            case 1
                comp_rx_pss = rx_data_comp_M1;
                est_epsilon_i = -1;
            case 2
                comp_rx_pss = rx_data_comp_00;
                est_epsilon_i = 0;
            case 0
                comp_rx_pss = rx_data_comp_P1;
                est_epsilon_i = 1;
        end
    case 3
        Nid2 = 2;
        tx_pss = tx_pss2;
        switch mod(corr_max_idx,3)
            case 1
                comp_rx_pss = rx_data_comp_M1;
                est_epsilon_i = -1;
            case 2
                comp_rx_pss = rx_data_comp_00;
                est_epsilon_i = 0;
            case 0
                comp_rx_pss = rx_data_comp_P1;
                est_epsilon_i = 1;
        end
end
part_comp_rx_pss = comp_rx_pss(1+N_CP:end);

corr_est_cfo = conj(sum(part_comp_rx_pss(1:1+N_IFFT/2-1).*conj(tx_pss(1:1+N_IFFT/2-1)))) * sum(part_comp_rx_pss(1+N_IFFT/2:1+N_IFFT-1).*conj(tx_pss(1+N_IFFT/2:1+N_IFFT-1)));
est_epsilon_f = (1/(pi)) * angle(corr_est_cfo);

est_epsilon = est_epsilon_i + est_epsilon_f;

fprintf("Epsilon : %+1.5f || Estimation Epsilon : %+1.5f || Error : %1.5f\n",[epsilon est_epsilon abs(epsilon-est_epsilon)]);

test_rx_pss = comp_rx_pss .* conj(CFO(est_epsilon_f,N_IFFT,N_IFFT+N_CP));
test_fft_rx_pss = 1 / sqrt(N_IFFT) * fftshift(fft(test_rx_pss(1+N_CP:end),N_IFFT));
scatter(real(test_fft_rx_pss(65:191)),imag(test_fft_rx_pss(65:191)));