
for i = 1:16
    k(i) = (2*i-12);
    rmse_auto(i) = Autocorrelation_Based_CFO_Estimation_RMSE(k(i));
    rmse_cross(i) = Crosscorrelation_Based_CFO_Estimation_RMSE(k(i));
    fprintf("%d\n",i);
end

plot(k,rmse_cross,"-o","LineWidth",2);
hold on;
plot(k,rmse_auto,"--o","LineWidth",2);
xlabel("SNR(dB)");
title("RMSE of Residual Frequency Offset" )
ylabel("Normalized Residual Frequency Offset");
legend({"Cross-Correlation","Auto-Correlation"});
xlim([k(1) k(end)]);
fontsize(12,"points");
grid on;