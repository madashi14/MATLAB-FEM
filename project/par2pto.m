function pto = par2pto(csi,eta,zita,el,p)
% PAR2PTO
% Trasforma le coordinate naturali (csi, eta, zita) in coordinate globali
% (x, y, z) usando il mapping isoparametrico dell'elemento Hexa20.
%
% Calcola: pto = sum_i N_i(csi,eta,zita) * p(el.indx(i))
% dove N_i sono le 20 funzioni di forma dell'Hexa20.
%
% E' usata per tracciare i bordi degli elementi nel plot e per il
% calcolo delle forze nodali equivalenti.
%
% INPUT:
%   csi, eta, zita : coordinate naturali nel dominio [-1, 1]^3
%   el             : struttura elemento con el.indx (indici nodali globali)
%   p              : array dei nodi con campi .x, .y, .z
%
% OUTPUT:
%   pto : struttura con campi .x, .y, .z (coordinate globali del punto)

    vN = vN_Hexa20(csi,eta,zita);

    pto.x = 0;
    pto.y = 0;
    pto.z = 0;

    for i = 1:20

        ig = el.indx(i);

        pto.x = pto.x + vN(i)*p(ig).x;
        pto.y = pto.y + vN(i)*p(ig).y;
        pto.z = pto.z + vN(i)*p(ig).z;

    end

end



function vN = vN_Hexa20(xi,eta,zita)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VN_HEXA20
%
% Funzioni di forma dell'elemento esaedrico serendipity a 20 nodi.
%
% Ordine dei nodi secondo il protocollo:
%
% Corner nodes:
%   1, 3, 5, 7, 13, 15, 17, 19
%
% Nodes on sides parallel to xi:
%   2, 6, 14, 18
%
% Nodes on sides parallel to eta:
%   4, 8, 16, 20
%
% Nodes on sides parallel to zita:
%   9, 10, 11, 12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    vN = zeros(20,1);

    % ---------------------------------------------------------------------
    % Corner nodes
    % Formula:
    % Ni = 1/8 * (1 + xi*xi_i) * (1 + eta*eta_i) * (1 + zita*zita_i)
    %          * (-2 + xi*xi_i + eta*eta_i + zita*zita_i)
    % ---------------------------------------------------------------------

    % Nodo 1: xi_i = -1, eta_i = -1, zita_i = -1
    vN(1) = 1/8*(1-xi)*(1-eta)*(1-zita)*(-2-xi-eta-zita);

    % Nodo 3: xi_i = +1, eta_i = -1, zita_i = -1
    vN(3) = 1/8*(1+xi)*(1-eta)*(1-zita)*(-2+xi-eta-zita);

    % Nodo 5: xi_i = +1, eta_i = +1, zita_i = -1
    vN(5) = 1/8*(1+xi)*(1+eta)*(1-zita)*(-2+xi+eta-zita);

    % Nodo 7: xi_i = -1, eta_i = +1, zita_i = -1
    vN(7) = 1/8*(1-xi)*(1+eta)*(1-zita)*(-2-xi+eta-zita);

    % Nodo 13: xi_i = -1, eta_i = -1, zita_i = +1
    vN(13) = 1/8*(1-xi)*(1-eta)*(1+zita)*(-2-xi-eta+zita);

    % Nodo 15: xi_i = +1, eta_i = -1, zita_i = +1
    vN(15) = 1/8*(1+xi)*(1-eta)*(1+zita)*(-2+xi-eta+zita);

    % Nodo 17: xi_i = +1, eta_i = +1, zita_i = +1
    vN(17) = 1/8*(1+xi)*(1+eta)*(1+zita)*(-2+xi+eta+zita);

    % Nodo 19: xi_i = -1, eta_i = +1, zita_i = +1
    vN(19) = 1/8*(1-xi)*(1+eta)*(1+zita)*(-2-xi+eta+zita);


    % ---------------------------------------------------------------------
    % Nodes on sides parallel to xi
    % Formula:
    % Ni = 1/4 * (1 - xi^2) * (1 + eta*eta_i) * (1 + zita*zita_i)
    %
    % Nodi: 2, 6, 14, 18
    % ---------------------------------------------------------------------

    % Nodo 2: eta_i = -1, zita_i = -1
    vN(2) = 1/4*(1-xi^2)*(1-eta)*(1-zita);

    % Nodo 6: eta_i = +1, zita_i = -1
    vN(6) = 1/4*(1-xi^2)*(1+eta)*(1-zita);

    % Nodo 14: eta_i = -1, zita_i = +1
    vN(14) = 1/4*(1-xi^2)*(1-eta)*(1+zita);

    % Nodo 18: eta_i = +1, zita_i = +1
    vN(18) = 1/4*(1-xi^2)*(1+eta)*(1+zita);


    % ---------------------------------------------------------------------
    % Nodes on sides parallel to eta
    % Formula:
    % Ni = 1/4 * (1 + xi*xi_i) * (1 - eta^2) * (1 + zita*zita_i)
    %
    % Nodi: 4, 8, 16, 20
    % ---------------------------------------------------------------------

    % Nodo 4: xi_i = +1, zita_i = -1
    vN(4) = 1/4*(1+xi)*(1-eta^2)*(1-zita);

    % Nodo 8: xi_i = -1, zita_i = -1
    vN(8) = 1/4*(1-xi)*(1-eta^2)*(1-zita);

    % Nodo 16: xi_i = +1, zita_i = +1
    vN(16) = 1/4*(1+xi)*(1-eta^2)*(1+zita);

    % Nodo 20: xi_i = -1, zita_i = +1
    vN(20) = 1/4*(1-xi)*(1-eta^2)*(1+zita);


    % ---------------------------------------------------------------------
    % Nodes on sides parallel to zita
    % Formula:
    % Ni = 1/4 * (1 + xi*xi_i) * (1 + eta*eta_i) * (1 - zita^2)
    %
    % Nodi: 9, 10, 11, 12
    % ---------------------------------------------------------------------

    % Nodo 9: xi_i = -1, eta_i = -1
    vN(9) = 1/4*(1-xi)*(1-eta)*(1-zita^2);

    % Nodo 10: xi_i = +1, eta_i = -1
    vN(10) = 1/4*(1+xi)*(1-eta)*(1-zita^2);

    % Nodo 11: xi_i = +1, eta_i = +1
    vN(11) = 1/4*(1+xi)*(1+eta)*(1-zita^2);

    % Nodo 12: xi_i = -1, eta_i = +1
    vN(12) = 1/4*(1-xi)*(1+eta)*(1-zita^2);

end