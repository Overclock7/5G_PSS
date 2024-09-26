
%% Plot

grid on;
hold on;

SNR_dB = -3;

title("False Alarm & Missing Probability (SNR\_dB = "+num2str(SNR_dB)+")");
xlabel("Threshold");
ylabel("Probability");
yscale("log");
xlim([-0.1 127]);


% false_alarm = [
%     Crosscorrelation_Based_False_Alarm_Probability(-3);
%     Crosscorrelation_Based_False_Alarm_Probability(0);
%     Crosscorrelation_Based_False_Alarm_Probability(3);
%     Crosscorrelation_Based_False_Alarm_Probability(6);
%     Crosscorrelation_Based_False_Alarm_Probability(9);
%     Crosscorrelation_Based_False_Alarm_Probability(12);
%     ];

% missing = [
%     Crosscorrelation_Based_Missing_Probability(-3);
%     Crosscorrelation_Based_Missing_Probability(0);
%     Crosscorrelation_Based_Missing_Probability(3);
%     Crosscorrelation_Based_Missing_Probability(6);
%     Crosscorrelation_Based_Missing_Probability(9);
%     Crosscorrelation_Based_Missing_Probability(12);
%     ];

false_alarm = [
        Autocorrelation_Based_False_Alarm_Probability(SNR_dB);
        Crosscorrelation_Based_False_Alarm_Probability(SNR_dB);
    ];

missing = [
        Autocorrelation_Based_Missing_Probability(SNR_dB);
        Crosscorrelation_Based_Missing_Probability(SNR_dB);
    ];

PF_M3_I = [0 5 10 15 20 25];
PF_M3_D = [0 6.5*10^-1 2*10^-1 2*10^-2 1.5*10^-3 4.5*10^-5];

CF_M3_I = [0 5 10 15 20 25 30 35];
CF_M3_D = [0 9.8*10^-1 8*10^-1 4*10^-1 10^-1 1.7*10^-2 1.8*10^-3 1.1*10^-4];

PF_0_I = [0 5 10];
PF_0_D = [0 1.9*10^-1 1.5*10^-3];

CF_0_I = [0 5 10 15 20 25];
CF_0_D = [0 9*10^-1 3.5*10^-1 7*10^-2 4*10^-3 9*10^-5];

s1 = semilogy(false_alarm(1,:),"Color","#0072BD");
s2 = semilogy(false_alarm(2,:),"Color","#D95319");
if SNR_dB == -3
    s3 = semilogy(PF_M3_I,PF_M3_D,"Color","#EDB120","Marker","o");
    s4 = semilogy(CF_M3_I,CF_M3_D,"Color","#7E2F8E","Marker","o");
elseif SNR_dB == 0
    s3 = semilogy(PF_0_I,PF_0_D,"Color","#EDB120","Marker","o");
    s4 = semilogy(CF_0_I,CF_0_D,"Color","#7E2F8E","Marker","o");
end

% semilogy(false_alarm(5,:),"Color","#77AC30","Marker","o");
% semilogy(false_alarm(6,:),"Color","#A2142F","Marker","o");

s5 = semilogy(missing(1,:),"Color","#0072BD");
s6 = semilogy(missing(2,:),"Color","#D95319");
% semilogy(missing(3,:),"Color","#EDB120","Marker","o");
% semilogy(missing(4,:),"Color","#7E2F8E","Marker","o");
% semilogy(missing(5,:),"Color","#77AC30","Marker","o");
% semilogy(missing(6,:),"Color","#A2142F","Marker","o");

legend([s1,s2,s3,s4],{"Auto","Cross","Proposed","Conventional"},"AutoUpdate","off");

hold off;