% SSRS type 2
clear;
close;
clc;

r = 12;
coeffs = [12, 8, 5, 4, 3, 1];  


state = [1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1]; 

sequence_length = 4095;  
sequence = zeros(1, sequence_length);  


for i = 1:sequence_length
    sequence(i) = state(end);
    
    r1 = state(end - coeffs + 1);
   
    feedback = mod(sum(r1), 2);  
    
    state = [feedback, state(1:end-1)];
end

result1 = sequence;


% Parameter
N_ML = 2^12-1;

%% LFSR (Type 2)
% b(D) = [b(-1) b(-2) b(-3) b(-4) b(-5) b(-6) b(-7) b(-8) b(-9) b(-10) b(-11) b(-12)]
register = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
% g(D) = flip([g(12) g(11) g(10) g(9) g(8) g(7) g(6) g(5) g(4) g(3) g(2) g(1) g(0)])
% g(D) = [g(0) g(1) g(2) g(3) g(4) g(5) g(6) g(7) g(8) g(9) g(10) g(11) g(12)]
generating_polynomial = flip([1 1 0 1 1 1 0 0 1 0 0 1 1]);
ml_sequence = zeros(1,N_ML);                              

% Generate N=127 m-Sequence
for i = 1:N_ML
    ml_sequence(i) = mod(sum(generating_polynomial(2:end).*register(1:end)),2);
    % Shift Register
    register = [ml_sequence(i) register(1:end-1)]; 
end

result2 = ml_sequence;