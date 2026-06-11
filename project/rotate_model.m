function st = rotate_model(st,ng, thx, thy, thz)
% ROTATE_MODEL
% Ruota il modello FEM applicando la rotazione composta Rx * Ry * Rz
% (prima z, poi y, poi x) alle coordinate dei nodi globali.
% Gli angoli di rotazione vengono chiesti all'utente tramite finestra
% di dialogo. Aggiorna le coordinate st.p(i).x/.y/.z.
% Non modifica la connettivita' st.el.
%
% INPUT:
%   st       : struttura modello FEM
%   thx, thy, thz : angoli di default in gradi (opzionali, default 0)
%
% OUTPUT:
%   st : struttura modello con coordinate nodali ruotate

    if nargin < 3
        thx = 0;
        thy = 0;
        thz = 0;
    end

    stitle = 'Ruota Modello';

    theta = char(952);  % simbolo theta
    vs = { [theta '_x'], [theta '_y'], [theta '_z'] };

    xmin = [0., 0., 0.];
    xmax = [360, 360, 360];
    xdef = [thx, thy, thz];

    out = query_multiple_exit(stitle, vs, xmin, xmax, xdef);

    thx = deg2rad(out(1));
    thy = deg2rad(out(2));
    thz = deg2rad(out(3));

    Rx = Rx_new(thx);
    Ry = Ry_new(thy);
    Rz = Rz_new(thz);

    R = Rx * Ry * Rz;

    % Matrice dei nodi globali
    nodes = zeros(st.nd,3);

    for i = 1:st.nd
        nodes(i,1) = st.p(i).x;
        nodes(i,2) = st.p(i).y;
        nodes(i,3) = st.p(i).z;
    end

    % Rotazione
    nodes_rot = (R * nodes')';

    % Salvataggio dentro st.p
    for i = 1:st.nd
        st.p(i).x = nodes_rot(i,1);
        st.p(i).y = nodes_rot(i,2);
        st.p(i).z = nodes_rot(i,3);
    end
 st=crea_modello_fem(st,ng);
 st=calcola_modello_modale(st);
end