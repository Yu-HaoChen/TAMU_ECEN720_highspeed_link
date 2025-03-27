% 4G tap number versus eye height
pda_eye_height_4G = [0.4501, 0.4957, 0.4957, 0.4957];

% 8G tap number versus eye height
pda_eye_height_8G = [0.0302, 0.2241, 0.2241, 0.2241];

% 16G tap number versus eye height
pda_eye_height_16G = [-0.3689, 0.0183, 0.0408, 0.0408];

% 2 tap versus resolution bits (3/4/5/6 bits)
pda_eye_height_2tap = [0.0241, 0.2190, 0.2165, 0.2199];

% 3 tap versus resolution bits (3/4/5/6 bits)
pda_eye_height_3tap = [0.2241, 0.2010, 0.2129, 0.2129];

% 4 tap versus resolution bits (3/4/5/6 bits)
pda_eye_height_4tap = [0.2241, 0.2010, 0.2129, 0.2105];

x = [1:4]
figure;
hold on
plt_4G = plot(x,pda_eye_height_4G,'r');
plt_8G = plot(x,pda_eye_height_8G,'b');
plt_16G = plot(x,pda_eye_height_16G,'g');
grid on;

set(plt_4G, 'LineWidth', [2.0]);
set(plt_8G, 'LineWidth', [2.0]);
set(plt_16G, 'LineWidth', [2.0]);

AX=gca;
set(AX, 'FontName', 'utopia');
set(AX, 'FontSize', [14]);
set(AX, 'LineWidth', [2.0]);
set(AX, 'XLim', [1 4]);
set(AX, 'XTick', 1:1:4);
set(AX, 'YLim', [-0.5 0.6]); 
set(AX, 'YTick', -0.5:0.1:0.6);

HX = get(AX, 'xlabel');
set(HX, 'string', 'Tap numbers','FontName','utopia', 'FontSize', [14], 'Color', [0 0 0]);
HY = get(AX, 'ylabel');
set(HY, 'string', 'Eye Height','FontName','utopia', 'FontSize', [14], 'Color', [0 0 0]);
Htitle = get(AX, 'title');
set(Htitle, 'string', 'Peak-Distortion Eye Height versus Tap Numbers','FontName','utopia', 'FontSize', [14], 'Color', [0 0 0]);

legend('4Gbps','8Gbps','16Gbps', 'Location', 'southeast')
%%
x1 = [3:6]
figure;
hold on
plt_2tap = plot(x1,pda_eye_height_2tap,'r');
plt_3tap = plot(x1,pda_eye_height_3tap,'b');
plt_4tap = plot(x1,pda_eye_height_4tap,'g');
grid on;

set(plt_2tap, 'LineWidth', [2.0]);
set(plt_3tap, 'LineWidth', [2.0]);
set(plt_4tap, 'LineWidth', [2.0]);

AX=gca;
set(AX, 'FontName', 'utopia');
set(AX, 'FontSize', [14]);
set(AX, 'LineWidth', [2.0]);
set(AX, 'XLim', [3 6]);
set(AX, 'XTick', 3:1:6);
set(AX, 'YLim', [0 0.25]); 
set(AX, 'YTick', 0:0.05:0.25);

HX = get(AX, 'xlabel');
set(HX, 'string', 'Resolution bits','FontName','utopia', 'FontSize', [14], 'Color', [0 0 0]);
HY = get(AX, 'ylabel');
set(HY, 'string', 'Eye Height','FontName','utopia', 'FontSize', [14], 'Color', [0 0 0]);
Htitle = get(AX, 'title');
set(Htitle, 'string', 'Peak-Distortion Eye Height versus Equalizer Resolution','FontName','utopia', 'FontSize', [14], 'Color', [0 0 0]);

legend('2tap','3tap','4tap', 'Location', 'southeast')

