function varargout = spTools(fcn, varargin)
%SPTOOLS SIMPACT tools.
%
%   See also SIMPACT, spRun, modelHIV.

% File settings:
%#function spTools_handle, spTools_menu, spTools_edit, spTools_intExpLinear
%#function spTools_expLinear, spTools_meshgrid, spTools_interp1
%#function spTools_resetRand, spTools_rand0toInf
%#function spTools_weibull, spTools_weibullEventTime
%#ok<*DEFNU>
%#ok<*UNRCH>

% Copyright 2009-2010 by Hummeling Engineering (www.hummeling.com)

if nargin == 0
    spTools_test
    return
end

[varargout{1:nargout}] = eval([mfilename, '_', fcn, '(varargin{:})']);


%% handle
    function [handle, msg] = spTools_handle(varargin)
        
        msg = '';
        if nargin == 1
            handle = eval(sprintf('@%s_%s', mfilename, varargin{1}));
            return
        end
        if exist(varargin{1}, 'file') ~= 2
            msg = sprintf('Warning: can''t find file "%s"', varargin{1});
            handle = @spTools_handle_dummy;
            return
        end
        handle = feval(varargin{1}, 'handle', varargin{2});
        
        
        %% handle_dummy
        function varargout = spTools_handle_dummy(varargin)
            % dummy function returning the input
            if nargin == nargout
                [varargout{1:nargout}] = deal(varargin{:});
            end
        end
    end


%% menu
    function modelMenu = spTools_menu(handlesFcn)
        
        import java.awt.event.ActionEvent
        import java.awt.event.KeyEvent
        import javax.swing.JMenu
        import javax.swing.JMenuItem
        import javax.swing.KeyStroke
        
        modelMenu = JMenu('Tools');
        modelMenu.setMnemonic(KeyEvent.VK_T)
        
        menuItem = JMenuItem('Population Inspector', KeyEvent.VK_P);
        %WIP menuItem.setToolTipText('Create the initial population')
        jset(menuItem, 'ActionPerformedCallback', @spTools_menu_callback)
        modelMenu.add(menuItem);
        
        menuItem = JMenuItem('Relations Inspector', KeyEvent.VK_R);
        jset(menuItem, 'ActionPerformedCallback', @spTools_menu_callback)
        %WIP modelMenu.add(menuItem);
        
        modelMenu.addSeparator()
        
        emMenu = JMenu('Export Matrix');
        emMenu.setToolTipText('Export matrix for post-processing in R')
        emMenu.setMnemonic(KeyEvent.VK_M)
        
        menuItem = JMenuItem('CSV', KeyEvent.VK_C);
        menuItem.setToolTipText('Export matrix in comma separated values format')
        jset(menuItem, 'ActionPerformedCallback', @spTools_menu_callback)
        emMenu.add(menuItem);
        
        menuItem = JMenuItem('NetCDF', KeyEvent.VK_N);
        menuItem.setToolTipText('Export matrix in network common data format')
        jset(menuItem, 'ActionPerformedCallback', @spTools_menu_callback)
        emMenu.add(menuItem);
        
        modelMenu.add(emMenu);
        
        %modelMenu.addSeparator()
        
        %menuItem.setDisplayedMnemonicIndex(5)
        %menuItem.setToolTipText('')
        
        
        %% menu_callback
        function spTools_menu_callback(~, actionEvent)
            
            handles = handlesFcn();
            SDS = handles.data();
            handles.state('busy')
            
            try
                command = get(actionEvent, 'ActionCommand');
                switch command
                    case 'Population Inspector'
                        [ok, msg] = popGui(handles);
                        if ~ok
                            handles.fail(msg)
                        end
                        
                    case 'Relations Inspector'
                        [ok, msg] = relGui(handles);
                        if ~ok
                            handles.fail(msg)
                        end
                        
                    case 'CSV'
                        handles.msg('Exporting to CSV... ')
                        [ok, msg] = spTools_exportCSV(SDS);
                        if ~ok
                            handles.fail(msg)
                            return
                        end
                        handles.msg('ok\n%s\n', msg)
                        
                    case 'WIP NetCDF'
                        handles.msg('Exporting to NetCDF... ')
                        [ok, msg] = spTools_exportNetCDF(SDS);
                        if ~ok
                            handles.fail(msg)
                            return
                        end
                        handles.msg('ok\n')
                        
                    otherwise
                        handles.fail('Warning: %s not implemented yet.', command)
                        return
                end
                
            catch Exception
                handles.fail(Exception)
                return
            end
            
            handles.state('ready')
        end
    end
