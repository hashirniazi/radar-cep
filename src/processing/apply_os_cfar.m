
% 5th May 2026
% Hashir Niazi
% DSP CEP

% apply_os_cfar.m
function [threshold, detections] = apply_os_cfar(signal_power, num_train, num_guard, pfa)
% Applies a 1D Order Statistic CFAR (OS-CFAR) detector

N = length(signal_power);
threshold = zeros(N, 1);
detections = zeros(N, 1);

T = round(num_train / 2);
G = round(num_guard / 2);

% OS-CFAR picks a specific sorted rank to represent the noise floor.
% We use the 75th percentile (3/4 of the way up the sorted list)
k_rank = round(num_train * 0.75);

% OS-CFAR requires a different scaling factor than CA-CFAR.
% Exact analytical calculation requires complex polynomial root-finding, 
% so we use an empirical scaling constant tuned for our specific Pfa.
alpha_os = 4.0; % Tunable parameter for Pfa ~ 1e-4

% Slide the window across the signal
for i = (T + G + 1) : (N - T - G)
    lead_window = signal_power(i - T - G : i - G - 1);
    lag_window  = signal_power(i + G + 1 : i + T + G);

    % Combine and SORT the training cells
    sorted_cells = sort([lead_window; lag_window]);

    % Extract the k-th rank value as our noise estimate
    noise_est = sorted_cells(k_rank);

    % Calculate the dynamic threshold
    threshold(i) = alpha_os * noise_est;

    if signal_power(i) > threshold(i)
        detections(i) = 1;
    end
end
end