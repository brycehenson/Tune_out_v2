function out=make_cal_model(anal_opts_afit,data)
%this function take in the data structure and returns a estimate of the total atom number by fitting a decay function 
%to the number in the pulsed atom laser 

atom_fit_mdl = @(b,x) b(1)*b(2)*((1-b(2)).^(x(:,1)-1));

exp_qe=0.09;


iimax=size(data.mcp_tdc.counts_txy,2); 
fit_out_frac_ntot=nan(iimax,2,2); %value and uncert
fprintf('Fitting atom number in shots %04i:%04i',iimax,0)
for ii=1:iimax
    if data.mcp_tdc.all_ok(ii)
        pulse_num=anal_opts_afit.pulses(1):anal_opts_afit.pulses(2);
        pulse_counts=data.mcp_tdc.al_pulses.num_counts(ii,pulse_num);

        coefs_guess=[data.mcp_tdc.num_counts(ii),1e-2];
        pulse_fit=fitnlm(pulse_num,pulse_counts,atom_fit_mdl,coefs_guess);
        fit_out_frac_ntot(ii,:,:)=[[pulse_fit.Coefficients.Estimate(2),pulse_fit.Coefficients.SE(2)];...
                                    [pulse_fit.Coefficients.Estimate(1)/exp_qe,...
                                     pulse_fit.Coefficients.SE(1)/exp_qe]];

        if anal_opts_afit.plot_each_shot
            fprintf('fit number in shot %u\n',ii)
            xplot=linspace(min(pulse_num),max(pulse_num),1e3)';
            [ymodel,ci]=predict(pulse_fit,xplot,'Prediction','observation','Alpha',1-erf(1/sqrt(2)));
            plot(pulse_num,pulse_counts,'kx')
            hold on
            plot(xplot,ymodel,'r-')
            plot(xplot,ci(:,2),'m-')
            plot(xplot,ci(:,1),'m-')
            hold off
            set(gca, 'YScale', 'log')
            fprintf('frac predicted %.2e�%.2e\n',...
                fit_out_frac_ntot(ii,1,1),fit_out_frac_ntot(ii,1,2))
            fprintf('Total no. fit %.2e�%.2e measured in file %.2e (qe %.1e corrected)\n',...
                fit_out_frac_ntot(ii,2,1),fit_out_frac_ntot(ii,2,2),data.mcp_tdc.num_counts(ii)/exp_qe,exp_qe)
            pause(0.1)
        end
    end
    if mod(ii,10)==0, fprintf('\b\b\b\b%04u',ii), end
end
fprintf('...Done\n')

out.fit_out_frac_ntot=fit_out_frac_ntot;
%%

figure(341)
clf
set(gcf,'color','w')
subplot(3,1,1)
errorbar(data.mcp_tdc.shot_num,fit_out_frac_ntot(:,1,1),fit_out_frac_ntot(:,1,2),'k.','capsize',0)
ylabel('Fit Out. Frac.')
xlabel('Shot number')
subplot(3,1,2)
errorbar(data.mcp_tdc.shot_num,fit_out_frac_ntot(:,2,1),fit_out_frac_ntot(:,2,2),'k.','capsize',0)
ylabel('Fit Total Num')
xlabel('Shot number')
subplot(3,1,3)
raw_counts_atom_num=data.mcp_tdc.num_counts(:)/exp_qe;
errorbar(data.mcp_tdc.shot_num,fit_out_frac_ntot(:,2,1)./raw_counts_atom_num,...
    fit_out_frac_ntot(:,2,2)./raw_counts_atom_num,'k.','capsize',0)
xl=xlim;
line(xl,[1,1],'color','k')
ylabel('Num count/Fit')
xlabel('Shot number')

%%


end