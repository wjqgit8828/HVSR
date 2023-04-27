function [vel, acc, disp] = remove_instrument_response_vel(data, conversion_factor, fsamp, cfg_file)
    % 该函数用于去除速度观测数据中的仪器响应，得到真实加速度、速度和位移
    
    % 从配置文件解析仪器响应
    [sensitivity, a0, pole_num, zero_num, poles, zeros] = parse_cfg(cfg_file);

    % 将观测数据转换为速度（单位：m/s）
    data = data * conversion_factor * 1e-6; % 转换为伏 (V)
    data = data / sensitivity ; % 转换为速度（m/s） 

    % 创建传递函数模型
    sys = zpk(zeros, poles, a0);

    % 计算仪器响应
    nfft = 2 ^ nextpow2(length(data)); % 计算下一个最接近的2的幂次
    f = linspace(0, fsamp / 2, nfft / 2 + 1);
    [mag, phase] = bode(sys, 2 * pi * f);
    mag1 = squeeze(mag);

    % 去除仪器响应
    data_fft = fft(data, nfft);
    mag1 = [1; mag1(2:end)]; % 修复大小不一致的问题
    data_fft(1:(nfft / 2) + 1) = data_fft(1:(nfft / 2) + 1) ./ mag1;
    data_fft((nfft / 2) + 2:end) = conj(data_fft((nfft / 2):-1:2));

    % 得到真实速度值（单位：m/s）
    vel = real(ifft(data_fft, nfft));
    vel = vel(1:length(data)); % 修剪信号长度

    % 计算加速度值（单位：m/s²）
    acc = diff(vel) * fsamp;

    % 使加速度值与速度值的长度相同
    acc = [acc; acc(end)];

    % 高通滤波器设置
    f1 = 0.1; % 有效频率范围的下限 (Hz)
    f2 = 10;  % 有效频率范围的上限 (Hz)  
    nyquist_freq = fsamp / 2;
    fc = (10^(-40/10))*(1000); % 截止频率 (Hz)
    [b, a] = butter(4, [f1 f2] / nyquist_freq, 'bandpass');

    % 计算位移值（单位：m）
    cumulative_vel = cumsum(vel) / fsamp;
    disp = filtfilt(b, a, cumulative_vel);

end