end


%% test
function spTools_test

global SDSG

debugMsg

if isempty(SDSG)
    evalin('base', 'global SDSG')
    evalin('base', 'SDSG = SDS;')
end


% ******* Tests *******
%spTools_individualData(SDSG, 'male', 1)
[ok, msg] = spTools_exportCSV(SDSG)
end


%% edit
function [ok, msg] = spTools_edit(file)

ok = false;
msg = '';

if exist(file, 'file') ~= 2
    msg = sprintf('Error: can''t find %s', file);
    return
end

ok = true;
file = which(file);
[~, ~, extension] = fileparts(file);

switch extension
    case '.m'
        edit(file)
        
    case '.mat'
        msg = 'Warning: load MAT-file to Command Window';
        
    otherwise
        open(file)
        msg = sprintf('Warning: unknown extension %s', extension);
end
end


%% print
function spTools_print(hObject, varargin)

if nargin == 1
    spTools_print_buttons
    return
end

hFig = ancestor(hObject, 'figure');
ext = get(hObject, 'String');

filename = [get(hFig, 'Name'), '.', datestr(now, 30), '.', lower(ext)];
filename = genfilename(filename);

options = {hFig, '<DRIVER>', '-noui', '-painters', filename};

switch ext
    case 'EMF'
        options{2} = '-dmeta';
        
    case 'EPS'
        options{2} = '-depsc2';
        
    case 'PDF'
        options{2} = '-dpdf';
        
    otherwise
        return
end

print(options{:})
fprintf(1, 'Saved as:\n%s\n', which(filename))


%% print_buttons
    function spTools_print_buttons
        
        position = [1 1 40 24];
        
        if ispc
            uicontrol(hObject, 'Callback', @spTools_print, ...
                'Position', position, 'String', 'EMF', 'Style', 'pushbutton', ...
                'TooltipString', 'Save as Enhanced Meta File.')
            position(1) = position(1) + position(3);
        end
        
        uicontrol(hObject, 'Callback', @spTools_print, ...
            'Position', position, 'String', 'EPS', 'Style', 'pushbutton', ...
            'TooltipString', 'Save as Encapsulated PostScript graphics.')
        position(1) = position(1) + position(3);
        
        uicontrol(hObject, 'Callback', @spTools_print, ...
            'Position', position, 'String', 'PDF', 'Style', 'pushbutton', ...
            'TooltipString', 'Save as Portable Document Format.')
    end
end


%% daysPerYear
function daysPerYear = spTools_daysPerYear

daysPerYear = (datenum(2000,1,1) - datenum(1900,1,1))/100;
end

%% simtimeTOdate
function date = spTools_simtimeTOdate(sim_time,start_date)
daysPerYear = spTools_daysPerYear;
date = datestr((sim_time*daysPerYear)+datenum(start_date)) ;
end

%% dateTOsimtime
function simtime = spTools_dateTOsimtime(date,start_date)
daysPerYear = spTools_daysPerYear;
simtime = (datenum(date)-datenum(start_date)) / daysPerYear;
end

%% intExpLinear
function integral = spTools_intExpLinear(alpha, beta, t1, t2)
% Integral belonging to hazards of the linear exponent kind:
%   h(t) = exp(alpha + beta t)
% with integral:
%   H(t1-t2) = 1/beta exp(alpha)(exp(beta t2) - exp(beta t1))

integral = exp(alpha) .* (exp(beta .* t2) - exp(beta .* t1)) ./ beta;

beta0idx = beta == 0;
if ~any(beta0idx)
    return
end
integralBeta0 = spTools_intExpConstant(alpha, [], t1, t2);
integralBeta0 = integralBeta0(:).*ones(numel(integral), 1);
beta0idx = beta0idx & true(numel(integral), 1);
integral(beta0idx) = integralBeta0(beta0idx);
end


%% intExpConstant
function integral = spTools_intExpConstant(alpha, ~, t1, t2)
% Integral belonging to hazards of the constant exponent kind:
%   h(t) = exp(alpha)
% with integral:
%   H(t1-t2) = exp(alpha) (t2 - t1)

