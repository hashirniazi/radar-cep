% 3rd May 2026
% Hashir Niazi
% DSP CEP

% test_transmitter.m
clear; clc; close all;


% 0. Add all subdirectories in the project root to the path
project_root = pwd; 
addpath(genpath(project_root));


% 2. Load global parameters
radar_config;

% 3. Generate the waveform
[tx_signal, t] = generate_lfm_chirp(fs, pulse_width, bandwidth);

% 4. Visualization
figure('Name', 'Transmitter Analysis: LFM Chirp');

% --- Time Domain (Real Part) ---
subplot(2,1,1);
plot(t * 1e6, real(tx_signal), 'b');
title('LFM Pulse - Time Domain (Real Part)');
xlabel('Time (\mu s)');
ylabel('Amplitude');
grid on;

% --- Frequency Domain (FFT) ---
subplot(2,1,2);
N = length(tx_signal);
% Zero-padding to get a high-resolution FFT curve
N_fft = 2^nextpow2(N) * 4; 
f_axis = linspace(-fs/2, fs/2, N_fft);

% Compute FFT and shift zero-frequency component to center
tx_fft = fftshift(fft(tx_signal, N_fft));
tx_fft_mag = abs(tx_fft) / max(abs(tx_fft)); % Normalize magnitude

plot(f_axis / 1e6, 20*log10(tx_fft_mag), 'r', 'LineWidth', 1.5);
title('Frequency Spectrum (FFT)');
xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');
ylim([-40 5]);
grid on;

% --- 5. Simulate the Environment (Echo & Noise) ---
[rx_signal, rx_t] = simulate_echo(tx_signal, fs, fc, c, target_range, target_velocity, initial_snr);

figure('Name', 'Receiver Analysis: Raw Noisy Echo');
plot(rx_t * 1e6, real(rx_signal), 'Color', [0.5 0.5 0.5]);
title(sprintf('Raw Received Signal (SNR = %d dB)', initial_snr));
xlabel('Time (\mu s)');
ylabel('Amplitude');
grid on;

% --- 6. Receiver Processing (Matched Filter) ---
[mf_out, mf_t] = apply_matched_filter(rx_signal, tx_signal, fs);

% Convert the matched filter output to Decibels for standard radar visualization
mf_mag_db = 20*log10(abs(mf_out) / max(abs(mf_out)));

figure('Name', 'Receiver Analysis: Matched Filter Output');
plot(mf_t * 1e6, mf_mag_db, 'b', 'LineWidth', 1.2);
title('Matched Filter Output (Pulse Compression)');
xlabel('Time (\mu s)');
ylabel('Normalized Magnitude (dB)');
ylim([-60 5]);
grid on;

% Add a line showing exactly where the target *should* be
target_time_delay = (2 * target_range / c) * 1e6;
xline(target_time_delay, 'r--', 'True Target Location', 'LabelVerticalAlignment', 'bottom');

% --- 7. Target Detection (CA-CFAR) ---
% Convert Matched Filter output to power (Square-Law Detection)
mf_power = abs(mf_out).^2;

[cfar_threshold, detections] = apply_ca_cfar(mf_power, num_train_cells, num_guard_cells, pfa);

% Convert to Decibels for visualization
mf_power_db = 10*log10(mf_power / max(mf_power));
threshold_db = 10*log10(cfar_threshold / max(mf_power));

% Find exactly where the detections happened for plotting
detect_indices = find(detections == 1);

figure('Name', 'Detection Analysis: CA-CFAR');
plot(mf_t * 1e6, mf_power_db, 'b', 'DisplayName', 'Signal Power');
hold on;
plot(mf_t * 1e6, threshold_db, 'r', 'LineWidth', 1.5, 'DisplayName', 'CA-CFAR Threshold');

% Overlay markers where the threshold was crossed
plot(mf_t(detect_indices) * 1e6, mf_power_db(detect_indices), 'go', 'MarkerFaceColor', 'g', 'DisplayName', 'Detections');

title(sprintf('CA-CFAR Detection (P_{fa} = %1.0e)', pfa));
xlabel('Time (\mu s)');
ylabel('Normalized Power (dB)');
ylim([-60 5]);
legend('Location', 'best');
grid on;
hold off;