clear all
% Calculate the instantaneous or adjusted radiative efficiency from a cross-section spectrum
% Author: K. Le Bris, modified by A. Limbo

%Enter the cross-section spectrum  (first column: wavenumber in cm-1, second column: cross-section in cm^2/molecule) 
fid = fopen('theoretical_CS_340_GFE_CALIBRATED.dat');
% Read two floating point numbers per line, skipping lines that start with #
data = textscan(fid, '%f %f', 'CommentStyle', '#', 'CollectOutput', true);
fclose(fid);
file1 = data{1};  % Should be Nx2 matrix
lifetime =6.1 % lifetime in years



% Enter the instantaneous or adjusted Pinnock curve (first column: wavenumber in cm-1, second column: radiative forcing in mW m^-2 cm (per 10e-18 cm^2 per molecule) 
Pinnock= load('NewPinnock.dat'); 

x=file1(:,1);


index=find(x>0);x=x(index);data =file1(:,2);
xmin=round(min(x));
xmax=round(max(x));
if xmax>3000, xmax=3000; end;
 
for i = xmin:xmax-1
    xlow=i;
    xhigh=i+1;
    xi=find(x>xlow & x<xhigh);
    v(i+1-xmin)=i+0.5;
    
        yj=mean(data(xi));
     
        y(i+1-xmin)=yj;
     
   
end

ind=find(Pinnock(:,1)>=xmin&Pinnock(:,1)<xmax);
    RE=y'.*Pinnock(ind,2)*1E18/1000;
    InsRE=trapz(v',RE) % instantaneous RE in W/m^2

    % Calculation of the lifetime adjusted RE
    a = 2.962; b = 0.9312; c = 2.994; d = 0.9302;% Empirical values from Hodnebrog 2020

 Lifetime_adj= a*lifetime^b/(1+c*lifetime^d)
 Adusted_RE =InsRE*Lifetime_adj
   % Lifetime adjusted RE can be found if the lifetime is know

