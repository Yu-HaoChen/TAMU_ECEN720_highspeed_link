% 清空工作區、命令視窗，並關閉所有圖形視窗
clear; clc; close all;

% 定義 case 與對應的 Eye Height 資料
cases = 1:7;
eyeHeight = [0.055, 0.035, 0.047, 0.035, 0.041, 0.043, 0.044];

% 建立圖形視窗
figure;

% 繪製折線圖，並以紅色圓點標記每個資料點
plot(cases, eyeHeight, '-o', 'Color', 'r', ...
    'LineWidth', 2, 'MarkerSize', 6);
hold on;
grid on;

% 設定 x, y 軸標籤及圖表標題
xlabel('Case #');
ylabel('Eye Height');
title('Eye Height vs. Case # at BER of 10^{-12}');

% (可選) 設定 y 軸的上下範圍
ylim([0 0.06]);  % 依需求修改，例如 [0 0.06]

% (可選) 若需要固定 x 軸範圍，可在此指定
% xlim([1 7]);

hold off;
