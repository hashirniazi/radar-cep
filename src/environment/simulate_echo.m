% 3rd May 2026
% Hashir Niazi
% DSP CEP
% simulate_echo.m
function [rx_signal, receive_time_axis] = simulate_echo(tx_signal, fs, fc, c, target_ranges, target_vels, target_rcs, snr_db, pulse_num, prf)
    % Simulates radar echoes for multiple targets with RCS and Multi-Pulse MTI support
    
    % Defaults for backward compatibility with Scenarios 1 & 2
    if nargin < 9; pulse_num = 1; end
    if nargin < 10; prf = 1000; end
    
    tx_signal = tx_signal(:);
    
    max_delay_time = 2 * max(target_ranges) / c;          
    max_delay_samples = round(max_delay_time * fs);     
    
    rx_signal_clean = zeros(length(tx_signal) + max_delay_samples + round(fs*10e-6), 1); 
    
    % Time elapsed since the very first pulse (Slow-Time)
    pri = 1 / prf;
    time_elapsed = (pulse_num - 1) * pri;
    
    % Superposition Loop
    for i = 1:length(target_ranges)
        delay_time = 2 * target_ranges(i) / c;
        delay_samples = round(delay_time * fs);
        
        doppler_freq = 2 * target_vels(i) * fc / c;
        
        % Fast-time Doppler (during the pulse)
        t_pulse = (0:length(tx_signal)-1).' / fs;
        fast_doppler_phase = exp(1j * 2 * pi * doppler_freq * t_pulse);
        
        % Slow-time Doppler (phase shift between pulses due to target movement)
        slow_doppler_phase = exp(1j * 2 * pi * doppler_freq * time_elapsed);
        
        % Scale amplitude by the Radar Cross Section (RCS)
        amplitude = sqrt(target_rcs(i));
        
        tx_doppler = tx_signal .* fast_doppler_phase .* slow_doppler_phase .* amplitude;
        
        start_idx = delay_samples + 1;
        end_idx = delay_samples + length(tx_signal);
        rx_signal_clean(start_idx:end_idx) = rx_signal_clean(start_idx:end_idx) + tx_doppler;
    end
    
    sig_power = mean(abs(tx_signal).^2);
    noise_power = sig_power / (10^(snr_db / 10));
    noise = sqrt(noise_power / 2) * (randn(size(rx_signal_clean)) + 1j * randn(size(rx_signal_clean)));
    
    rx_signal = rx_signal_clean + noise;
    receive_time_axis = (0:length(rx_signal)-1).' / fs;
end