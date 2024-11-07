
N_IFFT = 256;
N_CP = 18;
N_THRE = 127;

% Read .mat file
rx = matfile("rx_data.mat");
data = rx.xr;

% Correlation Result
auto_correlation = zeros(1,length(data)-N_IFFT);
count = 0;

Eavg = sum(abs(data).^2)/length(data);
normalized_data = sqrt(N_THRE/N_IFFT) * sqrt(1/Eavg) .* data;

% Autocorrelation
for i = 1:length(data)-N_IFFT
    selected_data = normalized_data(i:i+N_IFFT-1);
   
    auto_correlation(i) = abs(sum(selected_data(1+1:1+(N_IFFT/2-1)) .* selected_data(1+(N_IFFT-1):-1:1+N_IFFT-(N_IFFT/2 - 1))));

    if auto_correlation(i) >= 63.5
        count = count + 1;
    end
end

%CFAR

%