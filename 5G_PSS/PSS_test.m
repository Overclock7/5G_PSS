
% Input
% x(D) = [x(6) x(5) x(4) x(3) x(2) x(1) x(0)]
initial_value = [1 1 1 0 1 1 0];
% g(D) = [x(i+7) x(i+6) x(i+5) x(i+4) x(i+3) x(i+2) x(i+1) x(i+0)]
primitive_polynomial = [1 0 0 0 0 0 1 1];
% g(D) : x(i+7) = {x(i+4) + x(i)} mod 2 
n_ml = 2^7-1;

% Parameter
N_ML = n_ml;

%% Freq. Domain

register = initial_value;
generating_polynomial = primitive_polynomial;
ml_sequence = zeros(1,N_ML);                              

% Generate N=127 m-Sequence
for i = 1:N_ML
    ml_sequence(i) = register(end);
    register = [mod(sum(generating_polynomial(2:end).*register(1:end)),2) register(1:end-1)]; % Shift Register
end

% BPSK Modulation
bpsk_ml_sequence = (-1) .^ ml_sequence;
pss_1 = PSS(65:193);
idx = -500:500;
for i = 1:length(idx)
    corr(i) = xcorr(circshift(bpsk_ml_sequence,idx(i)),bpsk_ml_sequence,0);
end

stem(idx,abs(corr));
title("PSS Sequence Auto-Correlation");
xlabel("Index");
ylabel("Correlation Output");
xlim([-253 253]);
ylim([-0.1 130]);

%% Time Domain
% pss = [zeros(1,64) bpsk_ml_sequence zeros(1,65)];
% pss_0 = PSS(0);
% 
% ifft_pss = sqrt(256) * ifft(pss,256);
% 
% idx = -500:500;
% for i = 1:length(idx)
%     corr(i) = 1/256 * xcorr(circshift(ifft_pss,idx(i)),ifft_pss,0);
% end
% 
% stem(1:500,abs(corr));
% title("Time Domain PSS Auto-Correlation");
% xlabel("Sample Index");
% ylabel("Correlation Output");
% xlim([-256 256]);
% ylim([-0.1 1.25]);
% 
% result = isequal(pss,pss_0);
