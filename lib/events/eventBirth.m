function varargout = eventBirth(fcn, varargin)
%EVENTBIRTH SIMPACT event function: birth
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

        % ******* Function Handles *******
        empiricalCommunity = spTools('handle', 'empiricalCommunity');
        empiricalCRF = spTools('handle', 'empiricalCRF');  


%% init
    function [elements, msg] = eventBirth_init(SDS, event)
        
        elements = SDS.number_of_females;
        msg = '';
        
        P = event;                  % copy event parameters
        
        
        % ******* Function Handles *******
        
        empiricalCommunity = spTools('handle', 'empiricalCommunity');
        empiricalCRF = spTools('handle', 'empiricalCRF');        
        P.rand0toInf = spTools('handle', 'rand0toInf');
        P.weibull = spTools('handle', 'weibull');
        
        [P.enableFormation, thisMsg] = spTools('handle', 'eventFormation', 'enable');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        [P.enableConception, thisMsg] = spTools('handle', 'eventConception', 'enable');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        [P.enableMortality, thisMsg] = spTools('handle', 'eventMortality', 'enable');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        [P.enableCircumcision, thisMsg] = spTools('handle', 'eventCircumcision', 'enable');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        [P.updateTransmission, thisMsg] = spTools('handle', 'eventTransmission', 'update');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        [P.enableMTCT, thisMsg] = spTools('handle', 'eventMTCT', 'enable');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
         [P.blockANC, thisMsg] = spTools('handle', 'eventANC', 'block');
         [P.enableDebut, thisMsg] = spTools('handle', 'eventDebut', 'enable');
        
        % ******* Variables & Constants *******
        %P.rand = inf(1, elements);
        P.eventTimes = inf(1, elements, SDS.float);
        P.father = zeros(1, elements, SDS.integer);
        P.false = false(SDS.number_of_males, SDS.number_of_females);
    end


%% get
    function X = eventBirth_get(t)
	X = P;
    end

%% restore
    function [elements,msg] = eventBirth_restore(SDS,X)

        elements = SDS.number_of_females;
        msg = '';
        
	P = X;
	P.enable = SDS.birth.enable;
        
        P.rand0toInf = spTools('handle', 'rand0toInf');
        P.weibull = spTools('handle', 'weibull');
        
        [P.enableFormation, thisMsg] = spTools('handle', 'eventFormation', 'enable');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        [P.enableConception, thisMsg] = spTools('handle', 'eventConception', 'enable');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        [P.enableMortality, thisMsg] = spTools('handle', 'eventMortality', 'enable');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        [P.enableCircumcision, thisMsg] = spTools('handle', 'eventCircumcision', 'enable');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        [P.updateTransmission, thisMsg] = spTools('handle', 'eventTransmission', 'update');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
        [P.enableMTCT, thisMsg] = spTools('handle', 'eventMTCT', 'enable');
        if ~isempty(thisMsg)
            msg = sprintf('%s%s\n', msg, thisMsg);
        end
         [P.blockANC, thisMsg] = spTools('handle', 'eventANC', 'block');
         [P.enableDebut, thisMsg] = spTools('handle', 'eventDebut', 'enable');
        
    end

%% eventTime
    function eventTimes = eventBirth_eventTimes(~, ~)
        
        %time = P.weibull(P.lambda, P.kappa);
        
        eventTimes = P.eventTimes;
    end


%% advance
    function eventBirth_advance(P0)
        % Also invoked when this event isn't fired.
        
        P.eventTimes = P.eventTimes - P0.eventTime;
    end


