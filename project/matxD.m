function D = matxD(v,E)
% MATXD
% Calcola la matrice costitutiva elastica D (6x6) per un materiale
% isotropo tridimensionale, in funzione del coefficiente di Poisson v
% e del modulo di Young E.
%
% La matrice D lega il vettore delle deformazioni alle tensioni:
%   sigma = D * epsilon
% con:
%   epsilon = [eps_x, eps_y, eps_z, gamma_xy, gamma_yz, gamma_xz]^T
%   sigma   = [sig_x, sig_y, sig_z, tau_xy, tau_yz, tau_xz]^T
%
% INPUT:
%   v : coefficiente di Poisson
%   E : modulo di Young [Pa]
%
% OUTPUT:
%   D : matrice costitutiva elastica (6x6) [Pa]

zer=zeros(3); k=(1-2*v)/2;
vec=[k,k,k];
dg=diag(vec);
mat=[1-v v v; v 1-v v; v v 1-v];
mat2=[mat zer; zer dg];
a=E/((1+v)*(1-2*v));
D=a*mat2;
end

