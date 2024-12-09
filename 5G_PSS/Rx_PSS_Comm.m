clear;
clc;
close;

%% USRP Receiver
% Parameter
gain = 0; 
CenterFrequency = 2e9;
DecimationFactor = 24;
LOoffset = 0;
MasterClockRate = 184.32e6;
SamplesPerFrame = 274;

% USRP
rx = comm.SDRuReceiver(...
     'Platform','X310', ...
     'IPAddress', '192.168.10.2', ...
     'ChannelMapping', 1, ...
     'Gain', gain,...
     'CenterFrequency', CenterFrequency, ...
     'DecimationFactor',DecimationFactor, ...
     'LocalOscillatorOffset', LOoffset, ...
     'ClockSource','External', ...
     'MasterClockRate', MasterClockRate, ...
     'OutputDataType','double');
rx.SamplesPerFrame = SamplesPerFrame;

% Receive
numFrames = 2000; 
xr = zeros(1 , SamplesPerFrame * numFrames);
overrun_xr = zeros(1,numFrames);
for frame = 0 : numFrames - 1  
    [data,dataLen,overrun] = rx();
   
    xr( SamplesPerFrame * frame + 1 : SamplesPerFrame * frame + SamplesPerFrame ) = data;
    overrun_xr(frame+1) = overrun;

    
end

release(rx);