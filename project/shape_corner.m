function [N,Dnz,Dne,Dnx] = shape_corner(zita,eta,xi,zita_gp,eta_gp,xi_gp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHAPE_CORNER
%
% Calcola la funzione di forma di un nodo di vertice dell'elemento Hexa20
% e le sue derivate rispetto alle coordinate naturali.
%
% Il nodo considerato è identificato dalle sue coordinate naturali:
%
%       xi, eta, zita = ±1
%
% mentre la funzione viene valutata nel punto di Gauss:
%
%       xi_gp, eta_gp, zita_gp
%
% OUTPUT:
%   N   : valore della funzione di forma del nodo di vertice
%   Dnx : derivata di N rispetto a xi
%   Dne : derivata di N rispetto a eta
%   Dnz : derivata di N rispetto a zita
%
% La formulazione segue le funzioni di forma serendipity per elementi
% esaedrici quadratici a 20 nodi, come riportato in:
%
%   Dhatt, G., & Touzot, G.
%   The Finite Element Method Displayed, Capitolo 2.
%
% Federico Nanni, Samuele Tocco. 06-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=1/8*(1+xi*xi_gp)*(1+eta*eta_gp)*(1+zita*zita_gp)*(-2+xi*xi_gp+eta*eta_gp+zita_gp*zita);
Dnx=1/8*xi*(1+eta*eta_gp)*(1+zita*zita_gp)*(-1+2*xi*xi_gp+eta*eta_gp+zita_gp*zita);
Dne=1/8*eta*(1+xi*xi_gp)*(1+zita*zita_gp)*(-1+xi*xi_gp+2*eta*eta_gp+zita_gp*zita);
Dnz=1/8*zita*(1+eta*eta_gp)*(1+xi*xi_gp)*(-1+xi*xi_gp+eta*eta_gp+2*zita_gp*zita);

end