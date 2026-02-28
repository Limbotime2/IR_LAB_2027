% Concatenate all the cross sections for a given pressure-temperature set from the Excel log file and the *dat datafiles.
% Create and save weighted average XS files
% THE EXCEL LOG FILE MUST BE PROPERLY FORMATTED I.E.,
% - THE SAMPLE SET MUST BE SEPARATED BY AT LEAST ONE BLANK ROW.
% - ROW TITLE ON ROW 4.
% - DATA STARTS ON ROW 8.
clear all; close all
% [fileName, filePath] = uigetfile('*.xlsx', 'Select Excel File');
% excelFilePath = fullfile(filePath, fileName);
% %Set up import options
% opts = detectImportOptions(excelFilePath);
% opts.VariableNamesRange = 'A6:G6';
% opts.DataRange = 'A8:G8';
% opts.VariableNames = readcell(excelFilePath, 'Range', 'A6:G6');  % Force 10 variable names
% opts.SelectedVariableNames = opts.VariableNames;

% [fileName, filePath] = uigetfile('*.xlsx', 'Select Excel File');
% excelFilePath = fullfile(filePath, fileName);


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


% Step 5 Read headers manually from A6:G6
%headers = readcell(fullPath, 'Range', 'A6:G6');
headers = readcell(fullpath, 'Sheet', selectedSheet, 'Range', 'A6:G6');

% Clean headers (in case of empty cells)
for i = 1:length(headers)
    if isempty(headers{i}) || ~ischar(headers{i})
        headers{i} = ['Var' num2str(i)];
    end
end

% Step 6: Read data from A8 downward (only columns A to G)
exceldata = readtable(fullpath, 'Sheet', selectedSheet, 'Range', 'A8:G1000', 'ReadVariableNames', false);

% Assign cleaned headers to the table
exceldata.Properties.VariableNames = matlab.lang.makeValidName(headers);


% Find indices of non-missing entries in column P1
dataIndices = find(~ismissing(exceldata.P1));

% Initialize cell array to store the index sets
indexSets = {};

% Initialize counters
setStart = 1;
setCount = 1;

% Iterate through the indices to find blank spaces and create index sets
for i = 1:length(dataIndices) - 1
    if dataIndices(i + 1) - dataIndices(i) > 1
        % End of a set
        indexSets{setCount} = dataIndices(setStart:i);
        setCount = setCount + 1;
        setStart = i + 1;
    end
end
% Add the last set
indexSets{setCount} = dataIndices(setStart:end);

% Check if there are remaining indices
if setCount == 1 && isempty(indexSets{setCount})
    indexSets{setCount} = dataIndices;
end

for i = 1:length(indexSets)
    fprintf('Set %d indices: ', i);
    disp(indexSets{i}');
end

%--------------------------------------------------------------

% Determination of the temperature ranges

rangesT = unique(round(exceldata.T/5) * 5); % Assuming ranges separated by at least 5 degrees

%------------------------------------------------------------------------
all_xf = {};all_yf = {};P=[];


% Weight-averaged cross section for each temperature-pressure set
for j=1:numel(rangesT)
    % find data column matching a given temperature
    matching_rows = find(strcmpi(exceldata.MOLECULE, 'Y') & ...
                     abs(exceldata.T - rangesT(j)) <= 2);



% Filter indexSets based on matching_row1 and find the initial pressure of
% each temperature-pressure sample.
 indexSets2 = {}; 


for i = 1:length(indexSets)
 
    currentSet = indexSets{i};
    filteredSet = intersect(currentSet, matching_rows);
    
    if ~isempty(filteredSet)
        indexSets2{end+1} = filteredSet; % Find active scan indices for a T-P set
        Pressure=exceldata.P1(filteredSet(1));  % Find original pressure of the T-P set
        file_name = exceldata.FILE(filteredSet); weight=exceldata.nb_scans(filteredSet);
         fprintf('\n Set %d, Pressure: %0.5g Torr, Temperature: %d K: \n', i,Pressure,rangesT(j)); 
        DATAFiles = cellfun(@(name) [name, '.dat'], file_name, 'UniformOutput', false);
        y=[];
    
figure
        for ii=1:length(DATAFiles) % Number of files

    filename=char(DATAFiles(ii));
disp(['T= ',num2str(rangesT(j)),' K, ',num2str(Pressure),' Torr, ',filename]);
    fid = fopen(filename,'r');
    Mydata = textscan(fid,'%f %f','HeaderLines',0); % Skip header lines
    fid = fclose(fid);
    Mydata=cell2mat(Mydata); 

    plot(Mydata(:,1),Mydata(:,2));
    hold on

        if isempty(y)
        y = weight(ii) * Mydata(:,2);
        else

        y = y + weight(ii) * Mydata(:,2);
        end


        end
        W=sum(weight);
x=Mydata(:,1);y=y./W;
    all_xf{end+1} = x;
    all_yf{end+1} = y;
plot(x,y,'k');
ylim([-1e-19 4e-18])
title(['Figure ' num2str(rangesT(j)) ' K ' num2str(Pressure) ' torr']);
hold off
P=[P; Pressure];
data=[x,y];
charRepresentationP = num2str(Pressure*1000);
charRepresentationT = num2str(rangesT(j));
charRepresentationW = num2str(W);
fileout=[filename(1:3) '_' charRepresentationW '_' charRepresentationP 'mTorr_' charRepresentationT 'K.dat'];
save(fileout,'data','-ascii','-double')

    end

end


end

 figure;
hold on;
for i = 1:length(all_xf)
    plot(all_xf{i}, all_yf{i});
end
title('All Final Results');
xlabel('Wavenumber (cm-1)');
ylabel('Cross-section');
%legend(arrayfun(@(i) ['Iter ' num2str(i)], 1:length(all_xf), 'UniformOutput', false));
legend(arrayfun(@(x) sprintf('P = %.2f Torr', x), P, 'UniformOutput', false));
grid on;
 hold off;   