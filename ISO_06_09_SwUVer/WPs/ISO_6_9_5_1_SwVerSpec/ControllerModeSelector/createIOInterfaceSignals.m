%% Acceleration can  be -10 to 10
acceleration = [-10.2, -10,-3:2,10];
deceleration = [-10.2,-10,0, 2.3, 5.8, 9.8, 10,20];
watchdog_brake = [BrStatus.NoBrake, BrStatus.PB1Brake, BrStatus.PB2Brake, BrStatus.FBrake];

allcombs = combvec(acceleration, deceleration, watchdog_brake)';
acceleration = allcombs(:,1);
deceleration = allcombs(:,2);
watchdog_brake = allcombs(:,3);

baseline = acceleration;

wdg_out = watchdog_brake>0;
baseline(wdg_out)=-1*deceleration(wdg_out);

baseline(baseline>2)=2;
baseline(baseline<-10)=-10;

Ts = 0.1; 
time = 0:0.1:0.1*length(baseline)-0.1;
clear Ts