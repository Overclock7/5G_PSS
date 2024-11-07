
function rmse = Autocorrelation_Based_CFO_Estimation_RMSE(SNR_dB)

% SNR_dB = -3;
N_ITER = 1e4;
N_IFFT = 256;
N_CP = 18;
Max_Freq_Offset = 1.33;
Max_Epsilon_Integer = round(Max_Freq_Offset) + 21; % Margin for AWGN

%% PSS Freq Domain Reference
pss_reference = PSS(0);
pss_reference = pss_reference(65:191);

%% Epsilon List
epsilon = zeros(1,N_ITER);
est_epsilon = zeros(1,N_ITER);

count = 0;

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

    %% Autocorrelation Based Fraction CFO Estimation
    R_p = sum(rx_pss(1+N_CP+1:1+N_CP+(N_IFFT/2-1)).*rx_pss(1+N_CP+N_IFFT-1:-1:1+N_CP+N_IFFT-(N_IFFT/2-1)));
    R_c = sum(rx_pss(1+N_CP+1:1+N_CP+N_CP).*rx_pss(1+N_CP-1:-1:1+N_CP-N_CP));
    e_f = (1/(2*pi))*angle(R_p.*conj(R_c));

    %% CFO Compensation & Filter
    % comp_rx_pss = rx_pss(1:N_IFFT+N_CP) .* conj(CFO(e_f,N_IFFT,N_IFFT+N_CP));
    % part_comp_rx_pss = comp_rx_pss(N_CP+1:N_CP+N_IFFT);
    part_comp_rx_pss = rx_pss(N_CP+1:N_CP+N_IFFT) .* CFO(-e_f,N_IFFT,N_IFFT);

    %% IFFT
    ifft_rx_pss = 1/sqrt(N_IFFT) * fftshift(fft(part_comp_rx_pss,N_IFFT));

    %% Find Epsilon_i & Sector ID
    m = -86-Max_Epsilon_Integer : 0+Max_Epsilon_Integer;
    corr_result = zeros(1,length(m));

    for k = 1:length(m)
        corr_result(k) = abs(sum(ifft_rx_pss(65:191).*circshift(pss_reference,m(k))));
    end
    [max_result, max_index] = max(corr_result);

    if m(max_index) >= 0-Max_Epsilon_Integer && m(max_index) <= 0+Max_Epsilon_Integer
        est_Nid2 = 0;
        e_i = m(max_index);
    elseif m(max_index) >= -43-Max_Epsilon_Integer && m(max_index) <= -43+Max_Epsilon_Integer
        est_Nid2 = 1;
        e_i = m(max_index) + 43;
    elseif m(max_index) >= -86-Max_Epsilon_Integer && m(max_index) <= -86+Max_Epsilon_Integer
        est_Nid2 = 2;
        e_i = m(max_index) + 86;
    else
        count = count + 1;
        fprintf("SNR_dB: %2d || N_ITER: %6d || count: %3d || Out of Max Epsilon Integer\n",[SNR_dB,i,count]);
    end

    est_epsilon(i) = e_i + e_f;

end

rmse = sqrt(sum((epsilon - est_epsilon).^2) / N_ITER); 


