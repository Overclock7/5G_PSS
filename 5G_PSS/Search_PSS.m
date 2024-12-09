
close;
clear;
clc;

N_IFFT = 256;
N_CP = 18;
N_THRE = 127;


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

figure;
s1 = stem(-28:265,real(rx_data),'Color','#EA4335');
grid on;
hold on;
s2 = stem(0:255,real(rx_data(29:284)),'Color','#34A853');
s3 = stem(-18:-1,real(rx_data(11:28)),'Color','#FBBC05');
legend([s1 s2 s3],{"Zero Padding","PSS","Cyclic Prefix"},"AutoUpdate","off","Location",'northeast')
title("Received PSS Sample (CFO="+num2str(epsilon)+")");
xlabel("Sample Index");
ylabel("Amplitude");


%% Reference Signal
tx_pss0 = sqrt(N_IFFT) * ifft(ifftshift(PSS(0)),N_IFFT);
tx_pss1 = sqrt(N_IFFT) * ifft(ifftshift(PSS(1)),N_IFFT);
tx_pss2 = sqrt(N_IFFT) * ifft(ifftshift(PSS(2)),N_IFFT);

%% For Finding Threshold (Cross)

for i = 1+N_CP:length(rx_data)-(N_IFFT-1)

    selected_data_cross = rx_data(i-N_CP:i+N_IFFT-1).*conj(CFO(epsilon_i,N_IFFT,N_IFFT+N_CP));

    corr_cross(i) = abs(xcorr(selected_data_cross(1+N_CP:end),tx_pss0,0));
end

figure;
stem(0:38,corr_cross);
grid on;
title("Cross-corr based PSS Detection Result (CFO="+num2str(epsilon)+")");
xlabel("\tau");
ylabel("Correlation Result(\tau)");


%% For Finding Threshold (Auto)
for k = 1+N_CP:length(rx_data)-(N_IFFT-1)

    selected_data_auto = rx_data(k-N_CP:k+N_IFFT-1);

    corr_auto(k) = abs(sum(selected_data_auto(1+N_CP+1:1+N_CP+(N_IFFT/2 -1)) .* selected_data_auto(1+N_CP+(N_IFFT-1):-1:1+N_CP+N_IFFT-(N_IFFT/2 - 1))));

end

figure;
stem(0:38,corr_auto);
grid on;
title("Auto-corr based PSS Detection Result (CFO="+num2str(epsilon)+")");
xlabel("\tau");
ylabel("Correlation Result(\tau)");

