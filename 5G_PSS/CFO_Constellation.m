
N_IFFT = 256;

%% Make CFO
cfo_1 = CFO(0.1,N_IFFT,N_IFFT);
cfo_2 = CFO(0.2,N_IFFT,N_IFFT);
cfo_3 = CFO(0.3,N_IFFT,N_IFFT);
cfo_4 = CFO(0.4,N_IFFT,N_IFFT);

%% Plot
f1 = figure();
figure(f1);

subplot(221);
scatter(real(cfo_1),imag(cfo_1));
title("CFO = 0.1");
xlabel("Real");
ylabel("Imag");
xlim([-1.1 1.1]);
ylim([-1.1 1.1]);
pbaspect([1 1 1]);
grid on;

subplot(222);
scatter(real(cfo_2),imag(cfo_2));
title("CFO = 0.2");
xlabel("Real");
ylabel("Imag");
xlim([-1.1 1.1]);
ylim([-1.1 1.1]);
pbaspect([1 1 1]);
grid on;

subplot(223);
scatter(real(cfo_3),imag(cfo_3));
title("CFO = 0.3");
xlabel("Real");
ylabel("Imag");
xlim([-1.1 1.1]);
ylim([-1.1 1.1]);
pbaspect([1 1 1]);
grid on;

subplot(224);
scatter(real(cfo_4),imag(cfo_4));
title("CFO = 0.4");
xlabel("Real");
ylabel("Imag");
xlim([-1.1 1.1]);
ylim([-1.1 1.1]);
pbaspect([1 1 1]);
grid on;
