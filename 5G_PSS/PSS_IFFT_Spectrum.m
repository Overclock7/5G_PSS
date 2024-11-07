
N_IFFT = 256;

x = 0:(N_IFFT-1);
y = 0:(N_IFFT-1);

%% PSS
pss = PSS(0);

%% IFFT
pss_ifft = sqrt(N_IFFT)*ifft(ifftshift(pss),N_IFFT);

%% plot


subplot(1,3,1);

stem(y,pss);
xlim([x(1) x(end)]);
ylim([-1.5 1.5]);
title("PSS Spectrum in Freq. Domain");
xlabel("Freq Index");
ylabel("PSS");
pbaspect([1 1 1]);
grid on;


subplot(1,3,2);
stem(x,real(pss_ifft));
xlim([x(1) x(end)]);
ylim([-1.5 1.5]);
title("PSS Real Part Spectrum in Time Domain");
xlabel("Time Index");
ylabel("Real");
pbaspect([1 1 1]);
grid on;

subplot(1,3,3);
stem(x,imag(pss_ifft));
xlim([x(1) x(end)]);
ylim([-1.5 1.5]);
title("PSS Imag Part Spectrum in Time Domain");
xlabel("Time Index");
ylabel("Imag");
pbaspect([1 1 1]);
grid on;