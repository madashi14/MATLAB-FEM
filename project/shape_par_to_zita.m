function [N,Dnz,Dne,Dnx] = shape_par_to_zita(eta,xi,eta_gp,zita_gp,xi_gp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHAPE_PAR_TO_ZITA
%
% Calcola la funzione di forma di un nodo intermedio dell'elemento Hexa20
% posto su uno spigolo parallelo alla direzione naturale zita.
%
% Il nodo considerato ha coordinata naturale nulla lungo zita:
%
%       zita = 0
%
% mentre le coordinate naturali xi ed eta valgono ±1. La funzione viene
% valutata nel punto di Gauss:
%
%       xi_gp, eta_gp, zita_gp
%
% OUTPUT:
%   N   : valore della funzione di forma del nodo intermedio
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
% Federico Nanni, Samuele Tocco. 07-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=1/4*(1-zita_gp^2)*(1+xi*xi_gp)*(1+eta*eta_gp);
Dnz=-1/2*zita_gp*(1+xi_gp*xi)*(1+eta*eta_gp);
Dnx=1/4*xi*(1-zita_gp^2)*(1+eta*eta_gp);
Dne=1/4*eta*(1-zita_gp^2)*(1+xi*xi_gp);
end