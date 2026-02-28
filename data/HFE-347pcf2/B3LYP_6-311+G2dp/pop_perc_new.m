%Function for calculating population percentages for each conformer. Input
%is the number of conformers and the energ(y/ies) in Eh. Output is an array
%containing the population percentages

%author: ALimbo

function [pop_ent,pop_GFE]=pop_perc(num_conf,num_temp,T,enthalpy,GFE)

%initialize arrays
g=ones(1,num_conf); %degeneracy, if the degeneracy value for a particular conformer is >1, then it needs to be specified here
pop_ent=zeros(num_temp,num_conf);
pop_GFE=zeros(num_temp,num_conf);
E_min_ent=zeros(1,num_temp);
E_min_GFE=zeros(1,num_temp);

%convert values to joules
conversion=(4.359748199E-18);
enthalpy=enthalpy*conversion;
GFE=GFE*conversion;

%constants
k=1.380649e-23;


for j=1:num_temp
    %identify lowest energy for each temperature
    E_min_ent=min(enthalpy(:,j));
    E_min_GFE=min(GFE(:,j));
    %partition function
    z_ent=0.0;
    z_GFE=0.0;
    for i=1:num_conf
        z_ent=z_ent+g(i)*exp(-(enthalpy(i,j)-E_min_ent)/(k*T(j)));
        z_GFE=z_GFE+g(i)*exp(-(GFE(i,j)-E_min_GFE)/(k*T(j)));
    end
    %final calculation
    for i=1:num_conf
        pop_ent(i,j)=(g(i)*exp(-(enthalpy(i,j)-E_min_ent)/(k*T(j))))/z_ent;
        pop_GFE(i,j)=(g(i)*exp(-(GFE(i,j)-E_min_GFE)/(k*T(j))))/z_GFE;
    end
end

end


