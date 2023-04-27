clc
clear
addpath('function\');
addpath('../config/');
addpath('../data/')
% 加载数据
x01 = load("20230320060330.00E");
x02 = load("20230320060330.00N");
x03 = load("20230320060330.00U");

% 参数
fsamp = 100; dt = 1 / fsamp;% 采样率 (Hz)
N = length(x01); time = [0:N-1] / fsamp; % 时间尺度
cfg_file = 'js_a2.cfg'; % 仪器响应参数文件
conversion_factor = 0.0745; % 数据采集器转换因子 (uV/count)
h = 0.05; % 阻尼5%

% 定义频率和周期参数
FC = (10^(-40/10))*(1000);
f_step = 2^(1/9);
fc_totle = fix((log10(20)-log10(FC))/log10(f_step))+1;
for j = 1:fc_totle
    FFF(j) = FC * (f_step^(j-1));
end
T = 1./FFF;

% 去除仪器响应，得到加速度
[acc01, vel01, disp01] = remove_instrument_response_acc(x01, conversion_factor, fsamp, cfg_file);
[acc02, vel02, disp02] = remove_instrument_response_acc(x02, conversion_factor, fsamp, cfg_file);
[acc03, vel03, disp03] = remove_instrument_response_acc(x03, conversion_factor, fsamp, cfg_file);

% STA/LTA截取地震事件
step_sta = 0.2; step_lta = 20; 
time_start = sta_lta(acc03, step_sta, step_lta, fsamp);
time_len = 80; % 地震持时
data01 = trans_file_cut(acc01, time_start, time_len, time, fsamp);
data02 = trans_file_cut(acc02, time_start, time_len, time, fsamp);
data03 = trans_file_cut(acc03, time_start, time_len, time, fsamp);

% 计算加速度反应谱
res01 = ERES(h, T, dt, data01);
res02 = ERES(h, T, dt, data02);
res03 = ERES(h, T, dt, data03);

Sa01 = res01(:,:,1);
Sa02 = res02(:,:,1);
Sa03 = res03(:,:,1);

% 计算H/V谱比
hvsr = hvsrVR(T, dt, data03, data02, data01);

% 绘图
figure(2);
subplot(2,1,1);
plot(time, x03);
title('Raw data');
ylabel('Amplitude (count)');
xlabel('Time (s)');

subplot(2,1,2);
plot([0:(time_len * fsamp)], data03*100);
title('Acceleration');
ylabel('Acceleration (gal)');
xlabel('Time (s)');

fig_path = fullfile('../fig',['20230320060330','_data','.fig']);
png_path = fullfile('../result',['20230320060330','_data','.png']);
saveas(gcf, fig_path, 'fig');
saveas(gcf, png_path, 'png');

figure(3)
semilogx(T, Sa01, 'LineWidth', 2);hold on
semilogx(T, Sa02, 'LineWidth', 2);hold on
semilogx(T, Sa03, 'LineWidth', 2);hold on
legend('E','N','U')
xlabel('Time (s)')
ylabel('Sa (m/s^2)')
title('Acceleration response spectrum (damping 5 %)')
%axis([0.05 10 0 5])
fig_path = fullfile('../fig',['20230320060330','_Sa','.fig']);
png_path = fullfile('../result',['20230320060330','_Sa','.png']);
saveas(gcf, fig_path, 'fig');
saveas(gcf, png_path, 'png');

figure(4);
semilogx(T, hvsr, 'r', 'LineWidth', 2);grid on;
xlabel('Time (s)')
ylabel('H/V')
title('HVSR')
axis([0.05 10 0 5])
fig_path = fullfile('../fig',['20230320060330','_hvsr','.fig']);
png_path = fullfile('../result',['20230320060330','_hvsr','.png']);
saveas(gcf, fig_path, 'fig');
saveas(gcf, png_path, 'png');