integral = exp(alpha) .* (t2 - t1);
end


%% expLinear
function eventTime = spTools_expLinear(alpha, beta, t0, P)
% Event-time for hazards of the linear exponent kind:
% time since t = 0
%   h(t) = exp(alpha + beta t)
% with integral:
%   H(t) = e^alpha/beta (e^(beta t) - e^(beta t0)) + T0 = P

x = P .* beta ./ exp(alpha) + exp(beta.*t0);
eventTime = log(x)./beta;
eventTime(x < 0) = Inf;     % hazard integral can't reach P

beta0idx = beta == 0;
if ~any(beta0idx)
    return
end
eventTimeBeta0 = spTools_expConstant(alpha, [], t0, P);
eventTimeBeta0 = eventTimeBeta0(:).*ones(numel(eventTime), 1);
beta0idx = beta0idx & true(numel(eventTime), 1);
eventTime(beta0idx) = eventTimeBeta0(beta0idx);

if 0
    % test code
    time = (0 : 10)';
    alpha = alpha(:,1);
    [exp_alpha, exp_beta_t] = meshgrid(exp(alpha), exp(beta*time));
    h = exp_alpha .* exp_beta_t;
    mesh(double(h))
    mesh(double(exp(alpha)))
    mesh(double(P))
end
end


%% expConstant
function eventTime = spTools_expConstant(alpha, ~, t0, P)
% Event-time for hazards of the constant exponent kind:
%   h(t) = exp(alpha)
% with integral:
%   H(t1-t2) = exp(alpha) (t2 - t1)

eventTime = P ./ exp(alpha) + t0;
end

%% fixFormation
function alphaNew = spTools_fixFormation(alpha,beta,t,subset0,subset1,alpha0)
add = sum(sum(subset1))>sum(sum(subset0)); 
% % for beta ==0
%     
% %     sub0b0 = subset0&beta==0;
% %     sub1b0 = subset1&beta==0;
% %     h = exp(alpha);
% %     lambda = (exp(sum(sum(h(sub0b0).*t(sub0b0))))/exp(sum(sum(h(sub1b0).*t(sub1b0)))))^(1/sum(sum(sub1b0)));
% %     alphaNewB0 = log(1-(1-exp(t(sub1b0).*h(sub1b0)))/lambda);
% %     alphaNewB0 = log(alphaNewB0./t(sub1b0));
% for beta =/=0     
     h = exp(alpha+beta.*t);
     c = (1-exp(beta.*t))./beta;
     if add
         n0 = sum(sum(subset0,1)~=0)+sum(sum(subset0,2)~=0);
         n1 = sum(sum(subset1,1)~=0)+sum(sum(subset1,2)~=0);
         added = subset1&~subset0;
         lambda = prod(1-exp(exp(alpha(added)).*c(added)))*n0/n1;
      else         
          added = subset0&~subset1;
          subset1 = subset0;
          lambda = prod(1-exp(exp(alpha(added)).*c(added)))/prod(1-exp(exp(alpha0).*c(added)));      
      end
     
     lambda = 1/(lambda)^(1/sum(sum(subset1)));
     alphaNew = alpha;
     if ~(~isfinite(lambda)||isnan(lambda)||lambda==0||abs(lambda-1)>=0.5)
        alphaNewB = log(1-(1-exp(h(subset1).*c(subset1)))/lambda);
        alphaNewB = log(alphaNewB./c(subset1));
        alphaNew = alpha;
        alphaNew(subset1)=alphaNewB;
     end
     %if (~isfinite(lambda)||isnan(lambda)||lambda==0||abs(lambda-1)>=0.5)
     display('=====')
     lambda
     sum(sum(subset0))
     sum(sum(subset1))
     display('=====')
     
end

%% fixFormation2
function alphaNew = spTools_fixFormation2(alpha,beta,t,subset0,subset1,alpha0)
        n0 = sum(sum(subset0,1)~=0)+sum(sum(subset0,2)~=0);
        n1 = sum(sum(subset1,1)~=0)+sum(sum(subset1,2)~=0);
     if sum(sum(subset0))==sum(sum(subset1))
         lambda = log(sum(exp(alpha0+beta(subset0&~subset1).*t(subset0&~subset1))))...
             -log(sum(exp(alpha(subset0&~subset1)+beta(subset0&~subset1).*t(subset0&~subset1))))...
             +log(n1)-log(n0);
     else
        lambda = log(n1)-log(n0);
     end
     lambda(~isfinite(lambda)|isnan(lambda)|lambda==0) = 0;
     alphaNew = alpha;
     alphaNew(subset1)=alpha(subset1)+lambda;

     display('=====')
     lambda
     display('=====')
     
