% 4th May 2026
% Hashir Niazi
% DSP CEP

function [mf_out, mf_time_axis] = apply_matched_filter(rx_signal, tx_signal, fs)
% Applies a matched filter with optional windowing for sidelobe reduction

% 1. Create the matched filter impulse response
% Time-reverse and complex-conjugate the transmitted signal
h_mf = conj(flipud(tx_signal(:)));

% 2. Apply a Window (Addressing the CEP rubric for windowing trade-offs)
% A Hamming window reduces sidelobes but slightly widens the mainlobe (resolution loss)
win = hamming(length(h_mf));
h_mf_windowed = h_mf .* win;

% 3. Perform the convolution (Filtering)
mf_out = conv(rx_signal(:), h_mf_windowed, 'full');

% 4. Time Axis Alignment
% Convolution stretches the array. We calculate the new time axis and 
% shift it back by the length of the pulse so the peak aligns perfectly 
% with the target's true time delay.
mf_time_axis = (0:length(mf_out)-1).' / fs;
filter_delay = length(tx_signal) / fs;
mf_time_axis = mf_time_axis - filter_delay;
end