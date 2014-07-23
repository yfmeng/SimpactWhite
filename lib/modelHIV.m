function varargout = modelHIV(fcn, varargin)
%MODELHIV SIMPACT HIV model function which controls the data structure.
%   This function implements new, nextEvent, preprocess, initialise, menu.
%
%   See also SIMPACT, spRun, spTools.

% File settings:
%#ok<*DEFNU>

% Copyright 2009-2010 by Hummeling Engineering (www.hummeling.com)

persistent P0

if nargin == 0
    modelHIV_test
    return
end

switch fcn
    case 'handle'
        cmd = sprintf('@%s_%s', mfilename, varargin{1});
        
    otherwise
        cmd = sprintf('%s_%s(varargin{:})', mfilename, fcn);
end

[varargout{1:nargout}] = eval(cmd);


%% preprocess
    function [SDS, msg] = modelHIV_preprocess(SDS)
        % Invoked by spRun('start') during initialisation
        
        msg = '';
        
        %spTools('resetRand')	% reset random number generator
        
        % ******* Function Handles *******
        %empiricalExposure = spTools('handle', 'empiricalExposure');
        %empiricalCommunity = spTools('handle', 'empiricalCommunity');
        empiricalCRF = spTools('handle', 'empiricalCRF');
        
        %NIU populationCount = SDS.number_of_males + SDS.number_of_females;
        malesInt = zeros(1, SDS.number_of_males, SDS.integer);
        femalesInt = zeros(1, SDS.number_of_females, SDS.integer);
        malesZeros = zeros(1, SDS.number_of_males, SDS.float);
        femalesZeros = zeros(1, SDS.number_of_females, SDS.float);
        malesOnes = ones(1, SDS.number_of_males, SDS.float);
        femalesOnes = ones(1, SDS.number_of_females, SDS.float);
        %NIU femalesZeros = zeros(1, SDS.number_of_females, SDS.float);
        malesNaN = nan(1, SDS.number_of_males, SDS.float);
        femalesNaN = nan(1, SDS.number_of_females, SDS.float);
        malesFalse = false(1, SDS.number_of_males);     % boolean/uint8 = 8 bit
        %malesFalse = zeros(1, SDS.number_of_males, 'uint8');
        femalesFalse = false(1, SDS.number_of_females);
        falseMatrix = false(SDS.number_of_males, SDS.number_of_females);
        
        P0.now = 0;
        
        
        % ******* Influence Subset *******
        maleRange = 1 : SDS.initial_number_of_males;
        femaleRange = 1 : SDS.initial_number_of_females;
        P0.subset = falseMatrix;
        P0.adult = falseMatrix;
        P0.aliveMales = malesFalse;
        P0.aliveMales(maleRange) = true;
        P0.aliveFemales = femalesFalse;
        P0.aliveFemales(femaleRange) = true;
        P0.pregnant = femalesFalse;
        P0.adultMales = malesFalse;
        P0.adultFemales = femalesFalse;
        %P0.ANCtest = false; % false for general type testing, true for test at ANC
        
        % ******* Population *******
        SDS.males.father = malesInt;
        SDS.females.father = femalesInt;
        SDS.males.mother = SDS.males.father;
        SDS.females.mother = SDS.females.father;
        SDS.males.born = malesNaN;
        SDS.females.born = femalesNaN;
        SDS.males.deceased = malesNaN;
        SDS.females.deceased = femalesNaN;
        SDS.males.community = malesInt;
        SDS.females.community = femalesInt;
        SDS.males.partnering = malesOnes;
        SDS.females.partnering = femalesOnes;
        SDS.males.current_relations_factor = malesNaN;
        SDS.females.current_relations_factor = femalesNaN;
        SDS.males.MSM = malesFalse;
        
        MSM = round(SDS.percentage_of_MSM*SDS.number_of_males/100);
        SDS.males.MSM(randi(SDS.number_of_males,1,MSM)) = true;
        MSM = sum(SDS.males.MSM);
        falseMatrixMSM = false(MSM,MSM);
        P0.subsetMSM = falseMatrixMSM;
         
        if ~SDS.age_struct.read_from_table
            SDS.males.born(1:SDS.initial_number_of_males) = -ageCast('m',SDS.initial_number_of_males,SDS.age_struct.scale,SDS.age_struct.shape);
            SDS.females.born(1:SDS.initial_number_of_females) = -ageCast('f',SDS.initial_number_of_females,SDS.age_struct.scale,SDS.age_struct.shape); 
        else
            SDS.males.born(1:SDS.initial_number_of_males) = ageReadTable('m',SDS.age_struct.file);
            SDS.females.born(1:SDS.initial_number_of_females)= ageReadTable('f',SDS.age_struct.file);
        end
        % ******* Communities TEMP!!! *******
        
        communityMale = empiricalCommunity(SDS.initial_number_of_males, SDS.number_of_community_members);
        communityFemale = empiricalCommunity(SDS.initial_number_of_females, SDS.number_of_community_members);
        SDS.males.community(maleRange) = cast(communityMale, SDS.integer);
        SDS.females.community(femaleRange) = cast(communityFemale, SDS.integer);
        
        partMales = repmat(SDS.males.partnering, SDS.number_of_females,1);
        partFemales = repmat(SDS.females.partnering',1, SDS.number_of_males);
        % temp
        partneringFcn = 'mean';
        
        switch partneringFcn
            case 'min'
                P0.partnering = min(partMales, partFemales);
             %   P0.partneringMSM = min(partMSM,partMSM');
            case 'max'
                P0.partnering = max(partMales, partFemales);
              %  P0.partneringMSM = max(partMSM,partMSM');
            case 'mean'
                P0.partnering = (partMales + partFemales)/2;
               % P0.partneringMSM = (partMSM+partMSM')/2;
            case 'product'
                P0.partnering = partMales.*partFemales;
                %P0.partneringMSM = partMSM.*partMSM';
        end
        
        
        % ******* HIV Properties *******
        SDS.males.HIV_source = malesInt;
        SDS.females.HIV_source = femalesInt;
        SDS.males.HIV_positive = malesNaN;
        SDS.females.HIV_positive = femalesNaN;
        SDS.males.AIDS_death = malesFalse;
        SDS.females.AIDS_death = femalesFalse;
        SDS.males.ARV_eligible = malesNaN;
        SDS.females.ARV_eligible = femalesNaN;
        SDS.males.ARV_start = malesNaN;
        SDS.females.ARV_start = femalesNaN;
        SDS.males.ARV_stop = malesNaN;
        SDS.females.ARV_stop = femalesNaN;
        SDS.males.circumcision = malesNaN;
        SDS.males.condom = malesZeros;
        SDS.males.ARV = malesFalse;
        SDS.females.ARV = femalesFalse;
        %---------------------------------------------------------%
        SDS.males.HIV_test = malesNaN;
        SDS.females.HIV_test = femalesNaN;
        SDS.males.HIV_test_change = malesNaN;
        SDS.females.HIV_test_change= femalesNaN;
        % SDS.females.ANC = femalesNaN;
        SDS.males.CD4Infection = malesNaN;
        SDS.females.CD4Infection = femalesNaN;
        SDS.males.CD4ARV = malesNaN;
        SDS.females.CD4ARV = femalesNaN;
        SDS.males.CD4Death = malesNaN;
        SDS.females.CD4Death = femalesNaN;
        SDS.males.CD4_500 = malesNaN;
        SDS.females.CD4_500 = femalesNaN;
        SDS.males.CD4_350 = malesNaN;
        SDS.females.CD4_350 = femalesNaN;
        SDS.males.CD4_200 = malesNaN;
        SDS.females.CD4_200 = femalesNaN;
        SDS.males.viral_load = malesNaN;
        SDS.females.viral_load = femalesNaN;
        SDS.males.AIDSdeath = malesNaN; %since infection
        SDS.females.AIDSdeath = femalesNaN;
        SDS.person_years_aquired = 0;
        
        %%%tempo heterogeneous individual behaviour factor
        % shape = 5, scale = 1
        SDS.males.behaviour_factor = wblrnd(1,5, 1,SDS.number_of_males);
        SDS.females.behaviour_factor = wblrnd(1,5, 1,SDS.number_of_females);
        
        SDS.males.intervened = malesNaN;
        SDS.females.intervened = malesNaN;
        
        SDS.females.sex_worker = femalesFalse;
        
        SDS.tests.ID= zeros(SDS.number_of_tests,1, SDS.integer);
        SDS.tests.time = nan(SDS.number_of_tests,1, SDS.float);
        SDS.tests.enter = Inf(SDS.number_of_tests,1, SDS.float);
        
        SDS.ARV.ID = zeros(SDS.number_of_ARV, 1, SDS.integer);
        SDS.ARV.CD4 = zeros(SDS.number_of_ARV, 1, SDS.integer);
        SDS.ARV.time = nan(SDS.number_of_ARV, 2, SDS.float);
        SDS.ARV.life_year_saved = nan(SDS.number_of_ARV, 1, SDS.float);
        SDS.tests.typeANC = false(SDS.number_of_tests,1);
        %---------------------------------------------------------%
        
        
        SDS.males.AIDSdeath =  spTools('weibull', 11, 2.25, rand(1, SDS.number_of_males));
        SDS.females.AIDSdeath =  spTools('weibull', 11, 2.25, rand(1, SDS.number_of_females));
        
        % ******* Initialise Relations *******
        SDS.relations.ID = zeros(SDS.number_of_relations, 2, SDS.integer);
        SDS.relations.type = zeros(SDS.number_of_relations, 2, SDS.integer);
        SDS.relations.condom_use = zeros(SDS.number_of_relations,1,SDS.integer);
        SDS.relations.proximity = zeros(SDS.number_of_relations,1,SDS.integer);
        % single requires relative time (dt) for accuracy,
        % for base 1/1/00 datenum results in 1.5 hrs resolution
        SDS.relations.time = [
            nan(SDS.number_of_relations, 1, SDS.float), ...
            nan(SDS.number_of_relations, 1, SDS.float), ...
            zeros(SDS.number_of_relations, 1, SDS.float)
            ];
        
        SDS.relationsMSM.ID = zeros(MSM*MSM, 2, SDS.integer);
        SDS.relationsMSM.type = zeros(MSM*MSM, 2, SDS.integer);
        SDS.relationsMSM.condom_use = zeros(MSM*MSM,1);
        SDS.relationsMSM.proximity = zeros(MSM*MSM,1,SDS.integer);
        SDS.relationsMSM.time = [
            nan(MSM*MSM, 1, SDS.float), ...
            nan(MSM*MSM, 1, SDS.float), ...
            zeros(MSM*MSM, 1, SDS.float)
            ];
        
        % ******* Common Parameters for Population of Singles *******
        P0.maleRelationCount = zeros(SDS.number_of_males, 1, SDS.float);
        P0.femaleRelationCount = zeros(1, SDS.number_of_females, SDS.float);
        P0.relationCount = ...
            repmat(P0.maleRelationCount, 1, SDS.number_of_females) + ...
            repmat(P0.femaleRelationCount, SDS.number_of_males, 1);
        P0.relationCountDifference = abs(...
            repmat(P0.maleRelationCount, 1, SDS.number_of_females) - ...
            repmat(P0.femaleRelationCount, SDS.number_of_males, 1));
        P0.relationCountMSM = zeros(1, MSM, SDS.float);
        P0.relationCountMSM = repmat(P0.relationCountMSM,MSM,1)...
            + repmat(P0.relationCountMSM',1,MSM);
        P0.relationCountDifferenceMSM = abs(P0.relationCountMSM...
            -P0.relationCountMSM');
        
        
        P0.fsw = SDS.females.sex_worker;
        P0.transactionSex = repmat(P0.fsw, SDS.number_of_males, 1);
        
        P0.motheredChildren = zeros(1,SDS.number_of_females);
        P0.lastChild = femalesNaN;
        P0.contraception = falseMatrix;        
        P0.maleAge = -repmat(SDS.males.born(:), 1, SDS.number_of_females);
        P0.femaleAge = -repmat(SDS.females.born(:)', SDS.number_of_males, 1);
        P0.maleAge(P0.maleAge<15) = NaN;
        P0.femaleAge(P0.femaleAge<15) = NaN;
        P0.meanAge = (P0.maleAge + P0.femaleAge)/2;
        
        ageMSM = -repmat(SDS.males.born(SDS.males.MSM),MSM,1);
        P0.meanAgeMSM = (ageMSM+ageMSM')/2;
        P0.ageDifferenceMSM = abs(ageMSM-ageMSM');
        
        %%%%%%%%
        P0.maleCommunity = repmat(SDS.males.community(:), 1, SDS.number_of_females);
        P0.femaleCommunity = repmat(SDS.females.community(:)', SDS.number_of_males, 1);
        communityMSM = repmat(SDS.males.community(SDS.males.MSM),MSM,1);
        P0.communityDifferenceMSM = cast(communityMSM-communityMSM',SDS.float);
        
        P0.malecurrent_relations_factor = repmat(SDS.males.current_relations_factor(:), 1, SDS.number_of_females);%
        P0.femalecurrent_relations_factor = repmat(SDS.females.current_relations_factor(:)', SDS.number_of_males, 1);%
        
        P0.ageDifference = P0.maleAge - P0.femaleAge;
        P0.intervened = falseMatrix;
        P0.communityDifference = cast(P0.maleCommunity - P0.femaleCommunity, SDS.float);
        P0.current = falseMatrix;
        P0.currentMSM = falseMatrixMSM;
        
        maleHIVpos = falseMatrix;
        maleHIVpos(~isnan(SDS.males.HIV_positive), :) = true;
        femaleHIVpos = falseMatrix;
        femaleHIVpos(:, ~isnan(SDS.females.HIV_positive)) = true;
        P0.serodiscordant = xor(maleHIVpos, femaleHIVpos);
        P0.serodiscordantMSM = falseMatrixMSM;
        P0.ARV = [malesFalse,femalesFalse];
        P0.birth = false;
        P0.conception = false;
        P0.ANC= false;
        P0.introduce = false;
        P0.optionB = femalesFalse;
        P0.thisPregnantTime = zeros(1, SDS.number_of_females);
        P0.breastfeedingStop = nan(1, SDS.number_of_females);
        P0.thisChild = nan(1, SDS.number_of_females);
        P0.MSM = SDS.males.MSM;
        % ******* Event Functions *******
        P0.numberOfEvents = 0;
        P0.elements = [];
        P0.event = struct('eventTime', {}, 'fire', {}, 'advance', {}, 'time', {}, 'get', {},'restore',{},'P',{});
        modelHIV_preprocess_trace('SDS')    % ********
        P0.eventTime = 0; %[];
        P0.eventTimes = inf(1, sum(P0.elements));
        P0.cumsum = [0, cumsum(P0.elements)];
        P0.firedEvent = [];
        
        
        % ******* Warnings *******
        if P0.numberOfEvents == 0
            msg = 'Warning: no (enabled) events, nothing to simulate';
        end
        if max([SDS.number_of_males, SDS.number_of_females]) > intmax(SDS.integer)
            msg = sprintf('Warning: Insufficient integer type: %s', SDS.integer);
        end  % == maleRange???
        if SDS.number_of_males*SDS.number_of_females > SDS.number_of_relations
            msg = sprintf('Warning: Insufficient relations size: %d', SDS.number_of_relations);
        end
        
        
        %% preprocess_trace
        function modelHIV_preprocess_trace(Schar)
            
            subS = eval(Schar);
            
            
            % ******* Initialise Events *******
            if isstruct(subS) && isfield(subS, 'object_type') && ...
                    strcmp(subS.object_type, 'event')% && subS.enable
                
                if exist(subS.event_file, 'file') ~= 2
                    msg = sprintf('%sError: can''t find %s\n', msg, subS.event_file);
                    return
                end
                P0.numberOfEvents = P0.numberOfEvents + 1;
                if strcmp(subS.event_file,'eventFormation')|strcmp(subS.event_file,'eventFormationMSM')|strcmp(subS.event_file,'eventTransmissionMSM')
                    [elements, initMsg, P0] = feval(subS.event_file, 'init', SDS, subS,P0);
                else
                    [elements, initMsg] = feval(subS.event_file, 'init', SDS, subS);
                end
                if ~isempty(initMsg)
                    msg = sprintf('%s%s\n', msg, initMsg);
                end
                P0.event(P0.numberOfEvents).index = (1 : elements) + sum(P0.elements);
                P0.elements(P0.numberOfEvents) = elements;
                
                % ******* Function Handles for Calculation Performance *******
                P0.event(P0.numberOfEvents).eventTimes = feval(subS.event_file, 'handle', 'eventTimes');
                P0.event(P0.numberOfEvents).advance = feval(subS.event_file, 'handle', 'advance');
                P0.event(P0.numberOfEvents).fire = feval(subS.event_file, 'handle', 'fire');
                P0.event(P0.numberOfEvents).get = feval(subS.event_file,'handle','get');
                P0.event(P0.numberOfEvents).restore = feval(subS.event_file,'handle','restore');
            end
            
            for thisField = fieldnames(subS)'
                if ~isstruct(subS.(thisField{1}))
                    continue
                end
                
                % recurrence
                modelHIV_preprocess_trace([Schar, '.', thisField{1}])
            end
        end
    end

%% repreprocess
    function [SDS,msg] = modelHIV_repreprocess(SDS,P0restart)
        P0 =P0restart;
        % Invoked by spRun('start') during initialisation
        msg = '';
        P0.firedEvent = [];
        for ii = 1:P0.numberOfEvents
            X = P0.event(ii).P;
            feval(P0.event(ii).restore,SDS,X);
        end
        P0.event = rmfield(P0.event,'P');
        SDS.start_date = SDS.end_date;
        SDS.end_date = '31-Dec-2030';
    end

%% nextEvent
    function [SDS, t] = modelHIV_nextEvent(SDS)
        
        % ******* 1: Fetch Event Times *******
        for ii = 1 : P0.numberOfEvents
            %P0.event(ii).time = P0.event(ii).eventTime(SDS);  % earliest per event
            P0.eventTimes(P0.event(ii).index) = P0.event(ii).eventTimes(SDS, P0);
        end
        
        % ******* 2: Find First Event & Its Entry *******
        [P0.eventTime, firstIdx] = min(P0.eventTimes);  % index into event times
        P0.eventTime(~isreal(P0.eventTime)) = real(P0.eventTime);
        if P0.eventTime <= 0||isnan(P0.eventTime)
            problem = find(P0.cumsum >= firstIdx, 1) - 1;
            %debugMsg 'eventTime == 0' %you can ignore this mention as present -Fei  08/17/2012
            P0.eventTime = 0.0001;
            %keyboard
        end
        if ~isfinite(P0.eventTime)
            t = Inf;
            return
        end
        eventIdx = find(P0.cumsum >= firstIdx, 1) - 1;  % index of event
        P0.index = firstIdx - P0.cumsum(eventIdx);      % index into event
        
        
        % ******* 3: Update Time *******
        %SDS.now(end + 1, 1) = SDS.now(end) + P0.eventTime;
        P0.now = P0.now + P0.eventTime;
        P0.maleAge = P0.maleAge + P0.eventTime;
        P0.femaleAge = P0.femaleAge + P0.eventTime;
        P0.meanAge = P0.meanAge + P0.eventTime;
        P0.meanAgeMSM = P0.meanAgeMSM + P0.eventTime;
        
        
        % ******* 4: Advance All Events *******
        for ii = 1 : P0.numberOfEvents
            P0.event(ii).advance(P0)
        end
        
        
        % ******* 5: Fire First Event *******
        [SDS, P0] = P0.event(eventIdx).fire(SDS, P0);
        
        P0.firedEvent(end + 1) = eventIdx;
        t = P0.now;
        
    end



%% get
    function SDS = modelHIV_get(SDS)
        for ii = 1 : P0.numberOfEvents

            P0.event(ii).P = feval(P0.event(ii).get, P0.now) ;
            
        end
        
        SDS.P0 = P0;
        
    end
end


%% postprocess
function [SDS, msg] = modelHIV_postprocess(SDS)

msg = '';

if any(diff(SDS.relations.time(:, SDS.index.start)) < 0)
    msg = 'Warning: decreasing relation formation';
end

if isfinite(SDS.males.born(end))
    msg = 'Warning: male population limit reached, increase number of males';
end
if isfinite(SDS.females.born(end))
    msg = 'Warning: female population limit reached, increase number of females';
end

SDS.relations.time = roundd(SDS.relations.time, 8);
end


%% new
function [SDS, msg] = modelHIV_new

msg = '';

% ******* Defaults *******
time = now;
SDS = [];
SDS.user_name = getenv('USERNAME');
SDS.file_date = datestr(time);
SDS.data_file = sprintf('data%s.m', datestr(time, 30));
SDS.age_file = 'none';
SDS.model_function = mfilename;
SDS.population_function = '';

SDS.start_date = '01-Jan-1998';
SDS.end_date = '31-Dec-2018';
SDS.number_of_communities = 2;

SDS.iteration_limit = 9000000;
SDS.number_of_males = 180;
SDS.number_of_females = 180;
SDS.initial_number_of_males = 100;
SDS.initial_number_of_females = 100;
SDS.percentage_of_MSM = 0;
SDS.number_of_community_members = 500;
SDS.number_of_relations = SDS.number_of_males*SDS.number_of_females;
SDS.number_of_tests =  (SDS.number_of_males+SDS.number_of_females);
SDS.number_of_ARV = (SDS.number_of_males+SDS.number_of_females)*0.3;

%SDS.float = 'single';           % e.g. 3.14 (32 bit floating point)
SDS.float = 'double';           % e.g. 3.14 (64 bit floating point)
SDS.integer = 'uint16';         % e.g. 3 (16 bit positive integer)

item = [' ', char(183), ' '];

SDS.comments = {
    'Population properties:'
    [item, 'father           ID of father, 0 for initial population']
    [item, 'mother           ID of mother, 0 for initial population']
    [item, 'born             time of birth w.r.t. start date [date]']
    [item, 'deceased         time of death w.r.t. start date [date]']
    [item, 'community        community ID']
    [item, 'HIV source       ID of HIV source']
    [item, 'HIV positive     time of HIV transmission [date]']
    [item, 'AIDS death       time of AIDS caused death [date]']
    [item, 'HIV test         time of HIV-test [date]']
    [item, 'ARV start        start of antiretroviral treatment [date]']
    [item, 'ARV stop         stop of antiretroviral treatment [date]']
    [item, 'circumcision     time of circumcision [date]']
    [item, 'condom duration  duration of condom use (can be 0)']
    [item, 'conception       time of conception [date]']
    };
% ******* Index Keys *******
SDS.index.male   = logical([1, 0]);
SDS.index.female = logical([0, 1]);
SDS.index.start  = logical([1, 0, 0]);
SDS.index.stop   = logical([0, 1, 0]);
SDS.index.condom = logical([0, 0, 1]);
% ******* Global sexual frequency variables *******
SDS.risky_sex.baseline = 1;
SDS.risky_sex.female_age_factor = log(1);
SDS.risky_sex.mean_age_factor = log(1);
SDS.risky_sex.age_difference_factor = log(1);
SDS.risky_sex.children_factor = log(1);
% ******* Age structure variables ********
SDS.age_struct.scale = 30;
SDS.age_struct.shape = 3;
SDS.age_struct.read_from_table = false;
SDS.age_struct.file = '';
% ******* Population *******
commonPrp = struct('father',[], 'mother',[], ...
    'born',[], 'deceased',[], ...
    'HIV_source',[], ...                % source of the HIV [ID]
    'HIV_positive',[], ...              % time of HIV transmission [date]
    'AIDS_death',[], ...                % death by AIDS [boolean]
    'HIV_test',[], ...                  % time of HIV-test [date]
    'ARV_start',[], 'ARV_stop',[],'ARV_eligible',[], ...  % antiretroviral treatment [date]
    'CD4Infection',[],'CD4ARV',[],'CD4Death',[],...
    'CD4_500',[],'CD4_350',[],'CD4_200',[],'viral_load',[],...
    'intervened',[],...
    'community',[], ...                 % currently integer
    'partnering', [],'behaviour_factor',[]);  % sexual activity scale [0...1]
SDS.males = mergeStruct(commonPrp, struct(...
    'circumcision',[], ...              % time of circumcision [date]
    'condom',[]));             % duration of condom use (can be 0)
SDS.females = mergeStruct(commonPrp, struct(...
    'conception',[],...
    'sex_worker',[]));                  % time conception [date]


% ******* Relations *******
SDS.relations = struct('ID', [], 'time', []);
SDS.relationsMSM = struct('ID',[],'time',[]);

% ******* Fetch Available Events *******
folder = [fileparts(which(mfilename)) '/events'];
if ~isdeployed
    addpath(folder)
end

for thisFile = dir(fullfile(folder , 'event*.m'))'
    if strcmp(thisFile.name, 'eventTemplate.m')
        continue
    end
    [~, eventFile] = fileparts(thisFile.name);
    thisField = str2field(feval(eventFile, 'name'));
    SDS.(thisField) = modelHIV_eventProps(modelHIV_event(eventFile));
    %SDS.(thisField).comments = {''};
end
end

%% event
function event = modelHIV_event(eventFile)

event = struct('object_type', 'event', ...
    'enable', true, ...    'comments', {{''}}, ...
    'event_file', eventFile);
end


%% eventProps
function [subS, msg] = modelHIV_eventProps(subS)

msg = '';

% ******* Checks *******
if ~isfield(subS, 'event_file')
    msg = 'Warning: not a valid event object';
    return
end

if isempty(subS.event_file)
    subS.enable = false;
    msg = 'Warning: not all events have an event file set';
    return
end

if exist(subS.event_file, 'file') ~= 2
    msg = sprintf('Warning: can''t find event function ''%s''', ...
        subS.event_file);
    return
end

subFields = fieldnames(subS);
eventFields = fieldnames(modelHIV_event(''));
handleEvent = str2func(subS.event_file);
[propS, propMsg] = handleEvent('properties');
propFields = fieldnames(propS);


% ******* Remove Obsolete Properties *******
for thisField = subFields'
    
    eventIdx = strcmp(thisField{1}, eventFields);
    propIdx = strcmp(thisField{1}, propFields);
    
    if any(eventIdx) || any(propIdx) || isstruct(subS.(thisField{1}))
        continue
    end
    
    subS = rmfield(subS, thisField{1});
end


% ******* Add Event Properties *******
%subS = mergeStruct(subS, propS);
for thisField = propFields'
    
    if any(strcmp(thisField{1}, subFields))
        % property already present, don't overrule
        continue
    end
    subS.(thisField{1}) = propS.(thisField{1});
end

if ~isfield(subS, 'comments')
    subS.comments = {propMsg};
end
end

%% dataFile
function dataFile = modelHIV_dataFile(SDS)

dataFile = SDS.data_file;
end


%% test
function modelHIV_test

debugMsg -on
debugMsg

% ******* Relay to GUI Test *******
SIMPACT
end


%%
function modelHIV_

end
