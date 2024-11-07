clear
clc

N_IFFT = 256;
N_CP = 18;

Nid2 = input('Cell Sector ID = ');

% PSS
pss = PSS(Nid2);

% PSS Symbol
ifft_pss = sqrt(N_IFFT)*ifft(ifftshift(pss),N_IFFT);

% Add CP
xt_pss = [ifft_pss(end-(N_CP-1):end) ifft_pss];

% Calculate Eavg
Eavg = sum(abs(xt_pss).^2)/length(xt_pss);

% AWGN & CFO
SNR_dB = 0;
Epsilon = 1.33;
awgn = AWGN_Complex(SNR_dB,Eavg,N_CP+N_IFFT);
cfo = CFO(Epsilon,N_IFFT,N_CP+N_IFFT);

% Rx Signal
xt_pss = xt_pss.*cfo;

%% SS Block Burst Set (30kHz, 20ms)
xt_zeros = zeros(1,274);

zeros_rep3 = repmat(xt_zeros,1,3);
zeros_rep4 = repmat(xt_zeros,1,4);
zeros_rep536 = repmat(xt_zeros,1,536);

xt = [xt_pss, xt_zeros];

% xt = [
%     zeros_rep4 ...         % 00 ~ 03
%     xt_pss zeros_rep3 ...  % 04 ~ 07
%     xt_pss zeros_rep3 ...  % 08 ~ 11
%     zeros_rep4 ...         % 12 ~ 15
%     xt_pss zeros_rep3 ...  % 16 ~ 19
%     xt_pss zeros_rep3 ...  % 20 ~ 23
%     zeros_rep536 ...       % 24 ~ 559
%     ];                          


%% USRP
CenterFrequency=2e9;
MasterClockRate=184.32e6;
Gain=6;
InterpolationFactor=24;

% SamplingFrequency = MasterClockRate / InterpolationFactor
% SubCarrierSpacing = SamplingFrequency / Nfft
% SamplesPerFrame = 274 Sample of 1 Symbol  ( Nfft + Ncp = 274)

tx = comm.SDRuTransmitter(...
     'Platform','X310', ...
     'IPAddress', '192.168.10.2', ...
     'ChannelMapping', 1, ...
     'Gain',Gain,...
     'CenterFrequency', CenterFrequency, ...
     'InterpolationFactor',InterpolationFactor, ...
     'LocalOscillatorOffset', 0, ...
     'ClockSource','External', ...
     'PPSSource','External', ...
     'MasterClockRate', MasterClockRate);

while (1)

    step(tx,xt(:));

end