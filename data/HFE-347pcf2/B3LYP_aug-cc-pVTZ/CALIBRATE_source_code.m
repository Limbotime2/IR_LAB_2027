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
i=3; %Enter temperature index value
which_energy='GFE'; %enter 'ent' or 'GFE' (case sensitive)
x_orca=[3067.8,581.8,646.9,771.3,840.3,969.5];          %wavenumber from orca calculation, replace with wanted values
y_orca=[1.45277E-19,1.58687E-19,2.42836E-19,5.6213E-19,4.91047E-19,5.42776E-19];
x_hitr=[2990.07,588.004,659.388,768.799,847.927,970.566];          %wavenumber from hitran database, replace with wanted values
y_hitr=[1.381E-19,1.436E-19,2.071E-19,1.863E-19,3.021E-19,2.663E-19];

%load previously saved variables from CALCULATE_new_source_code.m
load("intermediary_variables.mat")

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
[File,path]=uigetfile('*.dat','Select theoretical cross section file');
filename=char(File);
fid=fopen(filename,'r');
data=textscan(fid,'%f %f');
fclose(fid);
x_original=data{1};
y=data{2};
x_calibrated=a*x_original+b;
AA=y_orca*FWHM;
FWHM_opt=sum(AA.^2)/sum(AA.*y_hitr);

disp(FWHM_opt);

%recalculate theoretical cross section
if strcmp('ent',which_energy)    
    SPEC=THEORETICAL_CROSS_SECTION(num_conf,T(i),which_energy,pop_ent(:,i),FWHM_opt,'lorentzian',ir_data,a,b,'yes');
else
    SPEC=THEORETICAL_CROSS_SECTION(num_conf,T(i),which_energy,pop_GFE(:,i),FWHM_opt,'lorentzian',ir_data,a,b,'yes');
end

%calculate R^2
y_pred=a*x_orca+b;
y_mean=mean(x_hitr);
SST=sum((x_hitr-y_mean).^2);
SSR=sum((x_hitr-y_pred).^2);
R2=1-SSR/SST;
