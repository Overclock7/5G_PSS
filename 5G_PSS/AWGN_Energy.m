 

E_avg = 127/256;

for i = 1:1e6
awgn_complex = AWGN_Complex(0,E_avg,256);
k = fft(awgn_complex,256);
m = k(57:183);
l(i) = sum(abs(m).^2)/127;
end

histogram(l,"Normalization","pdf");
result = mean(l);