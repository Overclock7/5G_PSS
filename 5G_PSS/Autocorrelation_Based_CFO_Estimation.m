
N_IFFT = 256;
N_THRE = 127;
N_CP = 18;
% SNR_dB = -9;
Max_Freq_Offset = 4/3;
Max_Epsilon_Integer = round(Max_Freq_Offset);

%% PSS Freq Domain Reference
pss_reference = PSS(0);
pss_reference = pss_reference(57:183);

%% Random Sector ID PSS
Nid2 = randi([0 2],1);
pss = PSS(Nid2);

%% Tx Signal
tx_pss = sqrt(N_IFFT) * ifft(pss,N_IFFT);
P_avg = sum(abs(tx_pss).^2) / N_IFFT;

%% CFO
epsilon = Max_Freq_Offset * rand() * (-1)^randi([0,1],1,1);
cfo = CFO(epsilon,N_IFFT,N_IFFT+N_CP);

%% AWGN
% awgn_complex = AWGN_Complex(SNR_dB,P_avg,N_IFFT+N_CP);

%% Rx Signal ( Perfect Symbol Timing )
rx_pss = [tx_pss(N_IFFT-(N_CP-1):N_IFFT) tx_pss].* cfo;

%% Autocorrelation Based CFO Estimation
R_p = sum(rx_pss(1+N_CP+1:1+N_CP+(N_IFFT/2-1)).*rx_pss(1+N_CP+N_IFFT-1:-1:1+N_CP+N_IFFT-(N_IFFT/2-1)));
R_c = sum(rx_pss(1+N_CP+1:1+N_CP+N_CP).*rx_pss(1+N_CP-1:-1:1+N_CP-N_CP));
e_f = (1/(2*pi))*angle(R_p.*conj(R_c));

%% CFO Compensation & Filter
% comp_rx_pss = rx_pss(1:N_IFFT+N_CP) .* conj(CFO(e_f,N_IFFT,N_IFFT+N_CP));
% part_comp_rx_pss = comp_rx_pss(N_CP+1:N_CP+N_IFFT);
part_comp_rx_pss = rx_pss(N_CP+1:N_CP+N_IFFT) .* conj(CFO(e_f,N_IFFT,N_IFFT));

%% IFFT
ifft_rx_pss = 1/sqrt(N_IFFT) * fft(part_comp_rx_pss,N_IFFT);

%% Find Epsilon_i & Sector ID
m = -86-Max_Epsilon_Integer:0+Max_Epsilon_Integer;
corr_result = zeros(1,length(m));

for i = 1:length(m)
    corr_result(i) = abs(sum(ifft_rx_pss(57:183).*circshift(pss_reference,m(i))));
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
    fprintf("Out of Max Epsilon Integer");
end
  

est_epsilon = e_i + e_f;

fprintf("Epsilon : %+1.5f || Estimation Epsilon : %+1.5f || Error : %1.5f\n",[epsilon est_epsilon abs(epsilon-est_epsilon)]);

%% Plot
% stem(m,corr_result);
% title("Correlation Result between Rx Signal and Reference PSS");
% xlabel("Index of Shift");
% xlim([m(1) m(end)]);
