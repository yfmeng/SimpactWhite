
function parameterMatrix = parameterLHS(n)
% this functions generates n conbinitions of parameters
% using a Latin Hypercube Sample created by lhsdesign.m
% requiring MATLAB_R2010aSV.app/toolbox/stats

lhs = lhsdesign(n, 17);
parameterMatrix = zeros(n,17);
parameterMatrix(:,1) =round(lhs(:,1)*50) + 150; % initial no. males/females
parameterMatrix(:, 2) = round(parameterMatrix(:,1).*(0.1+lhs(:,2)*0.1)); % community size
parameterMatrix(:, 3) = lhs(:,3)*0.01; % sex worker proportion

parameterMatrix(:, 4) = log(0.4+lhs(:,4)*0.2)./log(parameterMatrix(:,1)); %formation_BCC.baseline_factor
parameterMatrix(:, 5) = log(lhs(:,5)*0.15+0.05); %formation_BCC.current_relations_factor 
parameterMatrix(:, 6) = 3 + lhs(:, 6)*2; %formation_BCC.preferred_age_difference
parameterMatrix(:, 7) = 0; % log(lhs(:, 7)*0.25); %formation_BCC.community_difference_factor
parameterMatrix(:, 8) = log(1+lhs(:,8)*2); %formation_BCC.transaction_sex_factor
parameterMatrix(:, 9) = 0; % log(1+lhs(:,9)*0.05); %formation_BCC.last_change_factor

parameterMatrix(:,10) = log(1+lhs(:,10)*0.6);% SDS.dissolution.baseline_factor = config(10);
%%%????
parameterMatrix(:, 11) = 0;% -0.01;% -log(lhs(:,11)); %SDS.dissolution.current_relations_factor = config(12);
parameterMatrix(:, 12) = log(1+lhs(:,12)*0.5); %SDS.dissolution.last_change_factor = config(13);
parameterMatrix(:, 13) = log(1+lhs(:,13)); %SDS.dissolution.transaction_sex_factor = config(11);

parameterMatrix(:, 14) = 0.97; % %0.93 + lhs(:,14)*0.06; %SDS.HIV_transmission.infectiousness_decreased_by_ARV= config(14);
parameterMatrix(:, 15) = 2; % 1.5 + lhs(:,15)*1.5; %SDS.HIV_transmission.sexual_behaviour_parameters{2,1}=config(15);
parameterMatrix(:, 16) = log(1-lhs(:,16)*0.1); %SDS.HIV_transmission.sexual_behaviour_parameters{2,9}=config(16);

parameterMatrix(:, 17) = round(parameterMatrix(:,1).*(lhs(:,17)*0.02+0.01)); % number of introduction 2-4%

save fei/result/parameterMatrix.mat parameterMatrix;
save fei/result/latinHypercube.mat lhs;

end
