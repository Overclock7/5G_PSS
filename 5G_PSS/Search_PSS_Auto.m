
N_IFFT = 256;
N_CP = 18;
N_THRE = 127;
Nid2 = -1;

% Read .mat file
rx = matfile("rx_data_4.mat");
rx_data = rx.xr;

% %% For Finding Threshold
% for i = 1+N_CP:length(rx_data)-(N_IFFT-1)
% 
%     selected_data = rx_data(i-N_CP:i+N_IFFT-1).*conj(CFO(1,N_IFFT,N_IFFT+N_CP));
% 
%     corr(i-N_CP) = abs(sum(selected_data(1+N_CP+1:1+N_CP+(N_IFFT/2 -1)) .* selected_data(1+N_CP+(N_IFFT-1):-1:1+N_CP+N_IFFT-(N_IFFT/2 - 1))));
% 
% end
% 
% stem(corr)


%% Auto-correlation PSS Detection
for i = 1+N_CP:length(rx_data)-(N_IFFT-1)

    selected_data = rx_data(i-N_CP:i+N_IFFT-1);

    corr = abs(sum(selected_data(1+N_CP+1:1+N_CP+(N_IFFT/2 -1)) .* selected_data(1+N_CP+(N_IFFT-1):-1:1+N_CP+N_IFFT-(N_IFFT/2 - 1))));

    if corr > 10000000
        break
    end
end

%% Rx Signal ( Perfect Symbol Timing )
rx_pss = selected_data;

%% Autocorrelation Based CFO Estimation
R_p = sum(rx_pss(1+N_CP+1:1+N_CP+(N_IFFT/2-1)).*rx_pss(1+N_CP+N_IFFT-1:-1:1+N_CP+N_IFFT-(N_IFFT/2-1)));
R_c = sum(rx_pss(1+N_CP+1:1+N_CP+N_CP).*rx_pss(1+N_CP-1:-1:1+N_CP-N_CP));
est_epsilon_f = (1/(2*pi))*angle(R_p.*conj(R_c));

%% CFO Compensation & Filter
comp_rx_pss = rx_pss .* conj(CFO(est_epsilon_f,N_IFFT,N_IFFT+N_CP));
part_comp_rx_pss = comp_rx_pss(N_CP+1:N_CP+N_IFFT);

%% IFFT
fft_rx_pss = 1/sqrt(N_IFFT) * fftshift(fft(part_comp_rx_pss,N_IFFT));

%% Find Epsilon_i & Sector ID

epsilon = 4/3;
Max_Freq_Offset = 4/3;
Max_Epsilon_Integer = round(Max_Freq_Offset);
pss = PSS(0);
pss_reference = pss(65:191);

m = -86-Max_Epsilon_Integer:0+Max_Epsilon_Integer;
corr_result = zeros(1,length(m));

for i = 1:length(m)
    corr_result(i) = abs(sum(fft_rx_pss(65:191).*circshift(pss_reference,m(i))));
end
[max_result, max_index] = max(corr_result);

if m(max_index) >= 0-Max_Epsilon_Integer && m(max_index) <= 0+Max_Epsilon_Integer
    est_Nid2 = 0;
    est_epsilon_i = m(max_index);
elseif m(max_index) >= -43-Max_Epsilon_Integer && m(max_index) <= -43+Max_Epsilon_Integer
    est_Nid2 = 1;
    est_epsilon_i = m(max_index) + 43;
elseif m(max_index) >= -86-Max_Epsilon_Integer && m(max_index) <= -86+Max_Epsilon_Integer
    est_Nid2 = 2;
    est_epsilon_i = m(max_index) + 86;
else
    fprintf("Out of Max Epsilon Integer");
end


est_epsilon = est_epsilon_i + est_epsilon_f;

fprintf("Epsilon : %+1.5f || Estimation Epsilon : %+1.5f || Error : %1.5f\n",[epsilon est_epsilon abs(epsilon-est_epsilon)]);

%% Plot
figure;
stem(m,corr_result);
title("Correlation Result between Rx Signal and Reference PSS");
xlabel("Index of Shift");
xlim([m(1) m(end)+1 ]);

test_rx_pss = comp_rx_pss .* conj(CFO(est_epsilon_i,N_IFFT,N_IFFT+N_CP));
test_fft_rx_pss = 1 / sqrt(N_IFFT) * fftshift(fft(test_rx_pss(1+N_CP:end),N_IFFT));
scatter(real(test_fft_rx_pss(65:191)),imag(test_fft_rx_pss(65:191)));