% Convert raw spa files from the iS50 to readable prn files. The first column contains the
% wavenumbers, the second column contains the absorption values.
% Save the file using the same filename than the original with the
% extension prn.
% Unknow original author; modified and adapted by KLB (last update May 2025)

[Filenames,pathname]=uigetfile({'*.spa','Thermo Spectrum (*.spa)'}, ...
       'MultiSelect','on','Select Spectra Files...');
cd (pathname);  % Change to directory where the spectrum files are.
if ischar(Filenames)== 1           % If only 1 file is selected, Filenames
    NumSpectra = 1;                % is a char instead of a cell of chars,
else                               % which troubles fopen.
    NumSpectra =length(Filenames);
end

for i = 1:NumSpectra 
    DataStart=0;
    CommentStart=0;
    if NumSpectra == 1       
        filename=Filenames{i};fid=fopen(Filenames,'r');
    else
        filename=Filenames{i}; fid=fopen(filename,'r');
    end


% Find the number of points
fseek(fid,hex2dec('234'),'bof'); Number_of_DataPoints=fread(fid,1,'int32'); 

%Find the maximum and minimum of Wavenumber (cm-1) range; create the wavenumber column 
fseek(fid,576,'bof'); 
Maximum_Wavenumber=fread(fid,1,'single'); 
Minimum_Wavenumber=fread(fid,1,'single'); 
Interval=(Maximum_Wavenumber-Minimum_Wavenumber)/(Number_of_DataPoints-1); 
Wavenumber=linspace(Minimum_Wavenumber,Maximum_Wavenumber,Number_of_DataPoints).';

%Find the Y-Axis for Transmittance
fseek(fid,hex2dec('360'),'bof'); Y_Label=char(fread(fid,14,'uchar')'); 
% The following offset for the Nicolet iS50 FTIR Spectrometer spectral data has been found through trial and error. 
fseek(fid,1116,'bof'); spectrum=fread(fid,Number_of_DataPoints,'single'); spectrum=flip(spectrum);
data=[Wavenumber,spectrum];
plot(Wavenumber,spectrum); xlabel('Wavenumber /cm^{-1}'); ylabel('Absorption');hold on 
xn=findstr(filename,'.');
file_out=[filename(1:xn),'prn']
save(file_out, 'data', '-ascii', '-double');
%disp('Converted File:',file_out)
end 
hold off