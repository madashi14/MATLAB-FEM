function [N,Dnz,Dne,Dnx] = shape_par_to_xi(zita,eta,zita_gp,eta_gp,xi_gp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHAPE_PAR_TO_XI
%
% Calcola la funzione di forma di un nodo intermedio dell'elemento Hexa20
% posto su uno spigolo parallelo alla direzione naturale xi.
%
% Il nodo considerato ha coordinata naturale nulla lungo xi:
%
%       xi = 0
%
% mentre le coordinate naturali eta e zita valgono ±1. La funzione viene
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
% Federico Nanni, Samuele Tocco. 08-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=1/4*(1-xi_gp^2)*(1+eta*eta_gp)*(1+zita*zita_gp);
Dnx=-1/2*xi_gp*(1+eta_gp*eta)*(1+zita*zita_gp);
Dne=1/4*eta*(1-xi_gp^2)*(1+zita*zita_gp);
Dnz=1/4*zita*(1-xi_gp^2)*(1+eta*eta_gp);
end