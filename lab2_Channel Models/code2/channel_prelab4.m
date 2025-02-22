0% channel_data.m
% Sends data across a channel represented by an impulse response and produces an output wave

clear all;

bit_period = round(1e12 / 6e9);  % 6Gb/s with 1ps step time
opt_sample = 1 * (0e-2); % Used in plotting pulse response

% Load Channel Impulse Response
load C:\ECEN720\ir_B12.mat;

tsample = 1e-12;  % Impluse response has 1ps time step
sample_num = size(ir, 1);  
ir_data = ir(:, 1); 
scale_ir = 1; % 1 for B12 (This is Vpp Differential)

sig_ir = ir_data * scale_ir;

% Plot Channel Impulse Response
figure;
plot(sig_ir);
title('Channel Impulse Response');

time = (1:size(sig_ir, 1)) * 1e-12;

% Generate Random Data
nt = 1e3;  % Number of bits
m = rand(1, nt+1); % Random numbers between 1 and zero, will be quantized later
m = -1 * sign(m - 0.5).^2 + sign(m - 0.5) + 1;

% TX FIR Equalization Taps
eq_taps = [1];
m_fir = filter(eq_taps, 1, m);

m_dr = reshape(repmat(m_fir, bit_period, 1), 1, bit_period * size(m_fir, 2));
m_tx = m_dr;

data_channel = 0.5 * conv(sig_ir(:, 1), m_dr(1:nt * bit_period));

figure;
plot(data_channel);
grid on;

time_m_dr = (1:size(m_dr, 2)) * 1e-12;
time_dc = (1:size(data_channel, 1)) * 1e-12;

save data_channel.mat data_channel; % Save Channel Output

j = 1;
offset = 144;

% Eye Diagram Plot
for i = 55:floor(size(data_channel, 2) / bit_period) - 500
    eye_data(:, j) = 2 * data_channel(floor((bit_period * (i-1))) + offset : floor((bit_period * (i+1))) + offset);
    j = j + 1;
end

time = 0:2 * bit_period;
figure;
H = plot(time, eye_data);

AX = gca;
set(AX, 'FontName', 'utopia');
set(AX, 'FontSize', [12]);
set(AX, 'LineWidth', [2.0]);
set(AX, 'YLim', [-1 1]); 
set(AX, 'YTick', -1:0.2:1);
set(AX, 'YColor', [0 0 0]);
HX = get(AX, 'xlabel');
set(HX, 'string', 'Time (ps)', 'FontName', 'utopia', 'FontSize', [20], 'Color', [0 0 0]);
HY = get(AX, 'ylabel');
set(HY, 'string', 'Voltage (V)', 'FontName', 'utopia', 'FontSize', [20], 'Color', [0 0 0]);
Htitle = get(AX, 'title');
set(Htitle, 'string', 'B12 Backplane 6Gb/s NRZ Eye with Decision Window', 'FontName', 'utopia', 'FontSize', [20], 'Color', [0 0 0]);
grid on;

%% ========== 修正決策窗口位置，使其回到眼圖中心 ==========

% === 參數設定 ===
aperture_time = 10;      % 10 ps Aperture time
setup_hold_time = 20;    % 20 ps Setup + Hold time
timing_offset = 10;      % 10 ps Timing offset
jitter_sigma = 1;        % 1 ps Random jitter
voltage_offset = 10e-3;      % 10 mV Static voltage offset
latch_resolution = 2e-3;     % 2 mV Minimum latch resolution
input_noise_sigma = 2e-3;    % 2 mV Input referred noise
BER_target_sigma = 7;        % BER = 10^-12 (7σ)

% === window range ===
total_timing_offset = timing_offset + BER_target_sigma * jitter_sigma; 
decision_time_width = 2 * (aperture_time + total_timing_offset); 
% 27ps*2
total_voltage_offset = voltage_offset + latch_resolution;
decision_voltage_height = 2 * (total_voltage_offset + BER_target_sigma * input_noise_sigma); 
% 26mv*2

% === eyedigram center ===
decision_time_center = bit_period ; % time center
decision_voltage_center = 0; % NRZ signal center

% === plot window ===
rectangle('Position', [decision_time_center - decision_time_width / 2 , decision_voltage_center - decision_voltage_height/2, decision_time_width, decision_voltage_height],...
          'FaceColor', [1, 0, 0, 0.3], 'EdgeColor', 'none'); % 半透明紅色矩形






