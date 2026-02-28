% Phase ONE: Remove residual atmospheric lines from a purged spectrometer
% spectrum and save  the corrected area
clear
[FILE] = uigetfile('*.dat');
DATA=load(char(FILE));
x= DATA(:,1);y= DATA(:,2);

load locs_atmos_lines2.dat; %locs=locs_atmos_lines2(200:end-200);

locs = locs_atmos_lines2(locs_atmos_lines2 >= 550 & locs_atmos_lines2 <= 3450);

mask = true(size(y));  % logical mask (true = keep)



  j=1;
% Step 1: Identify outliers and mask y(i-10:i+10)

while j<length(locs)-1  
   
    [~, i] = min(abs(x - locs(j)));

    if i > 20 && i + 10 <= numel(y)
      

    y_ref = y(i-30:i-21);
    avg_y = mean(y_ref);
    std_y = std(y_ref);

    if abs(y(i) - avg_y) > 2 * std_y
        mask(i-20:i+30) = false;
  
    end
    
        if  locs(j)<max(locs)&& locs(j+1)-locs(j)<0.7 && mask(i)==false
        [~, i] = min(abs(x - locs(j+1)));
        mask(i-20:i+30) = false;
        j=j+1;
        end
    
    end
    
j=j+1;

end
 

% Step 2: Interpolate masked points using 20 valid pts before & after
y_interp = y;
invalid_indices = find(~mask);

for k = 1:length(invalid_indices)
    idx = invalid_indices(k);

    % Skip if not enough space on either side
    if idx <= 20 || idx >= numel(y)-20
        continue;
    end

    % Get 20 valid points before
    prev = find(mask(1:idx-1), 20, 'last');
    % Get 20 valid points after
    next = find(mask(idx+1:end), 20, 'first') + idx;

    if numel(prev) < 5 || numel(next) < 5
        continue;
    end

    % Interpolate using linear fit
    x_neighbors = [x(prev), x(next)];
    y_neighbors = [y(prev), y(next)];

    % Line fitting and interpolation
    p = polyfit(x_neighbors, y_neighbors, 1);
    y_interp(idx) = polyval(p, x(idx));

  
end


figure;
% plot(x, y, 'b-', x(~mask), y(~mask), 'ro', x, y_interp, 'k--',x,y_filtered);

plot(x, y, 'b-', x(~mask), y(~mask), 'ro', x, y_interp, 'k--');
legend('Original y', 'Masked points', 'Interpolated y');
xlabel('x'); ylabel('y'); title('Local Interpolation After Masking');
choice = input('Eliminate 2350 cm-1 area?? (y/n): ', 's');
 if lower(choice) == 'y'
    
  index=find(x>2290&x<2390);
  x(index)=[];interp_y(index)=[];
Dayfilename=char(FILE); 
Dayfilename=[Dayfilename(1:end-4) '_F.dat'];
data=[x, y_interp];
save (Dayfilename, 'data', '-ascii');