%% Add pathds, load rat data
addpath(fullfile(pwd,'Utils'));
addpath(fullfile(pwd,'Data'));
Fs = 125;
[trialVars,EEG] = extractSWATrial(fullfile(pwd,'Data','R0003_00231.BIN'),Fs);
exportPath = fullfile(pwd,'Export');

%% SW detection
Fc = trialVars.dominantFreq / 1000;
Fp = trialVars.phaseAngle / 1000;
Ms = trialVars.msToStim;
t = linspace(0,4,numel(EEG)); % just use even numbers
stimIdx = closest(t,max(t)/2+Ms/1000);
endStim = stimIdx + round(0.05/diff(t(1:2)));
midStim = closest(t,max(t)/2+(Ms+25)/1000);
midPoint = round(numel(t)/2);
EEG_cos = [flip(cos(-t(2:midPoint) * (2*pi*Fc) + deg2rad(Fp))) cos(t(1:midPoint+1) * (2*pi*Fc) + deg2rad(Fp))];
t = linspace(-2,2,numel(EEG)); % just use even numbers

fs = 14;
EEG_filt = bandpass(EEG,[0.5 4],Fs);
close all;
ff(1400,300);
rows = 1;
cols = 6;

subplot(rows,cols,1:4);
ln1 = plot(t,detrend(EEG),'k-','linewidth',2);
ylabel('EEG (\muV)');
hold on;
ln2 = plot(t,EEG_filt,'color',[0 0 0 0.7]);
legend([ln1,ln2],{'Raw','Filtered'},'Autoupdate','off','location','northwest','fontsize',fs-2);
legend box off;
yticks(-100:50:100);

yyaxis right;
plot(t(1:midPoint),EEG_cos(1:midPoint),'r-','linewidth',2);
hold on;
plot(t(midPoint:end),EEG_cos(midPoint:end),'r:','linewidth',2);
ylabel('Signal Estimate');
ylim([-1.5 1.8]);
yticks(ylim);
yticklabels([]);
set(gca,'ycolor','r');

colors = lines(5);
x = [t(stimIdx) t(endStim) t(endStim) t(stimIdx)];
y = [min(ylim) min(ylim) max(ylim) max(ylim)];
patch('XData',x,'YData',y,'FaceColor','red','EdgeColor','none','FaceColor',colors(5,:),'FaceAlpha',0.5);

xlim([min(t), max(t)]);
xticks(min(t):max(t)/4:max(t));
grid on;
xlabel('Time (s)');
xline(t(midPoint),'k-');
set(gca,'fontsize',14);

text(t(endStim),max(ylim),'\leftarrowSTIM','color',colors(5,:),'fontsize',fs-2,'verticalalignment','top','horizontalalignment','left');
text(t(midPoint),max(ylim),'DETECT\rightarrow','color','k','fontsize',fs-2,'verticalalignment','top','horizontalalignment','right');
title('SW Detection and Stimulus');

pos = get(gca,'Position');
set(gca,'Position',pos.*[1 1.5 0.96 .903]);

% SW Trial summary
load(fullfile(pwd,'Data','R0003_ESLOMethods_trialData')); % R0005
blackTrials = find(all_Sham==0 & all_Freq > 1);
redTrials = find(all_Sham & all_Freq > 1);
nBins = 13;
fs = 14;

subplot(rows,cols,5);
fHistBins = linspace(0,4,nBins);
histogram(all_Freq(blackTrials),fHistBins,'facecolor','k');
hold on;
histogram(all_Freq(redTrials),fHistBins,'facecolor','r');
% ylabel('# Trials');
xlabel('F_c (Hz)');
xticks(0:4);
set(gca,'fontsize',fs);
ylabel('Trials');
% set(gca,'view',[90 -90]);
ylim(ylim.*[0 1.2]);
% yticks(ylim);
grid on;
title('Center Frequency (F_c)');
legend({'Stim Trials','Sham Trials'},'location','north','fontsize',fs-2);
legend boxoff;

subplot(rows,cols,6);
msHistBins = linspace(0,500,nBins);
histogram(all_msToStim(blackTrials),msHistBins,'facecolor','k');
hold on;
histogram(all_msToStim(redTrials),msHistBins,'facecolor','r');
set(gca,'fontsize',fs);
ylabel('Trials');
% yticks(ylim);
grid on;
xlabel('Phase Delay (ms)')
title('Phase Delay Time');
legend({'Stim Trials','Sham Trials'},'location','north','fontsize',fs-2);
legend boxoff;

doSave = 0;
% FOR PAPER: doSave = 0, then copy/paste:
%     print(gcf,'-painters','-depsc',fullfile(exportPath,'ESLOMethods_DetectionFigure_raw.eps')); % required for vector lines
if doSave
    [xs,ys] = ginput(2);
    fs = 28;
    text(xs(1),ys(1),'A','fontsize',fs);
    text(xs(2),ys(1),'B','fontsize',fs);
    saveas(gcf,'ESLOMethods_DetectionFigure.jpg','jpg');
