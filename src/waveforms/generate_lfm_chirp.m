function [tx_signal, t] = generate_lfm_chirp(fs, pulse_width, bandwidth)
% 3rd May 2026
% Hashir Niazi
% DSP CEP

% generate_lfm_chirp.m
% Generates a complex baseband LFM (chirp) pulse

% Create a time vector centered at zero
t = -pulse_width/2 : 1/fs : pulse_width/2 - 1/fs;

% Calculate the chirp rate (K = Bandwidth / Time)
K = bandwidth / pulse_width; 

% Complex LFM signal equation
tx_signal = exp(1j * pi * K * (t.^2));
end