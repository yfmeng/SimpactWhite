function varargout = eventDissolutionMSM(fcn, varargin)
%eventDissolutionMSM SIMPACT event function: partnership dissolution MSM
%
%   Implements init, eventTimes, advance, fire, update, properties, name.
%
%   See also modelHIV, eventFormation.

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
    function [elements, msg] = eventDissolutionMSM_init(SDS, event)
        
        number_of_MSM = sum(SDS.males.MSM);
        elements = number_of_MSM*number_of_MSM;
        msg = '';
        
        P = event;                  % copy event parameters
        
        % ******* Function Handles *******
        P.rand0toInf = spTools('handle', 'rand0toInf');
        P.expLinear = spTools('handle', 'expLinear');
        P.intExpLinear = spTools('handle', 'intExpLinear');
        [P.updateFormationMSM, thisMsg] = spTools('handle', 'eventFormationMSM', 'update');
        [P.enableFormationMSM, thisMsg] = spTools('handle', 'eventFormationMSM', 'enable');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
       
        [P.blockTransmissionMSM, thisMsg] = spTools('handle', 'eventTransmissionMSM', 'block');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        [P.updateTest, thisMsg] = spTools('handle', 'eventTest', 'update');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        
        % ******* Variables & Constants *******
        P.number_of_MSM = sum(SDS.males.MSM);
        P.alpha = -inf(P.number_of_MSM, P.number_of_MSM, SDS.float);
        P.beta = P.mean_age_factor + P.last_change_factor;
        P.rand = P.rand0toInf(P.number_of_MSM, P.number_of_MSM);
        P.time0 = zeros(P.number_of_MSM, P.number_of_MSM, SDS.float);
        P.eventTimes = inf(P.number_of_MSM, P.number_of_MSM, SDS.float);
        
        % ******* Checks *******
        if P.beta == 0
            P.expLinear = spTools('handle', 'expConstant');
            P.intExpLinear = spTools('handle', 'intExpConstant');
        end
    end


%% get
    function X = eventDissolutionMSM_get(t)
        X = P;
    end

%% restore
    function [elements,msg] = eventDissolutionMSM_restore(SDS,X)
        
        elements = P.number_of_MSM * P.number_of_MSM;
        msg = '';
        
        P = X;
        P.enable = SDS.dissolution_MSM.enable;
        P.rand0toInf = spTools('handle', 'rand0toInf');
        P.expLinear = spTools('handle', 'expLinear');
        P.intExpLinear = spTools('handle', 'intExpLinear');
        [P.updateFormationMSM, thisMsg] = spTools('handle', 'eventFormationMSM', 'update');
        [P.enableFormationMSM, thisMsg] = spTools('handle', 'eventFormationMSM', 'enable');
        
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
       
        [P.blockTransmissionMSM, thisMsg] = spTools('handle', 'eventTransmissionMSM', 'block');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        [P.updateTest, thisMsg] = spTools('handle', 'eventTest', 'update');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end

    end
%% eventTimes
    function eventTimes = eventDissolutionMSM_eventTimes(~, ~)

        eventTimes = P.eventTimes;
    end


%% advance
    function eventDissolutionMSM_advance(P0)
        
        P.eventTimes = P.eventTimes - P0.eventTime;
    end


%% fire
    function [SDS, P0] = eventDissolutionMSM_fire(SDS, P0)
        
        % ******* Indices *******
        P0.MSM_1 = rem(P0.index - 1, P.number_of_MSM) + 1;
        P0.MSM_2 = ceil(P0.index/P.number_of_MSM);
        
        % ******* Dissolution of Relation *******
        [SDS, P0] = eventDissolutionMSM_dump(SDS, P0);
        
        % ******* Prepare Next *******
        P.blockTransmissionMSM(SDS, P0)
        P0.subsetMSM(P0.MSM_1, P0.MSM_2) = true;
        P0.currentMSM(P0.MSM_1, P0.MSM_2) = false;
        P0 = P.enableFormationMSM(P0);% uses P0.index
        
        % ******* Influence on All Events: Cross *******
        P0.subsetMSM(P0.MSM_1, :) = true;
        P0.subsetMSM(:, P0.MSM_2) = true;
        P0.subsetMSM=triu(P0.subsetMSM,1);
        P0 = P.updateFormationMSM(SDS, P0, 0);
        P0 = eventDissolutionMSM_update(P0);
%         P0.timeSinceLastMSM(P0.MSM_1,:) = 0;
%         P0.timeSinceLastMSM(:,P0.MSM_2) = 0;
    end


%% enable
    function eventDissolutionMSM_enable(P0)
        % Invoked by eventFormation_fire or eventFormationBCC_fire
        
        if ~P.enable
            return
        end
        
        subset = P0.index;
        P.rand(P0.index) = P.rand0toInf(1, 1);
        
        % ******* Integrated Hazard *******
        P.alpha(subset) = P.baseline_factor*P0.partneringMSM(subset)+ ...
            P.current_relations_factor*P0.relationCountMSM(subset) + ...
            P.mean_age_factor*(P0.meanAgeMSM(subset) - P.age_limit) + ...
            P.age_difference_factor*abs(P0.ageDifferenceMSM(subset) - P.preferred_age_difference) +...
            P.community_difference_factor*(P0.communityDifferenceMSM(subset)==0);
        % +P.last_change_factor*P0.timeSinceLastMSM(subset) 
        P.eventTimes(subset) = ...
            P.expLinear(P.alpha(subset), P.beta, 0, P.rand(subset));

    end
