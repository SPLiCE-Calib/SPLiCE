%% figure_eval_YUD_precision_recall

clc;
clear;
close all;


% York Urban Dataset (1~XX)
expCase = 1;
setupParams_York_Urban;


% load saved data in SaveDir
SaveDir = [datasetPath '/IROS2021'];
load([SaveDir '/MWMS.mat']);
load([SaveDir '/MWBnB.mat']);
load([SaveDir '/QBnB.mat']);
load([SaveDir '/OLRE.mat']);
load([SaveDir '/SLRE.mat']);


%% plot precision graph

% compute precision statistics
[statistics_p_MWMS] = computePrecisionStatistics(precision_MWMS);
[statistics_p_MWBnB] = computePrecisionStatistics(precision_MWBnB);
[statistics_p_QBnB] = computePrecisionStatistics(precision_QBnB);
[statistics_p_OLRE] = computePrecisionStatistics(precision_OLRE);
[statistics_p_SLRE] = computePrecisionStatistics(precision_SLRE);
data_p = [statistics_p_MWMS; statistics_p_MWBnB; statistics_p_QBnB; statistics_p_OLRE; statistics_p_SLRE];


% plot precision graph
figure;
h_p = bar(data_p.'); grid on;
leg_p = legend(h_p,'Proposed','BnB','QBnB','OLRE','SLRE');
set(leg_p, 'Location', 'northwest','FontName','Times New Roman','FontSize',19, 'Interpreter','latex');
set(gca,'xticklabel',{'<90','90~92.5','92.5~95','95~97.5','>97.5'});
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',21);
xlabel('Precision ($\%$)','Interpreter','latex','FontName','Times New Roman','FontSize',21);
ylabel('Frequency','Interpreter','latex','FontName','Times New Roman','FontSize',21);
axis([0.6 5.4 0 100]); set(gcf,'color','w');
set(gcf,'Units','pixels','Position',[400 350 720 550]);


% copy current figure as vector graphics format
copygraphics(gcf,'ContentType','vector','BackgroundColor','none');




%% plot recall graph

% compute recall statistics
[statistics_r_MWMS] = computeRecallStatistics(recall_MWMS);
[statistics_r_MWBnB] = computeRecallStatistics(recall_MWBnB);
[statistics_r_QBnB] = computeRecallStatistics(recall_QBnB);
[statistics_r_OLRE] = computeRecallStatistics(recall_OLRE);
[statistics_r_SLRE] = computeRecallStatistics(recall_SLRE);
data_r = [statistics_r_MWMS; statistics_r_MWBnB; statistics_r_QBnB; statistics_r_OLRE; statistics_r_SLRE];


% plot recall graph
figure;
h_p = bar(data_r.'); grid on;
leg_p = legend(h_p,'Proposed','BnB','QBnB','OLRE','SLRE');
set(leg_p, 'Location', 'northwest','FontName','Times New Roman','FontSize',19, 'Interpreter','latex');
set(gca,'xticklabel',{'<80','80~85','85~90','90~95','>95'});
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',21);
xlabel('Recall ($\%$)','Interpreter','latex','FontName','Times New Roman','FontSize',21);
ylabel('Frequency','Interpreter','latex','FontName','Times New Roman','FontSize',21);
axis([0.6 5.4 0 100]); set(gcf,'color','w');
set(gcf,'Units','pixels','Position',[400 350 720 550]);










