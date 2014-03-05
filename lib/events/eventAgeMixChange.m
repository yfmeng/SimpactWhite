function varargout = eventAgeMixChange(fcn, varargin)
%eventAgeMixChange SIMPACT event function: age_mix
%
%   See also modelHIV, eventMortality.

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
    function [elements, msg] = eventAgeMixChange_init(SDS, event)
        
        elements = 1;
        msg = '';
        
        P = event;                  % copy event parameters
        
        
        % ******* Function Handles *******
        [P.interveneFormation, thisMsg] = spTools('handle', 'eventFormation', 'intervene');
        P.time = event.intervention_time;
        daysPerYear = spTools('daysPerYear');
        P.time = (datenum(P.time)-datenum(SDS.start_date))/daysPerYear;
        P.end_time = '01-Jan-2009';
        P.end_time = (datenum(P.end_time)-datenum(SDS.start_date))/daysPerYear;
        P.recruit = event.recruit;
        P.interval = 1/event.recruit_frequency_per_year;
        P.recruit = event.recruit;
        P.size = event.max_effect_size;
        P.male=event.effect_females;
        P.female = event.effect_females;
        P.minAge = event.effect_age_lower_bound;
        P.maxAge = event.effect_age_upper_bound;
        P.range = event.effect_cluster;
        P.baselineChange = event.baseline_change;
        P.ageDifChange = event.age_difference_change;
        P.ageDifFactorChange = event.age_difference_factor_change;
        P.eventTimes = P.time;
    end


%% get
    function X = eventAgeMixChange_get(t)
        X = P;
    end

%% restore
    function [elements,msg] = eventAgeMixChange_restore(SDS,X)
        
        elements = SDS.number_of_females;
        msg = '';
        
        P = X;
        P.enable = SDS.age_mix.enable;
        [P.interveneFormation, thisMsg] = spTools('handle', 'eventFormation', 'intervene');
        
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        
    end

%% eventTime
    function eventTimes = eventAgeMixChange_eventTimes(~, ~)
        
        %time = P.weibull(P.lambda, P.kappa);
        
        eventTimes = P.eventTimes;
    end


%% advance
    function eventAgeMixChange_advance(P0)
        % Also invoked when this event isn't fired.
        
        P.eventTimes = P.eventTimes - P0.eventTime;
    end


%% fire
    function [SDS, P0] = eventAgeMixChange_fire(SDS, P0)
        if ~P.enable
            P.eventTimes = Inf;
            return
        end
       % draw a target group sized <= P.size
        P.targetMale = true(1,SDS.number_of_males)&P.male&isnan(SDS.males.intervened);
        P.targetFemale = true(1,SDS.number_of_males)&P.female&isnan(SDS.females.intervened);
        P.targetMale = P.targetMale&SDS.males.born>(-P.maxAge)&SDS.males.born<=(-P.minAge);
        P.targetFemale = P.targetFemale&SDS.females.born>(-P.maxAge)&SDS.females.born<=(-P.minAge);
        if P.range
            P.targetMale = P.targetMale&SDS.males.community==1;
            P.targetFemale = P.targetFemale&SDS.females.community==1;
        end
        if(sum(P.targetMale)+sum(P.targetFemale))>=P.size
            select = randperm((sum(P.targetMale)+sum(P.targetFemale)),P.size);
            select = sort(select);
            selectMale = select(1:floor(P.size/2));
            selectFemale = setdiff(select,selectMale)-sum(P.targetMale);
            P.targetMale = find(P.targetMale);
            P.targetMale = intersect(P.targetMale,selectMale);
            P.targetFemale = find(P.targetFemale);
            P.targetFemale = intersect(P.targetMale,selectFemale);
        end
        P0.subset(:) = false;
        P0.subset(P.targetMale,:)=true;
        P0.subset(:,P.targetFemale)=true;
        names = {'baseline_factor','preferred_age_difference','age_difference_factor'};
        values = [P.baselineChange,P.ageDifChange,P.ageDifFactorChange];
        P.interveneFormation(P0,names,values);
        P0.subset(:) = false;
        %temporary
        SDS.males.intervened(P.targetMale) = P0.now;
        SDS.females.intervened(P.targetFemale) = P0.now;
        if P.recruit&&P0.now<=P.end_time
            P.eventTimes = P.interval;
        else
            P.eventTimes = Inf;
        end
    end


%% enable
    function eventAgeMixChange_enable(index)
        % Invoked by eventConception_fire
        
    end

%% block
    function eventAgeMixChange_block(index)
        P.eventTimes(index) = Inf;
    end

end


%% name
function name = eventAgeMixChange_name

name = 'age_mix';
end


%% properties
function [props, msg] = eventAgeMixChange_properties
props.intervention_time = '01-Jan-1999';
props.end_time = '01-Jan-2005';
props.recruit = false;
props.recruit_frequency_per_year = 2;
props.max_effect_size = 200;
props.effect_males=true;
props.effect_females = true;
props.effect_age_lower_bound = 10;
props.effect_age_upper_bound = 30;
props.effect_cluster = 0;
props.baseline_change = 0;
props.age_difference_change = 0;
props.age_difference_factor_change = -0.05;
msg = 'change age mixing behaviour';
end
