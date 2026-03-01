clear all
% Calculate the instantaneous or adjusted radiative efficiency from a cross-section spectrum
% Author: K. Le Bris, modified by A. Limbo

%Enter the cross-section spectrum  (first column: wavenumber in cm-1, second column: cross-section in cm^2/molecule) 
fid = fopen('TET_600_518mTorr_295K_F.dat');
% Read two floating point numbers per line, skipping lines that start with #
data_raw = textscan(fid, '%f %f', 'CommentStyle', '#', 'CollectOutput', true);
fclose(fid);
file1 = data_raw{1};  % Should be Nx2 matrix

% Filter out negative cross-sections
fprintf('Original data size: %d rows\n', size(file1, 1));
valid_idx = file1(:,2) > 0;
file1 = file1(valid_idx, :);
fprintf('After filtering negatives: %d rows\n', size(file1, 1));

lifetime = 6.1; % lifetime in years

% Enter the instantaneous or adjusted Pinnock curve (first column: wavenumber in cm-1, second column: radiative forcing in mW m^-2 cm (per 10e-18 cm^2 per molecule) 
Pinnock = load('NewPinnock.dat'); 

% Extract wavenumber and cross-section columns
wavenumber = file1(:,1);
cross_section = file1(:,2);

% Find indices where wavenumber is positive
pos_idx = find(wavenumber > 0);
wavenumber = wavenumber(pos_idx);
cross_section = cross_section(pos_idx);

xmin = round(min(wavenumber));
xmax = round(max(wavenumber));
fprintf('Wavenumber range: %d to %d cm-1\n', xmin, xmax);

if xmax > 3000
    xmax = 3000;
    fprintf('Truncating to 3000 cm-1\n');
end

% Initialize arrays
v = [];
y = [];

for i = xmin:xmax-1
    xlow = i;
    xhigh = i+1;
    xi = find(wavenumber > xlow & wavenumber < xhigh);
    
    if ~isempty(xi)
        v(i+1-xmin) = i+0.5;
        yj = mean(cross_section(xi));
        y(i+1-xmin) = yj;
    else
        % Handle empty intervals
        v(i+1-xmin) = i+0.5;
        y(i+1-xmin) = 0; % or NaN, depending on how you want to handle gaps
        fprintf('Warning: No data in interval %d-%d cm-1\n', xlow, xhigh);
    end
end

% Find matching Pinnock indices
ind = find(Pinnock(:,1) >= xmin & Pinnock(:,1) < xmax);

if length(ind) ~= length(y)
    fprintf('Warning: Pinnock data length (%d) vs y length (%d) mismatch\n', ...
        length(ind), length(y));
end

% Calculate RE
RE = y' .* Pinnock(ind,2) * 1E18/1000;

% Check for NaN or Inf
if any(isnan(RE)) || any(isinf(RE))
    fprintf('Warning: NaN or Inf detected in RE\n');
    fprintf('Number of NaNs: %d\n', sum(isnan(RE)));
    fprintf('Number of Infs: %d\n', sum(isinf(RE)));
end

% Calculate instantaneous RE
InsRE = trapz(v', RE) % instantaneous RE in W/m^2

% Calculation of the lifetime adjusted RE
a = 2.962; 
b = 0.9312; 
c = 2.994; 
d = 0.9302; % Empirical values from Hodnebrog 2020

Lifetime_adj = a * lifetime^b / (1 + c * lifetime^d);
Adusted_RE = InsRE * Lifetime_adj
% Lifetime adjusted RE can be found if the lifetime is known
