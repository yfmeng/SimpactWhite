function [ok, msg] = formationScatter(SDS)
% Original code by Fei Meng, modified by Ralph

ok = false;
msg = '';

if isempty(SDS.relations.ID)
    msg = 'Warning: no population available';
    return
end


count = sum(SDS.relations.ID(:, SDS.index.male) ~= 0);
maleAge = nan(1, count);
femaleAge = nan(1, count);

for ii = 1 : count
    maleAge(ii) = SDS.relations.time(ii, SDS.index.start) - ...
        SDS.males.born(SDS.relations.ID(ii, SDS.index.male));
    femaleAge(ii) = SDS.relations.time(ii, SDS.index.start) - ...
        SDS.females.born(SDS.relations.ID(ii, SDS.index.female));
end

figPrp.Name = 'Relations Formation Scatter';
figPrp.ToolBar = 'figure';
hFig = fig(figPrp);
hAxes = axes('Parent', hFig);

hScat = scatter(hAxes, femaleAge, maleAge, 4, 'HitTest', 'off');
linePrp = [];
linePrp.Color = 'r';
linePrp.HitTest = 'off';
linePrp.Parent = hAxes;
linePrp.LineWidth = 2;
lim = [0 max([get(hAxes, 'XLim'), get(hAxes, 'YLim')])];
hLine = line(lim, lim, linePrp);

textPrp = [];
textPrp.BackgroundColor = [15 15 13]/15;
textPrp.EdgeColor = [4 6 8]/15;
textPrp.HitTest = 'off';
textPrp.Parent = hAxes;
textPrp.VerticalAlignment = 'top';
textPrp.Visible = 'off';
hText = nan(1, count);

t0 = datenum(SDS.start_date);
daysPerYear = spTools('daysPerYear');

for ii = 1 : count
    tStart = SDS.relations.time(ii, SDS.index.start);
    tStop = SDS.relations.time(ii, SDS.index.stop);
    if isfinite(tStop)
        stopStr = sprintf('\n%s', datestr(t0 + tStop*daysPerYear));
    else
        stopStr = '';
    end
    hText(ii) = text(femaleAge(ii), maleAge(ii), ...
        sprintf('Relation %d\nMale %d with female %d\n%s%s', ...
        ii, SDS.relations.ID(ii, SDS.index.male), ...
        SDS.relations.ID(ii, SDS.index.female), ...
        datestr(t0 + tStart*daysPerYear), stopStr), textPrp);
end

set(hAxes, 'ButtonDownFcn', @spGraphs_formationScatter_callback, ...
    'Box', 'on', 'Children', [hText, hScat, hLine], ...
    'DataAspectRatio', [1 1 1], ...
    'XGrid', 'on', 'YGrid', 'on', 'XLim', lim, 'YLim', lim)
title(hAxes, 'Click on a data point to see its properties')
xlabel(hAxes, 'female age')
ylabel(hAxes, 'male age ')

%zoom(hFig, 'on')


% ******* Add Print Buttons *******


figure(hFig)

ok = true;


%% formationScatter_callback
    function spGraphs_formationScatter_callback(~, ~)
        
        click = get(hAxes, 'CurrentPoint');
        [~, idx] = min((femaleAge - click(1)).^2 + (maleAge - click(1,2)).^2);
        set(hText(idx), 'Visible', onoff(~onoff(get(hText(idx), 'Visible'))))
    end
end