close;
clear;
clc;



%% Read .mat file
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
Max_Freq_Offset = epsilon;
Max_Epsilon_Integer = round(Max_Freq_Offset);

% %% For Finding Threshold
% corr = zeros(1,length(rx_data));
% 
% for i = 1+N_CP:length(rx_data)-(N_IFFT-1)
% 
%     selected_data = rx_data(i-N_CP:i+N_IFFT-1);
% 
%     corr(i-N_CP) = abs(sum(selected_data(1+N_CP+1:1+N_CP+(N_IFFT/2 -1)) .* selected_data(1+N_CP+(N_IFFT-1):-1:1+N_CP+N_IFFT-(N_IFFT/2 - 1))));
% 
% end
% 
% figure;
% stem(corr)


%% Auto-correlation PSS Detection
for i = 1+N_CP:length(rx_data)-(N_IFFT-1)

    selected_data = rx_data(i-N_CP:i+N_IFFT-1);

    corr = abs(sum(selected_data(1+N_CP+1:1+N_CP+(N_IFFT/2 -1)) .* selected_data(1+N_CP+(N_IFFT-1):-1:1+N_CP+N_IFFT-(N_IFFT/2 - 1))));

    if corr > 0.025
        break;
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
pss = PSS(0);
pss_reference = pss(65:191);

m = -86-Max_Epsilon_Integer:0+Max_Epsilon_Integer;
corr_result = zeros(1,length(m));

for k = 1:length(m)
    corr_result(k) = abs(sum(fft_rx_pss(65:191).*circshift(pss_reference,m(k))));
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
title("Constellation (Auto-corr, CFO="+num2str(epsilon)+")");
xlabel("Real");
ylabel("Imag");
xlim([-1.5 1.5]);
ylim([-1.5 1.5]);
grid on;
pbaspect([1 1 1]);