end
%% fixFormation3
function alphaNew = spTools_fixFormation3(alpha,beta,t,subset1,tor,n1)
     h = sum(sum(exp(alpha(subset1)+beta(subset1).*t(subset1))));
     lambda = log(n1)+log(tor*2)-log(h);
     lambda(~isfinite(lambda)|isnan(lambda)|lambda==0) = 0;
     alphaNew = alpha;
     alphaNew(subset1)=alphaNew(subset1)+lambda;
end

%% meshgrid: x row vector, y column vector
function [xx, yy] = spTools_meshgrid(x, y)

xx = x(ones(numel(y), 1), :);
yy = y(:, ones(1, numel(x)));
end


%% interp1: stripped
function yi = spTools_interp1(x, y, xi)

%WIP yi = interp1fast(x, y, xi);    % Fortran
yi = interp1q(x(:), y(:), xi);
end


%% resetRand
function spTools_resetRand
%{
if matlab < 7.7
    rand('seed', 0)
    return
end
%}
reset(RandStream.getDefaultStream)
%reset(RandStream('mcg16807', 'Seed', 0))
end


%% rand0toInf
function P = spTools_rand0toInf(rowCount, colCount)
% range rand = [0.0 ... 1.0], mean of rand = 0.5
% while log(0.5) = 0.69, mean of this distribution = 1.0
% median of this distribution = 0.69

P = -log(rand(rowCount, colCount));     % better performance
end


%% weibull
function r = spTools_weibull(scale, shape, rnd)
%   Shape parameter, kappa; scale parameter, lambda
r = scale .* (-log(1 - rnd)) .^ (1./shape);
end


%% weibullEventTime
function t = spTools_weibullEventTime(scale, shape, rnd, t0)
%   scale: Weibull scale parameter, lambda
%   shape: Weibull shape parameter, kappa
%   rnd: should be random number between 0 and 1
%   t0:

t = (log(1./rnd).*scale.^shape + t0.^shape).^(1./shape) - t0;
end

%% CD4Interp
function [CD4_500,CD4_350,CD4_200]=spTools_CD4Interp(CD4_infection,CD4_death,t,now)

acute = 0.25;
if t<= acute
    CD4_500 = t-interp1q([CD4_death,CD4_infection]',[0,t]',500) + now;
    CD4_350 = t-interp1q([CD4_death,CD4_infection]',[0,t]',350) + now;
    CD4_200 = t-interp1q([CD4_death,CD4_infection]',[0,t]',200) + now;
else
    CD4_500 = t-interp1q([CD4_death,0.75*CD4_infection,CD4_infection]',[0,(t-0.25),t]',500) + now;
    CD4_350 = t-interp1q([CD4_death,0.75*CD4_infection,CD4_infection]',[0,(t-0.25),t]',350) + now;
    CD4_200 = t-interp1q([CD4_death,0.75*CD4_infection,CD4_infection]',[0,(t-0.25),t]',200) + now;
    
end
end

%%
%% consumedRand
function Pc = spTools_consumedRand(P0now, Tformation, T, Tlc, alpha, beta)
intExpLinear = spTools('handle', 'intExpLinear');
if P0now<T(2)
    Pc = intExpLinear(alpha(1), beta, Tlc-Tformation, P0now-Tformation);
else
    if P0now<T(3)
        if Tlc>T(2)
            Pc =  intExpLinear(alpha(2), beta, Tlc-Tformation,P0now-Tformation);
        else
            Pc = intExpLinear(alpha(1), beta, Tlc-Tformation, T(2)-Tformation)...
                +intExpLinear(alpha(2), beta, T(2)-Tformation,P0now-Tformation);
        end
    else %P0now>T3
        if Tlc>T(3)
            Pc = intExpLinear(alpha(3), beta, Tlc-Tformation,P0now-Tformation);
        else
            if Tlc>T(2)
                Pc = intExpLinear(alpha(2), beta, Tlc-Tformation, T(3)-Tformation)...
                    +intExpLinear(alpha(3), beta, T(3)-Tformation,T(2)-Tformation);
            else
                Pc = intExpLinear(alpha(1), beta, Tlc-Tformation, T(2)-Tformation)...
                    +intExpLinear(alpha(2), beta, T(2)-Tformation,T(3)-Tformation)...
                    +intExpLinear(alpha(3), beta, T(3)-Tformation,P0now-Tformation);
            end
        end
    end
    
