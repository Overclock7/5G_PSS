% Simulation parameters
N_IFFT = 256; 
N_ITER = 1e5;       % Number of bits to simulate
SNR_dB = 0:10;      % Eb/N0 values in dB
P_e = zeros(size(SNR_dB));

for i = 1:length(SNR_dB)

    fprintf(i+"\n");
    
    Eb = 1; %BPSK
    SNR = 10^(SNR_dB(i)/10);
    N0 = Eb/SNR;
    sigma = sqrt(N0/2);
    
    for iter = 1:N_ITER
        
        % BPSK Data
        data = (-1).^randi([0 1],1,N_IFFT);
        detected_data = zeros(1,N_IFFT);

        tx_signal = sqrt(N_IFFT) * ifft(data,N_IFFT);

        % Add Gaussian noise
        awgn_complex = complex(sigma.*randn(1,N_IFFT),sigma.*randn(1,N_IFFT));
        
        rx_signal = tx_signal + awgn_complex;

        rx_data = 1/sqrt(N_IFFT) * fft(rx_signal,N_IFFT);
        
        % Integrate and Dump
        for k = 1:N_IFFT 
            if real(rx_data(k)) > 0
                detected_data(k) = 1;
            else
                detected_data(k) = -1;
            end
            % Check for errors
            if detected_data(k) ~= data(k)
                P_e(i) = P_e(i) + 1;
            end
        end

    end

end

% Calculate error probability
P_e = P_e / (N_IFFT * N_ITER);

% For Compare
theorical_SNR = 10.^(SNR_dB/10);
theorical_P_e = 1/2.*erfc(sqrt(2.*theorical_SNR)/sqrt(2));

% Plot the results
plot(SNR_dB, P_e);
hold on;
plot(SNR_dB,theorical_P_e);
yscale("log")
xlabel('SNR(dB)');
ylabel('P_E');
title('Error Probability(Simulation)');
legend('Simulation','Theoritical');
grid on;