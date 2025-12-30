%initialize storage
wavenumber=[];
intensity=[];


%open file
fid=fopen('TFTFE_C3.out'); %REPLACE WITH NAME OF INPUT FILE

%what to look for
pattern='IR SPECTRUM';

%search for it and extract
while ~feof(fid)
    line=fgetl(fid);
    if contains(line,pattern)
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

%close the input file for good programming practice <3
fclose(fid);

%write data to an output file
fid_out=fopen('TFTFE_C3_IRDATA.dat','w'); %REPLACE WITH NAME OF OUTPUT
for i=1:length(wavenumber)
    fprintf(fid_out,'%.4f\t%.6f\n',wavenumber(i),intensity(i));
end

%close the output file for good programming practice <3
fclose(fid_out);