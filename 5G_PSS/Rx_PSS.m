clear;
clc;
close;

% Parameter
DecimationFactor = 24;
MasterClockRate = 184.32e6;
LOoffset = 0;
CenterFrequency = 2e9;
gain = 6; 
SamplesPerFrame = 274;

% Receiver
rx = comm.SDRuReceiver(...
     'Platform','X310', ...
     'IPAddress', '192.168.10.2', ...
     'ChannelMapping', 1, ...
     'SerialNum','F5EB52', ...
     'Gain', gain,...
     'CenterFrequency', CenterFrequency, ... 1|2|3|4
     'DecimationFactor',DecimationFactor, ...
     'LocalOscillatorOffset', LOoffset, ...ff
     'ClockSource','External', ...
     'MasterClockRate', MasterClockRate ...
     );
rx.SamplesPerFrame = SamplesPerFrame;

% Data Memory (30kHz 20ms 560Frames)
numFrames = 20; 
xr = zeros(1 , SamplesPerFrame * numFrames);

for frame = 0 : numFrames - 1  
    [data,overrun] = rx();
   
    xr( SamplesPerFrame * frame + 1 : SamplesPerFrame * frame + SamplesPerFrame ) = data;
    
end
release(rx)