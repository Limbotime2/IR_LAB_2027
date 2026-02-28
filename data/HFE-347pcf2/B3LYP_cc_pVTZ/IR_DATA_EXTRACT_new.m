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

function [num_conf,enthalpy,GFE,ir_data]=IR_DATA_EXTRACT(num_temp)

[File]=uigetfile('*.out','Select ORCA Output Files','MultiSelect','on');

%initialize energy arrays
enthalpy=zeros(num_temp,length(File));
GFE=zeros(num_temp,length(File));

%initialize structure
ir_data=struct();

%what to look for, items can be added to list
pattern1='IR SPECTRUM';
pattern2='Total Enthalpy';
pattern3='Final Gibbs free energy';

for ii=1:length(File)
    filename=char(File(ii));
    fid = fopen(filename,'r');

    %initialize storage
    wavenumber=[];
    intensity=[];

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

    %search for Enthalpy and extract
    frewind(fid);
    temp_count=1;
    while ~feof(fid)
        line=fgetl(fid);
        if contains(line,pattern2)
            numbers=regexp(line,'-?\d+\.\d+','match');
            if ~isempty(numbers)
                enthalpy(ii,temp_count)=str2double(numbers{end});
                temp_count=temp_count+1;
            end
        end
    end

    %search for GFE and extract
    frewind(fid);
    temp_count=1;
    while ~feof(fid)
        line=fgetl(fid);
        if contains(line,pattern3)
            numbers=regexp(line,'-?\d+\.\d+','match');
            if ~isempty(numbers)
                GFE(ii,temp_count)=str2double(numbers{end});
                temp_count=temp_count+1;
            end
        end
    end    

    %close the input file for good programming practice <3
    fclose(fid);

    %OPTIONAL: write data to an output file and structure
    %uncomment if needed:
        %[~,baseName,~]=fileparts(filename);
        %outputfilename=sprintf('%s_IRDATA.dat',baseName);
        %fid_out=fopen(outputfilename,'w');
        %for i=1:length(wavenumber)
        %    fprintf(fid_out,'%.4f\t%.6e\n',wavenumber(i),intensity(i));
        %end

    ir_data(ii).wavenumber=wavenumber;
    ir_data(ii).intensity=intensity;

    %ouput number of conformers
    num_conf=length(File);
end

end