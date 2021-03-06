function varargout = eventBehaviourChange(fcn, varargin)
%eventBehaviourChange SIMPACT event function: HIV transmission
%
% See also spGui, spRun, spModel, spTools.

% Copyright 2009-2010 by Hummeling Engineering (www.hummeling.com)

persistent P

if nargin == 0
    eventBehaviourChange_test
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
    function [elements, msg] = eventBehaviourChange_init(SDS, event)
        
        elements = size(event.behaviour_changes,1)-1;
        msg = '';
        
        P = event; % copy event parameters
        
        % ******* Function Handles *******
        [P.changeTransmission, msg] = spTools('handle', 'eventTransmission', 'change');
        [P.updateTest, msg] = spTools('handle', 'eventTest', 'update');
        [P.updateFormation, msg] = spTools('handle', 'eventFormation', 'enable');

        P.eventTimes = Inf(1,elements);
        % ******* Variables & Constants *******
        daysPerYear = spTools('daysPerYear');
        P.names = {};
        P.duration = {};
        P.rate = {};
        P.coverage = {};
        for i = 1:elements
            P.names{i} = P.behaviour_changes{i+1,1};
            P.eventTimes(i) = (datenum(P.behaviour_changes{i+1,3}) - ...
            datenum(SDS.start_date))/daysPerYear;
            P.duration{i}= (datenum(P.behaviour_changes{i+1,4})-...
                datenum(P.behaviour_changes{i+1,3}))/daysPerYear;
            P.rate{i} = P.behaviour_changes{i+1,5};
            P.coverage{i} = P.behaviour_changes{i+1,6};
        end
        
    end

%% get
    function X = eventBehaviourChange_get(t)
        X = P;
    end

%% restore
    function [elements,msg] = eventBehaviourChange_restore(SDS,X)
        
        elements = size(X.behaviour_changes,1)-1;
        msg = '';
        
        P = X;
        P.enable = SDS.behaviour_change.enable;
        
        [P.changeTransmission, msg] = spTools('handle', 'eventTransmission', 'change');
        [P.updateTest, msg] = spTools('handle', 'eventTest', 'update');
        [P.updateFormation, msg] = spTools('handle', 'eventFormation', 'enable');
 end

%% eventTimes
    function eventTimes = eventBehaviourChange_eventTimes(~, ~)
        eventTimes = P.eventTimes;
    end


%% advance
    function eventBehaviourChange_advance(P0)
        % Also invoked when this event isn't fired.
        P.eventTimes = P.eventTimes - P0.eventTime;
    end


%% fire
    function [SDS, P0] = eventBehaviourChange_fire(SDS, P0)
       switch P.names{P0.index}
           case 'condom usage'
               P.changeTransmission(SDS,P0,P.coverage(1),P.rate(1));
           case 'concurrency'
           case 'prefered age'
           case 'baseline HIV test acceptance'
       end
       P.eventTimes(P0.index) = Inf;
    end


%% enable
    function  eventBehaviourChange_enable(SDS, P0)        
        
    end

%% block
    function eventBehaviourChange_block(SDS, P0)
        
    end
end


%% properties
function [props, msg] = eventBehaviourChange_properties

msg = '';

props.behaviour_changes = {
    'behaviour change' 'implementation' 'start time' 'end time' 'change rate' 'coverage'
    'condom usage'     true   '01-Jan-2001'    '01-Jan-2005'      0.5                0.5
    'condom usage'      true   '01-Jan-2003'    '01-Jan-2005'     0.6               0.5
    'condom usage'      true   '01-Jan-2005'    '01-Jan-2005'     0.6               0.5
    'condom usage'      true   '01-Jan-2007'    '01-Jan-2005'     0.4               0.3
    };

end


%% name
function name = eventBehaviourChange_name

name = 'behaviour_change';
end
