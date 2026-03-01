% Create a temperature-dependent and day-dependent Superbaseline from the Excel log file and the *prn datafile.
% Average spectra based on their weight 
% The Excel file should be properly formatted. The overhead is 7 line long.
% Baseline data are clearly indicated on column 3 of the Excel file.
% Pressures, number of scans and temperature should have the number format,
% not text format.

% Open and read Excel file
clear all, close all
% [fileName, filePath] = uigetfile('*.xlsx', 'Select Excel File');
% excelFilePath = fullfile(filePath, fileName);
% exceldata = readcell(excelFilePath); % Read the Excel file 


% Step 1: Select an Excel file
[filename, pathname] = uigetfile('*.xlsx', 'Select an Excel file');
if isequal(filename, 0)
    disp('File selection cancelled.');
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
%disp(data);

exceldata = exceldata(8:end,:); % Eliminate the overhead (first 7 lines)

exceldata = exceldata(~cellfun(@(x) ismissing(x), exceldata(:,6)), :); % Eliminate the empty rows

% Determine the temperature ranges
Temp=[];
 Temp = [Temp, exceldata(:,6)];

 Temp = cell2mat(Temp);
ranges = unique(round(Temp/5) * 5); % Assuming ranges separated by at least 2 degrees



% Find the date of acquisition
dateCol = exceldata(:,1);

dateCol = cellfun(@(x) convert_excel_date(x), dateCol);
[uniqueDates, ~, dateGroupIdx] = unique(dateCol);



for j=1:numel(ranges)
 disp([newline 'Baseline files for a temperature of ', num2str(ranges(j)), ' Kelvin'])
 
    for k=1:length(uniqueDates)
 file_name = [ ]; weight = []; 

% Check each row for the term "Baseline" in the 3rd column within a given temperature range
matching_rows = find(strcmpi(exceldata(:, 3), 'Baseline') & ...
                     abs(cell2mat(exceldata(:, 6)) - ranges(j)) <= 4 & dateGroupIdx == k);

% Eliminate empty matching_rows 
        if isempty(matching_rows)
            continue;  % Goes to next iteration of inner loop
        end
        disp([newline datestr(uniqueDates(k))])

        % Add the corresponding number from the 2nd column to the vector
        file_name = [file_name, exceldata(matching_rows, 2) ];
        % Add the corresponding number from the 7th column to the vector
        weight = [weight, exceldata(matching_rows, 7)];
   
       

        file_name = cellfun(@(x) char(string(x)), file_name, 'UniformOutput', false);
        baselineFiles = cellfun(@(x) [x, '.prn'], file_name, 'UniformOutput', false);
        weight=cell2mat(weight);


 
        y=[];
        for ii=1:length(baselineFiles) % Number of files

            filename=baselineFiles{ii};
            disp([baselineFiles{ii},' with weight ',num2str(weight(ii))]);

            fid = fopen(filename,'r');
            Mydata = textscan(fid,'%f %f','HeaderLines',0); % Skip header lines
            fid = fclose(fid);
            Mydata=cell2mat(Mydata); 

            plot(Mydata(:,1),Mydata(:,2));
            legend
            hold on
            if isempty(y)
             y = zeros(size(Mydata(:,2)));  
            end
            y=y+weight(ii)*Mydata(:,2);
        end
        x=Mydata(:,1);y=y./sum(weight); 

        plot(x,y,'k'), 
        data=[x,y];
        charRepresentation = num2str(ranges(j));
        date=uniqueDates(k);datestr_clean = char(datetime(date, 'Format', 'yyyyMMdd'));
        fileout=['baseline_' charRepresentation 'K_' datestr_clean '.prn'];
        save(fileout,'data','-ascii','-double')
    end
end

