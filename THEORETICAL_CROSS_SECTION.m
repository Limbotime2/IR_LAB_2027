weight=[.832358451254,.00136797200712,.166273576739]; %replace with weights here - ORDER MATTERS
FWHM=10;
method='lorentzian';

SPEC = generate_spec_conformers(weight,FWHM,method);

%*************************************************************************

%Matlab function that generates an absorption cross section spectrum from quantum calculations values.
% The codes will ask to select column files with the wavenumbers as X axis and the integrated intensities in cm/molecule as Y axis.

% Input
%  * weight is a vector containing the fractional population of each conformer. Be sure to enter the weight in the same order your files will be opened.
%  * FWHM is the Full Width at Half Maximum of the band in cm^{-1}. A value of 10 is recommended to start. The value can then be adjusted when comparing to experimental data.
%  * method: Three functions are possible: 'gaussian', 'lorentzian' or 'voigt'. 
%  * (Optional) ratio indicates the fraction Lorentzian versus Gaussian in the Voigt function (ratio =1 : pure lorentzian). Default value: ratio = 0.5
%  * (Optional) a and b are the calibration factors of the wavenumbers when compared to experimental data X(calibrated) = a*X(calculated)+b. Default values: a = 1, b = 0.

% Output: SPEC is 1x2 column file representing the absorption cross-sections as a function of the wavenumber. It can be saved separately.

% Author: KLB, modified by Aziell Paul S Limbo

function SPEC = generate_spec_conformers(weight,FWHM,method,ratio,a,b)

if nargin<6
    ratio=0.5;
end
if nargin<4
    a=1;b=0;
end

selectdir=uigetdir(pwd,'Select directory containing .dat files');
cd(selectdir);
filepattern=fullfile(selectdir,'*.dat');

[File,path]=uigetfile(filepattern,'Select .dat files','MultiSelect','on');

x = 0:0.1:3500;
xs=zeros(length(x),length(File));Y=zeros(length(x),1);
%hold on
for ii=1:length(File) % Number of files

filename=char(File(ii));
F = [filename,' with a weight of',num2str(weight(ii))];
disp(F)

fid = fopen(filename,'r');
Mydata = textscan(fid,'%f %f','HeaderLines',0); % Skip header lines
fclose(fid);
Mydata=cell2mat(Mydata); size(Mydata);

numpoints = max(size(Mydata(:,1)));

HWHM=FWHM/2;
sigma = (1/2.355)*FWHM;
spec = 0;
% Calibration
Mydata(:,1)=Mydata(:,1)*a+b;
if strcmp('gaussian',method)
     for n=1:numpoints
        spec = spec + Mydata(n,2).*exp(-((x-Mydata(n,1)).^2)/(2*(sigma).^2))/(sigma*sqrt(2*pi));
     end
elseif strcmp('lorentzian',method)
        for n=1:numpoints
            spec = spec + Mydata(n,2).*(1/pi).*(HWHM./((((x-Mydata(n,1)).^2)+HWHM.^2)));
        end
else
        for n=1:numpoints
            spec = spec + Mydata(n,2).*(ratio*(1/pi).*(HWHM./((((x-Mydata(n,1)).^2)+HWHM.^2)))+(1-ratio)*exp(-((x-Mydata(n,1)).^2)/(2*(sigma).^2))/(sigma*sqrt(2*pi)));
        end

end
xs(:,ii)=spec;

Y=Y+weight(ii).*xs(:,ii);
end
Y=Y*100000/6.022e23;

%plot(x,Y)
output_id=fopen('theoretical_CS.dat','w');
for i=1:length(x)
    fprintf(output_id,'%.4f\t%.6e\n', x(i), Y(i));
end
fclose(output_id);

SPEC=[x',Y];

end