function varargout = eventAgeMixChangeStop(fcn, varargin)
%eventAgeMixChangeStop SIMPACT event function: age_mix_stop
%
%   See also modelHIV, eventAgeMixChange

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
    function [elements, msg] = eventAgeMixChangeStop_init(SDS, event)
        
        elements = SDS.number_of_males+SDS.number_of_females;
        msg = '';
        
        P = event;                  % copy event parameters
        
        
        % ******* Function Handles *******
        [P.interveneStop, thisMsg] = spTools('handle', 'eventAgeMixChange', 'stop');
        P.rand = spTools('handle','rand0toInf');
        P.expConstant = spTools('handle','expConstant');
        P.rate = event.fading_rate_per_year;
        P.eventTimes = Inf(1,elements,SDS.float);
    end


%% get
    function X = eventAgeMixChangeStop_get(t)
        X = P;
    end

%% restore
    function [elements,msg] = eventAgeMixChangeStop_restore(SDS,X)
        
        elements = SDS.number_of_females+SDS.number_of_males;
        msg = '';
        
        P = X;
        P.enable = SDS.age_mix_stop.enable;
        [P.interveneStop, thisMsg] = spTools('handle', 'eventAgeMixChange', 'stop');
        P.rand = spTools('handle','rand0toInf');
        P.expConstant = spTools('handle','expConstant');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        
    end

%% eventTime
    function eventTimes = eventAgeMixChangeStop_eventTimes(~, ~)
        
        %time = P.weibull(P.lambda, P.kappa);
        
        eventTimes = P.eventTimes;
    end


%% advance
    function eventAgeMixChangeStop_advance(P0)
        % Also invoked when this event isn't fired.
        
        P.eventTimes = P.eventTimes - P0.eventTime;
    end


%% fire
    function [SDS, P0] = eventAgeMixChangeStop_fire(SDS, P0)
        P0.subset(:,:)=false;
        if P0.index<=SDS.number_of_males
            P0.subset(P0.index,:)=true;
        else
            P0.female = P0.index - SDS.number_of_males;
            P0.subset(:,P0.female)=true;
        end       
        P0.subset = P0.subset&P0.intervened;
        P.interveneStop(P0);
        P0.intervened(P0.subset)=false;
        P.eventTimes(P0.index) = Inf;
    end


%% enable
    function eventAgeMixChangeStop_enable(males,females)
        % use P0.subset
        if ~P.enable
            return
        end
        effected = [find(males),find(females)+length(males)];
        P.eventTimes(effected) = P.expConstant(log(P.rate),0,0,P.rand(1,length(effected)))+P.mininum_effect_years;
        
    end

%% block
    function eventAgeMixChangeStop_block(index)
        P.eventTimes(index) = Inf;
    end

end


%% name
function name = eventAgeMixChangeStop_name

name = 'age_mix_stop';
end


%% properties
function [props, msg] = eventAgeMixChangeStop_properties
props.mininum_effect_years = 5;
props.fading_rate_per_year = 0.1;
msg = 'fading effect of age mixing intervention';
end
