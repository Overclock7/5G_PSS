% % Read .mat file
% epsilon = 0;
% epsilon_i = 0;
% rx = matfile("data1.mat");
% rx_data = transpose(rx.xr);
% rx_data = rx_data(499988:500281);  %% PSS Location = 499998:500271

epsilon = 4/3;
epsilon_i = 1;
rx = matfile("data2.mat");
rx_data = transpose(rx.xr);
rx_data = rx_data(502008:502301); %% PSS Location = 502018:502291

%% Parameter
N_IFFT = 256;
N_CP = 18;
N_THRE = 127;
Nid2 = -1;

%% Reference Signal
tx_pss0 = sqrt(N_IFFT) * ifft(ifftshift(PSS(0)),N_IFFT);
tx_pss1 = sqrt(N_IFFT) * ifft(ifftshift(PSS(1)),N_IFFT);
tx_pss2 = sqrt(N_IFFT) * ifft(ifftshift(PSS(2)),N_IFFT);

% %% For Finding Threshold
% corr = zeros(1,length(rx_data));
% 
% for i = 1+N_CP:length(rx_data)-(N_IFFT-1)
% 
%     selected_data = rx_data(i-N_CP:i+N_IFFT-1).*conj(CFO(0,N_IFFT,N_IFFT+N_CP));
% 
%     corr(i-N_CP) = abs(xcorr(selected_data(1+N_CP:end),tx_pss0,0));
% end
% 
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

    if corr_max > 2
        break;
    end
end

%% Find Epsilon_i & Sector ID
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

%% Crosscorrelation Based CFO Estimation
part_comp_rx_pss = comp_rx_pss(1+N_CP:end);
corr_est_cfo = conj(sum(part_comp_rx_pss(1:1+N_IFFT/2-1).*conj(tx_pss(1:1+N_IFFT/2-1)))) * sum(part_comp_rx_pss(1+N_IFFT/2:1+N_IFFT-1).*conj(tx_pss(1+N_IFFT/2:1+N_IFFT-1)));
est_epsilon_f = (1/(pi)) * angle(corr_est_cfo);

est_epsilon = est_epsilon_i + est_epsilon_f;

fprintf("Epsilon : %+1.5f || Estimation Epsilon : %+1.5f || Error : %1.5f\n",[epsilon est_epsilon abs(epsilon-est_epsilon)]);

%% TEST

% Compensation
test_rx_pss = selected_data .* conj(CFO(est_epsilon,N_IFFT,N_IFFT+N_CP));
test_part_rx_pss = test_rx_pss(N_CP+1:end);

% FFT
test_fft_rx_pss =  1 / sqrt(N_IFFT) .* fftshift(fft(test_part_rx_pss,N_IFFT));
test_E = sum(abs(test_fft_rx_pss).^2);

% Normalization
test_normalized_fft_rx_pss =  sqrt(127) / sqrt(test_E) .* test_fft_rx_pss;
test_Eavg = sum(abs(test_normalized_fft_rx_pss).^2)/N_IFFT;

% Plot
figure;
scatter(real(test_normalized_fft_rx_pss(65:191)),imag(test_normalized_fft_rx_pss(65:191)));
title("Constellation (Cross-corr, CFO="+num2str(epsilon)+")");
xlabel("Real");
ylabel("Imag");
xlim([-1.5 1.5]);
ylim([-1.5 1.5]);
grid on;
pbaspect([1 1 1]);