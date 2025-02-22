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
%m=-1*sign(m-0.5).^2+sign(m-0.5)+1;

[max_val, max_ind] = max(sig_ir);

cursor = sig_ir(max_ind,1); 

% 计算前游（Pre-cursor）和后游（Post-cursor）
pre_cur = sig_ir(max_ind-10:max_ind-1,1);  % 目标脉冲前 10 个样本
post_cur = sig_ir(max_ind+1:max_ind+100,1); % 目标脉冲后 100 个样本

% 反转数组，符合时序
pre_cur_flip = flip(pre_cur);
post_cur_flip = flip(post_cur);

% 重新整形数组，使其变成一行
pre_cur_flip_tr = reshape(pre_cur_flip,1,[]);
post_cur_flip_tr = reshape(post_cur_flip,1,[]);

% 计算 Worst-Case 1 (ISI 最小的情况)
pre_cur_flip_one = -sign(pre_cur_flip_tr);
post_cur_flip_one = -sign(post_cur_flip_tr);

% 计算 Worst-Case 0 (ISI 最大的情况)
pre_cur_flip_zero = sign(pre_cur_flip_tr);
post_cur_flip_zero = sign(post_cur_flip_tr);

% 组合最坏情况比特模式
worst_pattern_one = [post_cur_flip_one 1 pre_cur_flip_one]; % 1 为目标比特
worst_pattern_zero = [post_cur_flip_zero -1 pre_cur_flip_zero];

% 复制模式，使其应用于 9 个 bit
%m = repmat(worst_pattern_zero,1,9);
m = repmat(worst_pattern_one,1,9);

% 生成随机比特流
nt = 999;         % 比特数
%m = rand(1,nt+1);  % 生成 0~1 之间的随机数
%m = -1*sign(m-0.5).^2 + sign(m-0.5) + 1; % 量化为 0 或 1

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




