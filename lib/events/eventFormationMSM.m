function varargout = eventFormationMSM(fcn, varargin)
%EVENTFORMATIONMSM SIMPACT event function: partnership formation between
%MSM
% See also modelHIV.

% Copyright 2009-2010 by Hummeling Engineering (www.hummeling.com)

persistent P

if nargin == 0
    return
end

switch fcn
    case 'handle'
        cmd = sprintf('@%s_%s', mfilename, varargin{1});
        
    otherwise
        cmd = sprintf('%s_%s(varargin{:})', mfilename, fcn);
end
[varargout{1:nargout}] = eval(cmd);


%% init
    function [elements, msg, P0] = eventFormationMSM_init(SDS, event, P0)
        
        number_of_MSM = sum(SDS.males.MSM);
        elements = number_of_MSM*number_of_MSM;
        msg = '';
        
        P = event;                      % copy event parameters
        
        
        % ******* Function Handles *******
        P.rand0toInf = spTools('handle', 'rand0toInf');
        P.expLinear = spTools('handle', 'expLinear');
        P.intExpLinear = spTools('handle', 'intExpLinear');
        
        [P.enableDissolutionMSM, thisMsg] = spTools('handle', 'eventDissolutionMSM', 'enable');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        [P.updateDissolutionMSM, thisMsg] = spTools('handle', 'eventDissolutionMSM', 'update');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        [P.updateFormation, thisMsg] = spTools('handle', 'eventFormation', 'update');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        [P.updateDissolution, thisMsg] = spTools('handle', 'eventDissolution', 'update');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        [P.enableTransmissionMSM, thisMsg] = spTools('handle', 'eventTransmissionMSM', 'enable');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        [P.enableTest, thisMsg] = spTools('handle', 'eventTest', 'enable');
        [P.updateTest, thisMsg] = spTools('handle', 'eventTest', 'update');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        % ******* Indices *******
        P.indexStartStop = SDS.index.start | SDS.index.stop;
        P.relation = find(SDS.relationsMSM.ID(:,1), 1, 'last');
        if isempty(P.relation)
            P.relation = 0;
        end
        P.number_of_MSM = sum(SDS.males.MSM);
        P.alpha = -inf(P.number_of_MSM, P.number_of_MSM, SDS.float);
        P.beta = - P.mean_age_factor + P.last_change_factor;
        P.beta = P.beta*ones(P.number_of_MSM, P.number_of_MSM, SDS.float);
        P.rand = Inf(P.number_of_MSM, P.number_of_MSM);
        P.time0 = zeros(P.number_of_MSM, P.number_of_MSM, SDS.float);
        P.eventTimes = inf(P.number_of_MSM, P.number_of_MSM, SDS.float);
        
        % ******* Checks *******
        if P.beta == 0
            P.expLinear = spTools('handle', 'expConstant');
            P.intExpLinear = spTools('handle', 'intExpConstant');
        end
        
        P0.subsetMSM(SDS.males.born(SDS.males.MSM)<-15,SDS.males.born(SDS.males.MSM)<-15) = true;
        P0.birth = false;
     %   P0 = eventFormationMSM_enable(SDS,P0);
        
    end

%% get
    function X = eventFormationMSM_get(t)
        
        X = P;
        
    end


%% restore
    function [elements,msg] = eventFormationMSM_restore(SDS,X)
        
        elements = SDS.number_of_males * SDS.number_of_females;
        msg = '';
        
        P = X;
        P.rand0toInf = spTools('handle', 'rand0toInf');
        P.expLinear = spTools('handle', 'expLinear');
        P.intExpLinear = spTools('handle', 'intExpLinear');
        
        [P.enableDissolutionMSM, thisMsg] = spTools('handle', 'eventDissolutionMSM', 'enable');
        [P.updateDissolutionMSM, thisMsg] = spTools('handle', 'eventDissolutionMSM', 'update');
        [P.updateFormation, thisMsg] = spTools('handle', 'eventFormation', 'update');
        [P.updateDissolution, thisMsg] = spTools('handle', 'eventDissolution', 'update');
        [P.enableTransmissionMSM, thisMsg] = spTools('handle', 'eventTransmissionMSM', 'enable');
        [P.enableTest, thisMsg] = spTools('handle', 'eventTest', 'enable');
        [P.updateTest, thisMsg] = spTools('handle', 'eventTest', 'update');
        if P.beta == 0
            P.expLinear = spTools('handle', 'expConstant');
            P.intExpLinear = spTools('handle', 'intExpConstant');
        end
    end

%% eventTimes
    function eventTimes = eventFormationMSM_eventTimes(~, ~)
        
        eventTimes = P.eventTimes;
    end


%% advance
    function eventFormationMSM_advance(P0)
        
        P.eventTimes = P.eventTimes - P0.eventTime;
    end


