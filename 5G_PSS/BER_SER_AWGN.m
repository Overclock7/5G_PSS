
% Simulation parameters
N_IFFT = 256; 
N_ITER = 1e4;            % Number of bits to simulate

EbN0_dB = 0:0.5:10;
EbN0 = 10.^(EbN0_dB/10);
SNR_bpsk = EbN0;
SNR_bpsk_dB = 10*log10(SNR_bpsk);
SNR_qpsk = 2*EbN0;
SNR_qpsk_dB = 10*log10(SNR_qpsk);

P_bpsk = zeros(size(SNR_bpsk_dB));
P_qpsk = zeros(size(SNR_qpsk_dB));
P_qpsk_b = zeros(size(SNR_qpsk_dB));

for i = 1:length(EbN0_dB)

    fprintf(i+"\n");
    
    % Energy
    Eb_bpsk = 1;
    Es_bpsk = Eb_bpsk;
    Eb_qpsk = 1;
    Es_qpsk = 2 * Eb_qpsk;

    % AWGN
    N0_bpsk= Es_bpsk/SNR_bpsk(i);
    sigma_bpsk = sqrt(N0_bpsk/2);
    
    N0_qpsk= Es_qpsk/SNR_qpsk(i);
    sigma_qpsk = sqrt(N0_qpsk/2);
    
    for iter = 1:N_ITER
        
        % TX
        tx_bpsk = sqrt(Es_bpsk) * (-1).^randi([0 1],1,N_IFFT);
        tx_qpsk = sqrt(Es_qpsk/2) * complex((-1).^randi([0 1],1,N_IFFT),(-1).^randi([0 1],1,N_IFFT));
        detected_bpsk = zeros(1,N_IFFT);
        detected_qpsk = zeros(1,N_IFFT);

        % Add Gaussian noise
        awgn_bpsk = complex(sigma_bpsk.*randn(1,N_IFFT),sigma_bpsk.*randn(1,N_IFFT));
        awgn_qpsk = complex(sigma_qpsk.*randn(1,N_IFFT),sigma_qpsk.*randn(1,N_IFFT));
        
        % RX
        rx_bpsk = tx_bpsk + awgn_bpsk;
        rx_qpsk = tx_qpsk + awgn_qpsk;
        
        % For BPSK
        for j = 1:N_IFFT

            if real(rx_bpsk(j)) > 0
                detected_bpsk(j) = sqrt(Es_bpsk) * 1;
            else
                detected_bpsk(j) = sqrt(Es_bpsk) * -1;
            end
            % Check for errors
            if detected_bpsk(j) ~= tx_bpsk(j)
                P_bpsk(i) = P_bpsk(i) + 1;
            end

        end

        % For QPSK
         for k = 1:N_IFFT 
            
            if real(rx_qpsk(k)) > 0 && imag(rx_qpsk(k)) > 0
                detected_qpsk(k) = sqrt(Es_qpsk/2) * complex(1, 1);
            elseif real(rx_qpsk(k)) < 0 && imag(rx_qpsk(k)) > 0
                detected_qpsk(k) = sqrt(Es_qpsk/2) * complex(-1,1);
            elseif real(rx_qpsk(k)) < 0 && imag(rx_qpsk(k)) < 0
                detected_qpsk(k) = sqrt(Es_qpsk/2) * complex(-1,-1);
            elseif real(rx_qpsk(k)) > 0 && imag(rx_qpsk(k)) < 0
                detected_qpsk(k) = sqrt(Es_qpsk/2) * complex(1,-1);
            end
            
            % Check for errors
            if detected_qpsk(k) ~= tx_qpsk(k)
                P_qpsk(i) = P_qpsk(i) + 1;
            end

            if real(detected_qpsk(k)) ~= real(tx_qpsk(k))
                P_qpsk_b(i) = P_qpsk(i) + 1;
            end

            if imag(detected_qpsk(k)) ~= imag(tx_qpsk(k))
                P_qpsk_b(i) = P_qpsk(i) + 1;
            end
         
         end

    end

end

% Calculate error probability
P_bpsk = P_bpsk / (N_IFFT * N_ITER);
P_qpsk = P_qpsk / (N_IFFT * N_ITER);
P_qpsk_b = P_qpsk_b / (2 * N_IFFT * N_ITER);

% For Compare
theo_SNR_bpsk = 10.^(SNR_bpsk_dB/10); % Sym SNR for BPSK = Es/N0 = Eb/N0
theo_SNR_qpsk = 10.^(SNR_qpsk_dB/10); % Sym SNR for QPSK = Es/N0 = 2Eb/N0
theo_P_bpsk = qfunc(sqrt(2 * theo_SNR_bpsk)); % BPSK => Q(sqrt(2Es/N0))
theo_P_qpsk = 2 * qfunc(sqrt(theo_SNR_qpsk)); % QPSK Sym => 2 * Q(sqrt(Es/N0))
theo_P_qpsk_b = qfunc(sqrt(theo_SNR_qpsk)); % QPSK Bit => Q(sqrt(Es/N0))

%plot
f1 = figure();
figure(f1);
hold on;
yscale('log');
semilogy(SNR_bpsk_dB,P_bpsk,'-^');
% semilogy(SNR_bpsk_dB,theo_P_bpsk,'-^');
% semilogy(SNR_qpsk_dB,P_qpsk,'-o');
% semilogy(SNR_qpsk_dB,theo_P_qpsk,'-*');
semilogy(EbN0_dB,P_qpsk_b,'-*');
% semilogy(EbN0_dB,theo_P_qpsk_b,'-*');
xlabel('SNR per Bit [dB]');
ylabel('P_{Error}');
title('Bit Error Rate');
legend('BPSK','QPSK');
grid on;

