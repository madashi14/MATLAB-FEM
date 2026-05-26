function [Jprod,N] = crea_N_dN(xi_gp,eta_gp,zita_gp,ndxel)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREA_N_DN
%
% Calcola le funzioni di forma dell'elemento Hexa20 e le rispettive
% derivate rispetto alle coordinate naturali nel punto di Gauss assegnato.
%
% La funzione usa le coordinate naturali dei 20 nodi dell'elemento:
%
%       xi, eta, zita ∈ [-1, 1]
%
% e distingue tra:
%   - nodi di spigolo, con una coordinata naturale nulla;
%   - nodi di vertice, con coordinate naturali pari a ±1.
%
% OUTPUT:
%   Jprod : matrice 3x20 contenente le derivate delle funzioni di forma
%           rispetto alle coordinate naturali:
%
%           Jprod = [dN/dxi;
%                    dN/deta;
%                    dN/dzita]
%
%   N     : matrice 3x60 delle funzioni di forma, costruita considerando
%           i tre gradi di libertà traslazionali per ogni nodo:
%
%           ux, uy, uz
%
% La matrice N viene poi utilizzata per il calcolo della matrice di massa:
%
%       Me = int_V rho * N' * N dV
%
% mentre Jprod viene usata per costruire il Jacobiano e successivamente
% la matrice B delle deformazioni.
%
% Riferimento bibliografico:
%   Dhatt, G., & Touzot, G.
%   The Finite Element Method Displayed, Capitolo 2.
%
% Federico Nanni, Samuele Tocco. 05-2026
nat_coord=[-1 -1 -1
    0 -1 -1
    1 -1 -1
    1 0 -1
    1 1 -1
    0 1 -1
    -1 1 -1
    -1 0 -1
    -1 -1 0
    1 -1 0
    1 1 0
    -1 1 0
    -1 -1 1
    0 -1 1
    1 -1 1
    1 0 1
    1 1 1
    0 1 1
    -1 1 1
    -1 0 1];
 Jprod = zeros(3,20);
 N = zeros(3,60);
for q=1:ndxel
            if nat_coord(q,1)== 0 
                    [Ns,Dnz,Dne,Dnx]=shape_par_to_xi(nat_coord(q,3),nat_coord(q,2),zita_gp,eta_gp,xi_gp);
            elseif nat_coord(q,2)==0
                    [Ns,Dnz,Dne,Dnx]=shape_par_to_eta(nat_coord(q,3),nat_coord(q,1),zita_gp,eta_gp,xi_gp);
            elseif nat_coord(q,3)==0
                    [Ns,Dnz,Dne,Dnx]=shape_par_to_zita(nat_coord(q,2),nat_coord(q,1),eta_gp,zita_gp,xi_gp);
             else
                    [Ns,Dnz,Dne,Dnx]=shape_corner(nat_coord(q,3),nat_coord(q,2),nat_coord(q,1),zita_gp,eta_gp,xi_gp);
            end
     
     N(1,3*q-2)=Ns;
     N(2,3*q-1)=Ns;
     N(3,3*q)=Ns;
     Jprod(1,q)=Dnx;
     Jprod(2,q)=Dne;
     Jprod(3,q)=Dnz;
 end

end

