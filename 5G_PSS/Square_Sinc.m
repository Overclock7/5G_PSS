
% Square Pulse

fs = 100e3;     % Sampling
t = -2:1/fs:2;  % Freq
w = 1;          % Bandwidth

x1 = rectpuls(t,w);

f1 = figure();
figure(f1);
plot(t,x1);
ylim([-0.2 1.2]);
xlim([-1 1]);
title('Square');
grid on;

% Sinc Pulse

x2 = -5:1/fs:5; % Time

f2 = figure();
figure(f2);
plot(x2,sinc(x2));
ylim([-0.4 1.2]);
xlim([-3 3]);
title('Sinc');
grid on;