function varargout = eventARVintervention(fcn, varargin)
%eventARVintervention SIMPACT event function: ARVintervention
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
    function [elements, msg] = eventARVintervention_init(SDS, event)
        
        elements = size(event.ARV_expansion_strategies,1)-1;
        msg = '';
        
        P = event;                  % copy event parameters
        P.eventTimes = Inf(1,elements);
        P.threshold = Inf(1,elements);
        P.coverage = Inf(1,elements);
        daysPerYear = spTools('daysPerYear');
        for i=1:elements
            P.eventTimes(1) = (datenum(P.ARV_expansion_strategies{i+1,2}) - ...
            datenum(SDS.start_date))/daysPerYear;
            P.threshold(i) = P.ARV_expansion_strategies{i+1,3};
            P.coverage(i) =P.ARV_expansion_strategies{i+1,4};
        end
        P.names ={'population' 'pregnant' 'discordant' 'fsw' 'age50' 'nonbreast' 'agemix' 'concurrent'};
       [P.interveneTest, msg] = spTools('handle', 'eventTest', 'intervene');
        
    end

%% get
    function X = eventARVintervention_get(t)
        X = P;
    end

%% restore
    function [elements,msg] = eventARVintervention_restore(SDS,X)
        
        elements = size(X.ARV_expansion_strategies,1)-1;
        msg = '';       
        P = X;
        [P.interveneTest, msg] = spTools('handle', 'eventTest', 'intervene');
    end

%% eventTimes
    function eventTimes = eventARVintervention_eventTimes(~, ~)  
        eventTimes = P.eventTimes;
    end


%% advance
    function eventARVintervention_advance(P0)
        
        P.eventTimes = P.eventTimes - P0.eventTime;
        
    end


%% fire
    function [SDS, P0] = eventARVintervention_fire(SDS, P0)
        if ~P.enable
            return
        end
               P.interveneTest(P.names{P0.index},P.threshold(P0.index), P.coverage(P0.index)/100);
               P.eventTimes(P0.index) = Inf;

    end

%% enable
function eventARVintervention_enable(SDS, P0)
% by eventBirth, eventTransmission
% new random number
if ~P.enable
    return
end
end

%% block
function eventARVintervention_block(P0)
P.eventTimes(P0.index) = Inf;
end


end


%% properties
function [props, msg] = eventARVintervention_properties

props.ARV_expansion_strategies = {
'target population'            'time'         'CD4 threshold'         'coverage'
'all HIV+'                           '01-Jan-2050'     500         40  
'pregnant women'            '01-Jan-2050'       500       40
'serodiscordant couples'  '01-Jan-2050'     500         40
'female sex workers'        '01-Jan-2050'       500       40
'aged 50+'                        '01-Jan-2050'       500       40
'non-breastfeeding'          '01-Jan-2050'       500        40
'intergeneration partners'    '01-Jan-2050'       500        40
'multi-partners'    '01-Jan-2050'       500        40
};
msg = 'ARV treatment interventions implemented by ARV intervention event.';
end


%% name
function name = eventARVintervention_name

name = 'ARV intervention';
end
