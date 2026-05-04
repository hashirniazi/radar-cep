% 3rd May 2026
% Hashir Niazi
% DSP CEP
% simulate_echo.m
function [rx_signal, receive_time_axis] = simulate_echo(tx_signal, fs, fc, c, target_range, target_vel, snr_db)
    % Simulates the radar echo with time delay, Doppler shift, and custom AWGN
    
    % Ensure tx_signal is a column vector
    tx_signal = tx_signal(:);
    
    % 1. Calculate physics
    delay_time = 2 * target_range / c;          % Round-trip time
    delay_samples = round(delay_time * fs);     % Convert time to discrete samples
    doppler_freq = 2 * target_vel * fc / c;     % Doppler shift
    
    % 2. Apply Doppler phase shift to the pulse
    t_pulse = (0:length(tx_signal)-1).' / fs;
    doppler_phase = exp(1j * 2 * pi * doppler_freq * t_pulse);
    tx_doppler = tx_signal .* doppler_phase;
    
    % 3. Create the receive window
    % We pad the array with zeros to simulate the time it took for the pulse to return
    rx_signal = zeros(length(tx_signal) + delay_samples + round(fs*10e-6), 1); 
    
    % 4. Insert the echo into the receive window
    start_idx = delay_samples + 1;
    end_idx = delay_samples + length(tx_signal);
    rx_signal(start_idx:end_idx) = tx_doppler;
    
    % 5. Add Additive White Gaussian Noise (AWGN) Manually
    % Calculate the average power of the tramsmitted signal
    sig_power = mean(abs(tx_signal).^2);
    
    % Calculate the required noise power based on the desired SNR (convert dB to linear)
    noise_power = sig_power / (10^(snr_db / 10));
    
    % Generate complex Gaussian noise
    % Split the noise power evenly between the real and imaginary parts
    noise = sqrt(noise_power / 2) * (randn(size(rx_signal)) + 1j * randn(size(rx_signal)));
    
    % Add the noise to the signal
    rx_signal = rx_signal + noise;
    
    % 6. Generate the time axis for the receive window
    receive_time_axis = (0:length(rx_signal)-1).' / fs;
end