%% fire
    function [SDS, P0] = eventFormationMSM_fire(SDS, P0)
        
        % ******* Indices *******
        P.relation = P.relation + 1;
        P0.MSM_1 = rem(P0.index - 1, P.number_of_MSM) + 1;
        P0.MSM_2 = ceil(P0.index/P.number_of_MSM);
        MSM = find(SDS.males.MSM);
        MSM_idx_1 = MSM(P0.MSM_1);
        MSM_idx_2 = MSM(P0.MSM_2);
        P0.currentMSM(P0.MSM_1, P0.MSM_2) = true;
        P0.currentMSM(P0.MSM_2, P0.MSM_1) = true;
        P0.currentMSM(logical(eye(size(P0.currentMSM))))=false;
        % ******* Formation of Relation *******
        
        SDS.relationsMSM.ID(P.relation, :) = [MSM_idx_1, MSM_idx_2];
        SDS.relationsMSM.time(P.relation, P.indexStartStop) = [P0.now, Inf];
        SDS.relationsMSM.proximity(P.relation) = abs(SDS.males.community(MSM_idx_1)-SDS.males.community(MSM_idx_2));
        
        P.enableDissolutionMSM(P0)  % use P0.index   
    
        % ******* Prepare Next *******
        P.eventTimes(P0.index) = Inf;   % block formation
        P.rand(P0.index) = Inf;
        
        % ******* Influence on All Events: Cross *******
        P0.subsetMSM(P0.MSM_1,:)=true;
        P0.subsetMSM(:,P0.MSM_2)=true;
        P0 = eventFormationMSM_update(SDS, P0, 1);
%         P0 = P.updateDissolutionMSM(P0);
%        P0 = eventFormation_update(SDS, P0, 1);
%         P0 = P.updateDissolution(P0);
%         
        P0.index = MSM_idx_1;
        P.updateTest(SDS, P0)
        P0.index = MSM_idx_2;
        P.updateTest(SDS, P0)
        
        if ~isnan(SDS.males.HIV_positive(MSM_idx_2))
            temp = P0.MSM_1;
            P0.MSM_1 = P0.MSM_2;
            P0.MSM_2 = temp;
        end
        if P0.serodiscordantMSM(P0.MSM_1,P0.MSM_2)
        P.enableTransmissionMSM(SDS,P0);
        end
        P.time0(P0.MSM_1,P0.MSM_2) = P0.now;
%         P0.timeSinceLastMSM(P0.MSM_1,:) = 0;
%         P0.timeSinceLastMSM(:,P0.MSM_2) = 0;
    end


%% enable
    function P0 = eventFormationMSM_enable(P0)
        % Invoked by eventDissolutionMSM_fire, eventDebut_fire
        % use P0.subsetMSM
        if ~P.enable
            return
        end
        
        P0.subsetMSM = P0.subsetMSM&~P0.currentMSM&~isfinite(P.eventTimes);
        P0.subsetMSM(~P0.adultMales(P0.MSM),:) = false;
        P0.subsetMSM(:,~P0.adultMales(P0.MSM)) = false;
        P0.subsetMSM=triu(P0.subsetMSM,1);
        P.rand(P0.subsetMSM) = P.rand0toInf(1,sum(sum(P0.subsetMSM)));
        P.alpha(P0.subsetMSM) = P.baseline_factor*P0.partneringMSM(P0.subsetMSM) + ...
            P.current_relations_factor.*P0.relationCountMSM(P0.subsetMSM) + ...
            P.current_relations_difference_factor*P0.relationCountDifferenceMSM(P0.subsetMSM)+ ...
            P.mean_age_factor*(P0.meanAgeMSM(P0.subsetMSM) - P.age_limit) + ...
            P.age_difference_factor*(exp(abs(P0.ageDifferenceMSM(P0.subsetMSM) - ...
            P.preferred_age_difference)/8)-1) + ...
            P.community_difference_factor*abs(P0.communityDifferenceMSM(P0.subsetMSM));
        P.beta(P0.subsetMSM) = P.beta(P0.subsetMSM) + ...
            P.behavioural_change_factor.*P0.relationCountMSM(P0.subsetMSM);
        
        
        P.eventTimes(P0.subsetMSM) = ...
            P.expLinear(P.alpha(P0.subsetMSM),P.beta(P0.subsetMSM),0,P.rand(P0.subsetMSM));
        P.time0(P0.subsetMSM) = P0.now;
        P0.subsetMSM(P0.subsetMSM) = false;
    end


