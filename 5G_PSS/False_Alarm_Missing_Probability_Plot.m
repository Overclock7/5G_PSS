
%% Parameter
SNR_dB = -3;

%% Figure
f1 = figure();
figure(f1);

grid on;
hold on;

title("False Alarm & Missing Probability (SNR\_dB = "+num2str(SNR_dB)+")");
xlabel("Threshold");
ylabel("Probability");
yscale("log");
fontsize(f1,12,"points");
ylim([10e-5 1]);
xlim([-0.1 127]);


%% Data
false_alarm = [
        Autocorrelation_Based_False_Alarm_Probability(SNR_dB);
        Crosscorrelation_Based_False_Alarm_Probability(SNR_dB);
    ];

missing = [
        Autocorrelation_Based_Missing_Probability(SNR_dB);
        Crosscorrelation_Based_Missing_Probability(SNR_dB);
    ];

%% Report Data (False Alarm)
% PF = Proposed(Auto) False Alarm
% CF = Conventional(Cross) False Alarm
% I = Index
% D = Data
PF_M3_I = [0 5 10 15 20 25];
PF_M3_D = [0 6.5*10^-1 2*10^-1 2*10^-2 1.5*10^-3 4.5*10^-5];

CF_M3_I = [0 5 10 15 20 25 30 35];
CF_M3_D = [0 9.8*10^-1 8*10^-1 4*10^-1 10^-1 1.7*10^-2 1.8*10^-3 1.1*10^-4];

PF_0_I = [0 5 10];
PF_0_D = [0 1.9*10^-1 1.5*10^-3];

CF_0_I = [0 5 10 15 20 25];
CF_0_D = [0 9*10^-1 3.5*10^-1 7*10^-2 4*10^-3 9*10^-5];

%% Semilogy
s1 = semilogy(false_alarm(1,:),"-^","Color","#0072BD","LineWidth",2,"MarkerIndices",1:5:length(false_alarm(1,:)));
s2 = semilogy(false_alarm(2,:),"-o","Color","#D95319","LineWidth",2,"MarkerIndices",1:5:length(false_alarm(2,:)));
% % For Report Data
% if SNR_dB == -3
%     s3 = semilogy(PF_M3_I,PF_M3_D,"Color","#EDB120","Marker","o");
%     s4 = semilogy(CF_M3_I,CF_M3_D,"Color","#7E2F8E","Marker","o");
% elseif SNR_dB == 0
%     s3 = semilogy(PF_0_I,PF_0_D,"Color","#EDB120","Marker","o");
%     s4 = semilogy(CF_0_I,CF_0_D,"Color","#7E2F8E","Marker","o");
% end


s5 = semilogy(missing(1,:),"--^","Color","#0072BD","LineWidth",2,"MarkerIndices",1:5:length(missing(1,:)));
s6 = semilogy(missing(2,:),"--o","Color","#D95319","LineWidth",2,"MarkerIndices",1:5:length(missing(2,:)));
% semilogy(missing(3,:),"Color","#EDB120","Marker","o");
% semilogy(missing(4,:),"Color","#7E2F8E","Marker","o");


%% For Legend Marker
s7 = semilogy(-1,1,"LineStyle","-","Marker","none","Color","#000000","LineWidth",2);
s8 = semilogy(-1,1,"LineStyle","--","Marker","none","Color","#000000","LineWidth",2);
s9 = semilogy(-1,1,"LineStyle","none","Marker","o","Color","#D95319","LineWidth",2);
s10 = semilogy(-1,1,"LineStyle","none","Marker","^","Color","#0072BD","LineWidth",2);

%% Legend
% legend([s1,s2,s3,s4],{"Auto","Cross","Proposed","Conventional"},"AutoUpdate","off");
legend([s7,s8,s9,s10],{"P_{False Alarm}","P_{Missing}","Cross-correlation Based","Auto-correlation Based"},"AutoUpdate","off","Location",'southeast');
hold off;