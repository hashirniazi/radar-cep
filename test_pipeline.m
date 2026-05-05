% 3rd May 2026
% Hashir Niazi
% DSP CEP

% test_transmitter.m
clear; clc; close all;


% Master Control Menu
project_root = pwd; 
addpath(genpath(project_root));

% --- The Interactive Live Demo Menu ---
disp('===================================================');
disp('   Advanced DSP Radar Processing Framework         ');
disp('===================================================');
disp('Select a Simulation Scenario:');
disp('1. Baseline LFM (Single Target + CA-CFAR)');
disp('2. Target Masking Stress Test (Closely Spaced Targets)');
disp('3. Clutter Mitigation (MTI Filtering) [Pending]');
disp('4. Waveform Comparison (LFM vs Phase-Coded) [Pending]');
disp('===================================================');

sim_mode = input('Enter scenario number (1-4): ');

% --- Dynamic Configuration Override ---
% Load the base config first
radar_config; 

switch sim_mode
    case 1
        disp('>> Initializing Baseline Single Target Scenario...');
        % Override config for a single target
        target_range = 5000;    
        target_velocity = 150;  
        initial_snr = -10;
        
    case 2
        disp('>> Initializing Target Masking Scenario...');
        % Override config for multiple targets close together
        target_range = [5000, 5020];    
        target_velocity = [150, 130];   
        initial_snr = -10;
        
    case 3
        disp('>> Initializing Clutter Mitigation (MTI) Scenario...');
        % Target 1: Massive Stationary Mountain at 4km
        % Target 2: Small Moving Jet at 5km
        target_range = [4000, 5000];    
        target_velocity = [0, 127];   
        target_rcs = [1000, 10]; % Mountain is 100x larger RCS than the jet
        initial_snr = 10; % Keep noise lower so we can see the clutter    
    case 4
        disp('>> Waveform module under construction.');
        return;
        
    otherwise
        disp('Invalid selection. Exiting.');
        return;
end

% ... [Rest of your pipeline code runs here using the dynamic variables] ...
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

% --- 5. Simulate the Environment & MTI Filtering ---
if sim_mode == 3
    % For MTI, we need to fire two pulses separated by the PRI
    disp('Firing Pulse 1...');
    [rx_pulse1, rx_t] = simulate_echo(tx_signal, fs, fc, c, target_range, target_velocity, target_rcs, initial_snr, 1, prf);
    
    disp('Firing Pulse 2...');
    [rx_pulse2, ~] = simulate_echo(tx_signal, fs, fc, c, target_range, target_velocity, target_rcs, initial_snr, 2, prf);
    
    % Apply 2-Pulse Delay Line Canceller (MTI Filter)
    rx_signal = rx_pulse2 - rx_pulse1;
else
    % Standard single-pulse operation for other scenarios
    [rx_signal, rx_t] = simulate_echo(tx_signal, fs, fc, c, target_range, target_velocity, target_rcs, initial_snr, 1, prf);
end

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

% --- 7. Target Detection (CFAR Comparison) ---
mf_power = abs(mf_out).^2;

% Dynamically choose the CFAR algorithm based on the menu selection
if sim_mode == 1
    % Scenario 1: Clean single target uses standard CA-CFAR
    cfar_name = 'CA-CFAR';
    [cfar_threshold, detections] = apply_ca_cfar(mf_power, num_train_cells, num_guard_cells, pfa);
else
    % Scenario 2: Multi-target masking requires OS-CFAR
    cfar_name = 'OS-CFAR';
    [cfar_threshold, detections] = apply_os_cfar(mf_power, num_train_cells, num_guard_cells, pfa);
end

% Convert to Decibels for visualization
mf_power_db = 10*log10(mf_power / max(mf_power));
threshold_db = 10*log10(cfar_threshold / max(mf_power));
detect_indices = find(detections == 1);

figure('Name', sprintf('Detection Analysis: %s', cfar_name));
plot(mf_t * 1e6, mf_power_db, 'b', 'DisplayName', 'Signal Power');
hold on;
plot(mf_t * 1e6, threshold_db, 'r', 'LineWidth', 1.5, 'DisplayName', sprintf('%s Threshold', cfar_name));

if ~isempty(detect_indices)
    plot(mf_t(detect_indices) * 1e6, mf_power_db(detect_indices), 'go', 'MarkerFaceColor', 'g', 'DisplayName', 'Detections');
end

title(sprintf('%s Detection (P_{fa} = %1.0e)', cfar_name, pfa));
xlabel('Time (\mu s)');
ylabel('Normalized Power (dB)');
ylim([-60 5]);
legend('Location', 'best');
grid on;
hold off;