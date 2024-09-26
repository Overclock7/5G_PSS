
function [awgn_complex] = AWGN_Complex(SNR_dB,Pavg,Length)

SNR = 10^(SNR_dB/10);
N0 = Pavg/SNR;
sigma = sqrt(N0/2);
awgn_complex = complex(sigma.*randn(1,Length),sigma.*randn(1,Length));