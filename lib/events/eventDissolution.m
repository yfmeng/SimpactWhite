function varargout = eventDissolution(fcn, varargin)
%EVENTDISSOLUTION SIMPACT event function: partnership dissolution
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
    function [elements, msg] = eventDissolution_init(SDS, event)
        
        elements = SDS.number_of_males * SDS.number_of_females;
        msg = '';
        
        P = event;                  % copy event parameters
        
        % ******* Function Handles *******
        P.rand0toInf = spTools('handle', 'rand0toInf');
        P.expLinear = spTools('handle', 'expLinear');
        P.intExpLinear = spTools('handle', 'intExpLinear');
        [P.updateFormation, thisMsg] = spTools('handle', 'eventFormation', 'update');
        [P.enableFormation, thisMsg] = spTools('handle', 'eventFormation', 'enable');
        [P.blockConception, thisMsg] = spTools('handle', 'eventConception', 'block');
        [P.blockTransmission, thisMsg] = spTools('handle', 'eventTransmission', 'block');
        [P.updateTest, thisMsg] = spTools('handle', 'eventTest', 'update');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        
        % ******* Variables & Constants *******
        P.alpha = -inf(SDS.number_of_males, SDS.number_of_females, SDS.float);
        P.beta = ones(SDS.number_of_males, SDS.number_of_females, SDS.float)*P.last_change_factor;
        P.rand = P.rand0toInf(SDS.number_of_males, SDS.number_of_females);
        P.time0 = zeros(SDS.number_of_males, SDS.number_of_females, SDS.float);
        P.lastChange = zeros(SDS.number_of_males, SDS.number_of_females, SDS.float);
        P.eventTimes = inf(SDS.number_of_males, SDS.number_of_females, SDS.float);
        
        % ******* Checks *******
        if P.beta == 0
            P.expLinear = spTools('handle', 'expConstant');
            P.intExpLinear = spTools('handle', 'intExpConstant');
        end
    end


%% get
    function X = eventDissolution_get(t)
        X = P;
    end

%% restore
    function [elements,msg] = eventDissolution_restore(SDS,X)
        
        elements = SDS.number_of_males * SDS.number_of_females;
        msg = '';
        
        P = X;
        P.enable = SDS.dissolution.enable;
        P.rand0toInf = spTools('handle', 'rand0toInf');
        P.expLinear = spTools('handle', 'expLinear');
        P.intExpLinear = spTools('handle', 'intExpLinear');
        [P.updateFormation, thisMsg] = spTools('handle', 'eventFormation', 'update');
        [P.enableFormation, thisMsg] = spTools('handle', 'eventFormation', 'enable');
        [P.blockConception, thisMsg] = spTools('handle', 'eventConception', 'block');
        [P.blockTransmission, thisMsg] = spTools('handle', 'eventTransmission', 'block');
        [P.updateTest, thisMsg] = spTools('handle', 'eventTest', 'update');
        
        % ******* Checks *******
        if P.beta == 0
            P.expLinear = spTools('handle', 'expConstant');
            P.intExpLinear = spTools('handle', 'intExpConstant');
        end
    end
%% eventTimes
    function eventTimes = eventDissolution_eventTimes(~, ~)

        eventTimes = P.eventTimes;
    end


%% advance
    function eventDissolution_advance(P0)
        
        P.eventTimes = P.eventTimes - P0.eventTime;
    end


%% fire
    function [SDS, P0] = eventDissolution_fire(SDS, P0)
        
        % ******* Indices *******
        P0.male = rem(P0.index - 1, SDS.number_of_males) + 1;
        P0.female = ceil(P0.index/SDS.number_of_males);
        
        % ******* Dissolution of Relation *******
        [SDS, P0] = eventDissolution_dump(SDS, P0); % uses P0.male; P0.female
        
        % ******* Prepare Next *******
        P.blockConception(P0)
        if P0.serodiscordant(P0.male, P0.female)
        P.blockTransmission(SDS, P0)
        end
        
        % ******* Influence on All Events: Cross *******
        P0.subset(P0.male, :) = true;
        P0.subset(:, P0.female) = true;
        P0 = P.updateFormation(P0, 0);
        P0 = eventDissolution_update(P0);
        P0.subset(P0.male, P0.female) = true;
        P0.current(P0.male, P0.female) = false;
        P0 = P.enableFormation(P0);
        
    end


%% enable
    function eventDissolution_enable(P0)
        % Invoked by eventFormation_fire or eventFormationBCC_fire
        
        if ~P.enable
            return
        end
        
        subset = P0.index;
        P.rand(P0.index) = P.rand0toInf(1, 1);
        
        
