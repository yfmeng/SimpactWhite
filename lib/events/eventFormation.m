function varargout = eventFormation(fcn, varargin)
%EVENTFORMATION SIMPACT event function: partnership formation with BCC
%effect
%
%   See also modelHIV.

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
    function [elements, msg, P0] = eventFormation_init(SDS, event, P0)
        
        elements = SDS.number_of_males * SDS.number_of_females;
        msg = '';
        
        P = event;                      % copy event parameters
        
        
        % ******* Function Handles *******
        P.rand0toInf = spTools('handle', 'rand0toInf');
        P.expLinear = spTools('handle', 'expLinear');
        P.intExpLinear = spTools('handle', 'intExpLinear');
        P.fixFormation = spTools('handle','fixFormation3');
        [P.enableConception, thisMsg] = spTools('handle', 'eventConception', 'enable');
        [P.enableDissolution, thisMsg] = spTools('handle', 'eventDissolution', 'enable');
        [P.updateDissolution, thisMsg] = spTools('handle', 'eventDissolution', 'update');
        [P.enableTransmission, thisMsg] = spTools('handle', 'eventTransmission', 'enable');
        [P.updateTest, thisMsg] = spTools('handle', 'eventTest', 'update');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        %NIU P.repmat = @eventFormation_repmat;
        %NIU P.meshgrid = @eventFormation_meshgrid;
        % ******* Indices *******
        P.indexStartStop = SDS.index.start | SDS.index.stop;
        P.relation = find(SDS.relations.ID(:,1), 1, 'last');
        if isempty(P.relation)
            P.relation = 0;
        end
        P.baseline_factor = event.baseline_factor*ones(SDS.number_of_males, SDS.number_of_females, SDS.float);
        
        P.hetero_age = event.heterogeneous_age_mixing_behaviour;
        P.hetero_age_shape = event.heterogeneous_preferred_age_Cacuchy_shape;
        P.hetero_age_boundary = event.heterogeneous_preferred_age_Cacuchy_boundary;
        P.malePreferredAge = cauchyrnd(SDS.number_of_males,P.preferred_age_difference,P.hetero_age_shape,P.hetero_age_boundary);
        P.malePreferredAge = repmat(P.malePreferredAge',1,SDS.number_of_females);
        P.femalePreferredAge = cauchyrnd(SDS.number_of_females,P.preferred_age_difference,P.hetero_age_shape,P.hetero_age_boundary);
        P.femalePreferredAge = repmat(P.femalePreferredAge,SDS.number_of_males,1);
        P.preferred_age_difference = event.preferred_age_difference*ones(SDS.number_of_males, SDS.number_of_females, SDS.float);
        P.age_difference_factor = event.age_difference_factor*ones(SDS.number_of_males, SDS.number_of_females, SDS.float);
               
        P.alpha = -inf(SDS.number_of_males, SDS.number_of_females, SDS.float);
        P.beta = P.last_change_factor;
        P.beta = P.beta*ones(SDS.number_of_males, SDS.number_of_females, SDS.float);
        P.rand = Inf(SDS.number_of_males, SDS.number_of_females);
        P.time0 = zeros(SDS.number_of_males, SDS.number_of_females, SDS.float);
        P.lastChange = zeros(SDS.number_of_males, SDS.number_of_females, SDS.float);
        P.eventTimes = inf(SDS.number_of_males, SDS.number_of_females, SDS.float);
        
        P.fix_PTR = event.fix_turn_over_rate;
        P.PTR = event.turn_over_rate;
        % ******* Checks *******
        if P.beta == 0
            P.expLinear = spTools('handle', 'expConstant');
            P.intExpLinear = spTools('handle', 'intExpConstant');
        end
        P0.adultMales = -SDS.males.born>=P.age_limit;
        P0.adultFemales = -SDS.females.born>=P.age_limit;
        P0.subset(P0.adultMales,:) = true;
        P0.subset(:,P0.adultFemales) =true;
        P0.adult(P0.subset) = true;
        %P0 = eventFormation_enable(P0);
        
    end

%% get
    function X = eventFormation_get(t)
        
        X = P;
    end


%% restore
    function [elements,msg] = eventFormation_restore(SDS,X)
        
        elements = SDS.number_of_males * SDS.number_of_females;
        msg = '';
        
        P = X;
        P.expLinear = spTools('handle', 'expLinear');
        P.rand0toInf = spTools('handle', 'rand0toInf');
        P.expLinear = spTools('handle', 'expLinear');
        P.intExpLinear = spTools('handle', 'intExpLinear');
        P.fixFormation = spTools('handle','fixFormation3');
        [P.enableConception, thisMsg] = spTools('handle', 'eventConception', 'enable');
        [P.enableDissolution, thisMsg] = spTools('handle', 'eventDissolution', 'enable');
        [P.updateDissolution, thisMsg] = spTools('handle', 'eventDissolution', 'update');
        [P.enableTransmission, thisMsg] = spTools('handle', 'eventTransmission', 'enable');
        [P.updateTest, thisMsg] = spTools('handle', 'eventTest', 'update');
        
        if P.beta == 0
            P.expLinear = spTools('handle', 'expConstant');
            P.intExpLinear = spTools('handle', 'intExpConstant');
        end
    end

%% eventTimes
    function eventTimes = eventFormation_eventTimes(~, ~)
        
        eventTimes = P.eventTimes;
    end


%% advance
    function eventFormation_advance(P0)
        
        P.eventTimes = P.eventTimes - P0.eventTime;
    end


%% fire
    function [SDS, P0] = eventFormation_fire(SDS, P0)

        % ******* Indices *******
        P.relation = P.relation + 1;
        P0.male = rem(P0.index - 1, SDS.number_of_males) + 1;
        P0.female = ceil(P0.index/SDS.number_of_males);
        P0.current(P0.male, P0.female) = true;
        
        % ******* Formation of Relation *******
        SDS.relations.ID(P.relation, :) = [P0.male, P0.female];
        SDS.relations.time(P.relation, P.indexStartStop) = [P0.now, Inf];
        SDS.relations.proximity(P.relation) = P0.communityDifference(P0.male,P0.female);
        
        P.enableConception(SDS, P0)          % uses P0.male; P0.female
        P.enableDissolution(P0)         % uses P0.index
        if P0.serodiscordant(P0.male, P0.female)
        SDS = P.enableTransmission(SDS,P0);
        end
        
        % ******* Prepare Next *******
        P.eventTimes(P0.index) = Inf;   % block formation
        P.rand(P0.index) = Inf;
        
        % ******* Influence on All Events: Cross *******
        P0 = eventFormation_update(P0, 1);
        P0 = P.updateDissolution(P0);
        
        P0.index = P0.male;
        P.updateTest(SDS, P0)
        P0.index = P0.female + SDS.number_of_males;
        P.updateTest(SDS, P0)
    end


%% enable
    function P0 = eventFormation_enable(P0)
        % Invoked by eventDissolution_fire, eventDebut_fire
        % Use P0.subset
        if ~P.enable
            return
        end
        
        
        P.rand(P0.subset) = P.rand0toInf(1,sum(sum(P0.subset)));
        subsetRelationsCount=repmat(P0.femaleRelationCount, size(P0.subset, 1), 1);
        MSM = repmat(P0.MSM',1, size(P0.subset, 2));

        P.alpha(P0.subset) = P.baseline_factor(P0.subset).*P0.partnering(P0.subset) + ...
            P.current_relations_factor.*P0.relationCount(P0.subset).*(~P0.transactionSex(P0.subset)) + ...
            P.current_relations_factor_fsw.*P0.relationCount(P0.subset).*P0.transactionSex(P0.subset) + ...
            P.current_relations_difference_factor*P0.relationCountDifference(P0.subset).*(~P0.transactionSex(P0.subset))+ ...
            P.female_current_relations_factor*subsetRelationsCount(P0.subset).*(~P0.transactionSex(P0.subset))+...
            P.mean_age_factor*(P0.meanAge(P0.subset) - P.age_limit) + ...
            (~P.hetero_age)*P.age_difference_factor(P0.subset).*(abs(P0.ageDifference(P0.subset) - P.preferred_age_difference(P0.subset)))+...
            P.hetero_age*P.male_heterogeneous_age_factor*abs(P0.ageDifference(P0.subset)-P.malePreferredAge(P0.subset))+...
            P.hetero_age*P.female_heterogeneous_age_factor*abs(P0.ageDifference(P0.subset)-P.femalePreferredAge(P0.subset))+...
            P.hetero_age*P.heterogeneous_preferred_age_factor*abs(P.femalePreferredAge(P0.subset)-P.malePreferredAge(P0.subset))+...
            P.male_age_difference_variation_factor.*abs(P0.maleAge(P0.subset)-P.max_difference_male_age).*(abs(P0.ageDifference(P0.subset) - P.preferred_age_difference(P0.subset))) + ...           
            P.female_age_difference_variation_factor.*abs(P0.femaleAge(P0.subset)-P.max_difference_female_age).*(abs(P0.ageDifference(P0.subset) - P.preferred_age_difference(P0.subset))) + ...
            P.transaction_sex_factor*P0.transactionSex(P0.subset) + ...
            P.community_difference_factor*abs(P0.communityDifference(P0.subset))+...
            P.MSM_factor*MSM(P0.subset);
                 % time when the event is enabled
        P0.subset = P0.subset&~P0.current&~isfinite(P.eventTimes);
        P0.subset(~P0.adultMales, :) = false;
        P0.subset(:,~P0.adultFemales) = false;
        
         if P.fix_PTR%&&P0.now>=0.1
            subset0 = P0.adult&~P0.current&~P0.subset;
            subset1 = P0.adult&~P0.current;
            % consumed randomness
            P.rand(subset0) = P.rand(subset0)-P.intExpLinear(P.alpha(subset0),P.beta(subset0),P.lastChange(subset0)-P.time0(subset0),P0.now-P.time0(subset0));            
            n = sum(P0.adultMales)+sum(P0.adultFemales);
            P.alpha = P.fixFormation(P.alpha,P.beta,P0.now-P.time0,subset1,P.turn_over_rate,n);
            P.eventTimes(subset0) = P.expLinear(P.alpha(subset0),P.beta(subset0),...
                P0.now-P.time0(subset0),P.rand(subset0))-P0.now+P.time0(subset0);
            P.lastChange(subset1) = P0.now;
        end
            P.eventTimes(P0.subset) = ...
            P.expLinear(P.alpha(P0.subset),P.beta(P0.subset),0,P.rand(P0.subset));        
            P.lastChange(P0.subset) = P0.now;
            P.time0(P0.subset) = P0.now;
            P0.subset(P0.subset) = false;
            
    end


%% update (FROM FEI 07/10/2012)
    function P0 = eventFormation_update(P0, type)

        % updated by formation, dissolution
        % use P0.male, P0.female
        P0.subset(P0.male,:) = true;
        P0.subset(:,P0.female) = true;
        P0.subset = P0.subset&~P0.current&isfinite(P.eventTimes);
        P0.subset(~P0.adultMales, :) = false;
        P0.subset(:,~P0.adultFemales) = false;
        
        Pc = P.intExpLinear(P.alpha(P0.subset),P.beta(P0.subset),P.lastChange(P0.subset)-P.time0(P0.subset),P0.now-P.time0(P0.subset));        
        
        P.rand(P0.subset) = P.rand(P0.subset)-Pc;
        P.rand(P.rand<0) = Inf;
        if type ==1
            % formation
            
            P0.maleRelationCount(P0.male) = P0.maleRelationCount(P0.male) + 1;
            P0.femaleRelationCount(P0.female) = P0.femaleRelationCount(P0.female) + 1;
            P0.relationCount(P0.male,:) = P0.relationCount(P0.male,:) + 1;
            P0.relationCount(:,P0.female) = P0.relationCount(:,P0.female) + 1;        
        end
        if type ==0
            % dissolution
            P0.maleRelationCount(P0.male) = P0.maleRelationCount(P0.male) - 1;
            P0.femaleRelationCount(P0.female) = P0.femaleRelationCount(P0.female) - 1;
            P0.relationCount(P0.male,:) = P0.relationCount(P0.male,:) - 1;
            P0.relationCount(:,P0.female) = P0.relationCount(:,P0.female) - 1;
        end
        femaleRelationMatrix = repmat(P0.femaleRelationCount, size(P0.current,1), 1);
        MSM = repmat(P0.MSM',1, size(P0.subset, 2));
        P0.relationCountDifference = abs(...
                repmat(P0.maleRelationCount,1, size(P0.current,2)) - ...
                femaleRelationMatrix);
        
        P.alpha(P0.subset) = P.baseline_factor(P0.subset).*P0.partnering(P0.subset) + ...
            P.current_relations_factor.*P0.relationCount(P0.subset).*(~P0.transactionSex(P0.subset))+ ...
            P.current_relations_factor_fsw.*P0.relationCount(P0.subset).*P0.transactionSex(P0.subset) + ...
            P.current_relations_difference_factor*P0.relationCountDifference(P0.subset) .*(~P0.transactionSex(P0.subset))+ ...
            P.female_current_relations_factor*femaleRelationMatrix(P0.subset).*(~P0.transactionSex(P0.subset))+...
            P.mean_age_factor*(P0.meanAge(P0.subset) - P.age_limit) + ...
             (~P.hetero_age)*P.age_difference_factor(P0.subset).*abs(P0.ageDifference(P0.subset) - P.preferred_age_difference(P0.subset))+...
            P.hetero_age*P.male_heterogeneous_age_factor*abs(P0.ageDifference(P0.subset)-P.malePreferredAge(P0.subset))+...
            P.hetero_age*P.female_heterogeneous_age_factor*abs(P0.ageDifference(P0.subset)-P.femalePreferredAge(P0.subset))+...
            P.hetero_age*P.heterogeneous_preferred_age_factor*abs(P.femalePreferredAge(P0.subset)-P.malePreferredAge(P0.subset))+...P.male_age_difference_variation_factor.*abs(P0.maleAge(P0.subset)-P.max_difference_male_age).*(abs(P0.ageDifference(P0.subset) - P.preferred_age_difference(P0.subset))) + ...
            P.female_age_difference_variation_factor.*abs(P0.femaleAge(P0.subset)-P.max_difference_female_age).*(abs(P0.ageDifference(P0.subset) - P.preferred_age_difference(P0.subset))) + ...
            P.transaction_sex_factor*P0.transactionSex(P0.subset) + ...
            P.community_difference_factor*abs(P0.communityDifference(P0.subset))+...
            P.MSM_factor*MSM(P0.subset);
        
        if P.fix_PTR%&&P0.now>=0.1
           
            subset0 = P0.adult&~P0.current&~P0.subset;
            Pc = P.intExpLinear(P.alpha(subset0),P.beta(subset0),...
                P0.now-P.lastChange(subset0),P0.now-P.time0(subset0));        
            P.rand(subset0) = P.rand(subset0)-Pc;
            P.rand(P.rand<0)=P.rand0toInf(1,sum(sum(P.rand<0)));

            % consumed randomness
            n = sum(P0.adultMales)+sum(P0.adultFemales);
            P.alpha = P.fixFormation(P.alpha,P.beta,P0.now-P.time0,subset0,P.turn_over_rate,n);
            P.eventTimes(subset0) = ...
            P.expLinear(P.alpha(subset0),P.beta(subset0),P0.now-P.time0(subset0),P.rand(subset0))...
            -P0.now+P.time0(subset0);
            P.lastChange(subset0) = P0.now;
        else
            P.eventTimes(P0.subset) = ...
            P.expLinear(P.alpha(P0.subset),P.beta(P0.subset),P0.now-P.time0(P0.subset), P.rand(P0.subset))...
            -P0.now+P.time0(P0.subset);
            P.lastChange(P0.subset) = P0.now;
         end        
        
        P0.subset(P0.subset) = false;

    end
%% intervene
    function P0 = eventFormation_intervene(P0,names,values)
        Pc = P.intExpLinear(P.alpha(P0.subset),P.beta(P0.subset),P.lastChange(P0.subset)-P.time0(P0.subset),P0.now-P.time0(P0.subset));                
        P.rand(P0.subset) = P.rand(P0.subset)-Pc;
        for i = 1:length(names)
            if values(i)~=0
            temp = P.(names{i});
            temp(P0.subset) = temp(P0.subset) + values(i);
            P.(names{i}) = temp;
            end
        end
        femaleRelationMatrix = repmat(P0.femaleRelationCount, size(P0.current,1), 1);
        MSM = repmat(P0.MSM',1, size(P0.subset, 2));
        P0.relationCountDifference = abs(...
                repmat(P0.maleRelationCount,1, size(P0.current,2)) - ...
                femaleRelationMatrix);
        
        P.alpha(P0.subset) = P.baseline_factor(P0.subset).*P0.partnering(P0.subset) + ...
            P.current_relations_factor.*P0.relationCount(P0.subset).*(~P0.transactionSex(P0.subset))+ ...
            P.current_relations_factor_fsw.*P0.relationCount(P0.subset).*P0.transactionSex(P0.subset) + ...
            P.current_relations_difference_factor*P0.relationCountDifference(P0.subset) .*(~P0.transactionSex(P0.subset))+ ...
            P.female_current_relations_factor*femaleRelationMatrix(P0.subset).*(~P0.transactionSex(P0.subset))+...
            P.mean_age_factor*(P0.meanAge(P0.subset) - P.age_limit) + ...
            (~P.hetero_age)*P.age_difference_factor(P0.subset).*(abs(P0.ageDifference(P0.subset) - P.preferred_age_difference(P0.subset)))+...
            P.hetero_age*P.male_heterogeneous_age_factor*abs(P0.ageDifference(P0.subset)-P.malePreferredAge(P0.subset))+...
            P.hetero_age*P.female_heterogeneous_age_factor*abs(P0.ageDifference(P0.subset)-P.femalePreferredAge(P0.subset))+...
            P.hetero_age*P.heterogeneous_preferred_age_factor*abs(P.femalePreferredAge(P0.subset)-P.malePreferredAge(P0.subset))+...P.male_age_difference_variation_factor.*abs(P0.maleAge(P0.subset)-P.max_difference_male_age).*(abs(P0.ageDifference(P0.subset) - P.preferred_age_difference(P0.subset))) + ...
            P.female_age_difference_variation_factor.*abs(P0.femaleAge(P0.subset)-P.max_difference_female_age).*(abs(P0.ageDifference(P0.subset) - P.preferred_age_difference(P0.subset))) + ...
            P.transaction_sex_factor*P0.transactionSex(P0.subset) + ...
            P.community_difference_factor*abs(P0.communityDifference(P0.subset))+...
            P.MSM_factor*MSM(P0.subset);
        P.beta(P0.subset) = P.beta(P0.subset) + ...
            P.behavioural_change_factor.*P0.relationCount(P0.subset);
        P.eventTimes(P0.subset) = ...
            P.expLinear(P.alpha(P0.subset),P.beta(P0.subset),P0.now-P.time0(P0.subset), P.rand(P0.subset))...
            -P0.now+P.time0(P0.subset);
        P.eventTimes(P0.current) = Inf;        
        P.eventTimes(~P0.adultMales,:) = Inf;
        P.eventTimes(:,~P0.adultFemales) = Inf;
    end
%% block
    function eventFormation_block(P0)
        
        P.eventTimes(P0.subset) = Inf;
    end
end


%% name
function name = eventFormation_name

%name = 'partnership formation BCC';
name = 'formation';
end


%% properties
function [props, msg] = eventFormation_properties

msg = '';

props.baseline_factor = log(0.5);
props.current_relations_factor =log(0.2);
props.current_relations_factor_fsw =0;% log(1);
props.male_current_relations_factor = 0;%log(1);
props.female_current_relations_factor = log(0.9);
props.current_relations_difference_factor =log(0.8);
props.mean_age_factor = -log(5)/50; %-log(hazard ration)/(age2-age1);
props.last_change_factor =log(0.99);% log(1);         % NOTE: intHazard = Inf for d = -c !!!
props.age_limit = 15;                 % no couple formation below this age
props.age_difference_factor = log(0.9);
props.preferred_age_difference = 4;
props.max_difference_male_age = 30;
props.male_age_difference_variation_factor = log(0.9);
props.max_difference_female_age = 30;
props.female_age_difference_variation_factor = log(0.9);
props.community_difference_factor =0;% log();
props.transaction_sex_factor =0;% log(3);
props.MSM_factor = log(1);
props.fix_turn_over_rate = 0;
props.heterogeneous_age_mixing_behaviour = 1;
props.heterogeneous_preferred_age_Cacuchy_shape = 10;
props.heterogeneous_preferred_age_Cacuchy_boundary = 50;
props.male_heterogeneous_age_factor = log(0.8)/2;
props.female_heterogeneous_age_factor = log(0.8)/2;
props.heterogeneous_preferred_age_factor = log(0.9);
props.turn_over_rate = 0.1;
end


%% repmat
function B = eventFormation_repmat(A, M, N)
% included for performance ==> might move to spTools

[m, n] = size(A);
mind = (1 : m)';
nind = (1 : n)';
B = A(mind(:, ones(1, M)), nind(:, ones(1, N)));
end


%% meshgrid
function [xx, yy] = eventFormation_meshgrid(x, y)
% included for performance ==> might move to spTools

xx = x(ones(numel(y), 1), :);
yy = y(:, ones(numel(x), 1));
end

%%
function eventFormation_

debugMsg

end