%% update (FROM FEI 07/10/2012)
    function P0 = eventFormationMSM_update(SDS, P0, type)
        % updated by formation, dissolution
        % use P0.MSM_1/2
        P0.subsetMSM(P0.MSM_1,P0.MSM_2) = true;
        P0.subsetMSM = P0.subsetMSM&~P0.currentMSM&isfinite(P.eventTimes);
        P0.subset(~P0.adultMales(SDS.males.MSM),~P0.adultMales(SDS.males.MSM)) = false;
        P0.subsetMSM(logical(eye(size(P0.subsetMSM))))=false;
        P0.subsetMSM=triu(P0.subsetMSM,1);
        Pc = P.intExpLinear(P.alpha(P0.subsetMSM),P.beta(P0.subsetMSM),...
            0,min(P0.timeSinceLast(P0.subsetMSM),P0.now-P.time0(P0.subsetMSM)));
        
        P.rand(P0.subsetMSM) = P.rand(P0.subsetMSM)-Pc;
        P.rand(P.rand<0)=P.rand0toInf(1,sum(sum(P.rand<0)));
        
        MSM = find(SDS.males.MSM);
        MSM_idx_1 = MSM(P0.MSM_1);
        MSM_idx_2 = MSM(P0.MSM_2);
        
        if type ==1
            % formation
            
            P0.maleRelationCount([MSM_idx_1,MSM_idx_2]) = P0.maleRelationCount([MSM_idx_1,MSM_idx_2]) + 1;
            P0.relationCount([MSM_idx_1,MSM_idx_2],:) = P0.relationCount([MSM_idx_1,MSM_idx_2],:) + 1;
            P0.relationCountMSM(P0.MSM_1,P0.MSM_2) = P0.relationCountMSM(P0.MSM_1,P0.MSM_2) + 1;
        end
        if type ==0
            % dissolution
            P0.maleRelationCount([MSM_idx_1,MSM_idx_2]) = P0.maleRelationCount([MSM_idx_1,MSM_idx_2]) - 1;
            P0.relationCount([MSM_idx_1,MSM_idx_2],:) = P0.relationCount([MSM_idx_1,MSM_idx_2],:) - 1;
            P0.relationCountMSM(P0.MSM_1,P0.MSM_2) = P0.relationCountMSM(P0.MSM_1,P0.MSM_2) - 1;
        end
            P0.relationCountDifference = abs(...
            repmat(P0.maleRelationCount, 1, SDS.number_of_females) - ...
            repmat(P0.femaleRelationCount, SDS.number_of_males, 1));
            P0.relationCountDifferenceMSM = abs(P0.relationCountMSM-P0.relationCountMSM');
         P.alpha(P0.subsetMSM) = P.baseline_factor*P0.partneringMSM(P0.subsetMSM) + ...
            P.current_relations_factor.*P0.relationCountMSM(P0.subsetMSM) + ...
            P.current_relations_difference_factor*P0.relationCountDifferenceMSM(P0.subsetMSM)+ ...
            P.mean_age_factor*(P0.meanAgeMSM(P0.subsetMSM) - P.age_limit) + ...
            P.age_difference_factor*(exp(abs(P0.ageDifferenceMSM(P0.subsetMSM) - ...
            P.preferred_age_difference)/8)-1) + ...
            P.community_difference_factor*abs(P0.communityDifferenceMSM(P0.subsetMSM));
        P.beta(P0.subsetMSM) = P.beta(P0.subsetMSM) + ...
            P.behavioural_change_factor.*P0.relationCountMSM(P0.subsetMSM);
        
        
        P.eventTimes(P0.subsetMSM) = ...
            P.expLinear(P.alpha(P0.subsetMSM),P.beta(P0.subsetMSM),0,P.rand(P0.subsetMSM));
       
        P0.subsetMSM(P0.subsetMSM) = false;
        
    end
%% intervene
    function eventFormation_interveneMSM(P0,names,values,start)
        for name = names
            P = setfield(P,name,values(names ==name));
        end
    end

%% block
    function eventFormationMSM_block(P0)
        
        P.eventTimes(P0.subsetMSM) = Inf;
    end
end


%% name
function name = eventFormationMSM_name

%name = 'partnership formation MSM';
name = 'formation MSM';
end


%% properties
function [props, msg] = eventFormationMSM_properties

msg = '';

props.baseline_factor = log(0.2);
props.current_relations_factor =log(0.18);
props.current_relations_difference_factor =log(1);
props.individual_behavioural_factor = 0;
props.behavioural_change_factor = 0;    % The effect of relations becomes larger during BCC;
props.mean_age_factor = 0;% -log(5)/50; %-log(hazard ration)/(age2-age1);
props.last_change_factor =0;% log(1);         % NOTE: intHazard = Inf for d = -c !!!
props.age_limit = 15;                 % no couple formation below this age
props.age_difference_factor = -log(5)/5;
props.preferred_age_difference = 4.5;
props.community_difference_factor = 0;

end


%% repmat
function B = eventFormationMSM_repmat(A, M, N)
% included for performance ==> might move to spTools

[m, n] = size(A);
mind = (1 : m)';
nind = (1 : n)';
B = A(mind(:, ones(1, M)), nind(:, ones(1, N)));
end


%%
function eventFormationMSM_

debugMsg

end
