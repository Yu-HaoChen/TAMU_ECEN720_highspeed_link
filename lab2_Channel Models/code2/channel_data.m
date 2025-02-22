% channel_data.m
% Sends data across a channel represented by an impulse response and produces an output wave

clear all;
%feature('javafigures',0);

bit_period=round(1e12/6e9);	% This is 6Gb/s with 1ps step time
opt_sample=1*(0e-2); % Used in plotting pulse response

% Load Channel Impulse Response
load C:\ECEN720\ir_B12.mat;

tsample=1e-12;  % Impluse response has 1ps time step
sample_num=size(ir,1);  
ir_data=ir(:,1); 
scale_ir=1; % 1 for B12 (This is Vpp Differential)

sig_ir=ir_data*scale_ir;

% Plot Channel Impulse Response
figure;
plot(sig_ir);
title('Channel Impulse Response');

time=(1:size(sig_ir,1))*1e-12;


% Generate Random Data
nt=1e3;         %number of bits
m=rand(1,nt+1);     %random numbers between 1 and zero, will be quantized later
m=-1*sign(m-0.5).^2+sign(m-0.5)+1;


% For Pulse Response
% nt=100;
% m(1:20)=0; m(21)=1; m(22:100)=0;
% %m=-1*sign(m-0.5).^2+sign(m-0.5)+1;
% m_stream(1:20)=0; m_stream(21)=1; m_stream(22:27)=[0 0 0 1 0 1]; m_stream(28:100)=0;
% m_stream=-1*sign(m_stream-0.5).^2+sign(m_stream-0.5)+1;

% TX FIR Equalization Taps
eq_taps=[1];
%eq_taps=[-0.046 0.78 -0.129 -0.0449]; % Random taps - not optimized for
%B12 channel
m_fir=filter(eq_taps,1,m);


%m_dr=reshape(repmat(m,bit_period,1),1,bit_period*size(m,2));
m_dr=reshape(repmat(m_fir,bit_period,1),1,bit_period*size(m_fir,2));

m_tx=m_dr;


data_channel=0.5*conv(sig_ir(:,1),m_dr(1:nt*bit_period));

figure;
plot(data_channel);
grid on;

time_m_dr=(1:size(m_dr,2))*1e-12;
time_dc=(1:size(data_channel,1))*1e-12;

save data_channel.mat data_channel; % Save Channel Output



j=1;
offset=144;


%To plot eye diagram 
%data_channel=data_channel';

% Uncomment to see unequalized eye
%data_channel=data_channel_noeq;

for ( i=55:floor(size(data_channel,2) / bit_period)-500)
    eye_data(:,j) = 2*data_channel(floor((bit_period*(i-1)))+offset: floor((bit_period*(i+1)))+offset);
    j=j+1;
end;

time=0:2*bit_period;
figure;
H=plot(time,eye_data);
%set(H, 'LineWidth', [2.0]);
AX=gca;
set(AX, 'FontName', 'utopia');
set(AX, 'FontSize', [12]);
set(AX, 'LineWidth', [2.0]);
%set(AX, 'XLim', [0 200]);
%set(AX, 'XTick', 0:25:200);
set(AX, 'YLim', [-1 1]); 
set(AX, 'YTick', -1:0.2:1);
set(AX, 'YColor', [0 0 0]);
HX = get(AX, 'xlabel');
set(HX, 'string', 'Time (ps)','FontName','utopia', 'FontSize', [20], 'Color', [0 0 0]);
HY = get(AX, 'ylabel');
set(HY, 'string', 'Voltage (V)','FontName','utopia', 'FontSize', [20], 'Color', [0 0 0]);
Htitle = get(AX, 'title');
set(Htitle, 'string', 'B12 Backplane 6Gb/s NRZ Eye','FontName','utopia', 'FontSize', [20], 'Color', [0 0 0]);
%L=legend('P1266','P1268','P1270','P1272',2);
%set(L, 'FontSize', [14]);
grid on;




