% 3rd May 2026
% Hashir Niaz
% DSP CEP

% radar_config.m
% Global configuration for DSP Radar Processing Framework

%% 1. Universal Constants
c = 3e8; % Speed of light (m/s)

%% 2. Radar System Parameters
fc = 10e9;              % Carrier frequency (10 GHz - X Band)
fs = 100e6;             % Sampling frequency (100 MHz)
pulse_width = 10e-6;    % Pulse duration (10 microseconds)
bandwidth = 50e6;       % LFM Bandwidth (50 MHz)
prf = 1e3;              % Pulse Repetition Frequency (1 kHz)

%% 3. Target Parameters (Sandbox Setup)

target_range = 5000;    % Target distance (5 km)
target_velocity = 150;  % Target speed (150 m/s moving away)
target_rcs = 10;        % Radar Cross Section (sq meters)

%% 4. Environment Parameters
initial_snr = 1;       % Starting Signal-to-Noise Ratio (dB)

%% 5. CFAcd R Detection Parameters
pfa = 1e-4;             % Probability of False Alarm (1 in 10,000)
num_train_cells = 40;   % Total training cells (20 on each side)
num_guard_cells = 4;    % Total guard cells (2 on each side)

% Display confirmation
disp('Radar configuration loaded successfully.');