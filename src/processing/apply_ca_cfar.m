% 5th May 2025
% Hashir Niazi
% DSP CEP

% appply_ca_cfar.m
function [threshold, detections] = apply_ca_cfar(signal_power, num_train, num_guard, pfa)
% Applies a 1D Cell-Averaging CFAR (CA-CFAR) detector

N = length(signal_power);
threshold = zeros(N, 1);
detections = zeros(N, 1);

% Split the cells to look at leading and lagging windows
T = round(num_train / 2);
G = round(num_guard / 2);

% Calculate the CFAR scaling factor (alpha) for a square-law detector
% This defines how far above the noise floor the threshold sits
alpha = num_train * (pfa^(-1/num_train) - 1);

% Slide the window across the signal
for i = (T + G + 1) : (N - T - G)
    % Extract the training cells (ignoring the guard cells and CUT)
    lead_window = signal_power(i - T - G : i - G - 1);
    lag_window  = signal_power(i + G + 1 : i + T + G);

    % Estimate the local noise power by averaging the training cells
    noise_est = sum([lead_window; lag_window]) / num_train;

    % Calculate the dynamic threshold
    threshold(i) = alpha * noise_est;

    % Target detection logic: If signal crosses threshold, mark it!
    if signal_power(i) > threshold(i)
        detections(i) = 1;
    end
end
end