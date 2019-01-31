% clear all
close all

fwtext('CAVITY SCAN ANALYSIS')

config.log_name='log_analog_in_*';

% config.datadir = 'C:\Data\blue_sfp';
% light_on_dirnames = {'probe_on_one_filt'};

config.datadir = 'C:\Data\20190125_sfp';
light_on_dirnames = {'sfp_0_filter','sfp_1_filter','sfp_2_filter','sfp_3_filter'};
config.savedir = 'C:\Users\jacob\Documents\Projects\Tune_out_v2\figs\cavity_analysis';
config.scan_time=14e-3;  %estimate of the sfp scan time,used to set the window and the smoothin
config.pzt_volt_smothing_time=config.scan_time/100;
config.pzt_division=0.2498;
config.sampl_start = 1;
config.demo_max = 4e3;
config.treshold = 1e-1; %min peak height for find_peaks
config.plot_out = false;

config.num_dirs = 4;
config.test.num_files = 1;
config.test.num_scans = NaN;


%% Calibration data
% fwtext('DARK SCANS')
% null_dirs = 'C:\Data\blue_sfp';
% light_off_dirnames = {'probe_off','red_off'};
% all_null = cell(numel(light_off_dirnames),1);
% config_null = config;
% for ii=1:numel(light_off_dirnames)
%     config_null.dir = fullfile(null_dirs,light_off_dirnames{ii});    
%     null_data = null_analysis(config_null);
%     all_null{ii} = null_data.data;
% end
% fwtext('Null scan complete')
% all_null = cell_vertcat(all_null);

%% Import light-on data
% 
fwtext('LIGHT ON')
config_light = config;
config_light.plot_out = false;
config_light.lorentz_fit = false;
config_light.zero_offset =-0.017;%mean(all_null{1});
config_light.peak_width = 0.5e-4;
config_light.valley_width = 0.7;
config_light.logscale = false;
config_light.lebesgue_thresh = .012; %Empirically chosen
config_light.lebesgue_thresh_demo = .15; %~1% of peak height
light_on_data = cell(numel(light_on_dirnames),1);
if ~isnan(config.num_dirs)
    num_dirs = config.num_dirs;
else
    num_dirs = numel(light_on_dirnames);
end
for ii=1:num_dirs
    fwtext({'Starting on %s',light_on_dirnames{ii}})
    config_light.dirname= light_on_dirnames{ii};
    config_light.dir = fullfile(config.datadir,config_light.dirname);
    light_on_data{ii} = light_on_analysis(config_light);
    
%     fprintf(['Completed ',config_light.dirname,', back/peak ratio %.4f +/- %.4f\n'],light_on_data{ii}.stats)
end
fwtext('All dirs analyzed')

%%
close all
fwtext('Presenting results')
fprintf('Lebesgue cutoff used: %f\n', config_light.lebesgue_thresh)

insp_data = cell(num_dirs,1);
for ii=1:num_dirs
    insp_data{ii} = inspect_light_on(light_on_data{ii},config_light);
    
    figure()
    for jj = 1:numel(light_on_data{ii}) %loop over files
       for kk = 1:numel(light_on_data{ii}{jj}) %loop over scans
            plot(sort(light_on_data{ii}{jj}{kk}.sweep))
            hold on
       end
    end
    set(gca,'Yscale','log')
    title('Sorted scan data')
    
    LB = insp_data{ii}.L_back;
    fprintf('Directory %u ratio %.5f +- %.5f, integrated BG %e +- %e\n',...
        ii,nanmean(insp_data{ii}.all_ratios),nanstd(insp_data{ii}.all_ratios),mean(LB),std(LB))
    
    
    figure()
    suptitle(sprintf('Directory %u', ii))
    subplot(2,1,1)
    
    for jj=1:numel(insp_data{ii}.L_ratios)
        plot(insp_data{ii}.L_ratios{jj},'x')
        hold on
    end
    title('Back/peak ratios by scan')
    xlabel('Scan number')
    ylabel('Back/peak ratio: Lebesgue method')
    ylim([0,0.08])


    subplot(4,1,3)
    for jj = 1:numel(insp_data{ii}.varf_ratios)
        Y = insp_data{ii}.varf_ratios{jj};
        X = insp_data{ii}.varf_axis{jj};
        for kk = 1:numel(X)
            plot(X{kk},Y{kk},'k')
            hold on
        end
    end
    title(sprintf('Ratio vs cutoff for dir %u', ii))
    xlabel('Integration cutoff')
    ylabel('Background/peak ratio')
    ylim([-0.01,0.15])
    
    subplot(4,1,4)
    for jj = 1:numel(insp_data{ii}.varf_back)
        Y = insp_data{ii}.varf_back{jj};
        X = insp_data{ii}.varf_axis{jj};
        for kk = 1:numel(X)
            plot(X{kk},Y{kk},'k')
            hold on
        end
    end
    title('Back values')
end

figure()
subplot(1,2,1)
X = 1:num_dirs;
Y = cellfun(@(x) x.L_mean,insp_data);
Y_err = cellfun(@(x) x.L_std,insp_data);
errorbar(X,Y,Y_err,'ro')
title('Background dependence on filters: Lebesgue method')
xlabel('Number filters')
ylabel('Background/peak ratio')
xlim([0,5])

subplot(1,2,2)



% allstats = cell_vertcat(cellfun(@(x) x.stats, light_on_data,'UniformOutput',false)');
% allstats=allstats{1};
% errorbar(allstats(:,1),allstats(:,2))
% title('back/peak ratio vs num filters')



