selectdir=uigetdir(pwd,'Select directory containing ORCA output files');
cd(selectdir);
filepattern=fullfile(selectdir,'*.out');
[File,path]=uigetfile(filepattern,'Select ORCA Output Files','MultiSelect','on');

%initialize arrays
energies=[];
g=ones(1,length(File)); %degeneracy, if the degeneracy value for a particular conformer is >1, then it needs to be specified
pop=zeros(1,length(File));

for ii=1:length(File)
    filename=char(File(ii));
    fid = fopen(filename,'r');

    %what to look for
    pattern='Total Enthalpy'; %can change to look for Gibbs free energy if found reliable
    
    %extract value
    while ~feof(fid)
        line=fgetl(fid);
        if contains(line,pattern)
            numbers=regexp(line,'-?\d+\.\d+','match');
            if ~isempty(numbers)
                energy_val=str2double(numbers{end});;
            end
            break;
        end
    end

    %close the input file
    fclose(fid);

    %store values in an array
    energies(end+1)=energy_val;
end

%convert Energy values to joules
energies=energies*(4.359748199e-18);

%identify lowest energy
E_min=min(energies);

%constants
k=1.380649e-23;
T=298.15;

%partition function
z=0.0;
for i=1:length(File)
    z=z+g(i)*exp(-(energies(i)-E_min)/(k*T));
end

%final calculation
for i=1:length(File)
    pop(i)=(g(i)*exp(-(energies(i)-E_min)/(k*T)))/z;
end

fprintf('%.10f\n',pop);
disp(sum(pop));


