function plotta_facce_vincolate_e_caricate(st)
% PLOTTA_FACCE_VINCOLATE_E_CARICATE
% Visualizza le condizioni al contorno del modello:
%   - Vincoli elastici : patch verde semitrasparente sulla faccia vincolata
%   - Carichi          : frecce rosse nella direzione del carico,
%                        campionate sulla faccia caricata
%
% Usa il mapping isoparametrico (par2pto) per tracciare le facce e
% posizionare le frecce in modo esatto sulla geometria curva.
% Da chiamare con hold on attivo dopo plotta_modello.
%
% INPUT:
%   st : struttura modello con st.nv, st.vinc, st.nf, st.F, st.el, st.p
%
% OUTPUT:
%   nessun output; aggiunge patch e frecce alla figura corrente

    % --- Controllo: niente da disegnare ---------------------------------
    nv = 0;  nf = 0;
    if isfield(st,'nv'),  nv = st.nv;  end
    if isfield(st,'nf'),  nf = st.nf;  end
    if nv == 0 && nf == 0,  return;  end

    N     = get_Nplot();
    N_arr = 5;                          % punti per lato per le frecce
    par   = linspace(-1, 1, N);
    par_a = linspace(-0.8, 0.8, N_arr); % griglia interna per le frecce
    toll  = 1e-12;
    hold on

    % ====================================================================
    % VINCOLI  →  patch verde
    % ====================================================================
    for iv = 1:nv
        v  = st.vinc(iv);
        el = st.el(v.el);
        xp = [];  yp = [];  zp = [];

        [xp, yp, zp] = campiona_faccia(v.u, v.v, v.w, el, st.p, par, toll);
        if isempty(xp),  continue;  end

        patch(xp, yp, zp, [0 0.8 0], ...
              'FaceAlpha', 0.25, ...
              'EdgeColor', [0 0.6 0], ...
              'LineStyle', '--', ...
              'LineWidth', 1.5);
    end

    % ====================================================================
    % FORZE  →  frecce rosse nella direzione del carico
    % ====================================================================
    if nf > 0
        % Scala frecce proporzionale alla dimensione della struttura
        L_str = dimensione_struttura(st.p);

        for q = 1:nf
            v  = st.F(q);
            el = st.el(v.el);
            px = v.p(1);  py = v.p(2);  pz = v.p(3);
            p_norm = sqrt(px^2 + py^2 + pz^2);
            if p_norm < 1e-30,  continue;  end

            % Direzione unitaria e scala visiva
            ux = px/p_norm;  uy = py/p_norm;  uz = pz/p_norm;
            scale = 0.15 * L_str;

            % Determina quale coordinata è fissa
            u_fisso = abs(v.u(2) - v.u(1)) < toll;
            v_fisso = abs(v.v(2) - v.v(1)) < toll;
            w_fisso = abs(v.w(2) - v.w(1)) < toll;

            % Campiona griglia N_arr x N_arr sulla faccia
            Xo = [];  Yo = [];  Zo = [];
            for ia = 1:N_arr
                for ib = 1:N_arr
                    a = par_a(ia);  b = par_a(ib);
                    if u_fisso
                        pto = par2pto(v.u(1), a, b, el, st.p);
                    elseif v_fisso
                        pto = par2pto(a, v.v(1), b, el, st.p);
                    elseif w_fisso
                        pto = par2pto(a, b, v.w(1), el, st.p);
                    else
                        continue
                    end
                    Xo(end+1) = pto.x;
                    Yo(end+1) = pto.y;
                    Zo(end+1) = pto.z;
                end
            end

            if isempty(Xo),  continue;  end

            % Frecce con quiver3
            quiver3(Xo, Yo, Zo, ...
                    ux*scale*ones(size(Xo)), ...
                    uy*scale*ones(size(Yo)), ...
                    uz*scale*ones(size(Zo)), ...
                    0, ...                  % AutoScale off
                    'Color', [0.85 0 0], ...
                    'LineWidth', 1.5, ...
                    'MaxHeadSize', 0.5);
        end
    end

    hold off
end


% ========================================================================
% Funzione locale: campiona il perimetro di una faccia isoparametrica
% e restituisce il poligono (xp, yp, zp) per patch
% ========================================================================
function [xp, yp, zp] = campiona_faccia(u_range, v_range, w_range, el, p, par, toll)
    xp = [];  yp = [];  zp = [];
    N  = length(par);

    u_fisso = abs(u_range(2) - u_range(1)) < toll;
    v_fisso = abs(v_range(2) - v_range(1)) < toll;
    w_fisso = abs(w_range(2) - w_range(1)) < toll;

    if u_fisso
        u0 = u_range(1);
        for i = 1:N,    pto=par2pto(u0,par(i),-1,el,p); xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = 1:N,    pto=par2pto(u0,1,par(i),el,p);  xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = N:-1:1, pto=par2pto(u0,par(i),1,el,p);  xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = N:-1:1, pto=par2pto(u0,-1,par(i),el,p); xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end

    elseif v_fisso
        v0 = v_range(1);
        for i = 1:N,    pto=par2pto(par(i),v0,-1,el,p); xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = 1:N,    pto=par2pto(1,v0,par(i),el,p);  xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = N:-1:1, pto=par2pto(par(i),v0,1,el,p);  xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = N:-1:1, pto=par2pto(-1,v0,par(i),el,p); xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end

    elseif w_fisso
        w0 = w_range(1);
        for i = 1:N,    pto=par2pto(par(i),-1,w0,el,p); xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = 1:N,    pto=par2pto(1,par(i),w0,el,p);  xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = N:-1:1, pto=par2pto(par(i),1,w0,el,p);  xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = N:-1:1, pto=par2pto(-1,par(i),w0,el,p); xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
    end
end


% ========================================================================
% Funzione locale: dimensione caratteristica della struttura
% ========================================================================
function L = dimensione_struttura(nodi)
    nd = length(nodi);
    x  = [nodi.x];  y = [nodi.y];  z = [nodi.z];
    L  = sqrt((max(x)-min(x))^2 + (max(y)-min(y))^2 + (max(z)-min(z))^2);
end