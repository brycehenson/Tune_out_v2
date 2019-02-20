%Script that scrapes the analysed data from dirs (currently messy but works)
clear all
%setup directories you wish to loop over
loop_config.dir = {
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190204_to_hwp_51_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190203_to_hwp_29_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190201_to_hwp_131_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190203_to_hwp_171_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190203_to_hwp_191_nuller_reconfig\',
    'Y:\TDC_user\ProgramFiles\my_read_tdc_gui_v1.0.1\dld_output\20190211_to_hwp_208_nuller_reconfig\',
    'Y:\TDC_user\ProgramFiles\my_read_tdc_gui_v1.0.1\dld_output\20190211_to_hwp_194_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190210_to_hwp_187_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190210_to_hwp_181_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190210_to_hwp_177_nuller_reconfig_part_b\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190210_to_hwp_177_nuller_reconfig_part_a\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190210_to_hwp_171_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190210_to_hwp_165_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190210_to_hwp_160_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190209_to_hwp_155_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190209_to_hwp_145_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190209_to_hwp_140_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190208_to_hwp_120_nuller_reconfig_okish\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190208_to_hwp_99_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190207_to_hwp_80_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190204_to_hwp_121_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190204_to_hwp_24_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190204_to_hwp_46_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190204_to_hwp_61_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190204_to_hwp_92_nuller_reconfig\',
    'Y:\TDC_user\ProgramFiles\my_read_tdc_gui_v1.0.1\dld_output\20190211_to_hwp_230_nuller_reconfig\',
    'Y:\TDC_user\ProgramFiles\my_read_tdc_gui_v1.0.1\dld_output\20190211_to_hwp_217_nuller_reconfig\',
    'Y:\TDC_user\ProgramFiles\my_read_tdc_gui_v1.0.1\dld_output\20190211_to_hwp_199_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190206_to_hwp_100_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190204_to_hwp_141_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190204_to_hwp_160_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190204_to_hwp_180_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190204_to_hwp_70_nuller_reconfig\',
    'Y:\TDC_user\ProgramFiles\my_read_tdc_gui_v1.0.1\dld_output\20190211_to_hwp_240_nuller_reconfig\',
    'Y:\TDC_user\ProgramFiles\my_read_tdc_gui_v1.0.1\dld_output\20190211_to_hwp_250_nuller_reconfig_tenma_setpoint\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190201_to_hwp_111_nuller_reconfig\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190203_to_hwp_151_nuller_reconfig\'
    };

data = to_data(loop_config);
drift_data_compiled = data.drift;
main_data_compiled = data.main;
TO_st_pt = 7.257355*1e14;
selected_dirs = 1:numel(loop_config.dir);
to_pol = zeros(numel(loop_config.dir),1);
to_pol_drift = [];

for loop_idx=selected_dirs
    current_dir = loop_config.dir{loop_idx};
    strt = strfind(current_dir,'hwp_');
    fin = strfind(current_dir,'_n');
    to_pol(loop_idx) = str2num(current_dir(strt+4:fin-1));
end
tot_avg_drift = sum(drift_data_compiled.to_val{1}./drift_data_compiled.to_val{2})./sum(1./drift_data_compiled.to_val{2})-TO_st_pt;
plot([min(main_data_compiled.time),max(main_data_compiled.time)],[tot_avg_drift,tot_avg_drift]./1e9,'color',[0 0.5 0])
title('Segment Scan data')
xlabel('time since epoch (h)')
ylabel([' TO value - ',num2str(TO_st_pt./1e9),' (GHz)'])
box on
hold off
%% Plot the analysis of whole runs
subplot(2,1,2)
errorbar(main_data_compiled.time,(main_data_compiled.quad_fit{1}-TO_st_pt)./1e9,main_data_compiled.quad_fit{2}./1e9,'kx')
hold on
errorbar(main_data_compiled.time,(main_data_compiled.lin_fit{1}-TO_st_pt)./1e9,main_data_compiled.lin_fit{2}./1e9,'bo')
tot_avg_quad = sum(main_data_compiled.quad_fit{1}./main_data_compiled.quad_fit{2})./sum(1./main_data_compiled.quad_fit{2})-TO_st_pt;
plot([min(main_data_compiled.time),max(main_data_compiled.time)],[tot_avg_quad,tot_avg_quad]./1e9,'color',[0 0.5 0])
legend('Quad','Lin','Total avg')
xlabel('time since epoch (h)')
ylabel([' TO value - ',num2str(TO_st_pt./1e9),' (GHz)'])
title('Quad fit data for whole runs')
set(gcf,'color','w')
%ylim([-3 5])
%%
fprintf('Fixed period fit\n')

vec_corr_to = main_data_compiled.lin_fit{1}./1e6;
to_vals_error = main_data_compiled.lin_fit{2}./1e6;

