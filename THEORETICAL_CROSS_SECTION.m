%Matlab function that generates an absorption cross section spectrum from quantum calculations values.
% The codes will ask to select column files with the wavenumbers as X axis and the integrated intensities in cm/molecule as Y axis.

% Input
%  * weight is a vector containing the fractional population of each conformer. Be sure to enter the weight in the same order your files will be opened.
%  * FWHM is the Full Width at Half Maximum of the band in cm^{-1}. A value of 10 is recommended to start. The value can then be adjusted when comparing to experimental data.
%  * method: Three functions are possible: 'gaussian', 'lorentzian' or 'voigt'. 
%  * (Optional) ratio indicates the fraction Lorentzian versus Gaussian in the Voigt function (ratio =1 : pure lorentzian). Default value: ratio = 0.5
%  * (Optional) a and b are the calibration factors of the wavenumbers when compared to experimental data X(calibrated) = a*X(calculated)+b. Default values: a = 1, b = 0.

% Output: SPEC is 1x2 column file representing the absorption
% cross-sections as a function of the wavenumber. It can be saved separately.
% Original function name: generate_spec_conformers

% Original Author: KLB, modified by Aziell Paul S Limbo, original code is
% available in Github repo

function SPEC = THEORETICAL_CROSS_SECTION(num_conf,weight,FWHM,method,ir_data,ratio)

if nargin<6
    ratio=0.5;
end

x = 0:0.1:3500;
xs=zeros(length(x),num_conf);Y=zeros(length(x),1);

for ii=1:num_conf

    Mydata=[ir_data(ii).wavenumber(:),ir_data(ii).intensity(:)]; size(Mydata);

    numpoints = max(size(Mydata(:,1)));

    HWHM=FWHM/2;
    sigma = (1/2.355)*FWHM;
    spec = 0;
    
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
selectdir=uigetdir(pwd,'Select directory to save output theoretical_CS.dat file');
addpath(selectdir)
savepath
output_id=fopen('theoretical_CS.dat','w');
for i=1:length(x)
    fprintf(output_id,'%.4f\t%.6e\n', x(i), Y(i));
end
fclose(output_id);

SPEC=[x',Y];

end