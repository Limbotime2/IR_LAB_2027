%Function for reading downloadable .xsc file from HITRAN.

%Input is the .xsc file, Output is a .dat file in two column formatting
%representing wavenumber vs. cross section

%author: ALimbo

function read_HITRAN(yes_no)

if strcmp('yes',yes_no)

    %open file
    selectdir=uigetdir(pwd,'Select directory containing HITRAN .xsc file');
    addpath(selectdir)
    savepath
    filepattern=fullfile(selectdir,'*.xsc');
    [File]=uigetfile(filepattern,'Select HITRAN file');
    filename=char(File);
    fid=fopen(filename,'r');
    
    %read header line
    headerLine=fgetl(fid);
    positions=[20,10,10,7,7,6,10,5,15,4,3,3];
    startPos=[1,cumsum(positions(1:end-1))+1];
    molecule=strtrim(headerLine(startPos(1):startPos(1)+positions(1)-1));
    V_min=str2double(headerLine(startPos(2):startPos(2)+positions(2)-1));
    V_max=str2double(headerLine(startPos(3):startPos(3)+positions(3)-1));
    N=str2double(headerLine(startPos(4):startPos(4)+positions(4)-1));
    T=str2double(headerLine(startPos(5):startPos(5)+positions(5)-1));
    P=str2double(headerLine(startPos(6):startPos(6)+positions(6)-1));
    sigma_max=str2double(headerLine(startPos(7):startPos(7)+positions(7)-1));
    resolution=str2double(headerLine(startPos(8):startPos(8)+positions(8)-1));
    common_name=strtrim(headerLine(startPos(9):startPos(9)+positions(9)-1));
    % Field 10: Not used (skip)
    broadener=strtrim(headerLine(startPos(11):startPos(11)+positions(11)-1));
    reference=str2double(headerLine(startPos(12):startPos(12)+positions(12)-1));

    % Display all parameters
    fprintf('=== HITRAN Experimental Parameters ===\n');
    fprintf('Molecule: %s\n', molecule);
    fprintf('Wavenumber range: %.2f to %.2f cm⁻¹\n', V_min, V_max);
    fprintf('Number of points: %d\n', N);
    fprintf('Temperature: %.1f K\n', T);
    fprintf('Pressure: %.1f Torr (≈%.3f atm)\n', P, P/760);
    fprintf('Max cross-section: %.3e cm²/molecule\n', sigma_max);
    fprintf('Instrument resolution: %.2f cm⁻¹\n', resolution);
    fprintf('Common name: %s\n', common_name);
    fprintf('Broadener: %s\n', broadener);
    fprintf('Reference index: %d\n\n', reference);
    
    % Calculate step size
    step_size=(V_max-V_min)/(N-1);  % N-1 intervals for N points
    fprintf('Step size: %.6f cm^-1\n', step_size);

    %read in data
    data=[];
    while true
        line=fgetl(fid);
        if ~ischar(line)
            break;
        end
        values=textscan(line,'%f');
        data=[data;values{1}];
    end

    %close file for good programming practice <3
    fclose(fid);

    %truncate last few data points if zero
    zerothreshold=1e-99;
    originalLength=length(data);
    lastnonzeroindex=originalLength;

    %first pass look for exact zeros
    for i=originalLength:-1:1
        if data(i)~=0
            lastnonzeroindex=i;
            break;
        end
    end

    %second pass, if no exact zeros, look for values below threshold
    if lastnonzeroindex==originalLength
        for i=originalLength:-1:1
            if data(i)>zerothreshold
                lastnonzeroindex=1;
                break;
            end
        end
    end
    if lastnonzeroindex<originalLength
        fprintf('Found %d trailing zero(s) - trimming data\n',originalLength-lastnonzeroindex);
        data=data(1:lastnonzeroindex);
        fprintf('Trimmed data to %d points\n',length(data));
    end

    %debugging check to ensure the right number of data points have been read
    if length(data) ~= N
        warning('Expected %d points, but read %d points',N,length(data));
    end

    %create x-axis using step size
    x=V_min:step_size:V_max;

    %write to output file
    selectdir=uigetdir(pwd,'Select directory to save output HITRAN_data.dat file');
    addpath(selectdir)
    savepath
    output_id=fopen('HITRAN_data.dat','w');
    for i=1:length(x)
        fprintf(output_id,'%.4f\t%.6e\n',x(i),data(i));
    end

    %close ouput file
    fclose(output_id);

else
    fprintf('No HITRAN data read \n');
end

end