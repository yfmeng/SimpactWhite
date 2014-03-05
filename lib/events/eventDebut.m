function varargout = eventDebut(fcn, varargin)
%eventDebut SIMPACT event function: debut
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
    function [elements, msg] = eventDebut_init(SDS, event)
        
        elements = SDS.number_of_males+SDS.number_of_females;
        msg = '';
        
        P = event;                  % copy event parameters
        
        
        % ******* Function Handles *******
        [P.enableFormation, thisMsg] = spTools('handle', 'eventFormation', 'enable');
        [P.enableFormationMSM, thisMsg] = spTools('handle', 'eventFormationMSM', 'enable');        
        [P.enableFSW, thisMsg] = spTools('handle', 'eventFSW', 'enable');

        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        
        P.eventTimes = inf(1, elements, SDS.float);
        P.debut = event.debut_age;
        age = -[SDS.males.born, SDS.females.born];
        P.eventTimes = P.debut-age;
        P.eventTimes(P.eventTimes<0) = rand(1,sum(P.eventTimes<0))/100;
    end


%% get
    function X = eventDebut_get(t)
	X = P;
    end

%% restore
    function [elements,msg] = eventDebut_restore(SDS,X)

        elements = SDS.number_of_females;
        msg = '';
        
    	P = X;
        P.enable = SDS.debut.enable;
       
        [P.enableFormation, thisMsg] = spTools('handle', 'eventFormation', 'enable');
        [P.enableFormationMSM, thisMsg] = spTools('handle', 'eventFormationMSM', 'enable');        
        [P.enableFSW, thisMsg] = spTools('handle', 'eventFSW', 'enable');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        
    end

%% eventTime
    function eventTimes = eventDebut_eventTimes(~, ~)
        
        %time = P.weibull(P.lambda, P.kappa);
        
        eventTimes = P.eventTimes;
    end


%% advance
    function eventDebut_advance(P0)
        % Also invoked when this event isn't fired.
        
        P.eventTimes = P.eventTimes - P0.eventTime;
    end


%% fire
    function [SDS, P0] = eventDebut_fire(SDS, P0) 
          if P0.index<= SDS.number_of_males
              % males
                ID = P0.index;
                P0.adultMales(ID) = true;
                
                P0.subset(ID,P0.adultFemales) = true;
                P0.adult(ID,P0.adultFemales) = true;
                P0.maleAge(ID,:) = P0.now - SDS.males.born(ID);
                
                if SDS.males.MSM(ID)
                  MSM_idx = sum(SDS.males.MSM(1:ID));
                  ageMSM = -repmat(SDS.males.born(SDS.males.MSM),sum(SDS.males.MSM),1);
                  P0.meanAgeMSM = (ageMSM+ageMSM')/2;
                  P0.ageDifferenceMSM = abs(ageMSM-ageMSM');
                  P0.subsetMSM(MSM_idx,:) = true;
                  P0.subsetMSM(:,MSM_idx) = true;
                  P0.subsetMSM=triu(P0.subsetMSM,1);
                  P0 = P.enableFormationMSM(P0);
                  P0.subsetMSM(P0.subsetMSM) = false;%            
                end
                
          else
                ID = P0.index- SDS.number_of_males;
                P0.adultFemales(ID) = true;
                P0.subset(P0.adultMales, ID) = true;
                P0.adult(P0.adultMales, ID) = true;
                P0.femaleAge(:,ID) = P0.now - SDS.females.born(ID);
                P.enableFSW(SDS,P0,ID);
          end
        
            P0.meanAge = (P0.maleAge + P0.femaleAge)/2;
            P0.ageDifference = P0.maleAge - P0.femaleAge;
            P0.communityDifference = cast(P0.maleCommunity - P0.femaleCommunity, SDS.float);
            P0.current_relations_factorMax = max(P0.malecurrent_relations_factor, P0.femalecurrent_relations_factor);
            P0.current_relations_factorMin = min(P0.malecurrent_relations_factor, P0.femalecurrent_relations_factor);
            P0.current_relations_factorMean = (P0.malecurrent_relations_factor + P0.femalecurrent_relations_factor)/2;
            
            P0 = P.enableFormation(P0);%use P0.subset
            P.eventTimes(P0.index) = Inf;
    end


%% enable
    function eventDebut_enable(index)
        % Invoked by eventConception_fire
        
        if ~P.enable
            return
        end       
        P.eventTimes(index) = P.debut;
    end
%% intervene
    function eventDebut_intervene(P0,names,values,start)
        % temp
        P.debut_age =  P.debut_age + values;
        P.eventTimes = P.eventTimes + values;
    end

%% block
    function eventDebut_block(index)
        P.eventTimes(index) = Inf;
    end

end


%% name
function name = eventDebut_name

name = 'debut';
end


%% properties
function [props, msg] = eventDebut_properties
props.debut_age = 15;
msg = 'Individuals are allowed to debut sex at age 15';
end
