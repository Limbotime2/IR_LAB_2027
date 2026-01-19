%Program that calculates the calibration parameters from program
%CALCULATE_source_code.m

%author: ALimbo

%HOW TO USE:

%   1. Select the peaks you wish to 'line up' manually, and note their
%   wavenumbers
%   2. For ORCA's wavenumbers, list them in x_orca
%   3. For HITRAN's wavenumbers, list them in x_hitr
%   4. The order doesn't necessarily matter, but they do need to be paired
%   accordingly. The first element of each array corresponds to the first
%   peak you wish to calibrate, the second element of each array
%   corresponds to the second peak, etc.
%   5. It is suggested to use around 3-10 peaks
%   6. Program will ask for input of the theoretical cross section .dat
%   file from CALCULATE_source_code.m
%   7. Output is a new .dat file with new calibration parameters applied.
%   The new parameters is also specified in the output file's comments.

%input data
x_orca=[3088.2;1464.4;1441.6;1166.6;1276.5;978.1];          %peaks from orca calculation, replace with wanted values
x_hitr=[2999.2011;1436.4430;1418.0923;1144.6405;1256.1908;970.7764]; %peaks from hitran database, replace with wanted values

%compare R^2 before calibration
a_before=1;
b_before=0;
y_pred_before=a_before*x_orca+b_before;  % This is just x_orca itself
y_mean=mean(x_hitr);
SST=sum((x_hitr-y_mean).^2);
SSR_before=sum((x_hitr-y_pred_before).^2);
R2_before=1-SSR_before/SST;

%calculate
N=length(x_orca);
A=[ sum(x_orca.^2) sum(x_orca)
    sum(x_orca)  N];
B=[ sum(x_orca.*x_hitr)
    sum(x_hitr)];
x=A\B;
a=x(1);
b=x(2);

%apply to data
selectdir=uigetdir(pwd,'Select directory containing theoretical cross section file');
cd(selectdir);
filepattern=fullfile(selectdir,'*.dat');
[File,path]=uigetfile(filepattern,'Select theoretical cross section file');
filename=char(File);
fid=fopen(filename,'r');
data=textscan(fid,'%f %f');
fclose(fid);
x_original=data{1};
y=data{2};
x_calibrated=a*x_original+b;

%calculate R^2
y_pred=a*x_orca+b;
y_mean=mean(x_hitr);
SST=sum((x_hitr-y_mean).^2);
SSR=sum((x_hitr-y_pred).^2);
R2=1-SSR/SST;

%write out to data
selectdir=uigetdir(pwd,'Select directory to save output theoretical_CS_CALIBRATED.dat file');
cd(selectdir);
output_id=fopen('theoretical_CS_CALIBRATED.dat','w');
fprintf(output_id,'# Calibration parameters: %.4f\t%.4f\n',a,b);
fprintf(output_id,'# R^2 before calibration: %.6f\n',R2_before);
fprintf(output_id,'# R^2 after calibration : %.6f\n',R2);
for i=1:length(x_calibrated)
    fprintf(output_id,'%.4f\t%.6e\n', x_calibrated(i), y(i));
end
fclose(output_id);