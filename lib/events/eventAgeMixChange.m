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
        [P.stop, thisMsg] = spTools('handle', 'eventAgeMixChangeStop', 'enable');
        P.time = event.intervention_time;
        daysPerYear = spTools('daysPerYear');
        P.time = (datenum(P.time)-datenum(SDS.start_date))/daysPerYear;
        P.end_time = (datenum(P.end_time)-datenum(SDS.start_date))/daysPerYear;
        P.recruit = event.recruit;
        P.interval = 1/event.recruit_frequency_per_year;
        P.recruit = event.recruit;
        P.male=event.effect_females;
        P.female = event.effect_females;
        P.minAge = event.effect_age_lower_bound;
        P.maxAge = event.effect_age_upper_bound;
        P.uptaken = event.uptaken_proportion;
        P.all = event.all_communities;        
        P.baselineChange = event.baseline_change;
        P.ageDifChange = event.age_difference_change;
        P.ageDifFactorChange = event.age_difference_factor_change;
        P.maleMax = event.max_difference_male_age_change;
        P.femaleMax = event.max_difference_female_age_change;
        P.eventTimes = P.time;
    end


%% get
    function X = eventAgeMixChange_get(t)
        X = P;
    end

%% restore
    function [elements,msg] = eventAgeMixChange_restore(SDS,X)
        
        elements = 1;
        msg = '';
        
        P = X;
        P.enable = SDS.age_mix.enable;
        [P.interveneFormation, thisMsg] = spTools('handle', 'eventFormation', 'intervene');
        [P.stop, thisMsg] = spTools('handle', 'eventAgeMixChangeStop', 'enable');
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
        P.targetFemale = true(1,SDS.number_of_females)&P.female&isnan(SDS.females.intervened);
        P.targetMale = P.targetMale&SDS.males.born>(-P.maxAge)&SDS.males.born<=(-P.minAge);

        P.targetFemale = P.targetFemale&SDS.females.born>(-P.maxAge)&SDS.females.born<=(-P.minAge);
        P.targetMale = find(P.targetMale);
        P.targetFemale = find(P.targetFemale);
        if ~P.all
            P.targetMale = P.targetMale(ismember(P.targetMale,find(SDS.males.community==1)));
            P.targetFemale = P.targetFemale(ismember(P.targetFemale,find(SDS.females.community==1)));
        end
        maleSize = floor(length(P.targetMale)*P.uptaken); 
        femaleSize = floor(length(P.targetFemale)*P.uptaken);  

        if femaleSize>0
            P.targetFemale = P.targetFemale(randperm(length(P.targetFemale),femaleSize));
        else
            P.targetFemale = [];
        end
        if maleSize>0
            P.targetMale = P.targetMale(randperm(length(P.targetMale),maleSize));
        else
             P.targetMale = [];
        end
        if ~P.male
            P.targetMale = [];
        end        
        
        P0.subset(:) = false;
        P0.subset(P.targetMale,:)=true;
        P0.subset(:,P.targetFemale)=true;
        P0.subset(P0.intervened) = false;
        P.names = {'baseline_factor','preferred_age_difference','age_difference_factor'...
            'max_difference_male_age','max_difference_female_age'};
        P.values = [P.baselineChange,P.ageDifChange,P.ageDifFactorChange,P.maleMax,P.femaleMax];
        P0 = P.interveneFormation(P0,P.names,P.values);
        P.stop(P.targetMale,P.targetFemale);
        P0.intervened(P0.subset==true)=true;
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
    function eventAgeMixChange_enable
        
    end
%% stop
    function eventAgeMixChange_stop(P0)
        values = -P.values;
        P.interveneFormation(P0,P.names,values);        
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
props.intervention_time = '02-Jan-1998';
props.end_time = '01-Jan-2005';
props.recruit = true;
props.recruit_frequency_per_year = 1;
props.uptaken_proportion = 0.8;
props.all_communities = false;
props.effect_males=false;
props.effect_females = true;
props.effect_age_lower_bound = 14;
props.effect_age_upper_bound = 18;
props.baseline_change = 0;
props.age_difference_change = 0;
props.age_difference_factor_change = 0;
props.max_difference_male_age_change = 0;
props.max_difference_female_age_change = 0;
msg = 'change age mixing behaviour';
end