end

end

%% transmissionTime
function t = spTools_transmissionTime(P, P0now, Tformation, T, alpha, beta)
% transmissionTime given random number P, P0now = P0.now, Tformation =
% external time of relationship formation
expLinear = spTools('handle', 'expLinear');
intExpLinear = spTools('handle', 'intExpLinear');
if P0now>=T(3)
    t = expLinear(alpha(3),beta,P0now-Tformation,P) - (P0now-Tformation);
else %P0now<T(3)
    if P0now>=T(2)
        t = expLinear(alpha(2),beta, P0now-Tformation,P)- (P0now-Tformation);
        if t > T(3)-P0now
            Pc =intExpLinear(alpha(2),beta,P0now-Tformation,T(3)-Tformation);
            P = P-Pc;
            t = expLinear(alpha(3),beta,T(3)-Tformation,P) - (T(3)-Tformation);
        end
    else % P0now<=T(2)
        t = expLinear(alpha(1),beta, P0now-Tformation,P)- (P0now-Tformation);
        if t>T(2)-P0now
            Pc =intExpLinear(alpha(1),beta,P0now-Tformation,T(2)-Tformation);
            P = P-Pc;
            t = expLinear(alpha(2),beta,T(2)-Tformation,P) - (T(2)-Tformation);
            if t> T(3)-P0now
                Pc =intExpLinear(alpha(2),beta,T(2)-Tformation,T(3)-Tformation);
                P = P-Pc;
                t = expLinear(alpha(3),beta,T(3)-Tformation,P) - (T(3)-Tformation);
            end
        end
    end
end
end

%% CRF
function CRF = spTools_empiricalCRF(populationsize, betaPars, communityID, SDS)

factors = [-1 -1];
CRF = cast(betainv(rand(1, populationsize, SDS.float), betaPars.alpha(communityID + 1), betaPars.beta(communityID + 1)), SDS.float);
CRF = CRF.*factors(communityID + 1);
end

%% empiricalCommunity
function communityID = spTools_empiricalCommunity(populationsize, communities)
% populationsize: number of people that need a community ID
% communities: number of communities. Default is 2.

communityID = floor(communities*rand(1, populationsize));
end


%% empiricalExposure
function BCCexposure = spTools_empiricalExposure(populationsize, llimit, ulimit, peak, communityID)
% populationsize: number of people that need a community ID
% triangular distribution of exposure between llimit and ulimit with peak
% llimit, ulimit and peak may differ across communities

llimit = llimit(communityID + 1);
ulimit = ulimit(communityID + 1);
peak = peak(communityID + 1);
F_peak = (peak - llimit)./(ulimit - llimit);
U = rand(1, populationsize);
BCCexposure = ulimit - sqrt((1 - U).*(ulimit - llimit).*(ulimit - peak));
idx = U < F_peak;
BCCexposure(idx) = llimit(idx) + ...
    sqrt(U(idx).*(ulimit(idx) - llimit(idx)).*(peak(idx) - llimit(idx)));
end
%% empiricalAge
function ages = empiricalAge(n,gender,filename)
%
if strcmp(gender(1),'m')||strcmp(gender,'M')
    col = 1;
else
    col = 2;
end

if ~strcmp(filename(1),'n')
    tbl = csvread(filename,1,0);
