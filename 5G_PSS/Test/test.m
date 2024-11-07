% SSRS type 1

r = 12;
coeffs = [12, 8, 5, 4, 3, 1]; 


state = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]; 

sequence_length = 4095;  
sequence = zeros(1, sequence_length);  

for i = 1:sequence_length
    sequence(i) = state(end);    
    feedback = mod(sum(state(coeffs)), 2);    
    state = [feedback, state(1:end-1)];
end


sequence = 2 * sequence - 1;


auto_corr = zeros(1, sequence_length);  


for k = 0:(sequence_length-1)
    sum_value = 0;
    for n = 1:(sequence_length-k)  
        sum_value = sum_value + sequence(n) * sequence(n + k);
    end
    auto_corr(k + 1) = sum_value;
end


figure;
subplot(2,1,1); 
stem(0:sequence_length-1, (sequence+1)/2, 'o', 'LineWidth', 1.5);  
xlabel('n');
ylabel('b[n]');
title('Stem Plot of Type 1 SSRS');
grid on;
ylim([-0.1 1.1]);


subplot(2,1,2); 
stem(0:(sequence_length-1), auto_corr, 'o', 'LineWidth', 1.5);
xlabel('k');
ylabel('Auto-Correlation');
title('Auto-Correlation of Type 1 SSRS');
grid on;
ylim([-1/sequence_length-0.1 1]);





