

function [Jprod,N] = crea_N_dN_new(xi_gp, eta_gp, zita_gp)
% CREA_N_DN_NEW (versione esplicita ottimizzata)
% Calcola le 20 funzioni di forma e le 60 derivate dell'elemento Hexa20
% nel punto di Gauss (xi_gp, eta_gp, zita_gp), tutte scritte esplicitamente
% senza loop, per massima efficienza numerica.
%
% Le formule seguono la serendipity quadratica dell'Hexa20:
%   - Nodi di vertice: N = (1/8)*(1+xi_0*xi)*(1+eta_0*eta)*(1+zita_0*zita)*(-2+xi_0*xi+eta_0*eta+zita_0*zita)
%   - Nodi medi:       N = (1/4)*(1-xi^2)*(1+eta_0*eta)*(1+zita_0*zita)  (e simili)
%
% INPUT:
%   xi_gp, eta_gp, zita_gp : coordinate naturali del punto di Gauss
%
% OUTPUT:
%   Jprod : [3 x 20] derivate delle funzioni di forma rispetto a xi, eta, zita
%   N     : [3 x 60] funzioni di forma espanse sui 3 gdl traslazionali per nodo


Jprod = zeros(3,20);
N     = zeros(3,60);

% --- NODO 1: (-1,-1,-1) vertice ---
N1   =  1/8*(1-xi_gp)*(1-eta_gp)*(1-zita_gp)*(-2-xi_gp-eta_gp-zita_gp);
dN1x = -1/8*(1-eta_gp)*(1-zita_gp)*(-1-2*xi_gp-eta_gp-zita_gp);
dN1e = -1/8*(1-xi_gp) *(1-zita_gp)*(-1-xi_gp-2*eta_gp-zita_gp);
dN1z = -1/8*(1-eta_gp)*(1-xi_gp) *(-1-xi_gp-eta_gp-2*zita_gp);

% --- NODO 2: (0,-1,-1) medio ||xi ---
N2   =  1/4*(1-xi_gp^2)*(1-eta_gp)*(1-zita_gp);
dN2x = -1/2*xi_gp*(1-eta_gp)*(1-zita_gp);
dN2e = -1/4*(1-xi_gp^2)*(1-zita_gp);
dN2z = -1/4*(1-xi_gp^2)*(1-eta_gp);

% --- NODO 3: (1,-1,-1) vertice ---
N3   =  1/8*(1+xi_gp)*(1-eta_gp)*(1-zita_gp)*(-2+xi_gp-eta_gp-zita_gp);
dN3x =  1/8*(1-eta_gp)*(1-zita_gp)*(-1+2*xi_gp-eta_gp-zita_gp);
dN3e = -1/8*(1+xi_gp) *(1-zita_gp)*(-1+xi_gp-2*eta_gp-zita_gp);
dN3z = -1/8*(1-eta_gp)*(1+xi_gp) *(-1+xi_gp-eta_gp-2*zita_gp);

% --- NODO 4: (1,0,-1) medio ||eta ---
N4   =  1/4*(1-eta_gp^2)*(1+xi_gp)*(1-zita_gp);
dN4x =  1/4*(1-eta_gp^2)*(1-zita_gp);
dN4e = -1/2*eta_gp*(1+xi_gp)*(1-zita_gp);
dN4z = -1/4*(1-eta_gp^2)*(1+xi_gp);

% --- NODO 5: (1,1,-1) vertice ---
N5   =  1/8*(1+xi_gp)*(1+eta_gp)*(1-zita_gp)*(-2+xi_gp+eta_gp-zita_gp);
dN5x =  1/8*(1+eta_gp)*(1-zita_gp)*(-1+2*xi_gp+eta_gp-zita_gp);
dN5e =  1/8*(1+xi_gp) *(1-zita_gp)*(-1+xi_gp+2*eta_gp-zita_gp);
dN5z = -1/8*(1+eta_gp)*(1+xi_gp) *(-1+xi_gp+eta_gp-2*zita_gp);

