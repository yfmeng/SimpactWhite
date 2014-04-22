function varargout = eventConception(fcn, varargin)
%EVENTCONCEPTION SIMPACT event function: conception
%
% See also SIMPACT, spRun, spTools, modelHIV.

% Copyright 2009-2010 by Hummeling Engineering (www.hummeling.com)

persistent P

switch fcn
    case 'handle'
        cmd = sprintf('@%s_%s', mfilename, varargin{1});
    otherwise
        cmd = sprintf('%s_%s(varargin{:})', mfilename, fcn);
end
[varargout{1:nargout}] = eval(cmd);


%% init
    function [elements, msg] = eventConception_init(SDS, event)
        
        elements = SDS.number_of_males * SDS.number_of_females;
        msg = '';
        
        P = event;                  % copy event parameters
        
        P.eventTimes = inf(SDS.number_of_males, SDS.number_of_females, SDS.float);
        P.pregnant = false(1, SDS.number_of_females);
        
        P.beta = event.time_factor;
        P.expLinear = spTools('handle','expLinear');
        if P.beta ==0
            P.expLinear = spTools('handle','expConstant');
        end
        P.weeksPerYear = spTools('daysPerYear')/7;
        P.rand0toInf = spTools('handle', 'rand0toInf');
        %P.enableBirth = eventBirth('handle', 'enable');
        [P.enableBirth, msg] = spTools('handle', 'eventBirth', 'enable');
        [P.enableANC, msg] = spTools('handle', 'eventANC', 'enable');
        [P.updateTransmission, msg] = spTools('handle', 'eventTransmission', 'update');
    end
%% get
    function X = eventConception_get(t)
        X = P;
    end

%% restore
    function [elements,msg] = eventConception_restore(SDS,X)
        
        elements = SDS.number_of_males * SDS.number_of_females;
        msg = '';
        
        P = X;
        P.enable = SDS.conception.enable;
        P.expLinear = spTools('handle','expLinear');
        if P.beta ==0
            P.expLinear = spTools('handle','expConstant');
        end
        P.weeksPerYear = spTools('daysPerYear')/7;
        P.rand0toInf = spTools('handle', 'rand0toInf');
        %P.enableBirth = eventBirth('handle', 'enable');
        [P.enableBirth, msg] = spTools('handle', 'eventBirth', 'enable');
        [P.enableANC, msg] = spTools('handle', 'eventANC', 'enable');
        [P.updateTransmission, msg] = spTools('handle', 'eventTransmission', 'update');
    end

%% eventTimes
    function eventTimes = eventConception_eventTimes(~, ~)
        
        %subset = P0.subset & P0.current;    % what about relations braking up?
        
        eventTimes = P.eventTimes;
    end


%% advance
    function eventConception_advance(P0)
        % Also invoked when this event isn't fired.
        
        P.eventTimes = P.eventTimes - P0.eventTime;
    end


%% fire
    function [SDS, P0] = eventConception_fire(SDS, P0)
        
        P0.male = rem(P0.index - 1, SDS.number_of_males) + 1;
        P0.female = ceil(P0.index/SDS.number_of_males);
        
        
        
        P0.pregnant(P0.female) = true;
        P.enableBirth(P0)                   % uses P0.male, P0.female
        P.enableANC(P0)
        
        %eventConception_block(P0)
        P.eventTimes(:,P0.female) = Inf;
        P0.index = P0.female + SDS.number_of_males;
        P0.thisPregnantTime(P0.female) = P0.now;
        currentIdx = SDS.relations.time(:, SDS.index.stop) == Inf;
        for relIdx = find(currentIdx & (SDS.relations.ID(:, SDS.index.female) == P0.female) &...
                ismember(SDS.relations.ID(:, SDS.index.male),find(isnan(SDS.males.HIV_positive))))'
            P0.male = SDS.relations.ID(relIdx, SDS.index.male);
            if P0.serodiscordant(P0.male, P0.female)
                P0.conception = true;
                [SDS, P0] = P.updateTransmission(SDS, P0);
                P0.conception = false;
            end
        end
        
        
    end


%% enable
    function eventConception_enable(SDS,P0)
        % Invoked by eventFormation_fire
        % Invoked by eventBirth_fire
        motherAge = P0.now-SDS.females.born(P0.female);
        if ~P.enable||P0.pregnant(P0.female)||motherAge>P.female_age_limit
            return
        end
        alpha = log(P0.coitalFrequency(P0.male,P0.female)*P.weeksPerYear)...
            +P.female_age_factor*motherAge...
            +P.previous_children_factor*P0.motheredChildren(P0.female)...
            +P.contraception_effect*P0.contraception(P0.male,P0.female);
        P.eventTimes(P0.male,P0.female) = P.expLinear(alpha,P.beta,0,P.rand0toInf(1,1));

    end


%% block
    function eventConception_block(P0)
        % Invoked by eventDissolution_dump
        % Invoked by eventConception_fire
        
        P.eventTimes(P0.male, P0.female) = Inf;
    end
end


%% properties
function [props, msg] = eventConception_properties
props.baseline_factor = 0.5;
props.female_age_factor = -0.2;
props.contraception_effect = -0.5;
props.previous_children_factor = -0.5;
props.time_factor = 0.1;
props.female_age_limit = 50;
msg = 'Birth implemented by birth event.';
end

%% name
function name = eventConception_name

name = 'conception';
end