%fit sin waves to the two sets of data
modelfun = @(b,x) b(1).*(cos(x(:,1).*pi./180+b(2).*2*pi).^2)+b(3);
opts = statset('MaxIter',1e4);
ci_size_cut_outliers=1-erf(10/sqrt(2));%1-erf(zvalue/sqrt(2)) %confidence interval for cutting outliers
beta0 = [1e3,0.5,nanmean(vec_corr_to)]; %intial guesses
wlin=1./(to_vals_error.^2);
fit_mdl_lin = fitnlm(to_pol,vec_corr_to,modelfun,beta0,...
    'Options',opts,'Weights',wlin,'CoefficientNames' ,{'amp','phase','offset'});

%cut outliers
[to_predict,yci_cull_lim]=predict(fit_mdl_lin,to_pol,'Prediction','observation','Alpha',ci_size_cut_outliers);
is_outlier_idx=vec_corr_to>yci_cull_lim(:,1) & vec_corr_to<yci_cull_lim(:,2);
vec_corr_to_trim = vec_corr_to(is_outlier_idx);
to_res = vec_corr_to-to_predict;

beta0 = fit_mdl_lin.Coefficients{:,1}'; %intial guesses
fit_mdl_lin = fitnlm(to_pol(is_outlier_idx),vec_corr_to(is_outlier_idx),modelfun,beta0,...
    'Options',opts,'CoefficientNames' ,{'amp','phase','offset'});
lin_fit_max=[fit_mdl_lin.Coefficients.Estimate(1)+fit_mdl_lin.Coefficients.Estimate(3)...
    sqrt(fit_mdl_lin.Coefficients.SE(1)^2+fit_mdl_lin.Coefficients.SE(3)^2)];

sfigure(8419);
clf
ci_size_disp=1-erf(1/sqrt(2));%one sd %confidence interval to display
plot_padd=20;
xsamp = linspace(min(to_pol)-plot_padd,max(to_pol)+plot_padd,1e4).';
fit_values = fit_mdl_lin.Coefficients{:,1};
%subplot(2,1,1)
hold on
title(['amp= ',num2str(fit_values(1)),'MHz , phase= ',num2str(fit_values(2)),', offset= ',num2str(fit_values(3)),'MHz , period=180(fixed)^\circ'])
xlabel('Input Pol angle (degrees)')
ylabel(sprintf('Tune out value-%.1f�%.1f (MHz)',lin_fit_max(1),lin_fit_max(2)) )
fprintf('Tune out value-%.1f�%.1f (MHz) (BLUE)\n',lin_fit_max(1),lin_fit_max(2))
fprintf('Tune out value-%.1f�%.1f (MHz) (RED)\n',lin_fit_max(1)/2,lin_fit_max(2)/2)
errorbar(to_pol,vec_corr_to_trim-lin_fit_max(1),to_vals_error(is_outlier_idx),'ko')
[y_lin,yci_lin]=predict(fit_mdl_lin,xsamp,'Prediction','observation','Alpha',ci_size_disp); %'Prediction','observation'
%y_lin = b1(1).*(cos(xsamp.*pi/180+b1(2).*2*pi).^2)+b1(3);
plot(xsamp,y_lin-lin_fit_max(1),'b-','LineWidth',1.6)
plot(xsamp,yci_lin(:,1)-lin_fit_max(1),'r-','LineWidth',1.6)
plot(xsamp,yci_lin(:,2)-lin_fit_max(1),'r-','LineWidth',1.6)
errorbar(to_pol(~is_outlier_idx),vec_corr_to(~is_outlier_idx)-lin_fit_max(1),to_vals_error(~is_outlier_idx),'rx')

%% Plot tune out value against parameters in the analysis (to see if there is any underling corralations)
%Should turn this into a loop, didn't get around to it
sfigure(1929);
clf
subplot(2,2,1)
scatter(main_data_compiled.grad,to_res,'kx')
xlabel('Gradient of Signal')
ylabel(' Residual (MHz)')
set(gcf,'color','w')
box on
subplot(2,2,2)
scatter(main_data_compiled.shots,to_res,'kx')
xlabel('Shot number')
ylabel(' Residual (MHz)')
set(gcf,'color','w')
box on
subplot(2,2,3)
scatter(main_data_compiled.set_pt,to_res,'kx')
xlabel('Set pt')
ylabel(' Residual (MHz)')
set(gcf,'color','w')
box on
subplot(2,2,4)
scatter(main_data_compiled.freq,to_res,'kx')
xlabel('Trap Freq')
ylabel(' Residual (MHz)')
set(gcf,'color','w')
box on

