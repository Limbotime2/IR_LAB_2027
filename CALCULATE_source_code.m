%Program that produces theoretical cross section from ORCA calculations.

%Author: Alimbo

%INPUT: 

%   1. .out File(s) from ORCA
%   2. [Optional] HITRAN .xsc file, default is on

%OUTPUT:

%   1. Wavenumber vs. Intensity coefficients .dat files for each conformer
%   2. [Optional] HITRAN's experimental data in two column format, default
%   is on
%   3. Wavenumber vs cross section intensities .dat file

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%IMPORTANT - USER INSTRUCTIONS: 

% IF HITRAN DATA IS NOT AVAILABLE, CHANGE
%'yes' TO 'no' ON LINE 52. USE 'no' if a REPEATED READING OF DATA IS NOT NEEDED

% CHANGE/USE INPUT PARAMETERS ON LINE 61. THE FUNCTION IS DECLARED AS:
% function SPEC = THEORETICAL_CROSS_SECTION(num_conf,weight,FWHM,method,ir_data,ratio)

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%Extract and store
[num_conf,energies,ir_data]=IR_DATA_EXTRACT();

%code debug print
fprintf('Input ORCA .out files read. Data extract successful \n')
fprintf('Energies (in Eh) in conformational order: \n')
disp(energies);

%Go to the correct directory, it's likely different from where the output
%files from the previous IR_DATA_EXTRACT function has called for
selectdir=uigetdir(pwd,'IMPORTANT: select directory where pop_perc.m is saved');
cd(selectdir);

%calculate population percentages
pop=pop_perc(num_conf,energies);

%code debug print
fprintf('Population percentages: \n')
fprintf('%.10f\n',pop);
fprintf('The sum of the population percentages should be 1. \n')
fprintf('Calculated sum = %.4f\n\n',sum(pop))

%read in HITRAN data
read_HITRAN('yes'); %CHANGE TO 'NO' IF NOT COMPARING TO HITRAN DATA OR CROSS SECTION DATA NOT AVAILABLE

%Go to the correct directory, it's likely different from where the output
%files from the previous read_HITRAN function has called for
selectdir=uigetdir(pwd,'IMPORTANT: select directory where THEORETICAL_CROSS_SECTION.m is saved');
cd(selectdir);

%calculate theoretical cross section using resolution
FWHM=10; %change value if needed
SPEC=THEORETICAL_CROSS_SECTION(num_conf,pop,FWHM,'lorentzian',ir_data);