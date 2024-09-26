
threshold = 1:127;

[false_alarm_probability_0dB, missing_probability_0dB] =  False_Alarm_Miss_Probability_Fast(0);
[false_alarm_probability_3dB, missing_probability_3dB] =  False_Alarm_Miss_Probability_Fast(3);
[false_alarm_probability_6dB, missing_probability_6dB] =  False_Alarm_Miss_Probability_Fast(6);
[false_alarm_probability_9dB, missing_probability_9dB] =  False_Alarm_Miss_Probability_Fast(9);
[false_alarm_probability_12dB, missing_probability_12dB] =  False_Alarm_Miss_Probability_Fast(12);

hold on;

title("False Alarm / Missing Probability");

plot(threshold,false_alarm_probability_0dB,"-om");
plot(threshold,false_alarm_probability_3dB,"-or");
plot(threshold,false_alarm_probability_6dB,"-ok");
plot(threshold,false_alarm_probability_9dB,"-og");
plot(threshold,false_alarm_probability_12dB,"-ob");

plot(threshold,missing_probability_0dB,"-om");
plot(threshold,missing_probability_3dB,"-or");
plot(threshold,missing_probability_6dB,"-ok");
plot(threshold,missing_probability_9dB,"-og");
plot(threshold,missing_probability_12dB,"-ob");

xlabel("Threshold");
ylabel("Probability");
legend("0dB","3dB","6dB","9dB","12dB");

hold off;
