
function cfo = CFO(epsilon,N_FFT,Length)

%% Carrier Frequency Offset (CFO)
cfo = zeros(1,Length);
for n=0:Length-1
    cfo(n+1) = exp(2*1i*pi*epsilon*n/N_FFT);
end

% % Plot
% plot(real(cfo),imag(cfo),"-o");
% xlim([-1.1 1.1]);
% ylim([-1.1 1.1]);
% grid on;