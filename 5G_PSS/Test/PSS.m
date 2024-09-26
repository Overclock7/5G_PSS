function pss = PSS(Nid2)

% Parameter
% Nid2 = 0
N_ML = 127;

% LFSR
register = [0 1 1 0 1 1 1]; % Initial Value = [x(0) x(1) x(2) x(3) x(4) x(5) x(6)]
generator_polynomial = [1 0 0 0 1 0 0 1]; % x(i+7) = ( x(i+4) + x(i) ) mod 2
ml_sequence = zeros(1,N_ML);

% Generate N=127 m-Sequence
for i = 1:N_ML
    ml_sequence(i) = register(1); 
    register = [register(2:end) mod(sum(generator_polynomial(1:end-1).*register(1:end)),2)]; % Shift Register
end

% BPSK Modulation
bpsk_ml_sequence = (-1) .^ ml_sequence;

% Make PSS Symbol
pss = [zeros(1,56) circshift(bpsk_ml_sequence,-43*Nid2) zeros(1,57)];




