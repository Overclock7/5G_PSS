
function cfo = CFO(epsilon,N_FFT,Length)

%% Carrier Frequency Offset (CFO)
cfo = zeros(1,Length);
for i=0:Length-1
    cfo(i+1) = exp(sqrt(-1)*2*pi*epsilon*i/N_FFT);
end

% % Plot
% plot(real(cfo),imag(cfo),"-o");
% xlim([-1.1 1.1]);
% ylim([-1.1 1.1]);
% grid on;