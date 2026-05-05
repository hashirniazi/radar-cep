% 4th May 2026
% Hashir Niazi
% DSP CEP

function [mf_out, mf_time_axis] = apply_matched_filter(rx_signal, tx_signal, fs, sim_mode)
    % Applies a matched filter with conditional windowing
    
    if nargin < 4; sim_mode = 1; end % Default to 1 if not provided
    
    h_mf = conj(flipud(tx_signal(:)));
    
    % Adaptive Windowing Strategy
    if sim_mode == 4
        % Barker codes require perfect amplitude matching. NO WINDOWING.
        h_mf_windowed = h_mf;
    else
        % LFM chirps benefit from sidelobe reduction via Hamming Window.
        win = hamming(length(h_mf));
        h_mf_windowed = h_mf .* win;
    end
    
    mf_out = conv(rx_signal(:), h_mf_windowed, 'full');
    
    mf_time_axis = (0:length(mf_out)-1).' / fs;
    filter_delay = length(tx_signal) / fs;
    mf_time_axis = mf_time_axis - filter_delay;
end