sfigure(1923);
clf
subplot(2,2,1)
scatter(main_data_compiled.grad,to_res,'kx')
xlabel('Gradient of Signal')
ylabel(' Residual (MHz)')
set(gcf,'color','w')
box on
subplot(2,2,2)
scatter(main_data_compiled.shots,to_res,'kx')
xlabel('Shot number')
ylabel(' Residual (MHz)')
set(gcf,'color','w')
box on
subplot(2,2,3)
scatter(main_data_compiled.set_pt,to_res,'kx')
xlabel('Set pt')
ylabel(' Residual (MHz)')
set(gcf,'color','w')
box on
subplot(2,2,4)
scatter(main_data_compiled.freq,to_res,'kx')
xlabel('Trap Freq')
ylabel(' Residual (MHz)')
set(gcf,'color','w')
box on

% subplot(4,4,5)
% scatter(drift_data_compiled.avg_coef(:,3),(drift_data_compiled.to_val{:,1}-TO_st_pt)./1e9,'kx')
% xlabel('Phase')
% ylabel([' TO value - ',num2str(TO_st_pt./1e9),' (GHz)'])
% set(gcf,'color','w')
% box on
% subplot(4,4,6)
% scatter(drift_data_compiled.avg_coef(:,4),(drift_data_compiled.to_val{:,1}-TO_st_pt)./1e9,'kx')
% xlabel('Detector offset')
% ylabel([' TO value - ',num2str(TO_st_pt./1e9),' (GHz)'])
% set(gcf,'color','w')
% box on
% subplot(4,4,7)
% scatter(drift_data_compiled.avg_coef(:,5),(drift_data_compiled.to_val{:,1}-TO_st_pt)./1e9,'kx')
% xlabel('x ramp')
% ylabel([' TO value - ',num2str(TO_st_pt./1e9),' (GHz)'])
% set(gcf,'color','w')
% box on
% subplot(4,4,8)
% scatter(drift_data_compiled.avg_coef(:,6),(drift_data_compiled.to_val{:,1}-TO_st_pt)./1e9,'kx')
% xlabel('z ramp')
% ylabel([' TO value - ',num2str(TO_st_pt./1e9),' (GHz)'])
% set(gcf,'color','w')
% box on
% subplot(4,4,9)
% scatter(drift_data_compiled.avg_coef(:,7),(drift_data_compiled.to_val{:,1}-TO_st_pt)./1e9,'kx')
% xlabel('Damping rate')
% ylabel([' TO value - ',num2str(TO_st_pt./1e9),' (GHz)'])
% set(gcf,'color','w')
% box on
% subplot(4,4,10)
% scatter(drift_data_compiled.avg_coef(:,8),(drift_data_compiled.to_val{:,1}-TO_st_pt)./1e9,'kx')
% xlabel('y ramp')
% ylabel([' TO value - ',num2str(TO_st_pt./1e9),' (GHz)'])
% set(gcf,'color','w')
% box on
% subplot(4,4,11)
% scatter(drift_data_compiled.avg_coef_unc(:,2),(drift_data_compiled.to_val{:,1}-TO_st_pt)./1e9,'kx')
% xlabel('unc in osc freq')
% ylabel([' TO value - ',num2str(TO_st_pt./1e9),' (GHz)'])
% set(gcf,'color','w')
% box on
% subplot(4,4,12)
% scatter(drift_data_compiled.avg_coef_unc(:,1),(drift_data_compiled.to_val{:,1}-TO_st_pt)./1e9,'kx')
% xlabel('unc in osc amplitude')
% ylabel([' TO value - ',num2str(TO_st_pt./1e9),' (GHz)'])
% set(gcf,'color','w')
% box on
% subplot(4,4,13)
% scatter(drift_data_compiled.avg_coef_unc(:,3),(drift_data_compiled.to_val{:,1}-TO_st_pt)./1e9,'kx')
% xlabel('unc in phase')
% ylabel([' TO value - ',num2str(TO_st_pt./1e9),' (GHz)'])
% set(gcf,'color','w')
% box on
% subplot(4,4,14)
% scatter(drift_data_compiled.avg_coef_unc(:,4),(drift_data_compiled.to_val{:,1}-TO_st_pt)./1e9,'kx')
% xlabel('unc in detector offset')
% ylabel([' TO value - ',num2str(TO_st_pt./1e9),' (GHz)'])
% set(gcf,'color','w')
% box on
% subplot(4,4,15)
% scatter(drift_data_compiled.avg_coef_unc(:,7),(drift_data_compiled.to_val{:,1}-TO_st_pt)./1e9,'kx')
% xlabel('unc in damping rate')
% ylabel([' TO value - ',num2str(TO_st_pt./1e9),' (GHz)'])
% set(gcf,'color','w')
% box on
% subplot(4,4,16)
% scatter(drift_data_compiled.avg_coef_unc(:,8),(drift_data_compiled.to_val{:,1}-TO_st_pt)./1e9,'kx')
% xlabel('unc in y ramp')
% ylabel([' TO value - ',num2str(TO_st_pt./1e9),' (GHz)'])
% set(gcf,'color','w')
% box on
set(gcf, 'Units', 'pixels', 'Position', [100, 100, 1600, 900])