%     close(gcf);
end

%% squirrel sleep
% do=1 to setup
if do
    [type,data,labels] = extractSD(fullfile(pwd,'Data','S0006_ESLORB2.TXT'),Inf,datetime(2021,8,13));
    do = false;
    SDreport(type,labels);
    useTypes = ["EEG2","EEG3","XlX","XlY","XlZ"];
    dataIntervals = findESLOIntervals(data,type,labels,useTypes);
end

Fs = 50;
axyFs = 1;
startHour = 20;
showHours = 8;
esloGain = 12;

iSegment = 4;
xRow = find(dataIntervals.segment == iSegment & dataIntervals.type == ESLOType("XlX",labels));
x = data(dataIntervals.range{xRow});
yRow = find(dataIntervals.segment == iSegment & dataIntervals.type == ESLOType("XlY",labels));
y = data(dataIntervals.range{yRow});
zRow = find(dataIntervals.segment == iSegment & dataIntervals.type == ESLOType("XlZ",labels));
z = data(dataIntervals.range{zRow});
OA = axyOA(x,y,z,axyFs);

EEG_row = find(dataIntervals.segment == iSegment & dataIntervals.type == ESLOType("EEG2",labels));
EEG = double(data(dataIntervals.range{EEG_row}));
EEG = ADSgain(EEG,esloGain); % convert to uV
EEG = cleanEEG(EEG,300); % clean at 300uV

% data is loaded, trim recording
secondsOffset = startHour*60*60 - (hour(dataIntervals.time(EEG_row))*60*60 ...
    + minute(dataIntervals.time(EEG_row))*60 + second(dataIntervals.time(EEG_row)));
sampleOffset = round(secondsOffset * Fs);
if sampleOffset < 1
    sampleOffset = 1;
end
sampleRange = sampleOffset:sampleOffset+showHours*3600*Fs;
if sampleRange > numel(EEG)
    error('showHours out of range');
end
EEG = detrend(EEG(sampleRange));
x = x(secondsOffset:secondsOffset+showHours*3600*axyFs);
y = y(secondsOffset:secondsOffset+showHours*3600*axyFs);
z = z(secondsOffset:secondsOffset+showHours*3600*axyFs);
OA = OA(secondsOffset:secondsOffset+showHours*3600*axyFs);

t_EEG = linspace(0,numel(EEG)/Fs/3600,numel(EEG));
t_axy = linspace(0,numel(EEG)/Fs/3600,numel(x));

fs = 14;
lw = 1.5;
lns = [];
close all;
rows = 3;
cols = 2;
ff(800,600);

t_sleep = 2.2003;
t_wake = 6.3818;
t_int = 10/3600; % 10 seconds

iPlotTitles = {'Overnight EEG and Accelerometer (Axy) Data','Sleep','Wake'};
plotMap = {1:2,3,4};
for iPlot = 1:3
    subplot(rows,cols,plotMap{iPlot});
    lns(1) = plot(t_EEG,EEG,'k','linewidth',lw);
    ylim([-500,800]);
    yticks([-200,0,200]);
    xlim([min(t_EEG),max(t_EEG)]);
    set(gca,'fontsize',fs);
    if ismember(iPlot,[1,2])
        ylabel('EEG (\muV)');
    end
    grid on;

    yyaxis right;
    colors = lines(3);
    lns(2) = plot(t_axy,normalize(x,'range'),'-','color',colors(1,:),'linewidth',lw);
    hold on;
    lns(3) = plot(t_axy,normalize(y,'range'),'-','color',colors(2,:),'linewidth',lw);
    lns(4) = plot(t_axy,normalize(z,'range'),'-','color',colors(3,:),'linewidth',lw);

    ylim([-2.35 1.5]);
    yticks(0.5);
    yticklabels({'±2'});
    
    if ismember(iPlot,[1,3])
        ylabel('Axy (mg)','VerticalAlignment','top');
    end
    grid on;
    set(gca,'ycolor','k');
    if iPlot == 1
        lg = legend(lns,{'EEG','X-axis','Y-axis','Z-axis'},'orientation','horizontal','location','southwest','fontsize',fs-2);
        pos = lg.Position;
        lg.Position = pos.*[1,.98,1,1];
        legend box off;
        xlabel('Time (hours)');
        text(min(xlim),max(ylim),' 8PM','fontsize',fs,'verticalalignment','top');
        text(t_sleep,max(ylim),'\downarrowSleep','fontsize',fs,'verticalalignment','top');
        text(t_wake,max(ylim),'\downarrowWake','fontsize',fs,'verticalalignment','top');
    end
    if iPlot == 2
        xlim([t_sleep t_sleep+t_int]);
    end
    if iPlot == 3
        xlim([t_wake t_wake+t_int]);
    end
    if ismember(iPlot,2:3)
        xticks(xlim);
        xticklabels({'0','10'});
        xlabel('Time (seconds)','verticalalignment','bottom');
    end

    title(iPlotTitles{iPlot});
