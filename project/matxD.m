function D = matxD(v,E)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATXD
%
% Calcola la matrice costitutiva elastica D per un materiale isotropo
% lineare in campo tridimensionale.
%
% La matrice D lega tensioni e deformazioni tramite la legge di Hooke:
%
%       sigma = D * epsilon
%
% INPUT:
%   v : coefficiente di Poisson
%   E : modulo elastico di Young
%
% OUTPUT:
%   D : matrice costitutiva elastica 6x6
%
% La matrice viene utilizzata nel calcolo della rigidezza elementare:
%
%       Ke = int_V B' * D * B dV
%
% Federico Nanni, Samuele Tocco. 05-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

zer=zeros(3); k=(1-2*v)/2;
vec=[k,k,k];
dg=diag(vec);
mat=[1-v v v; v 1-v v; v v 1-v];
mat2=[mat zer; zer dg];
a=E/((1+v)*(1-2*v));
D=a*mat2;
end