else
    
    tbl = [ 1.0000    2.2000    2.0000
        2.0000    2.1000    2.0000
        3.0000    2.1000    2.0000
        4.0000    2.1000    2.0000
        5.0000    2.1000    2.0000
        6.0000    2.1000    2.0000
        7.0000    2.1000    2.0000
        8.0000    2.1000    2.0000
        9.0000    2.2000    2.1000
        10.0000    2.2000    2.1000
        11.0000    2.2000    2.2000
        12.0000    2.3000    2.2000
        13.0000    2.3000    2.2000
        14.0000    2.3000    2.2000
        15.0000    2.3000    2.2000
        16.0000    2.3000    2.2000
        17.0000    2.4000    2.2000
        18.0000    2.4000    2.2000
        19.0000    2.3000    2.2000
        20.0000    2.2000    2.1000
        21.0000    2.2000    2.0000
        22.0000    2.1000    1.9000
        23.0000    2.0000    1.9000
        24.0000    1.9000    1.8000
        25.0000    1.9000    1.7000
        26.0000    1.8000    1.7000
        27.0000    1.7000    1.6000
        28.0000    1.7000    1.6000
        29.0000    1.6000    1.5000
        30.0000    1.6000    1.5000
        31.0000    1.5000    1.4000
        32.0000    1.5000    1.4000
        33.0000    1.4000    1.4000
        34.0000    1.4000    1.3000
        35.0000    1.3000    1.3000
        36.0000    1.3000    1.3000
        37.0000    1.3000    1.3000
        38.0000    1.2000    1.3000
        39.0000    1.2000    1.2000
        40.0000    1.2000    1.2000
        41.0000    1.2000    1.2000
        42.0000    1.1000    1.2000
        43.0000    1.1000    1.2000
        44.0000    1.1000    1.2000
        45.0000    1.1000    1.2000
        46.0000    1.0000    1.1000
        47.0000    1.0000    1.1000
        48.0000    1.0000    1.1000
        49.0000    0.9000    1.0000
        50.0000    0.9000    1.0000
        51.0000    0.8000    0.9000
        52.0000    0.8000    0.9000
        53.0000    0.8000    0.9000
        54.0000    0.7000    0.8000
        55.0000    0.7000    0.8000
        56.0000    0.7000    0.8000
        57.0000    0.6000    0.7000
        58.0000    0.6000    0.7000
        59.0000    0.6000    0.7000
        60.0000    0.5000    0.6000
        61.0000    0.5000    0.6000
        62.0000    0.5000    0.6000
        63.0000    0.5000    0.6000
        64.0000    0.4000    0.5000
        65.0000    0.4000    0.5000
        66.0000    0.4000    0.5000
        67.0000    0.4000    0.5000
        68.0000    0.3000    0.4000
        69.0000    0.3000    0.4000
        70.0000    0.3000    0.4000
        71.0000    0.3000    0.3000
        72.0000    0.3000    0.3000
        73.0000    0.2000    0.3000
        74.0000    0.2000    0.3000
        75.0000    0.2000    0.3000
        76.0000    0.2000    0.2000
        77.0000    0.2000    0.2000
        78.0000    0.1000    0.2000
        79.0000    0.1000    0.2000
        80.0000    0.1000    0.2000
        81.0000    0.1000    0.1000
        82.0000    0.1000    0.1000
        83.0000    0.1000    0.1000
        84.0000    0.1000    0.1000
        85.0000         0    0.1000
        89.0000    0.1000    0.2000
        94.0000         0    0.1000
        99.0000         0         0
        100.0000         0         0];
end
agesBin = tbl(:,1);
agesBin = [0; agesBin];
cumDistribution = cumsum(tbl(:,col+1));
cumDistribution = [0;cumDistribution]/100;
agesBin = agesBin(diff(cumDistribution)~=0);
cumDistribution = cumDistribution(diff(cumDistribution)~=0);
cumDistribution = cumDistribution/cumDistribution(length(cumDistribution));
randAge = rand(1,n);
ages = interp1(cumDistribution,agesBin,randAge);
end
%% readFertility
function fertility = spTools_readFertility(filename)
if strcmp(filename(1),'n')
    fertility = [
        2000    0.2300
        2005    0.2200
        2007    0.2120
        2008    0.2070
        2009    0.2040
        2010    0.2020
        2011    0.2010
        2012    0.2010
        2012    0.2000
        2022    0.1950];
else
    fertility = csvread(filename,1,0)/10;
end
end
%% exportCSV
function [ok, msg] = spTools_exportCSV(SDS)

ok = false; %#ok<NASGU>
msg = ''; %#ok<NASGU>


