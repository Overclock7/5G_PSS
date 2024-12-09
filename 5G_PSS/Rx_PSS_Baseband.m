clear;
clc;
close;

%% USRP
CenterFrequency=2e9; %% 2GHz
MasterClockRate=184.32e6;
Gain=0;
InterpolationFactor=24;

% SamplingFrequency = MasterClockRate / InterpolationFactor = 7.68MHz
% SubCarrierSpacing = SamplingFrequency / Nfft = 30kHz
% SamplesPerFrame = 274 Sample of 1 Symbol  (Nfft + Ncp = 274)

bbrx = basebandReceiver("X310",...
                           "CenterFrequency",CenterFrequency,...
                           "Antennas","RFA:RX2",...
                           "RadioGain",Gain,...
                           "SampleRate",MasterClockRate/InterpolationFactor, ...
                           "CaptureDataType","double",...
                           "DroppedSamplesAction","error");

[xr,timestamp,droppedSamples] = capture(bbrx,milliseconds(1/30 * 8 * 267.578));