end

subplot(rows,cols,5:6);
[P,F,T] = pspectrum(EEG,Fs,'spectrogram','frequencylimits',[0.5 20]);
T = linspace(0,8,numel(T));
imagesc(T,F,P);
set(gca,'ydir','normal','fontsize',fs);
colormap(magma);
xlabel('Time (hours)');
ylabel('Frequency (Hz)');
caxisauto(P,1);

yyaxis right;
colors = lines(3);
lns(2) = plot(t_axy,normalize(x,'range'),'-','color',colors(1,:),'linewidth',lw);
hold on;
lns(3) = plot(t_axy,normalize(y,'range'),'-','color',colors(2,:),'linewidth',lw);
lns(4) = plot(t_axy,normalize(z,'range'),'-','color',colors(3,:),'linewidth',lw);
ylabel('Axy (mg)','VerticalAlignment','top');
set(gca,'ycolor','k');
title('EEG Spectrogram');
ylim([-2.35 1.5]);
yticks(0.5);
yticklabels({'±2'});
text(min(xlim),max(ylim),' 8PM','fontsize',fs,'verticalalignment','top','color','w');
text(t_sleep,max(ylim),'\downarrowSleep','fontsize',fs,'verticalalignment','top','color','w');
text(t_wake,max(ylim),'\downarrowWake','fontsize',fs,'verticalalignment','top','color','w');

doSave = 0;
%     print(gcf,'-painters','-depsc',fullfile(exportPath,'ESLOMethods_S0006_raw.eps')); % required for vector lines
if doSave
    [xs,ys] = ginput(3);
    fs = 28;
    text(xs(1),ys(1),'A','fontsize',fs);
    text(xs(1),ys(2),'B','fontsize',fs);
    text(xs(1),ys(3),'C','fontsize',fs);
    saveas(gcf,'ESLOMethods_S0006.jpg','jpg');
%     close(gcf);
end
%% Squirrel SW Cycle, must run previous figure first
fIdx = find(F >= 0.5 & F < 4);
subP = P(fIdx,:); % plot(mean(subP));
Fs_d = numel(T)/showHours;
[Pd,Fd] = pspectrum(detrend(mean(subP)),Fs_d);
% do=1 to setup
if do
    nSurr = 1000;
    Pd_surr = [];
    for iSurr = 1:nSurr
        [Pd_x,~] = pspectrum(detrend(randsample(mean(subP),numel(mean(subP)),false)),Fs_d);
        Pd_surr(iSurr,:) = Pd_x;
    end
    Pd_sig = 1 - sum(Pd' > Pd_surr)./nSurr;
    do = 0;
end

pThresh = 0.001;
fs = 14;
close all
ff(900,200);
rows = 1;
cols = 4;

subplot(rows,cols,1:3);
plot(T,mean(subP),'k','linewidth',2);
ylabel('Power (\mu^2)');
set(gca,'fontsize',fs);
xlabel('Time (hours)');
grid on;
title('Overnight SW (0.5-4Hz) Power');
pos = get(gca,'Position');
set(gca,'Position',pos.*[1 2.3 1 0.7]);
text(min(xlim),max(ylim),' 8PM','fontsize',fs,'verticalalignment','top');

% mark 3 oscillations
% % [xs,ys] = ginput(3);
xs = [3.2773,3.5430,3.8555];
ys = [244.0789,249.3421,238.8158];
for ii = 1:3
    text(xs(ii),ys(ii),'\downarrow','fontsize',fs,'HorizontalAlignment','center','verticalalignment','bottom');
end

subplot(rows,cols,4);
plot(Fd,Pd,'k','linewidth',2);
hold on;
pIds = find(Pd_sig < pThresh);
plot(Fd(pIds),Pd(pIds),'r.');
ylabel('Magnitude (A.U.)');
yticks(ylim);
yticklabels([]);
xlim([0 15]);
xlabel('Cycles (per hour)');
set(gca,'fontsize',fs);
title('SW Cycles');
grid on;
pos = get(gca,'Position');
set(gca,'Position',pos.*[1 2.3 1 0.7]);
[~,k] = max(Pd);
text(Fd(k),Pd(k),strcat(' \leftarrow',sprintf('%1.2f',Fd(k))),'color','r','fontsize',fs);

doSave = 0;
%     print(gcf,'-painters','-depsc',fullfile(exportPath,'ESLOMethods_S0006_SWCycle_raw.eps')); % required for vector lines
if doSave
    [xs,ys] = ginput(2);
    fs = 28;
    text(xs(1),ys(1),'A','fontsize',fs);
    text(xs(2),ys(1),'B','fontsize',fs);
    saveas(gcf,'ESLOMethods_S0006_SWCycle.jpg','jpg');
end