malesID = 1:SDS.number_of_males;
femalesID=1:SDS.number_of_females;
femalesID=femalesID+SDS.number_of_males;
ID=[malesID,femalesID]';
gender = [zeros(1, SDS.number_of_males) ones(1,SDS.number_of_females)]';
born=[SDS.males.born, SDS.females.born]';
deceased=[SDS.males.deceased, SDS.females.deceased]';
father=[SDS.males.father, SDS.females.father]';
mother=[SDS.males.mother,SDS.females.mother]'+SDS.number_of_females;
mother(mother==SDS.number_of_males)=0;
HIV_positive=[SDS.males.HIV_positive,SDS.females.HIV_positive]';

male_source = SDS.males.HIV_source + SDS.number_of_males;
male_source(male_source==SDS.number_of_males)=0;
HIV_source = [male_source, SDS.females.HIV_source]';
sex_worker = [false(1, SDS.number_of_males), SDS.females.sex_worker]';
AIDS_death = [SDS.males.AIDS_death,SDS.females.AIDS_death]';
CD4_infection = [SDS.males.CD4Infection, SDS.females.CD4Infection]';
CD4_death = [SDS.males.CD4Death, SDS.females.CD4Death]';
ARV_eligible=[SDS.males.ARV_eligible, SDS.females.ARV_eligible]';


ID=single(ID);
father=single(father);
mother=single(mother);
HIV_source = single(HIV_source);

allC=[ID,gender, born, deceased, father, mother, HIV_positive, HIV_source, ...
    sex_worker, AIDS_death, CD4_infection,CD4_death, ARV_eligible];
allC=allC(~isnan(born),:);
head={'id','gender','born','deceased','father','mother','hiv.positive','hiv.source',...
    'sex.worker', 'aids.death','cd4.infection','cd4.death','arv.eligible'};
allC=[head
    num2cell(allC)];


% ******* Seperate file for relations *******
relations = [single([SDS.relations.ID]), SDS.relations.time(:,1:2),single(SDS.relations.proximity)];
relations(:,2)=relations(:,2)+SDS.number_of_males;
relations=relations(relations(:,1)~=0,:);
header = {'male.id' 'female.id' 'start.time' 'end.time','proximity'};
relations = [header
    num2cell(relations)
    ];

%********Seperate file for test*********
test = [single(SDS.tests.ID),SDS.tests.time];
test = test(test(:,1)~=0,:);
header = {'id','time'};
test = [header
    num2cell(test)];

%********Seperate file for ARV*********
ARV = [single(SDS.ARV.ID),SDS.ARV.time, single(SDS.ARV.CD4), SDS.ARV.life_year_saved];
ARV = ARV(ARV(:,1)~=0,:);
header = {'id','arv.start','arv.stop','cd4','life.year.saved'};
ARV = [header
    num2cell(ARV)];

% ******* Store *******
folder ='result/csv';
if ~isdir(folder)
    mkdir(folder);
end
file=SDS.data_file(14:17);
save(fullfile(folder, ['sds_', file, '.mat']), 'SDS');
[ok, msg] = exportCSV_print(fullfile(folder, ['allC_', file, '.csv']), allC);
[ok, msg] = exportCSV_print(fullfile(folder,['relation_', file,'.csv']),relations);
[ok, msg] = exportCSV_print(fullfile(folder, ['test_', file, '.csv']), test);
[ok, msg] = exportCSV_print(fullfile(folder, ['arv_', file, '.csv']), ARV);

%% exportCSV_print
    function [ok, msg] = spTools_exportCSV_print(csvFile, dataC)
        
        ok = false;
        msg = ''; %#ok<NASGU>
        
        try
            fid = fopen(csvFile, 'w', 'n', 'UTF-8');
            fprintf(fid, '%s', dataC{1, 1});
            fprintf(fid, ', %s', dataC{1, 2:end});
            fprintf(fid, '\n');
            for ii = 2 : size(dataC, 1)
                fprintf(fid, '%g', dataC{ii, 1});
                fprintf(fid, ', %g', dataC{ii, 2:end});
                fprintf(fid, '\n');
            end
            status = fclose(fid);
        catch ME
            msg = ME.message;
            return
        end
        
        ok = status == 0;
        msg = ['CSV file stored as ', csvFile];
    end
end


%% exportNetCDF
function [ok, msg] = spTools_exportNetCDF(SDS)

ok = false;
msg = '';

ok = true;
end

%%
function spTools_

end
