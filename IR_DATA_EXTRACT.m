%Function for extracting data from ORCA ouput files. Input is the .out ORCA
%file(s) for each conformer.

%author: ALimbo

%List of data extracted/Explanation of variables:

%   1. Wavenumber & Intensity Coefficients for each conformer. The ouput
%   for these values are all in seperate files named '%s_IRDATA.dat' The
%   number of these files is the same number of conformers

%   2. Total Enthalpy/GFE Values for each conformer. Default is Total 
%   Enthalpy. This is stored in variable 'energies'

%   3. The number of conformers. This is stored in variable 'num_conf'

%   4. ir_data structure is used for later calculations. Instead of
%   extracting data again in later code, it saves this information for
%   later use

function [num_conf,energies,ir_data]=IR_DATA_EXTRACT()

selectdir=uigetdir(pwd,'Select directory containing ORCA .out files');
addpath(selectdir)
savepath
filepattern=fullfile(selectdir,'*.out');
[File]=uigetfile('*.out','Select ORCA Output Files','MultiSelect','on');

%initialize energies array
energies=[];

%initialize structure
ir_data=struct();

%choose where to save output files
selectdir=uigetdir(pwd,'Select directory to save output .dat files');
addpath(selectdir)
savepath

for ii=1:length(File)
    filename=char(File(ii));
    fid = fopen(filename,'r');

    %initialize storage
    wavenumber=[];
    intensity=[];

    %what to look for
    pattern1='IR SPECTRUM';
    %pattern2='Total Enthalpy'; %can change to look for Gibbs free energy if found reliable
    pattern2='Final Gibbs free energy';    %uncomment and comment the
    %previous line if using Gibbs free energy

    %search for IR SPECTRUM and extract
    while ~feof(fid)
        line=fgetl(fid);
        if contains(line,pattern1)
            for i=1:5
                line=fgetl(fid);
            end
            data_count=0;
            while ~feof(fid)
                line=fgetl(fid);
                if isempty(line)
                    break;
                end
                line_clean=strrep(line, ':',' ');
                nums=sscanf(line_clean,'%f');
                if length(nums)>4
                    wavenumber(end+1)=nums(2);
                    intensity(end+1)=nums(4);
                end
            end
            break;
        end
    end

    %search for Enthalpy/GFB and extract
    while ~feof(fid)
        line=fgetl(fid);
        if contains(line,pattern2)
            numbers=regexp(line,'-?\d+\.\d+','match');
            if ~isempty(numbers)
                energy_val=str2double(numbers{end});;
            end
            break;
        end
    end

    %close the input file for good programming practice <3
    fclose(fid);

    %write data to an output file and structure
    [~,baseName,~]=fileparts(filename);
    outputfilename=sprintf('%s_IRDATA.dat',baseName);
    fid_out=fopen(outputfilename,'w');
    for i=1:length(wavenumber)
        fprintf(fid_out,'%.4f\t%.6e\n',wavenumber(i),intensity(i));
    end
    ir_data(ii).wavenumber=wavenumber;
    ir_data(ii).intensity=intensity;

    %store values in an array
    energies(end+1)=energy_val;

    %close the output file for good programming practice <3
    fclose(fid_out);

    %ouput number of conformers
    num_conf=length(File);
end

end