%         % ******* Integrated Hazard *******
        P.alpha(subset) = P.baseline_factor + ...
            P.current_relations_factor*P0.relationCount(subset) + ...
            P.mean_age_factor*(P0.meanAge(subset) - P.age_limit) + ...
            P.age_difference_factor*abs(P0.ageDifference(subset) - P.preferred_age_difference) +...
            P.transaction_sex_factor*P0.transactionSex(subset) + ...
            P.community_difference_factor*(P0.communityDifference(subset)==0);
        
        P.eventTimes(subset) = ...
            P.expLinear(P.alpha(subset), P.beta(subset), 0, P.rand(subset));
        P.time0(subset) = P0.now;
        P.lastChange(subset) = P0.now;

    end
%% update
    function P0 = eventDissolution_update(P0)
        % called by formation, dissolution
        % use P0.male/P0.female
        P0.subset(P0.male,:) = true;
        P0.subset(:,P0.female) = true;
        P0.subset = P0.subset&~P0.current&isfinite(P.eventTimes);
        P0.subset(~P0.adultMales, :) = false;
        P0.subset(:,~P0.adultFemales) = false;
       
        Pc = P.intExpLinear(P.alpha(P0.subset),P.beta(P0.subset),...
            P.lastChange(P0.subset)-P.time0(P0.subset),P0.now-P.time0(P0.subset));
	    P.rand(P0.subset) = P.rand(P0.subset)-Pc;
        P.rand(P.rand<0)=P.rand0toInf(1,sum(sum(P.rand<0)));
        
        P.alpha(P0.subset) = P.baseline_factor*P0.partnering(P0.subset) + ...
            P.current_relations_factor.*P0.relationCount(P0.subset) + ... %P.current_relations_difference_factor*P0.relationCountDifference(P0.subset)
            P.mean_age_factor*(P0.meanAge(P0.subset) - P.age_limit) + ...
            P.age_difference_factor*abs(P0.ageDifference(P0.subset) - P.preferred_age_difference) +...
            P.transaction_sex_factor*P0.transactionSex(P0.subset) + ...
            P.community_difference_factor*abs(P0.communityDifference(P0.subset));
        
         P.eventTimes(P0.subset) = ...
             P.expLinear(P.alpha(P0.subset),P.beta(P0.subset), 0, P.rand(P0.subset));
        P.lastChange(P0.subset) = P0.now;
        P0.subset(P0.subset) = false;
    end
%% intervene
    function eventDissolution_intervene(P0,names,values,start)
        for name = names
            P = setfield(P,name,values(names ==name));
        end
    end

%% dump
    function [SDS, P0] = eventDissolution_dump(SDS, P0)
        % Invoked by eventDissolution_fire
        % Invoked by eventMortality_fire
        
        P.alpha(P0.male, P0.female) = -Inf;
        P.eventTimes(P0.male, P0.female) = Inf;
        
        relation = ...
            SDS.relations.ID(:, SDS.index.male) == P0.male & ...
            SDS.relations.ID(:, SDS.index.female) == P0.female;
        SDS.relations.time(find(relation, 1, 'last'), SDS.index.stop) = P0.now;
        
        if SDS.males.deceased(P0.male)==P0.now||SDS.females.deceased(P0.female)==P0.now
        P0.relationCount(P0.male, :) = P0.relationCount(P0.male, :) - 1;
        P0.relationCount(:, P0.female) = P0.relationCount(:, P0.female) - 1;
        P0.maleRelationCount(P0.male) = P0.maleRelationCount(P0.male) - 1;
        P0.femaleRelationCount(P0.female) = P0.femaleRelationCount(P0.female) - 1;
        P0.relationCountDifference = abs(...
            repmat(P0.maleRelationCount, 1, SDS.number_of_females) - ...
            repmat(P0.femaleRelationCount, SDS.number_of_males, 1));

        P0.current(P0.male, P0.female) = false;
        end
        P.blockConception(P0)
    end

end


%% name
function name = eventDissolution_name

%name = 'partnership dissolution';
name = 'dissolution';
end


%% properties
function [props, msg] = eventDissolution_properties

msg = '';

props.baseline_factor = log(0.6);
props.community_difference_factor = 0;%log(0.8);
props.current_relations_factor = log(1); %log(4);
props.individual_behavioural_factor = 0;
props.mean_age_factor = log(1); %-log(hazard ration)/(age2-age1);
props.last_change_factor =0;% log(1.4);
props.age_limit = 15;
props.age_difference_factor = 0;%log(1.1);% log(1);
props.transaction_sex_factor = 0;%log(5);
props.preferred_age_difference = 0;%4.5;

end
