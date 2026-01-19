%Function for calculating population percentages for each conformer. Input
%is the number of conformers and the energ(y/ies) in Eh. Output is an array
%containing the population percentages

%author: ALimbo

function [pop]=pop_perc(num_conf,energies)

%initialize arrays
g=ones(1,num_conf); %degeneracy, if the degeneracy value for a particular conformer is >1, then it needs to be specified here
pop=zeros(1,num_conf);

%convert Energy values to joules
energies=energies*(4.359748199e-18);

%identify lowest energy
E_min=min(energies);

%constants
k=1.380649e-23;
T=298.15;

%partition function
z=0.0;
for i=1:num_conf
    z=z+g(i)*exp(-(energies(i)-E_min)/(k*T));
end

%final calculation
for i=1:num_conf
    pop(i)=(g(i)*exp(-(energies(i)-E_min)/(k*T)))/z;
end

end


