function [N,Dnz,Dne,Dnx] = shape_par_to_eta(zita,xi,zita_gp,eta_gp,xi_gp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHAPE_PAR_TO_ETA
%
% Calcola la funzione di forma di un nodo intermedio dell'elemento Hexa20
% posto su uno spigolo parallelo alla direzione naturale eta.
%
% Il nodo considerato ha coordinata naturale nulla lungo eta:
%
%       eta = 0
%
% mentre le coordinate naturali xi e zita valgono ±1. La funzione viene
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
% Federico Nanni, Samuele Tocco. 09-2026

N=1/4*(1-eta_gp^2)*(1+xi*xi_gp)*(1+zita*zita_gp);
Dne=-1/2*eta_gp*(1+xi_gp*xi)*(1+zita*zita_gp);
Dnx=1/4*xi*(1-eta_gp^2)*(1+zita*zita_gp);
Dnz=1/4*zita*(1-eta_gp^2)*(1+xi*xi_gp);
end