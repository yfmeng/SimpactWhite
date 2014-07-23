function parameters= ageMixingStructParameters
%%
parameters = lhsdesign(500,10);
%formation
parameters(:,1)=1-parameters(:,1)*0.1;%mean age factor
parameters(:,2)=parameters(:,2)*10;%prefered age
parameters(:,3)=0.99-parameters(:,3)*0.24;%age difference factor
parameters(:,4)=(5+(parameters(:,4)))/300;%baseline
%age structure
parameters(:,5)= 20+parameters(:,5)*25;% weibull scale 20-45
parameters(:,6)= 1+parameters(:,6);% weibull shape 1-2
%sex freq
parameters(:,7)=1.5+parameters(:,7)*0.5;%baseline 2-4
parameters(:,8)=0.99+parameters(:,8)*0.01;%female_age_factor
parameters(:,9)=0.99+parameters(:,9)*0.01;%mean_age_factor
parameters(:,10)=0.975+parameters(:,10)*0.05;%age_difference_factor
p.p = parameters;
save p;
end