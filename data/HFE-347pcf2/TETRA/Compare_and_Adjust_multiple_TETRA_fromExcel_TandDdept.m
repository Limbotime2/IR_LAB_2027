% CREATION OF AN AVERAGE DAY BASELINE FILE from different spectra
% From an original code by K. Le Bris, Jan 2009
% Updated to upload all the information directly from the Excel log file (Jan
% 2024)
% Modified for iS50 spectrometer data (May 2025).
% Modified to take into account the day of acquisition. (Jun 2025)
% Modified to take into account strong atmospheric line absorptions -
% around 670 cm-1, 1600 cm-1, 2350 cm-1 and 3700 cm-1
%-------------------------------------------------------
%-------------------------------------------------------
% Line 65 needs to be adapted for each compound. The new file must be saved
% as Compare_And_Adjust_multiple_XXX_fromExcel.m where XXX represent the 
% code name of the molecule.
%-------------------------------------------------------
%-------------------------------------------------------
clear all
close all


%---------------------------------------------------------------------
%open Excel file
% [fileName, filePath] = uigetfile('*.xlsx', 'Select Excel File');
% excelFilePath = fullfile(filePath, fileName);
% exceldata = readcell(excelFilePath); % Read the Excel file starting line 8


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











exceldata = exceldata(8:end,:); %eliminate the overhead
nonEmptyRows = ~cellfun('isempty', exceldata(:, 3)) & cellfun(@(x) ischar(x) && ~isempty(x), exceldata(:, 3));

exceldata = exceldata(nonEmptyRows,:);
%---------------------------------------------------------------------
%Select and load the temperature-dependent baseline

[BAS] = uigetfile('*.prn','BAS');
SUP=load(char(BAS));
x= SUP(:,1);
%SUP(:,2)=1.01*SUP(:,2); 

%---------------------------------------------------------------------
%find the temperature range and the date

[~, nameNoExt, ~] = fileparts(BAS);

 nums = regexp(nameNoExt, '\d+', 'match');

T=str2double(nums{1});  
%date = str2double(nums{end});

BASdate = nums{end}; % BASdate is a string



% Check each row for the term "Y" in the 3rd column and within a
% given temperature range taken the same date as the superbaseline.

% if isnumeric(raw)
%     dt = datetime(raw, 'ConvertFrom', 'excel');
% elseif ischar(raw) || isstring(raw)
%     dt = datetime(raw);  % Let MATLAB parse it
% else
%     dt = raw;  % Already datetime
% end

%dateNum = str2double(datestr(dt, 'yyyymmdd'));

dateCol = exceldata(:,1);

dateCol = cellfun(@(x) convert_excel_date(x), dateCol);
exceldate=string(dateCol, 'yyyyMMdd'); % Conversion Excel date to string


matching_rows = find(strcmpi(exceldata(:, 3), 'Y') & ...
                     abs(cell2mat(exceldata(:, 6)) - T) <= 2&...
                     exceldate==BASdate);
% Select the spectral files corresponding to the temperature range
Filename= [ ];
if ~isempty(matching_rows)
        % Add the corresponding number from the 2nd column to the vector
        Filename = [Filename, exceldata(matching_rows, 2) ];

  
end

    if isempty(Filename)
        error('No sample files associated with the baseline. Stopping execution.');
        
    end


File = cellfun(@(x) [x, '.prn'], Filename, 'UniformOutput', false);
disp('Files associated with this baseline')
disp(File)
%---------------------------------------------------------------------
% Adjustment of the baseline to each spectral files and creation of a DAY
% baseline

% Select areas of no absorption when the pressure is high
range=find(x>2640&x<2800);


for ii=1:length(File)

Celldata=load(char(File(ii)));
p_coeff=polyfit(x(range),SUP(range,2)-Celldata(range,2),1);
FSUP=SUP(:,2)-polyval(p_coeff,x);
%---------------------------------------------------------
% Deal with varying atmospheric lines
targetName = Filename{ii};
targetIdx = find(strcmp(exceldata(:,2), targetName), 1);
fileNames = exceldata(:,2);
descriptions = exceldata(:,3);

% ---- Find previous "Baseline" ----
prevIdx = [];
for k = targetIdx-1:-1:1
    if ischar(fileNames{k}) && contains(descriptions{k}, 'Baseline', 'IgnoreCase', true)
        prevIdx = k;
        break;
    end
end

% ---- Find next "Baseline" ----
nextIdx = [];
for k = targetIdx+1:length(fileNames)
    if ischar(fileNames{k}) && contains(descriptions{k}, 'Baseline', 'IgnoreCase', true)
        nextIdx = k;
        break;
    end
end

% Load previous and next baseline
prevFile = fileNames{prevIdx}; prevFile2=append(prevFile,'.prn');  CelldataPrev=load(prevFile2);
nextFile = fileNames{nextIdx}; nextFile2=append(nextFile,'.prn');  CelldataNext=load(nextFile2);

% Adjust previous, next and average baseline
p_coeff=polyfit(x(range),CelldataPrev(range,2)-Celldata(range,2),1);
PREV=CelldataPrev(:,2)-polyval(p_coeff,x);

p_coeff=polyfit(x(range),CelldataNext(range,2)-Celldata(range,2),1);
NEXT=CelldataNext(:,2)-polyval(p_coeff,x);

AVG_bas=(CelldataPrev(:,2)+CelldataNext(:,2))/2;
p_coeff=polyfit(x(range),AVG_bas(range)-Celldata(range,2),1);
AVG=AVG_bas-polyval(p_coeff,x);

% Find which baseline has the better fit around atmopsheric lines
range_atmo=find(x>584.6&x<584.85|x>600.02&x<600.2|x>1594.2&x<1594.8|x>1606.8&x<1607.6);
%range_atmo=find(x>730&x<800); % UofT data issue with channeling
curves = [FSUP,PREV,NEXT,AVG];
diffs = curves(range_atmo,:) - Celldata(range_atmo,2);
std_bas = std(diffs);
[~, minIdx] = min(std_bas);
DAY=curves(:,minIdx);



curveNames = {'FSUP', 'PREV', 'NEXT', 'AVG'};

% Display result
fprintf('The closest baseline of "%s" is "%s"\n', char(Filename(ii)), curveNames{minIdx});


%---------------------------------------------------------




figure
plot(x,Celldata(:,2),'-',x,FSUP,'r',x,PREV,'k',x,NEXT,'g',x,AVG,'y');

data=[x,DAY];

% Save the adusdted baseline as DAYXXX.prn where XXX correspond to the
% spectral file number
filenumber = regexp(char(File(ii)), '\d{4}', 'match');
Dayfilename=['DAY' filenumber '.prn'];

save (string(cell2mat(Dayfilename)), 'data', '-ascii');
end

