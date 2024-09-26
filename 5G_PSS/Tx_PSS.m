clear
clc

N_IFFT = 256;
N_CP = 18;

Nid2 = input('Cell Sector ID = ');

% PSS
pss = PSS(Nid2);

% PSS Symbol
ifft_pss = sqrt(N_IFFT)*ifft(pss,N_IFFT);

% Add CP
tx_pss = [ifft_pss(end-(N_CP-1):end),ifft_pss];

% Calculate Eavg
Eavg = sum(abs(tx_pss).^2)/length(tx_pss);

% AWGN & CFO
% SNR_dB = 0;
% Epsilon = 1.33 * rand() * (-1) ^ randi([0 1]);
% awgn = AWGN_Complex(SNR_dB,Eavg,N_CP+N_IFFT);
% cfo = CFO(Epsilon,N_IFFT,N_CP+N_IFFT);

% Rx Signal
% rx_pss = tx_pss.*cfo + awgn;

%% USRP
CenterFrequency=2e9;
MasterClockRate=184.32e6;
Gain=16;
InterpolationFactor=24;

tx = comm.SDRuTransmitter(...
     'Platform','X310', ...
     'IPAddress', '192.168.10.2', ...
     'ChannelMapping', 1, ...
     'SerialNum','F06271', ...
     'Gain',Gain,...
     'CenterFrequency', CenterFrequency, ...
     'InterpolationFactor',InterpolationFactor, ...
     'LocalOscillatorOffset', 0, ...
     'ClockSource','Internal', ...
     'MasterClockRate', MasterClockRate);

while (1)
  
    step(tx,(tx_pss(:)))

end