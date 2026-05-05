% 3rd May 2026
% Hashir Niazi
% DSP CEP
% simulate_echo.m
function [rx_signal, receive_time_axis] = simulate_echo(tx_signal, fs, fc, c, target_ranges, target_vels, snr_db)
    % Simulates radar echoes for multiple targets with custom AWGN
    
    tx_signal = tx_signal(:);
    
    % Find the furthest target to size the receive window properly
    max_delay_time = 2 * max(target_ranges) / c;          
    max_delay_samples = round(max_delay_time * fs);     
    
    % Initialize empty clean receive window
    rx_signal_clean = zeros(length(tx_signal) + max_delay_samples + round(fs*10e-6), 1); 
    
    % Loop through targets and add them (Superposition)
    for i = 1:length(target_ranges)
        delay_time = 2 * target_ranges(i) / c;
        delay_samples = round(delay_time * fs);
        doppler_freq = 2 * target_vels(i) * fc / c;
        
        t_pulse = (0:length(tx_signal)-1).' / fs;
        doppler_phase = exp(1j * 2 * pi * doppler_freq * t_pulse);
        tx_doppler = tx_signal .* doppler_phase;
        
        start_idx = delay_samples + 1;
        end_idx = delay_samples + length(tx_signal);
        
        % Add this target's echo to the clean environment
        rx_signal_clean(start_idx:end_idx) = rx_signal_clean(start_idx:end_idx) + tx_doppler;
    end
    
    % Add AWGN manually based on a single pulse's power
    sig_power = mean(abs(tx_signal).^2);
    noise_power = sig_power / (10^(snr_db / 10));
    noise = sqrt(noise_power / 2) * (randn(size(rx_signal_clean)) + 1j * randn(size(rx_signal_clean)));
    
    rx_signal = rx_signal_clean + noise;
    
    receive_time_axis = (0:length(rx_signal)-1).' / fs;
end