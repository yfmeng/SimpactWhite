function varargout = eventTransmissionMSM(fcn, varargin)
%eventTransmissionMSM SIMPACT event function: HIV transmission MSM
%
% See also spGui, spRun, spModel, spTools.

% Copyright 2009-2010 by Hummeling Engineering (www.hummeling.com)

persistent P

if nargin == 0
    eventTransmissionMSM_test
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
    function [elements, msg, P0] = eventTransmissionMSM_init(SDS, event, P0)
        
        number_of_MSM = sum(SDS.males.MSM);
        elements = number_of_MSM*number_of_MSM;
        infections = number_of_MSM;
        msg = '';
        
        P = event;                  % copy event parameters
        
        % ******* Function Handles *******
        [P.enableAIDSmortality, msg] = spTools('handle', 'eventAIDSmortality', 'enable');
        [P.enableTest, msg] = spTools('handle', 'eventTest', 'enable');
        [P.enableARV, msg] = spTools('handle', 'eventARV', 'enable');
        [P.fireTest, msg] = spTools('handle', 'eventTest', 'fire');
        [P.enableTransmission, msg] = spTools('handle', 'eventTransmission', 'enable');
        
        % ******* Variables & Constants *******
        P.number_of_MSM = number_of_MSM;
        
        P.rand = spTools('rand0toInf', P.number_of_MSM, P.number_of_MSM);
        P.consumedRand = spTools('handle','consumedRand');
        P.transmissionTime = spTools('handle','transmissionTime');
        P.sexActsPerYear =event.sexual_behaviour_parameters{2,1}*52;%*(unprotected+(1-unprotected)*(1-condomEffect));
        P.ARVeffect = 1- event.infectiousness_decreased_by_ARV;
        P.probabilityChange = ones(P.number_of_MSM, P.number_of_MSM);
        P.eventTimes = inf(P.number_of_MSM, P.number_of_MSM, SDS.float);
        
        varWeibull = event.AIDS_mortality_distribution{2, 1};
        P.shape = event.AIDS_mortality_distribution{2, 2};
        P.scale = event.AIDS_mortality_distribution{2, 3};
        P.timeDeath = SDS.males.AIDSdeath(SDS.males.MSM);
        
        P.false = false(P.number_of_MSM,P.number_of_MSM);
        P.update = false;
        
        P.probability = [event.infectiousness{2:end, end}]';
        P.loglogP =  log(-log(1-P.probability/100));
        % random weibull
        P.alpha = P.sexActsPerYear*ones(P.number_of_MSM,P.number_of_MSM);%.*(-log(rand(SDS.number_of_males,SDS.number_of_females))).^(1/4);
        P.alpha = log(P.alpha)...
            +log(repmat(SDS.males.behaviour_factor(P0.MSM)',1,P.number_of_MSM))...
            +log(repmat(SDS.males.behaviour_factor(P0.MSM),P.number_of_MSM,1));
        P.beta = event.sexual_behaviour_parameters{2,end};
        P.t = nan(4, infections, SDS.float);
        
        P.algebraicSystem = [
            event.infectiousness(2:end, 1:2)
            {varWeibull, ''}
            ];
        debugState = false;
        if isme
            debugState = he('-debug');
        end
        if debugState
            he('-debug')
        end
        tic
        for ii = 1 : infections
            P.algebraicSystem{4, 2} = sprintf('%g', P.timeDeath(ii));
            P.algebraicSystem = solvesys(P.algebraicSystem);
            P.t(:, ii) = [P.algebraicSystem{:, 3}]';
        end
        %toc    % ~1/200 sec/infection
        if debugState
            he('-debug')
        end
        
        % ******* Integrated Hazards for Entire Population *******
        % CD4 count at infection
        P.ageFactor =  event.CD4_distribution_at_infection{2,2};
        P.CD4shape= event.CD4_distribution_at_infection{2,4};
        %logMedian = log(event.CD4_distribution_at_infection{2,1});
        %P.C0 = lognrnd(logMedian, P.CD4shape, 1, SDS.number_of_males+SDS.number_of_females);
        P.C0 = 600*ones(1,SDS.number_of_males+SDS.number_of_females);
        P.lastChange = nan(SDS.number_of_males,SDS.number_of_females, SDS.float);
    end

%% get
    function X = eventTransmissionMSM_get(t)
        X = P;
    end

%% restore
    function [elements,msg] = eventTransmissionMSM_restore(SDS,X)
        
        number_of_MSM = sum(SDS.males.MSM);
        elements = number_of_MSM*number_of_MSM;
        msg = '';
        
        P = X;
        P.enable = SDS.HIV_transmission.enable;
        
        [P.enableAIDSmortality, msg] = spTools('handle', 'eventAIDSmortality', 'enable');
        [P.enableTest, msg] = spTools('handle', 'eventTest', 'enable');
        [P.fireTest, msg] = spTools('handle', 'eventTest', 'fire');
        
        % ******* Variables & Constants *******
        P.consumedRand = spTools('handle','consumedRand');
        P.transmissionTime = spTools('handle','transmissionTime');
        
    end

%% eventTimes
    function eventTimes = eventTransmissionMSM_eventTimes(~, ~)
        eventTimes = P.eventTimes;
    end


%% advance
    function eventTransmissionMSM_advance(P0)
        % Also invoked when this event isn't fired.
        P.eventTimes = P.eventTimes - P0.eventTime;
    end


%% fire
    function [SDS, P0] = eventTransmissionMSM_fire(SDS, P0)
        
        % ******* Indices *******
        MSM = find(SDS.males.MSM);
        if P0.introduce %
            MSM_idx_1 = 0;
            MSM_idx_2= P0.male;
            P0.MSM_1 = 0;
            P0.MSM_2 = sum(P0.MSM(1:P0.male));
            P0.serodiscordantMSM(P0.MSM_2, :) = ~P0.serodiscordantMSM(P0.MSM_2, :);
            P0.serodiscordantMSM(:, P0.MSM_2) = ~P0.serodiscordantMSM(:, P0.MSM_2);
        else
            P0.MSM_1 = rem(P0.index - 1, P.number_of_MSM) + 1;
            P0.MSM_2 = ceil(P0.index/P.number_of_MSM);
            % ******* Prepare Next *******
            P.eventTimes(P0.MSM_1, P0.MSM_2) = Inf;
            MSM_idx_1 = MSM(P0.MSM_1);
            MSM_idx_2 = MSM(P0.MSM_2);
            % always male no.1 infect male no.2
            if isnan(SDS.males.HIV_positive(MSM_idx_1))&&~isnan(SDS.males.HIV_positive(MSM_idx_2))
                temp = P0.MSM_1;
                P0.MSM_1 = P0.MSM_2;
                P0.MSM_2 = temp;
                MSM_idx_1 = MSM(P0.MSM_1);
                MSM_idx_2 = MSM(P0.MSM_2);
            end
            P0.serodiscordantMSM(P0.MSM_2, :) = ~P0.serodiscordantMSM(P0.MSM_2, :);
            P0.serodiscordantMSM(:, P0.MSM_2) = ~P0.serodiscordantMSM(:, P0.MSM_2);
            P0.serodiscordantMSM(P0.MSM_1, P0.MSM_2)=false;
            P0.serodiscordantMSM(P0.MSM_2, P0.MSM_1)=false;
        end
        P0.serodiscordant(MSM_idx_2, :) = ~P0.serodiscordant(MSM_idx_2, :);
        P0.subsetMSM = P.false;
        % ******* Infection *******
        
        P0.subset(MSM_idx_2, :) = true;
        SDS.males.HIV_source(MSM_idx_2) = MSM_idx_1;
        SDS.males.HIV_positive(MSM_idx_2) = P0.now;
        P0.index = MSM_idx_2;
        P.eventTimes(P0.MSM_2, ~P0.serodiscordantMSM(P0.MSM_2,:)) = Inf;
        
        SDS.males.CD4Infection(MSM_idx_2) = P.C0(MSM_idx_2) ...
            + P.ageFactor*(P0.now-SDS.males.born(MSM_idx_2));
        SDS.males.CD4Death(MSM_idx_2) = SDS.males.CD4Infection(MSM_idx_2)*(1-(1-rand)^.5)/15;
        [SDS.males.CD4_500(MSM_idx_2),SDS.males.CD4_350(MSM_idx_2),SDS.males.CD4_200(MSM_idx_2)]=...
            CD4Interp(SDS.males.CD4Infection(MSM_idx_2),SDS.males.CD4Death(MSM_idx_2),SDS.males.AIDSdeath(MSM_idx_2),P0.now);
        SDS.males.AIDSdeath(MSM_idx_2) = P.timeDeath(P0.MSM_2);
        P0.index = MSM_idx_2;
        P.enableTest(SDS,P0) %uses P0.index
        
        currentIdx = SDS.relations.time(:, SDS.index.stop) == Inf;
        for relIdx = find(currentIdx & (SDS.relations.ID(:, SDS.index.male) == MSM_idx_2) &...
                ismember(SDS.relations.ID(:, SDS.index.female),find(isnan(SDS.females.HIV_positive))))'
            % ******* Enable Transmission for His Heterosexual Relations *******
            P0.male = MSM_idx_2;
            P0.female = SDS.relations.ID(relIdx, SDS.index.female);
            P.enableTransmission(SDS, P0)   % uses P0.male; P0.female
        end
        
        currentIdx = SDS.relationsMSM.time(:, SDS.index.stop) == Inf;
        
        relIdx_1 =find(currentIdx&(SDS.relationsMSM.ID(:,1) == MSM_idx_2)&ismember(SDS.relationsMSM.ID(:,2),find(isnan(SDS.males.HIV_positive))))';
        relIdx_2 =find(currentIdx&(SDS.relationsMSM.ID(:,2) == MSM_idx_2)&ismember(SDS.relationsMSM.ID(:,1),find(isnan(SDS.males.HIV_positive))))';
        relIdx_Union = union(relIdx_1,relIdx_2);
        relIdx_Union = intersect(relIdx_Union,find(~isfinite(SDS.relationsMSM.time(:,SDS.index.stop))));
        temp_infector = P0.MSM_2;
        if ~isempty(relIdx_Union)
            for relIdx = relIdx_Union
                % ******* Enable Transmission for His Other MSM Relations *******
                P0.MSM_1 = temp_infector;
                P0.MSM_2 = setdiff(SDS.relationsMSM.ID(relIdx,:),MSM_idx_2);
                P0.MSM_2 = sum(P0.MSM(1:P0.MSM_2));
                eventTransmissionMSM_enable(SDS, P0)
            end
        end
        
        
        delay = rand*2*SDS.ARV_treatment.average_delay_after_AIDS...
            +P.t(3,P0.MSM_2);
        P.enableARV(P0,delay);
        
        P0.index = P0.MSM_2;
        P.enableAIDSmortality(P0, P.timeDeath(P0.MSM_2))    % uses P0.index=P0.MSM_2
        
        %         if P0.male~=0&&P0.female~=0
        %             P.lastChange(P0.male, P0.female) = P0.now;
        %         end
        % ******* Influence on All Events: Points *******
        P0.subset = P0.subset & P0.current;
    end


%% enable
    function  eventTransmissionMSM_enable(SDS, P0)
        % Invoked by eventFormationMSM_fire
        
        if ~P.enable
            return
        end
        
        MSM = find(P0.MSM);
        MSM_idx_1 = MSM(P0.MSM_1);
        MSM_idx_2 = MSM(P0.MSM_2);
        
        timeHIVpos = SDS.males.HIV_positive(MSM_idx_1);
        ARV = SDS.males.ARV(MSM_idx_1);
        condom = SDS.males.condom(MSM_idx_1); %added by Lucio
        circumcision = ~isnan(SDS.males.circumcision(MSM_idx_1));
        if isnan(timeHIVpos)
            % male 2 is HIV+, switch male 1 and male 2
            timeHIVpos = SDS.males.HIV_positive(MSM_idx_2);
            ARV = SDS.males.ARV(MSM_idx_2);
            condom = SDS.males.condom(MSM_idx_2); %added by Lucio
            circumcision = ~isnan(SDS.males.circumcision(MSM_idx_2));
            temp = P0.MSM_1;
            P0.MSM_1 = P0.MSM_2;
            P0.MSM_2 = temp;
            temp = MSM_idx_1;
            MSM_idx_1 = MSM_idx_2;
            MSM_idx_2 = temp;
        end
        
        if ~P.update % enabled by eventTransmissionMSM
            % determining alpha by
            % 'baseline' 'mean age' 'age difference' 'relation type' 'relations count' 'serodiscordant' 'HIV disclosure'
            % P.alpha(P0.male, P0.female)=
            
            if condom %added by Lucio 08/30
                P.probabilityChange(P0.MSM_1,P0.MSM_2) = 1-P.infectiousness_decreased_by_condom;
            end
            
            if ARV
                P.probabilityChange(P0.MSM_1,P0.MSM_2) = 1-P.infectiousness_decreased_by_ARV;
            end
            
            if circumcision
                P.probabilityChange(P0.MSM_1,P0.MSM_2) = P.probabilityChange(P0.MSM_1,P0.MSM_2)* (1-P.infectiousness_decreased_by_circumcision);
            end
        end
        
        probability = P.probability * P.probabilityChange(P0.MSM_1,P0.MSM_2);
        loglogP =  log(-log(1- probability/100));
        %loglogP = log(probability/100);
        a = P.alpha(P0.MSM_1,P0.MSM_2) + loglogP;
        T = [timeHIVpos, P.t(2:end, P0.MSM_1)'+timeHIVpos];
        %         T = [timeHIVpos, P.t(2:end, idx)'];
        %         T = cumsum(T);
        relationID_1 = intersect(find(SDS.relationsMSM.ID(:,1)==MSM_idx_1),find(SDS.relationsMSM.ID(:,2)==MSM_idx_2));
        relationID_2 = intersect(find(SDS.relationsMSM.ID(:,2)==MSM_idx_1),find(SDS.relationsMSM.ID(:,1)==MSM_idx_2));
        relationID = union(relationID_1,relationID_2);
        
        relationID = relationID(end);
        Tformation = SDS.relationsMSM.time(relationID,1);
        
        P.eventTimes(P0.MSM_1,P0.MSM_2) = ...
            P.transmissionTime(P.rand(P0.MSM_1,P0.MSM_2), P0.now, Tformation, T, a, P.beta);
        %P.lastChangeMSM(P0.MSM_1,P0.MSM_2) = P0.now;
        
        
    end

%% update
    function [SDS,P0] = eventTransmissionMSM_update(SDS, P0)
        % called by eventARV, eventARVstop, eventConception, eventBirth,
        % eventCircumcision, eventCondom
        
        MSM = find(P0.MSM);
        MSM_idx_1 = MSM(P0.MSM_1);
        MSM_idx_2 = MSM(P0.MSM_2);
        
        timeHIVpos = SDS.males.HIV_positive(MSM_idx_1);
        ARV = SDS.males.ARV(MSM_idx_1);
        condom = SDS.males.condom(MSM_idx_1); %added by Lucio
        circumcision = ~isnan(SDS.males.circumcision(MSM_idx_1));
        if isnan(timeHIVpos)
            % male 2 is HIV+
            timeHIVpos = SDS.males.HIV_positive(MSM_idx_2);
            ARV = SDS.males.ARV(MSM_idx_2);
            condom = SDS.males.condom(MSM_idx_2); %added by Lucio
            circumcision = ~isnan(SDS.males.circumcision(MSM_idx_2));
            temp = P0.MSM_1;
            P0.MSM_1 = P0.MSM_2;
            P0.MSM_2 = temp;
            temp = MSM_idx_1;
            MSM_idx_1 = MSM_idx_2;
            MSM_idx_2 = temp;
        end
        
        if ~P.update % enabled by eventTransmissionMSM
            % determining alpha by
            % 'baseline' 'mean age' 'age difference' 'relation type' 'relations count' 'serodiscordant' 'HIV disclosure'
            % P.alpha(P0.male, P0.female)=
            
            if condom %added by Lucio 08/30
                P.probabilityChange(P0.MSM_1,P0.MSM_2) = 1-P.infectiousness_decreased_by_condom;
            end
            
            if ARV
                P.probabilityChange(P0.MSM_1,P0.MSM_2) = 1-P.infectiousness_decreased_by_ARV;
            end
            
            if circumcision
                P.probabilityChange(P0.MSM_1,P0.MSM_2) = P.probabilityChange(P0.male,P0.female)* (1-P.infectiousness_decreased_by_circumcision);
            end
        end
        
        if ARVstart
            % transmission hazard shift with ARV  start
            P.algebraicSystem{4, 2} = sprintf('%g', timeDeath);
            P.algebraicSystem = solvesys(P.algebraicSystem);
            P.t(3, idx) = P.algebraicSystem{3, 3};
            P.t(4, idx) = P.algebraicSystem{4, 3};
            P.probabilityChange(P0.MSM_1,P0.MSM_2) = P.probabilityChange(P0.MSM_1,P0.MSM_2)*(1-P.infectiousness_decreased_by_ARV);
        end
        
        if ARVstop
            P.algebraicSystem{4, 2} = sprintf('%g', timeDeath);
            P.algebraicSystem = solvesys(P.algebraicSystem);
            P.t(3, idx) = P.algebraicSystem{3, 3};
            P.t(4, idx) = P.algebraicSystem{4, 3};
            P.probabilityChange(P0.MSM_1,P0.MSM_2) = P.probabilityChange(P0.MSM_1,P0.MSM_2)/(1- P.infectiousness_decreased_by_ARV);
        end
        
        %monitor
        
        P.update = true;
        eventTransmissionMSM_enable(SDS,P0)
        P.update = false;
    end


%% change
    function eventTransmissionMSM_change(SDS,P0,coverage,rate)
        %         coverage = cell2mat(coverage);
        %         rate = cell2mat(rate);
        %         covered = rand(size(P.alpha,1),size(P.alpha,2))<coverage;
        %         index = find(P.eventTimes>0&~isinf(P.eventTimes)&covered);
        %         for i = 1:length(index)
        %             P0.index = index(i);
        %             P0.male = rem(P0.index - 1, SDS.number_of_males) + 1;
        %             P0.female = ceil(P0.index/SDS.number_of_males);
        %              timeHIVpos = SDS.males.HIV_positive(P0.male);
        %         idx = P0.male;
        %         if isnan(timeHIVpos)
        %             % female is HIV+
        %             timeHIVpos = SDS.females.HIV_positive(P0.female);
        %             idx = SDS.number_of_males + P0.female;
        %             %circumcision = false;
        %         end
        %         probability = P.probability * P.probabilityChange(P0.male,P0.female);
        %         loglogP =  log(-log(1- probability/100));
        %         %loglogP = log(probability/100);
        %         lastChange = P.lastChange(P0.male, P0.female);
        %         T = [timeHIVpos, P.t(2:end, idx)'+timeHIVpos];
        %         %         T = [timeHIVpos, P.t(2:end, idx)'];
        %         %         T = cumsum(T);
        %         relationID = intersect(find(SDS.relations.ID(:,1)==P0.male),find(SDS.relations.ID(:,2)==P0.female));
        %         relationID = relationID(end);
        %         Tformation = SDS.relations.time(relationID,1);
        %         a = P.alpha(P0.male, P0.female) + loglogP;
        %         P.rand(P0.male,P0.female) = P.rand(P0.male,P0.female) ...
        %             - consumedRand(P0.now, Tformation, T, lastChange, a, P.beta);
        %         P.alpha(P0.male,P0.female) = log(P.sexActsPerYear*(1-rate)+...
        %             P.sexActsPerYear*rate*(1-P.infectiousness_decreased_by_condom));
        %         eventTransmissionMSM_update(SDS, P0)
        %         end
        %         index = find(covered);
        %         for  i = 1:length(index);
        %             P0.index = index(i);
        %             P0.male = rem(P0.index - 1, SDS.number_of_males) + 1;
        %             P0.female = ceil(P0.index/SDS.number_of_males);
        %             P.alpha(P0.male,P0.female) = log(P.sexActsPerYear*(1-rate)+...
        %             P.sexActsPerYear*rate*(1-P.infectiousness_decreased_by_condom));
        %         end
    end
%% setup

    function SDS = eventTransmissionMSM_setup(SDS, P0)
        MSM = find(P0.MSM);
        P0.index = MSM(P0.MSM_2);
        SDS.males.CD4Infection(P0.index) = P.C0(P0.index) + P.ageFactor*(P0.now-SDS.males.born(P0.index)) + P.genderDifference*0;
        SDS.males.CD4Death(P0.index) = SDS.males.CD4Infection(P0.index)*(1-(1-rand)^.5)/15;
        SDS.males.AIDSdeath(P0.index) = P.timeDeath(P0.index);
    end

%% abolish
    function eventTransmissionMSM_abolish(SDS, P0)
        %             index = sum(P0.MSM(1:P0.index));
        %             P.eventTimes(:, index) = Inf;
        %             P.eventTimes(index, :) = Inf;
        %             P.rand(:, index) = Inf;
        %             P.rand(index,:) = Inf;
    end

%% block
    function eventTransmissionMSM_block(SDS, P0)
        % Invoked by eventDissolution_dump
        
        if isempty(P)
            debugMsg('isempty(P)')
            return
        end
        MSM = find(P0.MSM);
        MSM_idx_1 = MSM(P0.MSM_1);
        MSM_idx_2 = MSM(P0.MSM_2);
        
        timeHIVpos = SDS.males.HIV_positive(MSM_idx_1);
        
        if isnan(timeHIVpos)
            % MSM_idx_2 is HIV+
            timeHIVpos = SDS.females.HIV_positive(MSM_idx_2);
            temp = P0.MSM_1;
            P0.MSM_1 = P0.MSM_2;
            P0.MSM_2 = temp;
        end
        probability = P.probability * P.probabilityChange(P0.MSM_1,P0.MSM_2);
        loglogP = - log(log(1- probability/100));
        T = [timeHIVpos, P.t(2:end, P0.MSM_1)'+timeHIVpos];
        
        relationID_1 = intersect(find(SDS.relationsMSM.ID(:,1)==MSM_idx_1),find(SDS.relationsMSM.ID(:,2)==MSM_idx_2));
        relationID_2 = intersect(find(SDS.relationsMSM.ID(:,2)==MSM_idx_1),find(SDS.relationsMSM.ID(:,1)==MSM_idx_2));
        relationID = union(relationID_1, relationID_2);
        relationID = relationID(end);
       
        Tformation = SDS.relations.time(relationID,1);
        alpha = P.alpha(P0.MSM_1,P0.MSM_2) + loglogP;
        P.rand(P0.MSM_1,P0.MSM_2) = P.rand(P0.MSM_1,P0.MSM_2) ...
            - P.consumedRand(P0.now, Tformation, T, P.lastChange(P0.MSM_1,P0.MSM_2), alpha, P.beta);
        P.eventTimes(P0.MSM_1,P0.MSM_2) = Inf;
    end
end


%% properties
function [props, msg] = eventTransmissionMSM_properties

msg = '';

props.infectiousness = {
    'variable'  'time [year]'       'transmission probability [%]'
    't0'        '0'                 5
    't1'        'min(t, 0.25)'      5
    't2'        't1 + (t - t1)*.9'  1.52
    };
props.AIDS_mortality_distribution = {
    'variable'  'Weibull shape [year]'  'Weibull scale [year]'
    't'         2.25                    11
    };
props.infectiousness_decreased_by_condom = 0.8;
props.infectiousness_decreased_by_ARV = .96;
props.infectiousness_increased_during_conception = 1;
props.infectiousness_decreased_by_circumcision = 0.3;
props.CD4_distribution_at_infection = {
    'baseline' 'age factor' 'gender difference' 'shape'
    600         5            40                          0.1
    };

props.sexual_behaviour_parameters = {'baseline' 'mean age' 'age difference' 'relation type' 'relations count' 'serodiscordant' 'HIV disclosure' 'time'
    2 0 0 0 0 0 0 log(0.95)};
end


%% name
function name = eventTransmissionMSM_name

name = 'HIV transmission MSM';
end


%% test
function eventTransmissionMSM_test

% global SDSG
%
% %SDSG = [];
% if isempty(SDSG)
%     [SDSG, msg] = spModel('new');
%     [SDSG, msg] = spModel('update', SDSG);
%     eventFormation('init', SDSG, SDSG.event(1))
%     %SDSG.now(end + 1) = SDSG.now(end) + eventFormation('eventTime', SDSG);
%     SDSG = eventFormationMSM('fire', SDSG);
% end
%
% eventTransmissionMSM('init', SDSG, SDSG.event(3))
% time = eventTransmissionMSM('eventTime', SDSG);
end
