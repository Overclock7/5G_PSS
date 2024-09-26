clc;
clear;

N = 2^18;

SNR_dB = 10;
SNR = 10^(SNR_dB/10);

% AWGN (Real)
N0_real = 1/SNR; % Es = 1
sigma_real = sqrt(N0_real); % Sharetechnote : sigma = sqrt(Es/SNR)
noise_real = sigma_real.*randn(1,N);
fprintf("Sharetechnote Real = Mean %d , Sigma %d\n",mean(noise_real),sqrt(var(noise_real)));

% AWGN (Complex)
N0_complex = 1/SNR; % Es = 1
sigma_complex = sqrt(N0_complex/2); % Sharetechnote : sigma = sqrt(Es/(2*SNR))
noise_complex = complex(sigma_complex.*randn(1,N),sigma_complex.*randn(1,N));
fprintf("Sharetechnote Complex = Mean %d , Sigma %d\n",mean(noise_complex),sqrt(var(noise_complex)));

% AWGN in MATLAB (Real)
x1 = (1-2*randi(1,1,N));
Ex1 = mean(abs(x1).^2); % Ex2 = 1
noise_awgn_real = awgn(x1,SNR_dB,pow2db(Ex1),"dB") - x1;
fprintf("Matlab Real = Mean %d , Sigma %d\n",mean(noise_awgn_real),sqrt(var(noise_awgn_real)));

% AWGN in MATLAB (Complex)
x2 = sqrt(1/2) * (1-2*randi(1,1,N)) + sqrt(1/2) * 1i * (1-2*randi(1,1,N));
Ex2 = mean(abs(x2).^2); % Ex1 = 1
noise_awgn_complex = awgn(x2,SNR_dB,pow2db(Ex2),"dB") - x2;
fprintf("Matlab Complex = Mean %d , Sigma %d\n",mean(noise_awgn_complex),sqrt(var(noise_awgn_complex)));

% Gaussian PDF (Real)
k1 = -3*sigma_real : 0.001 : 3*sigma_real;
o1 = sqrt(1/(2*pi*sigma_real^2)) * exp(-1/2 * k1.^2 / sigma_real^2);

% Gaussian PDF (Complex)
k2 = -3*sigma_complex : 0.001 : 3*sigma_complex;
o2 = sqrt(1/(2*pi*sigma_complex^2)) * exp(-1/2 * k2.^2 / sigma_complex^2);

% Rayleigh PDF
k3 = 0 : 0.001 : 8*sigma_complex;
o3 = (k3 ./ (sigma_complex^2)) .* exp((-k3.^2) ./ (2*sigma_complex^2));

% Uniform PDF
k4 = -pi:pi;
o4 = 1/(2*pi);

% Plot
% f1 = figure();
% figure(f1);
% subplot(221);
% title("AWGN Real");
% grid on;
% hold on;
% histogram(real(noise_real),"Normalization","pdf");
% plot(k1,o1);
% hold off;
% 
% subplot(222);
% title("AWGN in MATLAB Real");
% grid on;
% hold on;
% histogram(real(noise_awgn_real),"Normalization","pdf");
% plot(k1,o1);
% hold off;
% 
% subplot(223);
% title("AWGN Complex");
% grid on;
% hold on;
% histogram(real(noise_complex),"Normalization","pdf");
% histogram(imag(noise_complex),"Normalization","pdf");
% plot(k2,o2,"Color",	"#77AC30","LineWidth",2);
% hold off;
% 
% 
% subplot(224);
% title("AWGN in MATLAB Complex");
% grid on;
% hold on;
% histogram(real(noise_awgn_complex),"Normalization","pdf");
% histogram(imag(noise_awgn_complex),"Normalization","pdf");
% plot(k2,o2);
% hold off;

f2 = figure();
figure(f2);
title("AWGN Complex Distribution");
grid on;
hold on;
histogram(real(noise_complex),"Normalization","pdf");
histogram(imag(noise_complex),"Normalization","pdf");
plot(k2,o2,"Color",	"#77AC30","LineWidth",2);
text(0.8,1.8,"N = 2^{18}");
hold off;

f3 = figure();
figure(f3);
grid on;
hold on;
histogram(abs(noise_complex),"Normalization","pdf");
plot(k3,o3,"LineWidth",2);
title("Amplitude Distribution");
hold off;

f4 = figure();
figure(f4);
grid on;
hold on;
histogram(angle(noise_complex),20,"Normalization","pdf");
yline(o4,"LineWidth",2);
xlim([-pi pi]);
title("Phase Distribution");
hold off;