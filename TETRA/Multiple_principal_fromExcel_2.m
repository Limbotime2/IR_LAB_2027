% Read the Excel log file and use the experimental spectrum files (*.prn) and adjusted baseline
% files (*.prn) to calculate the temperature and pressure dependent cross-section spectra.

% Read the Excel log file number, temperature, P1 and P2.
% spectra to be included should be marked with the character Y on the third column
% of the Excel log file.
% Samples should be separated by a space row or a non "Y" row in the Excel
% log file.
clear all;
% [fileName, filePath] = uigetfile('*.xlsx', 'Select Excel File');
% excelFilePath = fullfile(filePath, fileName);
% exceldata = readcell(excelFilePath); % Read the Excel file

%-------------------------Open and read the Excel log file---------------
% Step 1: Select an Excel file
[filename, pathname] = uigetfile('*.xlsx', 'Select an Excel file');
if isequal(filename, 0)
    disp('User canceled file selection.');
    return;
end
fullpath = fullfile(pathname, filename);

% Step 2: Get available sheet names
[~, sheetNames] = xlsfinfo(fullpath);
if isempty(sheetNames)
    error('No sheets found in the selected file.');
end

% Step 3: Choose a sheet by name (via popup list dialog)
[sheetIdx, ok] = listdlg('PromptString', 'Select a sheet:', ...
                         'SelectionMode', 'single', ...
                         'ListString', sheetNames);
if ~ok
    disp('User canceled sheet selection.');
    return;
end

% Step 4: Get selected sheet name
selectedSheet = sheetNames{sheetIdx};

% Step 5: Read the selected sheet
exceldata = readcell(fullpath, 'Sheet', selectedSheet);

% Step 6: Show what was loaded
fprintf('Loaded sheet: %s\n', selectedSheet);
%------------------------- Initialisation -------------------------
% Create vectors of 
% the file name of each baseline file
 file_name = [ ];
% the number of scans in each baseline file
weight = [];
% the initial and final pressure
P1=[]; P2 = [];
% the temperature
Temp=[];
Row=[];

% Check each row for the letter "Y" in the 3rd column
for i = 1:size(exceldata, 1)
    if  ischar(exceldata{i, 3}) && strcmpi(exceldata{i, 3}, 'Y') % Case-insensitive comparison
        % Add the corresponding number from the 2nd column to the vector
        file_name = [file_name, exceldata(i, 2) ];
        % Add the corresponding number from the 7th column to the vector
        weight = [weight, exceldata(i, 7)];
        % Add the corresponding numbers from the 3rd, 4th and 5th columns to the vector
        P1 = [P1, exceldata(i, 4)];P2 = [P2, exceldata(i, 5)];Temp = [Temp, exceldata(i, 6)];
        % Save the row number from Excel
        Row=[Row, i];
    end
end
% Conversion cell array into numerical array
weight=cell2mat(weight);P1=cell2mat(P1);P2=cell2mat(P2);
Temp=cell2mat(Temp);
% Conversion cell array into character array
Files = cellfun(@(x) [x, '.prn'], file_name, 'UniformOutput', false);
P=zeros(length(P1),1);

%------------------------- File by file processing -----------------
colors = distinguishable_colors(20);   % Generate 20 distinct colors

figure
set(gca, 'ColorOrder', colors, 'NextPlot', 'replacechildren')  % Set color order
hold on
for i = 1:length(file_name)
   
% Open spectrum and adjusted baseline files and read wavenumber and intensity
File=char(Files(i));
fid = fopen(File,'r');
Mydata = textscan(fid,'%f %f','HeaderLines',0); % Skip header lines
fid = fclose(fid);
Mydata=cell2mat(Mydata); 

% % Find and open the adjusted baseline files and read wavenumber and intensity
    %  Find the four digits before the dot of the *.prn file
    matches = regexp(File, '(\d+)\.', 'tokens');
    numStr=matches{1}{1};

    % Check if the extracted substring contains only numbers
    if all(isstrprop(numStr, 'digit'))
        % Find the baseline name with the desired format
        numValue = str2double(numStr);
        BaselineName = sprintf('DAY%04d.prn', numValue);
    end
fid = fopen(BaselineName,'r');
Baseline_data = textscan(fid,'%f %f','HeaderLines',0); % Skip header lines
fid = fclose(fid);
Baseline_data=cell2mat(Baseline_data); 

% Find the effective pressure during the scan



    if ((i == 1)||(Row(i)-Row(i-1)>1))  && (P1(i) <= P2(i)) % Check if the pressure increases (cell leaking air from outside)
       P(i) = P1(i);
    elseif ((i == 1)||(Row(i)-Row(i-1)>1))  && (P1(i) > P2(i))% Decreasing pressure due to gas sample condensation
            P(i) = (P1(i) + P2(i)) / 2;
    elseif (P1(i) <= P2(i))
        P(i)=P(i-1);
    else P(i) = (P1(i) + P2(i)) / 2;

    end


fprintf('%s %.3f %5.2f \n', File,P(i),Temp(i));
%disp([File,char(P(i)),char(Temp(i))])




%--------------------------------------------------------------------
% Calculation of the cross-section
range=find(Mydata(:,1)>499.999 &Mydata(:,1)<3500);

data_full_cell=[Mydata(range,:)]; data_empty_cell=[Baseline_data(range,:)];
cross_section_value=Cross_Section_Kelvin(data_empty_cell(:,2),data_full_cell(:,2),P(i),Temp(i))';
file_out=[File(1:end-3) 'dat'];
data=[data_full_cell(:,1),cross_section_value];
save(file_out, 'data', '-ascii', '-double');
plot(data_full_cell(:,1),cross_section_value); 
legends{i} = [sprintf('%.3f', P(i)) ' Torr'];


    end
legend(legends)
hold off;
