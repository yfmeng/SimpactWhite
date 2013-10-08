function [ok, msg] = demo(SDS)

ok = false;
msg = '';

if isempty(SDS.males) || isempty(SDS.females)
    msg = 'Warning: no population available';
    return
end

timeRange = ceil((datenum(SDS.end_date) - datenum(SDS.start_date))/spTools('daysPerYear'));

figPrp.Name = 'Demographics';
figPrp.ToolBar = 'figure';
hFig = fig(figPrp);

% ******* Population size *******
axesPrp.Box = 'on';
axesPrp.Parent = hFig;
axesPrp.Position = [.1 .6 .85 .35];
axesPrp.Units = 'normalized';
% axesPrp.XGrid = 'on';
% axesPrp.YGrid = 'on';
hAxes = axes(axesPrp);


ReportingInterval = .1;                  % yearly degree distibutions
ReportingTimes = ReportingInterval : ReportingInterval : timeRange;
N = numel(ReportingTimes);
population = zeros(N, 1);
age_edges = 0:10:120;
histo_matrix = zeros(N, 1);


for ii = 1 : N
    
    ST = ReportingTimes(ii);            % stock taking
    existM = SDS.males.born<=ST;
    existF = SDS.females.born<=ST;
    aliveM = (SDS.males.deceased>ST)|isnan(SDS.males.deceased);
    aliveF = (SDS.females.deceased>ST)|isnan(SDS.females.deceased);
    stockM = existM&aliveM;
    stockF = existF&aliveF;
    population(ii) = sum(stockM)+sum(stockF);
    
    agehist = histc(ST -[SDS.males.born(stockM) SDS.females.born(stockF)], age_edges);

    histo_matrix(ii,1:length(agehist)) = agehist / sum(agehist);
end
    
linePrp.Color = [12 14 12]/15;
linePrp.Marker = '.';
linePrp.MarkerEdgeColor = [0 10 0]/15;
linePrp.Parent = hAxes;



line(ReportingTimes, population, linePrp)
xlabel(hAxes, 'time [years]')
ylabel(hAxes, 'population size')
set(hAxes, 'XLim', [0, timeRange])
set(hAxes, 'YLim', [0, round(max(population))+10])


% Age distribution
axesPrp.Position(2) = .1;
hAxes = axes(axesPrp);



linePrp.Parent = hAxes;
%axesPrp.YLim = [0 1];
%axesPrp.Xlim = [0, timeRange];
%set(hAxes, 'XLim', [0, timeRange])
set(hAxes, 'Ylim', [0, 1])

bar(hAxes, histo_matrix,'stack')

set(hAxes,'YLim',[0 1]); %'XLim',[0 timeRange]);
xlabel(hAxes, 'time [years]')
ylabel(hAxes, 'Fraction')
%legend(hAxes(2), '1', '2', '3', '4', '5', '6', '7', '8', '9', '10')
legend(hAxes, '0-10', '10-20', '20-30', '30-40', '40-50', '50-60', '60-70', '70-80', '80-90', '90-100',...
    '100-110', '110-120'); %num2cell(num2str((1 : size(histo_matrix, 2))')))



% line(newYear, incidence*100, linePrp)

%set(hAxes, 'XLim', [0, timeRange])





%linkaxes(hAxes, 'x')
zoom(hFig, 'on')
figure(hFig)


% ******* Add Print Buttons *******

ok = true;
end
