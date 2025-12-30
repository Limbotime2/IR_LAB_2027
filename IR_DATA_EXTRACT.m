[File]=uigetfile('*.out','Select ORCA Output Files','MultiSelect','on');

for ii=1:length(File)

    filename=char(File(ii));

    fid = fopen(filename,'r');

    %initialize storage
    wavenumber=[];
    intensity=[];

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
    [~,baseName,~]=fileparts(filename);
    outputfilename=sprintf('%s_IRDATA.dat',baseName);
    fid_out=fopen(outputfilename,'w');
    for i=1:length(wavenumber)
        %convert intensity values to cm/molecule
        intensity(i)=intensity(i)*(100000/(6.02214129e23));
        fprintf(fid_out,'%.4f\t%.6e\n',wavenumber(i),intensity(i));
    end

    %close the output file for good programming practice <3
    fclose(fid_out);

    fprintf('Successfully created for %s\n',outputfilename)
end