% --- NODO 6: (0,1,-1) medio ||xi ---
N6   =  1/4*(1-xi_gp^2)*(1+eta_gp)*(1-zita_gp);
dN6x = -1/2*xi_gp*(1+eta_gp)*(1-zita_gp);
dN6e =  1/4*(1-xi_gp^2)*(1-zita_gp);
dN6z = -1/4*(1-xi_gp^2)*(1+eta_gp);

% --- NODO 7: (-1,1,-1) vertice ---
N7   =  1/8*(1-xi_gp)*(1+eta_gp)*(1-zita_gp)*(-2-xi_gp+eta_gp-zita_gp);
dN7x = -1/8*(1+eta_gp)*(1-zita_gp)*(-1-2*xi_gp+eta_gp-zita_gp);
dN7e =  1/8*(1-xi_gp) *(1-zita_gp)*(-1-xi_gp+2*eta_gp-zita_gp);
dN7z = -1/8*(1+eta_gp)*(1-xi_gp) *(-1-xi_gp+eta_gp-2*zita_gp);

% --- NODO 8: (-1,0,-1) medio ||eta ---
N8   =  1/4*(1-eta_gp^2)*(1-xi_gp)*(1-zita_gp);
dN8x = -1/4*(1-eta_gp^2)*(1-zita_gp);
dN8e = -1/2*eta_gp*(1-xi_gp)*(1-zita_gp);
dN8z = -1/4*(1-eta_gp^2)*(1-xi_gp);

% --- NODO 9: (-1,-1,0) medio ||zita ---
N9   =  1/4*(1-zita_gp^2)*(1-xi_gp)*(1-eta_gp);
dN9x = -1/4*(1-zita_gp^2)*(1-eta_gp);
dN9e = -1/4*(1-zita_gp^2)*(1-xi_gp);
dN9z = -1/2*zita_gp*(1-xi_gp)*(1-eta_gp);

% --- NODO 10: (1,-1,0) medio ||zita ---
N10   =  1/4*(1-zita_gp^2)*(1+xi_gp)*(1-eta_gp);
dN10x =  1/4*(1-zita_gp^2)*(1-eta_gp);
dN10e = -1/4*(1-zita_gp^2)*(1+xi_gp);
dN10z = -1/2*zita_gp*(1+xi_gp)*(1-eta_gp);

% --- NODO 11: (1,1,0) medio ||zita ---
N11   =  1/4*(1-zita_gp^2)*(1+xi_gp)*(1+eta_gp);
dN11x =  1/4*(1-zita_gp^2)*(1+eta_gp);
dN11e =  1/4*(1-zita_gp^2)*(1+xi_gp);
dN11z = -1/2*zita_gp*(1+xi_gp)*(1+eta_gp);

% --- NODO 12: (-1,1,0) medio ||zita ---
N12   =  1/4*(1-zita_gp^2)*(1-xi_gp)*(1+eta_gp);
dN12x = -1/4*(1-zita_gp^2)*(1+eta_gp);
dN12e =  1/4*(1-zita_gp^2)*(1-xi_gp);
dN12z = -1/2*zita_gp*(1-xi_gp)*(1+eta_gp);

% --- NODO 13: (-1,-1,1) vertice ---
N13   =  1/8*(1-xi_gp)*(1-eta_gp)*(1+zita_gp)*(-2-xi_gp-eta_gp+zita_gp);
dN13x = -1/8*(1-eta_gp)*(1+zita_gp)*(-1-2*xi_gp-eta_gp+zita_gp);
dN13e = -1/8*(1-xi_gp) *(1+zita_gp)*(-1-xi_gp-2*eta_gp+zita_gp);
dN13z =  1/8*(1-eta_gp)*(1-xi_gp) *(-1-xi_gp-eta_gp+2*zita_gp);

% --- NODO 14: (0,-1,1) medio ||xi ---
N14   =  1/4*(1-xi_gp^2)*(1-eta_gp)*(1+zita_gp);
dN14x = -1/2*xi_gp*(1-eta_gp)*(1+zita_gp);
dN14e = -1/4*(1-xi_gp^2)*(1+zita_gp);
dN14z =  1/4*(1-xi_gp^2)*(1-eta_gp);

