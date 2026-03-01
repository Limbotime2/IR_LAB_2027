function [cross_section]=Cross_Section_Kelvin(data_empty_cell,data_full_cell,pressure,temperature)
%function for calculate the CROSS SECTION
% it will ratio the full and the empity cell spectra and aply the appropriated constants
%uses as input data:
%   empty cell spectra: data_empty_cell
%   full cell spectra: data_full_cell

N = 2.6868E19;  %Loschmidt constant (molecules/cm3)
L = 10.00;     %length of cell (cm)
p = 101325.0; %reference pressure (Pa)
t = 273.15; %reference temperature (K)

%converting pressure from Toor to Pascal:
% 1 atm = 760 Torr
% 1 atm=1.01325e5 Pa exact
% 1 Torr=133.3224 Pa
convertion_factor=133.3224;
pressure=pressure*convertion_factor;

%converting temperature from Celsius to K
%temperature=temperature+273.15;

%calculating cross section

rho = 1.0/(((pressure/p)*(t/temperature))*N*L); % inverse of the (molecular density times L)

x=data_full_cell./data_empty_cell;
index_negative=find(x<0.0);
x(index_negative)=1.0;

cross_section =(-log(x)*rho)';

return;