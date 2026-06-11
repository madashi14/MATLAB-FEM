function [dK,dM] = add_gauss_contribution(ui,vj,wk,coord,D,ro,ndxel)
% ADD_GAUSS_CONTRIBUTION
% Calcola il contributo di rigidezza (dK) e di massa (dM) di un singolo
% punto di Gauss nel volume dell'elemento Hexa20.
%
% Per ogni punto di Gauss (ui, vj, wk) in coordinate naturali:
%   1. Calcola le funzioni di forma N e le derivate Jprod tramite crea_N_dN_new.
%   2. Costruisce il Jacobiano Js = Jprod * coord e verifica che det(Js) > 0.
%   3. Assembla la matrice B delle deformazioni tramite Assembla_B.
%   4. Calcola il contributo elementale:
%        dK = B^T * D * B * det(Js)
%        dM = rho * N^T * N * det(Js)
%
% INPUT:
%   ui, vj, wk : coordinate naturali del punto di Gauss
%   coord      : coordinate globali dei 20 nodi dell'elemento (20x3)
%   D          : matrice costitutiva elastica (6x6)
%   ro         : densita' del materiale [kg/m^3]
%   ndxel      : numero di nodi per elemento (tipicamente 20)
%
% OUTPUT:
%   dK : contributo di rigidezza (60x60)
%   dM : contributo di massa (60x60)

    [Jprod,N] = crea_N_dN_new(ui,vj,wk);

    Js = Jprod * coord;

    detJ = det(Js);
    if detJ <= 0
        fprintf('\nERRORE: detJ = %.16e\n', detJ);
        fprintf('Gauss point: xi = %.6f, eta = %.6f, zita = %.6f\n', ui, vj, wk);
        disp('Coordinate elemento:');
        disp(coord);
        error('Jacobiano negativo o nullo: controlla ordine nodi Hexa20');
    end

    B = Assembla_B(Js,Jprod,ndxel);

    dK = B' * D * B * detJ;
    dM = ro * N' * N * detJ;

end