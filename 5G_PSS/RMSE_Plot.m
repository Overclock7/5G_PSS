
for i = 1:16
    k(i) = (2*i-12);
    rmse_auto(i) = Autocorrelation_Based_CFO_Estimation_RMSE(k(i));
    rmse_cross(i) = Crosscorrelation_Based_CFO_Estimation_RMSE(k(i));
    fprintf("%d\n",i);
end

plot(k,rmse_cross,"-o");
hold on;
plot(k,rmse_auto,"--o");
xlabel("SNR(dB)");
ylabel("Normalized Residual Frequency Offset");
legend({"Conventional","Proposed"});
xlim([k(1) k(end)]);
grid on;