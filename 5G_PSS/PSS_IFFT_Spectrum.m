
N_IFFT = 256;

x = 0:(N_IFFT-1);
y = 0:239;

%% PSS
pss = PSS(0);

%% IFFT
pss_ifft = sqrt(N_IFFT)*ifft(pss,N_IFFT);

%% plot


subplot(2,2,[1,2]);

stem(y,pss);
xlim([x(1) x(end)]);
ylim([-1 1]);
title("Cell Sector ID 0 PSS Spectrum in Freq Domain");
xlabel("Freq Index");
ylabel("Real");


subplot(2,2,3)
stem(x,real(pss_ifft));
xlim([x(1) x(end)]);
ylim([-1.5 1.5]);
title("Cell Sector ID 0 PSS Real Part Spectrum in Time Domain");
xlabel("Time Index");
ylabel("Real");

subplot(2,2,4);
stem(x,imag(pss_ifft));
xlim([x(1) x(end)]);
ylim([-1.5 1.5]);
title("Cell Sector ID 0 PSS Imag Part Spectrum in Time Domain");
xlabel("Time Index");
ylabel("Imag");