% --- NODO 15: (1,-1,1) vertice ---
N15   =  1/8*(1+xi_gp)*(1-eta_gp)*(1+zita_gp)*(-2+xi_gp-eta_gp+zita_gp);
dN15x =  1/8*(1-eta_gp)*(1+zita_gp)*(-1+2*xi_gp-eta_gp+zita_gp);
dN15e = -1/8*(1+xi_gp) *(1+zita_gp)*(-1+xi_gp-2*eta_gp+zita_gp);
dN15z =  1/8*(1-eta_gp)*(1+xi_gp) *(-1+xi_gp-eta_gp+2*zita_gp);

% --- NODO 16: (1,0,1) medio ||eta ---
N16   =  1/4*(1-eta_gp^2)*(1+xi_gp)*(1+zita_gp);
dN16x =  1/4*(1-eta_gp^2)*(1+zita_gp);
dN16e = -1/2*eta_gp*(1+xi_gp)*(1+zita_gp);
dN16z =  1/4*(1-eta_gp^2)*(1+xi_gp);

% --- NODO 17: (1,1,1) vertice ---
N17   =  1/8*(1+xi_gp)*(1+eta_gp)*(1+zita_gp)*(-2+xi_gp+eta_gp+zita_gp);
dN17x =  1/8*(1+eta_gp)*(1+zita_gp)*(-1+2*xi_gp+eta_gp+zita_gp);
dN17e =  1/8*(1+xi_gp) *(1+zita_gp)*(-1+xi_gp+2*eta_gp+zita_gp);
dN17z =  1/8*(1+eta_gp)*(1+xi_gp) *(-1+xi_gp+eta_gp+2*zita_gp);

% --- NODO 18: (0,1,1) medio ||xi ---
N18   =  1/4*(1-xi_gp^2)*(1+eta_gp)*(1+zita_gp);
dN18x = -1/2*xi_gp*(1+eta_gp)*(1+zita_gp);
dN18e =  1/4*(1-xi_gp^2)*(1+zita_gp);
dN18z =  1/4*(1-xi_gp^2)*(1+eta_gp);

% --- NODO 19: (-1,1,1) vertice ---
N19   =  1/8*(1-xi_gp)*(1+eta_gp)*(1+zita_gp)*(-2-xi_gp+eta_gp+zita_gp);
dN19x = -1/8*(1+eta_gp)*(1+zita_gp)*(-1-2*xi_gp+eta_gp+zita_gp);
dN19e =  1/8*(1-xi_gp) *(1+zita_gp)*(-1-xi_gp+2*eta_gp+zita_gp);
dN19z =  1/8*(1+eta_gp)*(1-xi_gp) *(-1-xi_gp+eta_gp+2*zita_gp);

% --- NODO 20: (-1,0,1) medio ||eta ---
N20   =  1/4*(1-eta_gp^2)*(1-xi_gp)*(1+zita_gp);
dN20x = -1/4*(1-eta_gp^2)*(1+zita_gp);
dN20e = -1/2*eta_gp*(1-xi_gp)*(1+zita_gp);
dN20z =  1/4*(1-eta_gp^2)*(1-xi_gp);

% ---- Assemblaggio N [3x60] ----
Nvec = [N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20];
for q = 1:20
    N(1, 3*q-2) = Nvec(q);
    N(2, 3*q-1) = Nvec(q);
    N(3, 3*q  ) = Nvec(q);
end

% ---- Assemblaggio Jprod [3x20] ----
Jprod(1,:) = [dN1x, dN2x, dN3x, dN4x, dN5x, dN6x, dN7x, dN8x, dN9x, dN10x, ...
              dN11x,dN12x,dN13x,dN14x,dN15x,dN16x,dN17x,dN18x,dN19x,dN20x];
Jprod(2,:) = [dN1e, dN2e, dN3e, dN4e, dN5e, dN6e, dN7e, dN8e, dN9e, dN10e, ...
              dN11e,dN12e,dN13e,dN14e,dN15e,dN16e,dN17e,dN18e,dN19e,dN20e];
Jprod(3,:) = [dN1z, dN2z, dN3z, dN4z, dN5z, dN6z, dN7z, dN8z, dN9z, dN10z, ...
              dN11z,dN12z,dN13z,dN14z,dN15z,dN16z,dN17z,dN18z,dN19z,dN20z];

end