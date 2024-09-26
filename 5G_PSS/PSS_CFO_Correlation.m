N_IFFT = 256;

%% PSS
pss_0 = PSS(0);

%% Time Domain
tx_pss = sqrt(N_IFFT) .* ifft(pss_0,N_IFFT);

%% CFO
cfo_0 = CFO(0,N_IFFT,N_IFFT);
cfo_1 = CFO(0.25,N_IFFT,N_IFFT);
cfo_2 = CFO(0.5,N_IFFT,N_IFFT);

%% Rx (Neglect AWGN)
rx_pss_0 = tx_pss .* cfo_0;
rx_pss_1 = tx_pss .* cfo_1;
rx_pss_2 = tx_pss .* cfo_2;

%% Freq Domain
fft_rx_pss_1 = fft(1/sqrt(N_IFFT) .* rx_pss_1,N_IFFT);
part_fft_rx_pss_1 = fft_rx_pss_1(57:183);

%% Correlation
[result0,index0] = xcorr(rx_pss_0,tx_pss);
[result1,index1] = xcorr(rx_pss_1,tx_pss);
[result2,index2] = xcorr(rx_pss_2,tx_pss);

%% Plot
f1 = figure();
figure(f1);

grid on;
subplot(131);
stem(index0,abs(result0));
title("CFO = 0");
xlabel("\tau");
ylabel("R[\tau]");
ylim([0 140]);

subplot(132);
stem(index1,abs(result1));
title("CFO = 0.25");
xlabel("\tau");
ylabel("R[\tau]");
ylim([0 140]);

subplot(133);
stem(index2,abs(result2));
title("CFO = 0.5");
xlabel("\tau");
ylabel("R[\tau]");
ylim([0 140]);


f2 = figure();
figure(f2);

scatter(real(part_fft_rx_pss_1),imag(part_fft_rx_pss_1));
title("PSS Constellation (CFO = 0.25)");
xlabel("Real");
ylabel("Imag");
xlim([-3 3]);
ylim([-3 3]);


