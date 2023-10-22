function [bep,tgtRptPlotterFcn] = helperSetupBEP(egoVehicle,rdr)

name = 'Simulating Radar Scenario';
figname = strtrim([name ' BEP']);
[fig,isNew] = helperFigureName(figname);
if isNew
    fig.Visible = 'on';
end
clf(fig);
ax = axes(fig);

bep = birdsEyePlot('XLim',[-5 60],'YLim',20*[-1 1],'Parent',ax);
legend(ax,'off');

helperPlotScenario(bep,egoVehicle);


% Add radar's field of view
caPlotter = coverageAreaPlotter(bep,'DisplayName','Radar FoV','FaceColor','m');
pos = rdr.MountingLocation(1:2);
rgMax = rdr.RangeLimits(2);
yaw = rdr.MountingAngles(1);
azFov = rdr.FieldOfView(1);

plotCoverageArea(caPlotter,pos,rgMax,yaw,azFov);

if nargin>1
    if strcmpi(rdr.TargetReportFormat,'Tracks')
        tgtRptPlotter = trackPlotter(bep,'MarkerFaceColor','k','DisplayName','Radar tracks','VelocityScaling',0.3);
        tgtRptPlotterFcn = @(trks,config)helperPlotTracks(tgtRptPlotter,trks,config);
    else
        tgtRptPlotter = detectionPlotter(bep,'DisplayName','Radar detections','VelocityScaling',0.3,'MarkerFaceColor','k');
        tgtRptPlotterFcn = @(dets,config)helperPlotDetections(tgtRptPlotter,dets,config);
    end
    legend(ax,'show');
end
end

function helperPlotDetections(detPlotter,dets,config)
if numel(dets)
    pos = cell2mat(cellfun(@(d)d.Measurement(1:2),dets(:)','UniformOutput',false))';
    vel = cell2mat(cellfun(@(d)d.Measurement(4:5),dets(:)','UniformOutput',false))';
    plotDetection(detPlotter,pos,vel);
    
elseif config.IsValidTime
    clearData(detPlotter);
end
end
