function imp=xfr_fn_to_imp(f,H,Ts,Tsym)
%%% Create impulse response from transfer function in frequency domain  %%%
%%% Impulse response is interpolated to the sample time required by the
%%% simulator
% input 
%   f - frequency in Hz
%   H - transfer function
%   Ts - simulator sample time
%   Tsym - simulator symbol period
% output
%   imp_response

% clear all;
% load hdata;
% Ts=1e-12;
% Tsym=80e-12;
num_fft_pts=2^16;

% set the symbol frequency
f_sym=1/Tsym;
% get the maximum sampling frequency from the transfer function
f_sym_max=2*max(f);
% stop the simulation if the symbol frequency is smaller than the maximum
% measured sampling frequency
if (f_sym > f_sym_max), 
   error('Max input frequency too low for requested symbol rate, can''t interpolate!');
end	

f_sym_max=f_sym*floor(f_sym_max/f_sym);     % Originally 2*15GHz
Hm=abs(H);
Hp=angle(H);

%%% need to force phase to zero at zero frequency to avoid funky behavior
if f(1)==0,
   Hm_ds=[fliplr(Hm(2:end-1)) Hm];
   Hp_ds=[fliplr(-Hp(2:end-1)) Hp];
   fds=[-fliplr(f(2:end-1)) f];
   fds_m = fds; 
   fds_p = fds;
else
   Hm_ds=[fliplr(Hm(1:end-1)) Hm];
   Hp_ds=[fliplr(-Hp(1:end-1)) 0 Hp];
   fds_m=[-fliplr(f(1:end-1)) f];
   fds_p=[-fliplr(f(1:end-1)) 0 f];
end

fmax=1/Ts;
df=fmax/2/num_fft_pts;                             
f_ds_interp=-f_sym_max/2+df:df:f_sym_max/2;             
f_ds_interp_a=-fmax/2+df:df:fmax/2;             
Hm_ds_interp=spline(fds_m,Hm_ds,f_ds_interp);           % Interpolate for FFT point number
Hp_ds_interp=spline(fds_p,unwrap(Hp_ds),f_ds_interp);
Hm_ds_interp_sh_orig=fftshift(Hm_ds_interp);
Hp_ds_interp_sh_orig=fftshift(Hp_ds_interp);

% figure;
% H=plot(f_ds_interp/1e9,20*log10(Hm_ds_interp_sh_orig),'-b');
% set(H, 'LineWidth', [2.0]);
% AX=gca;
% set(AX, 'FontName', 'utopia');
% set(AX, 'FontSize', [14]);
% set(AX, 'LineWidth', [2.0]);
% set(AX, 'XLim', [-15 15]);
% set(AX, 'XTick', [-15:5:15]);
% set(AX, 'XTickLabel', {'0'; '5'; '10'; '15,-15'; '-10'; '-5'; '0'});
% %set(AX, 'YLim', [-60 0]); 
% %set(AX, 'YTick', -60:10:0);
% %set(AX, 'YLim', [-0.55 0.55]); 
% %set(AX, 'YTick', -0.5:0.1:0.5);
% set(AX, 'YColor', [0 0 0]);
% HX = get(AX, 'xlabel');
% set(HX, 'string', 'Frequency (GHz)','FontName','utopia', 'FontSize', [20], 'Color', [0 0 0]);
% HY = get(AX, 'ylabel');
% set(HY, 'string', 'S_2_1 (dB)','FontName','utopia', 'FontSize', [20], 'Color', [0 0 0]);
% Htitle = get(AX, 'title');
% set(Htitle, 'string', 'T20 Backplane Channel','FontName','utopia', 'FontSize', [20], 'Color', [0 0 0]);
% %L=legend('P1266','P1268','P1270','P1272',2);
% %set(L, 'FontSize', [14]);
% grid on;
% 

Hm_ds_interp_a(1:(2*num_fft_pts-size(Hm_ds_interp,2))/2)=0;
Hm_ds_interp_a((2*num_fft_pts-size(Hm_ds_interp,2))/2+1:(2*num_fft_pts+size(Hm_ds_interp,2))/2)=Hm_ds_interp;
Hm_ds_interp_a((2*num_fft_pts+size(Hm_ds_interp,2))/2+1:2*num_fft_pts)=0;
Hp_ds_interp_a(1:(2*num_fft_pts-size(Hp_ds_interp,2))/2)=0;
Hp_ds_interp_a((2*num_fft_pts-size(Hp_ds_interp,2))/2+1:(2*num_fft_pts+size(Hp_ds_interp,2))/2)=Hp_ds_interp;
Hp_ds_interp_a((2*num_fft_pts+size(Hp_ds_interp,2))/2+1:2*num_fft_pts)=0;

% figure
% plot(fds_m,Hm_ds,'-b')
% figure
% plot(f_ds_interp/1e9,20*log10(Hm_ds_interp),'-b')
% figure
% plot(f_ds_interp_a,Hm_ds_interp_a,'-g')
% 



Hm_ds_interp_sh=fftshift(Hm_ds_interp_a);
Hp_ds_interp_sh=fftshift(Hp_ds_interp_a);
size(Hp_ds_interp_sh);
% figure
% plot(f_ds_interp_a,Hm_ds_interp_sh,'-g')

% figure;
% H=plot(f_ds_interp_a/1e9,Hm_ds_interp_sh,'-b')
% set(H, 'LineWidth', [2.0]);
% AX=gca;
% set(AX, 'FontName', 'utopia');
% set(AX, 'FontSize', [14]);
% set(AX, 'LineWidth', [2.0]);
% set(AX, 'XLim', [-500 500]);
% set(AX, 'XTick', [-500:250:500]);
% set(AX, 'XTickLabel', {'0'; '250'; '500,-500'; '-250'; '0'});
% set(AX, 'YLim', [0 1]); 
% set(AX, 'YTick', 0:0.2:1);
% %set(AX, 'YLim', [-0.55 0.55]); 
% %set(AX, 'YTick', -0.5:0.1:0.5);
% set(AX, 'YColor', [0 0 0]);
% HX = get(AX, 'xlabel');
% set(HX, 'string', 'Frequency (GHz)','FontName','utopia', 'FontSize', [20], 'Color', [0 0 0]);
% HY = get(AX, 'ylabel');
% set(HY, 'string', 'S_2_1','FontName','utopia', 'FontSize', [20], 'Color', [0 0 0]);
% Htitle = get(AX, 'title');
% set(Htitle, 'string', 'T20 Backplane Channel','FontName','utopia', 'FontSize', [20], 'Color', [0 0 0]);
% %L=legend('P1266','P1268','P1270','P1272',2);
% %set(L, 'FontSize', [14]);
% grid on;


H_ds_interp_sh=Hm_ds_interp_sh.*exp(j*Hp_ds_interp_sh);



% impulse response from ifft of interpolated frequency response
size(H_ds_interp_sh)
imp=ifft(H_ds_interp_sh);
imp_r=real(imp);

dt_sym=1/fmax;
imp=imp_r;
%dt_sym=1/f_sym_max;



%refit data into simulator's time step
dt_time=0:dt_sym:dt_sym*(length(imp_r)-1);
time = 0:Ts:dt_time(end); 
%imp = interp1(dt_time, imp_r, time, 'spline')*Ts/dt_sym;

% figure(1000)
% plot(imp);

return
   