%% update
    function P0 = eventDissolutionMSM_update(P0)
        % called by formation, dissolution
        % use P0.MSM_1/2
        P0.subsetMSM(P0.MSM_1,:) = true;
        P0.subsetMSM(:,P0.MSM_2) = true;
        P0.subsetMSM = P0.subsetMSM&~P0.currentMSM&isfinite(P.eventTimes);
        P0.subsetMSM(~P0.adultMales(P0.MSM), :) = false;
        P0.subsetMSM(:,~P0.adultMales(P0.MSM)) = false;
        P0.subsetMSM=triu(P0.subsetMSM,1);
        Pc = P.intExpLinear(P.alpha(P0.subsetMSM),P.beta(P0.subsetMSM),...
            0,min(P0.timeSinceLast(P0.subsetMSM),P0.now-P.time0(P0.subsetMSM)));
	    P.rand(P0.subsetMSM) = P.rand(P0.subsetMSM)-Pc;
        P.rand(P.rand<0)=P.rand0toInf(1,sum(sum(P.rand<0)));
        
        P.alpha(P0.subsetMSM) = P.baseline_factor*P0.partneringMSM(P0.subsetMSM) + ...
            P.current_relations_factor.*P0.relationCountMSM(P0.subsetMSM) + ... %P.current_relations_difference_factor*P0.relationCountDifference(P0.subset)
            P.mean_age_factor*(P0.meanAgeMSM(P0.subsetMSM) - P.age_limit) + ...
         P.age_difference_factor*(exp(abs(P0.ageDifferenceMSM(P0.subsetMSM) - ...
            P.preferred_age_difference)/8)-1) + ...
            P.community_difference_factor*abs(P0.communityDifferenceMSM(P0.subsetMSM));
        %   P.last_change_factor*P0.timeSinceLastMSM(P0.subsetMSM) + ...
            
        % P.beta(P0.subset) = P.beta(P0.subset) ;
        %+ P.behavioural_change_factor.*P0.relationCount(P0.subset);     
        
         P.eventTimes(P0.subsetMSM) = ...
             P.expLinear(P.alpha(P0.subsetMSM),P.beta(P0.subsetMSM), 0, P.rand(P0.subsetMSM));
         
        P0.subset(P0.subset) = false;
    end
%% intervene
    function eventDissolutionMSM_intervene(P0,names,values,start)
        for name = names
            P = setfield(P,name,values(names ==name));
        end
    end

%% dump
    function [SDS, P0] = eventDissolutionMSM_dump(SDS, P0)
        % Invoked by eventDissolutionMSM_fire
        % Invoked by eventMortality_fire
        
        P.alpha(P0.MSM_1, P0.MSM_2) = -Inf;
        P.eventTimes(P0.MSM_1, P0.MSM_2) = Inf;
        MSM = find(SDS.males.MSM);
        MSM_idx_1 = MSM(P0.MSM_1);
        MSM_idx_2 = MSM(P0.MSM_2);
        relation = ...
            SDS.relationsMSM.ID(:, 1) == MSM_idx_1 & ...
            SDS.relationsMSM.ID(:, 2) == MSM_idx_2;
        SDS.relationsMSM.time(find(relation, 1, 'last'), SDS.index.stop) = P0.now;
        
        if SDS.males.deceased(MSM_idx_1)==P0.now||SDS.males.deceased(MSM_idx_2)==P0.now
        P0.relationCountMSM(P0.MSM_1, :) = P0.relationCountMSM(P0.MSM_1, :) - 1;
        P0.relationCountMSM(:, P0.MSM_2) = P0.relationCountMSM(:, P0.MSM_2) - 1;
        P0.maleRelationCount(MSM_idx_1) = P0.maleRelationCount(MSM_idx_1) - 1;
        P0.maleRelationCount(MSM_idx_2) = P0.maleRelationCount(MSM_idx_2) - 1;
        P0.relationCountDifferentMSM = abs(P0.maleRelationCount-P0.maleRelationCount');
        
        P0.timeSinceLastMSM(MSM_idx_1, MSM_idx_2) = 0;
        P0.currentMSM(P0.MSM_1, P0.MSM_2) = false;
        
        end
        
    end

end


%% name
function name = eventDissolutionMSM_name

%name = 'partnership dissolution';
name = 'dissolution MSM';
end


%% properties
function [props, msg] = eventDissolutionMSM_properties

msg = '';

props.baseline_factor = log(0.25);
props.community_difference_factor = -1;
props.current_relations_factor = log(2); %log(4);
props.individual_behavioural_factor = 0;
props.mean_age_factor = 0;% log(0.8); %-log(hazard ration)/(age2-age1);
props.last_change_factor = log(1.3);
props.age_limit = 15;
props.age_difference_factor = log(1);
props.transaction_sex_factor = log(5);
props.preferred_age_difference = 4;

end