%% fire
    function [SDS, P0] = eventBirth_fire(SDS, P0) 
        
        
        P0.female = P0.index;
        P0.pregnant(P0.female) = false;
        P0.motheredChildren(P0.female) = P0.motheredChildren(P0.female)+1;
        P0.lastChild(P0.female) = P0.now;
        P0.subset = P.false;        % required by eventFormation_eventTimes
        P0.birth = true;
        P.blockANC(P0)
        P0.index = P0.index+SDS.number_of_males;
        currentIdx = SDS.relations.time(:, SDS.index.stop) == Inf;
       
       for relIdx = find(currentIdx & (SDS.relations.ID(:, SDS.index.female) == P0.female) &...
                  ismember(SDS.relations.ID(:, SDS.index.male),find(isnan(SDS.males.HIV_positive))))'
              P0.male = SDS.relations.ID(relIdx, SDS.index.male);
              if P0.serodiscordant(P0.male, P0.female)
                  
                  [SDS, P0] = P.updateTransmission(SDS, P0);
              end
       end
              
        if rand < P.boy_girl_ratio
            % baby boy born
            sex = 'males';
        else
            % baby girl born
            sex = 'females';
        end
        
        ID = find(isnan(SDS.(sex).born), 1);
        if isempty(ID)
            % population overflow!
            eventBirth_abort(P0)
            return
        end
        

        
        SDS.(sex).father(ID) = P.father(P0.female);
        SDS.(sex).mother(ID) = P0.female;
        SDS.(sex).born(ID) = P0.now;
        
        %SDS.(sex).community(ID) = empiricalCommunity(1, SDS.number_of_communities);
        SDS.(sex).community(ID) = SDS.females.community(P0.female);       
        
        SDS.(sex).current_relations_factor(ID) = SDS.formation.current_relations_factor;
            %empiricalCRF(1, betaPars, SDS.(sex).community(ID), SDS);  
        
        switch sex
            case 'males'
                P0.alive(ID, :) = true;
                P0.aliveMales(ID) = true;
                %P0.malecommID = repmat(SDS.males.commID(:), 1, SDS.number_of_females);
                P0.maleCommunity(ID, :) = SDS.males.community(ID);
                P0.malecurrent_relations_factor = repmat(SDS.males.current_relations_factor(:), 1, SDS.number_of_females);
                
                Pmort.index = ID;
                Pmort.now = P0.now;
                P.enableCircumcision(SDS, Pmort)       % uses P0.index
                
            case 'females'
                P0.alive(:, ID) = true; 
                P0.aliveFemales(ID) = true;
                %P0.femalecommID = repmat(SDS.females.commID(:)', SDS.number_of_males, 1);
                P0.femaleCommunity(:, ID) = SDS.females.community(ID);
                P0.femalecurrent_relations_factor = repmat(SDS.females.current_relations_factor(:)', SDS.number_of_males, 1);
                Pmort.index = SDS.number_of_males + ID;
        end
        
        P.enableMortality(Pmort)            % uses P0.index
        
        mother = SDS.(sex).mother(ID);
        P0.thisChild(mother) = ID+SDS.number_of_males*(strcmp(sex,'females'));
        if ~isnan(SDS.females.HIV_positive(mother))
           [SDS, P0] = P.enableMTCT(SDS, P0,mother);
        end
        
        for male = find(P0.current(:, P0.female))'
            P0.male = male;
            P.enableConception(SDS,P0)          % uses P0.male, P0.female
        end     
 
        eventBirth_abort(P0)                % uses P0.female
        P.enableDebut(Pmort.index);
        
    end


%% enable
    function eventBirth_enable(P0)
        % Invoked by eventConception_fire
        
        if ~P.enable
            return
        end
        
        
        P.eventTimes(P0.female) = P.gestation;
        P.father(P0.female) = P0.male;
    end


%% abort
    function eventBirth_abort(P0)
        % Invoked by eventBirth_fire
        % Invoked by eventMortality_fire
        
        P.eventTimes(P0.female) = Inf;
    end
end


%% name
function name = eventBirth_name

name = 'birth';
end


%% properties
function [props, msg] = eventBirth_properties

props.boy_girl_ratio = 1/2.01;
%NIU props.Weibull_shape_parameter = 2.25;       % kappa
%NIU props.Weibull_scale_parameter = 10.5;       % lambda
props.gestation = 40/52;

msg = 'Every pregnant woman gives birth, unless mortality occurs first';
end
