% Basic code to plot three data files with # headers
clear all; close all; clc;

% STEP 1: REPLACE THESE FILENAMES WITH YOUR OWN
filenames = {'HITRAN_305_data.dat', 'TET_600_518mTorr_295K_F.dat', 'theoretical_CS_305_GFE_CALIBRATED.dat'};  % Change these

figure('Position', [100, 100, 800, 600]);
hold on;

for i = 1:length(filenames)
    % Use readmatrix which handles comments better
    % 'CommentStyle' tells MATLAB to ignore lines starting with #
    data = readmatrix(filenames{i}, 'CommentStyle', '#');
    
    % Assuming first column is x, second column is y
    x = data(:, 1);
    y = data(:, 2);
    
    plot(x, y, 'LineWidth', 1.5, 'DisplayName', filenames{i});
end

xlabel('Wavenumber (cm^{-1})')
ylabel('Cross Section (cm^{2}/molecule)')
title('Spectra Results of HFE-347pcf2');
grid on;
hold off;