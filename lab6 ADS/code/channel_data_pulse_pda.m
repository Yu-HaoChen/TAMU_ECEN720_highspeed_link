% channel_data.m
% Sends data across a channel represented by an impulse response and produces an output wave

clear all;
%feature('javafigures',0);

bit_period=round(1e12/5e9);	% This is 10Gb/s with 1ps step time
opt_sample=1*(0e-2); % Used in plotting pulse response

% Load Channel Impulse Response
load C:\Users\harri\Downloads\ir_T20_01.mat;
%load C:\Users\Sam\Documents\research\tamu\electrical_io\channels\ir_server_clean.mat;

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


% TX Equalization Function
eq_tap_number=2;    % Equalization Tap Number
precursor_number=0; % Number of Pre-Cursor Taps
num_bits=3;         % TX Equalization Resolution
% Calls TX Equalization Function
% taps output is un-quatized filter taps
% taps_quan output is filter taps quantized to equalizer resoltion
[taps,taps_quan]=tx_eq(sig_ir,bit_period,eq_tap_number,precursor_number,num_bits)


% For Pulse Response
 nt=100;
 m(1:20)=0; m(21)=1; m(22:100)=0;
% %m=-1*sign(m-0.5).^2+sign(m-0.5)+1;
% m_stream(1:20)=0; m_stream(21)=1; m_stream(22:27)=[0 0 0 1 0 1]; m_stream(28:100)=0;
% m_stream=-1*sign(m_stream-0.5).^2+sign(m_stream-0.5)+1;

% TX FIR Equalization Taps
% Set eq_taps equal to "taps" for infinite TX Eq resolution
% and "taps_quan" for finite TX Eq resolution
eq_taps=taps_quan;  % or taps
%eq_taps=[-0.046 0.78 -0.129 -0.0449]; % Random taps - not optimized for
%B12 channel
m_fir=filter(eq_taps,1,m);


%m_dr=reshape(repmat(m,bit_period,1),1,bit_period*size(m,2));
m_dr=reshape(repmat(m_fir,bit_period,1),1,bit_period*size(m_fir,2));

m_tx=m_dr;

% Note the 0.5 scale factor is to model a maximum logic swing of 0.5V per 
% symbol, or 1Vppd
data_channel=0.5*conv(sig_ir(:,1),m_dr(1:nt*bit_period));

figure;
plot(data_channel);
grid on;

time_m_dr=(1:size(m_dr,2))*1e-12;
time_dc=(1:size(data_channel,1))*1e-12;

save data_channel.mat data_channel; % Save Channel Output

% Uncomment below to plot pulse stuff
[max_data_ch,max_data_ch_idx]=max(abs(data_channel));
pulse_xaxis(1,:)=((1:size(data_channel,1))-max_data_ch_idx)./bit_period;

% Take 10 pre-cursor, cursor, and 90 post-cursor samples
sample_offset=opt_sample*bit_period;
for i=1:101
sample_points(i)=max_data_ch_idx+sample_offset+(i-11)*bit_period;
end
sample_values=data_channel(sample_points);
sample_points=(sample_points-max_data_ch_idx)./bit_period;
%figure; plot(2*data_channel,'-b'); hold on; stem(sample_points,2*sample_values,'-*r'); grid on;

figure;
%J=plot(pulse_noeq_xaxis,2*data_channel_noeq,'-r'); hold on;
H=plot(pulse_xaxis,data_channel,'-r'); hold on;
I=stem(sample_points,sample_values,'-*r'); 
%K=stem(sample_points_noeq,2*sample_values_noeq,'-*r'); grid on;
grid on;
set(H, 'LineWidth', [2.0]);
set(I, 'LineWidth', [2.0]);
%set(J, 'LineWidth', [2.0]);
%set(K, 'LineWidth', [2.0]);
%set(H, 'Color', [0 0 0]);
AX=gca;
set(AX, 'FontName', 'utopia');
set(AX, 'FontSize', [16]);
set(AX, 'LineWidth', [2.0]);
set(AX, 'XLim', [-3 10]);
set(AX, 'XTick', -3:1:10);
set(AX, 'YLim', [-0.05 0.25]); 
set(AX, 'YTick', 0:0.05:0.25);
set(AX, 'YColor', [0 0 0]);
HX = get(AX, 'xlabel');
set(HX, 'string', 'Time (UI)','FontName','utopia', 'FontSize', [20], 'Color', [0 0 0]);
HY = get(AX, 'ylabel');
set(HY, 'string', 'Voltage (V)','FontName','utopia', 'FontSize', [20], 'Color', [0 0 0]);
Htitle = get(AX, 'title');
set(Htitle, 'string', '12" BP 10Gb/s 0.5V Pulse Response','FontName','utopia', 'FontSize', [20], 'Color', [0 0 0]);
%L=legend('No Eq','4-tap TX Eq & RX CTLE',1);
%set(L, 'FontSize', [10]);

% Compute PDA
pda_eye_height=2*(sample_values(11)-(sum(abs(sample_values(1:10)))+sum(abs(sample_values(12:101)))))




