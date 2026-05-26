function st = rotate_model(st, thx, thy, thz)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROTATE_MODEL
%
% Ruota il modello FEM agendo sulle coordinate dei nodi globali.
%
% INPUT:
%   st  : struttura modello FEM
%   thx : angolo iniziale attorno a x, in gradi, opzionale
%   thy : angolo iniziale attorno a y, in gradi, opzionale
%   thz : angolo iniziale attorno a z, in gradi, opzionale
%
% OUTPUT:
%   st  : struttura modello ruotata
%
% La funzione aggiorna:
%   st.p(i).x
%   st.p(i).y
%   st.p(i).z
%
% Non aggiorna st.el, perché st.el contiene solo la connettività nodale.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if nargin < 2
        thx = 0;
        thy = 0;
        thz = 0;
    end

    stitle = 'Ruota Modello';

    theta = char(952);  % simbolo theta
    vs = { [theta '_x'], [theta '_y'], [theta '_z'] };

    xmin = [0, 0, 0];
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

end