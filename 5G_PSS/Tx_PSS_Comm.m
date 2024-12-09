clear;
clc;
close;

N_IFFT = 256;
N_CP = 18;
% SNR_dB = 0;
% Epsilon = 4/3;

%% Input Cell Sector ID
Nid2 = input('Cell Sector ID = ');

%% PSS
pss = PSS(Nid2);

%% PSS Symbol
ifft_pss = sqrt(N_IFFT)*ifft(ifftshift(pss),N_IFFT);

%% Add CP
xt_pss = [ifft_pss(end-(N_CP-1):end) ifft_pss];

%% Calculate Eavg
Eavg = sum(abs(ifft_pss).^2)/length(ifft_pss);

% %% AWGN & CFO
% awgn = AWGN_Complex(SNR_dB,Eavg,N_CP+N_IFFT);
% cfo = CFO(Epsilon,N_IFFT,N_CP+N_IFFT);

%% Rx Signal
xt_pss = xt_pss;

%% Add Zeros (30kHz, 20ms)
xt_zeros = zeros(1,274);

zeros_rep19 = repmat(xt_zeros,1,19);
zeros_rep3 = repmat(xt_zeros,1,3);
zeros_rep4 = repmat(xt_zeros,1,4);
zeros_rep536 = repmat(xt_zeros,1,536);

xt = [zeros_rep3 xt_pss zeros_rep4];

% xt = [
%     zeros_rep4 ...         % 00 ~ 03
%     xt_pss zeros_rep3 ...  % 04 ~ 07
%     xt_pss zeros_rep3 ...  % 08 ~ 11
%     zeros_rep4 ...         % 12 ~ 15
%     xt_pss zeros_rep3 ...  % 16 ~ 19
%     xt_pss zeros_rep3 ...  % 20 ~ 23
%     zeros_rep536 ...       % 24 ~ 559
%     ];                          


%% USRP Transmitter
% Parameter
Gain=27;
CenterFrequency=2e9;
InterpolationFactor=24;
LOoffset = 0;
MasterClockRate=184.32e6;

% SamplingFrequency = MasterClockRate / InterpolationFactor
% SubCarrierSpacing = SamplingFrequency / Nfft
% SamplesPerFrame = 274 Sample of 1 Symbol  (Nfft + Ncp = 274)

% USRP
tx = comm.SDRuTransmitter(...
     'Platform','X310', ...
     'IPAddress', '192.168.10.2', ...
     'ChannelMapping', 1, ...
     'Gain',Gain,...
     'CenterFrequency', CenterFrequency, ...
     'InterpolationFactor',InterpolationFactor, ...
     'LocalOscillatorOffset', LOoffset, ...
     'ClockSource','External', ...
     'MasterClockRate', MasterClockRate);

% Transmit
while (1)
    step(tx,transpose(xt));
end