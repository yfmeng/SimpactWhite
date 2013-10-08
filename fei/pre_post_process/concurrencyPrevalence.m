function concurrencyPrevalence(SDS)

ok = false;
msg = '';

if isempty(SDS.males) || isempty(SDS.females)
    msg = 'Warning: no population available';
    return
end

timeRange = ceil((datenum(SDS.end_date) - datenum(SDS.start_date))/spTools('daysPerYear'));

figPrp.Name = 'Concurrency Point Prevalence';
hFig = fig(figPrp);


% ******* Male Concurrency Point Prevalence *******
axesPrp.Box = 'on';
axesPrp.Parent = hFig;
axesPrp.Position = [.1 .6 .85 .35];
axesPrp.Units = 'normalized';
% axesPrp.XGrid = 'on';
% axesPrp.YGrid = 'on';
hAxes(1) = axes(axesPrp);



ReportingInterval = .1;                  % yearly degree distibutions
ReportingTimes = ReportingInterval : ReportingInterval : timeRange;
N = numel(ReportingTimes);
x_m_outmatrix = zeros(N, 1);
x_f_outmatrix = zeros(N, 1);
histo_mmatrix = zeros(N, 1);
histo_fmatrix = zeros(N, 1);


for ii = 1 : N
    
    ST = ReportingTimes(ii);            % stock taking
    relationsIdx = ...
        (SDS.relations.time(:, SDS.index.start) < ST) & ...
        (SDS.relations.time(:, SDS.index.stop) >= ST);
    
    malePartners = SDS.relations.ID(relationsIdx, 1);
    femalePartners = SDS.relations.ID(relationsIdx, 2);
    unique_mp = unique(malePartners);
    unique_fp = unique(femalePartners);
    partners_m = nan(1, length(unique_mp));
    partners_f = nan(1, length(unique_fp));
    
    for jj = 1 : length(unique_mp)
        rel_mp = find(malePartners == unique_mp(jj));
        partners_m(jj) = length(unique(femalePartners(rel_mp)));
    end
    for jj = 1 : length(unique_fp)
        rel_fp = find(femalePartners == unique_fp(jj));
        partners_f(jj) = length(unique(malePartners(rel_fp)));
    end
    x_m = 1 : max(partners_m);
    x_f = 1 : max(partners_f);
    [histo_m, x_m_out] = hist(partners_m, x_m);
    [histo_f, x_f_out] = hist(partners_f, x_f);
    
    x_m_outmatrix(ii,1:length(x_m_out)) = x_m_out;
    x_f_outmatrix(ii,1:length(x_f_out)) = x_f_out;
    histo_mmatrix(ii,1:length(histo_m)) = histo_m / sum(histo_m);
    histo_fmatrix(ii,1:length(histo_f)) = histo_f / sum(histo_f);
    %{
    NIU
    %}
    %figure(ii)
    %bar(x_m_outmatrix{ii,:}, histo_mmatrix{ii,:})
    % It's better to make a trellis plot;
    
end

bar(hAxes(1), histo_mmatrix, 'stack')
set(hAxes(1),'YLim',[0 1],'XLim',[0 size(histo_mmatrix,1)]);
xlabel(hAxes(1), 'time [years]')
ylabel(hAxes(1), 'Fraction')
%legend(hAxes(1), '1', '2', '3', '4', '5', '6', '7', '8', '9', '10')
legend(hAxes(1), num2cell(num2str((1 : size(histo_mmatrix, 2))')))


% ******* Female Concurrency Point Prevalence *******

axesPrp.Position(2) = .1;
axesPrp.YLim = [0 1];
hAxes(2) = axes(axesPrp);

bar(hAxes(2), histo_fmatrix,'stack')
set(hAxes(2),'YLim',[0 1],'XLim',[0 size(histo_fmatrix,1)]);
xlabel(hAxes(2), 'time [years]')
ylabel(hAxes(2), 'Fraction')
%legend(hAxes(2), '1', '2', '3', '4', '5', '6', '7', '8', '9', '10')
legend(hAxes(2), num2cell(num2str((1 : size(histo_fmatrix, 2))')))

linkaxes(hAxes, 'x')
zoom(hFig, 'on')
figure(hFig)


% ******* Add Print Buttons *******


ok = true;
end