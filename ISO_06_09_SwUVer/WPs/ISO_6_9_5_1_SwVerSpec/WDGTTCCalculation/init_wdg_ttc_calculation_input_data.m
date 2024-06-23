Ts = 0.1;

mioDistance = 0:20:1000;
mioVelocity = [-140:20:-10, -1,0,1 ,10:20:140];



allcombs = combvec(mioDistance, mioVelocity)';
mioDistance = allcombs(:,1);
mioVelocity = allcombs(:,2);


Ts = 0.1; 
time = 0:Ts:Ts*length(mioDistance)-Ts;
clear Ts;   
