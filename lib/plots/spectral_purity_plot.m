function dum = spectral_purity_plot()
%Script that scrapes the analysed data from dirs (currently messy but works)
%setup directories you wish to loop over
loop_config.dir = {
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190218_filt_dep_0\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190218_filt_dep_1\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190218_filt_dep_1_run2\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190218_filt_dep_2\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190218_filt_dep_3\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190219_filt_dep_2_run2\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190219_filt_dep_3_run2\',
    'Z:\EXPERIMENT-DATA\2018_Tune_Out_V2\20190220_filt_dep_1_run3\'
    };

data = to_data(loop_config);
selected_dirs = 1:numel(loop_config.dir);
filt_num = zeros(numel(data.drift.to_time),1);
shot_idx = 1;

for loop_idx=selected_dirs
    current_dir = loop_config.dir{loop_idx};
    strt = strfind(current_dir,'dep_');
    filt_num(shot_idx:(shot_idx+data.main.scan_num(loop_idx)-1),1) = ones(data.main.scan_num(loop_idx),1).*str2double(current_dir(strt+4));
    shot_idx = shot_idx+data.main.scan_num(loop_idx);
end
%%
sfigure(3000);
plot_offset = sum(data.drift.to_val{1}.*data.drift.to_val{2})/sum(data.drift.to_val{2});
errorbar(filt_num,(data.drift.to_val{1}-plot_offset).*1e-6,data.drift.to_val{2}.*1e-6,'kx')
set(gcf,'color','w')
xlabel('Filter Number')
ylabel(sprintf('Tune-out value - %.3f (MHz)',plot_offset.*1e-6))
xlim([-0.1, 3.2])
%%
to_vals = data.drift.to_val{1};
weights=1./data.drift.to_val{2}.^2';
weights=weights/sum(weights);
num_bin = 4;
bin_size = 1;
c_data = viridis(num_bin);
x_grouped = ones(1,num_bin);
y_grouped=nan(numel(num_bin),2);
x_lims = ones(2,num_bin);
for jj=0:(num_bin-1)
    bin_centre = jj*bin_size+min(filt_num);
    x_mask = (abs(filt_num-bin_centre)<(bin_size*0.5));
    x_grouped(jj+1) = nanmean(filt_num(x_mask));
    y_grouped(jj+1,1)=sum(to_vals(x_mask).*weights(x_mask)')./sum(weights(x_mask));
    y_grouped(jj+1,2)=sqrt(nanvar(to_vals(x_mask),weights(x_mask)));
end

yneg = (y_grouped(:,2).*1e-6)./2;
ypos = (y_grouped(:,2).*1e-6)./2;

colors_main=[[233,87,0];[33,188,44];[0,165,166]];
plot_title='Spectral purity';
font_name='cmr10';
font_size_global=14;


colors_main=colors_main./255;
lch=colorspace('RGB->LCH',colors_main(:,:));
lch(:,1)=lch(:,1)+20;
colors_detail=colorspace('LCH->RGB',lch);
%would prefer to use srgb_2_Jab here
color_shaded=colorspace('RGB->LCH',colors_main(3,:));
color_shaded(1)=125;
color_shaded=colorspace('LCH->RGB',color_shaded);

mdl_fun = @(b,x) b(1)+b(2).*x(:,1);
beta0 = [1e14,1e5];
opts = statset('nlinfit');

fit_mdl = fitnlm(filt_num',to_vals',mdl_fun,beta0,'Options',opts,'Weight',weights);%'ErrorModel','combined'
ci_size_disp = 1-erf(1/sqrt(2));

sfigure(3001);
clf
x_grouped_pad = linspace(-1, x_grouped(end)*2.01,6);
[ysamp_culled,yci_culled]=predict(fit_mdl,x_grouped_pad','Alpha',ci_size_disp); %'Prediction','observation'
%we add another offset so that the plot is about the TO
plot_offset=predict(fit_mdl,0);
patch([x_grouped_pad, fliplr(x_grouped_pad)], ([yci_culled(:,1)', fliplr(yci_culled(:,2)')]-plot_offset).*1e-9, color_shaded,'EdgeColor','none');  %
hold on
plot(x_grouped_pad,(yci_culled'-plot_offset).*1e-6,'r','color',colors_main(3,:),'LineWidth',1.5);
xl=xlim;
%line(xl,[0,0],'color','k','LineWidth',1)
title(plot_title)
plot(x_grouped_pad,(ysamp_culled-plot_offset).*1e-6,'-','color',colors_main(2,:),'LineWidth',1.5)

errorbar(x_grouped,(y_grouped(:,1)-plot_offset).*1e-6,yneg,ypos,'o','CapSize',0,'MarkerSize',5,'Color',colors_main(1,:),...
    'MarkerFaceColor',colors_detail(1,:),'LineWidth',1.5);
xlabel('Filter Number')
ylabel(sprintf('Tune-out value - %.3f (MHz)',plot_offset.*1e-6))
set(gca,'xlim',[-0.1,3.1])
%set(gca,'ylim',first_plot_lims(2,:))
set(gcf, 'Units', 'pixels', 'Position', [100, 100, 1600, 900])
set(gcf,'color','w')
set(gca,'FontSize',font_size_global,'FontName',font_name)
box on
end