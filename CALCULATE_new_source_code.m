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
% calls a function named IR_DATA_EXTRACT
% num_conf: number of conformations found
% energies: energies (likely from ORCA output files, in HITRAN
% ir_data: infrared (IR) spectral data
% ("read ORCA output files and pull out all of the useful stuff")
[num_conf,energies,ir_data]=IR_DATA_EXTRACT();

% prints the statis/debugs message to the MATLAB Command Window 
% \n adds a new line 
%code debug print
fprintf('Input ORCA .out files read. Data extract successful \n')

% Prints a label descirbing what is about to be displayed 
% Eh = HTRANS units (common in quantum chem)
fprintf('Energies (in Eh) in conformational order: \n')

% displays the contents of the variable energies in the Command Window 
% results = a list/array of energies printed out 
disp(energies);


%Go to the correct directory, it's likely different from where the output
%files from the previous IR_DATA_EXTRACT function has called for
% opens the folder seelction dialog 
selectdir=uigetdir(pwd,'IMPORTANT: select directory where pop_perc.m is saved');
%CHANGED CODE HERE (used to be cd(selectdir)
addpath(selectdir)
savepath

%calculate population percentages
% calls the function pop_perc using the num_conf and energies command
% stores the returned population fractions in pop often these are used to
% sum to 1
pop=pop_perc(num_conf,energies);

%code debug print
fprintf('Population percentages: \n')
% prints each value in pop to 10 decimal places each on a new line 
fprintf('%.10f\n',pop);
% prints a reminder message
fprintf('The sum of the population percentages should be 1. \n')
% computes sum(pop) and prints it with 4 decimal places 
% the \n\n adds two new lines for spacing. 
fprintf('Calculated sum = %.4f\n\n',sum(pop))

%read in HITRAN data
% calls read_HITRAN ('yes') which will read HITRAN reference data and/or
% creates output files needed later for comparison 
read_HITRAN('yes'); %CHANGE TO 'NO' IF NOT COMPARING TO HITRAN DATA OR CROSS SECTION DATA NOT AVAILABLE

%Go to the correct directory, it's likely different from where the output
%files from the previous read_HITRAN function has called for
selectdir=uigetdir(pwd,'IMPORTANT: select directory where THEORETICAL_CROSS_SECTION.m is saved');
addpath(selectdir);
addpath(genpath(selectdir));
disp(selectdir)

%calculate theoretical cross section using resolution
FWHM=10; %change value if needed
SPEC=THEORETICAL_CROSS_SECTION(num_conf,pop,FWHM,'lorentzian',ir_data);