% 5th May 2026
% Hashir Niazi
% DSP CEP

% generate_barker_code.m
function [tx_signal, t] = generate_barker_code(fs, pulse_width)
% Generates a baseband 13-bit Barker phase-coded waveform

% The 13-bit sequence
barker_13 = [1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1];
num_chips = length(barker_13);

% How long each phase "chip" lasts
chip_duration = pulse_width / num_chips;

% Time axis for the entire pulse
t = (0 : round(pulse_width * fs) - 1).' / fs;
tx_signal = zeros(size(t));

% Assign the +1 or -1 phase to each segment of time
for i = 1:num_chips
    start_time = (i-1) * chip_duration;
    end_time = i * chip_duration;

    % Find the time indices that fall into the current chip
    chip_indices = (t >= start_time) & (t < end_time);

    % Apply the phase
    tx_signal(chip_indices) = barker_13(i);
end
end