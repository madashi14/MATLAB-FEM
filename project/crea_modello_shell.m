function st = crea_modello_shell(R, h, L, n_circ, n_ax, n_thick, ro, ni, E, k_pen, file_el)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREA_MODELLO_SHELL
%
% Genera la mesh a elementi finiti di un guscio cilindrico chiuso (shell)
% discretizzato con elementi Hexa20 (serendipity a 20 nodi) ANCHE nello
% spessore, lo vincola con appoggio semplice senza vincolo assiale
% (shear diaphragm, Blevins sez. 12.2.3) e scrive il file .el nel
% formato letto da LEGGI_MODELLO.
%
% Condizioni al contorno (z=0 e z=L):
%   v = w = 0 (radiale e circonferenziale bloccati)  =>  kx=ky=k_pen
%   u libero  (assiale libero, N_x = 0)              =>  kz=0
%
% L'ordine dei nodi locali dell'elemento e' identico a quello usato in
% CREA_N_DN (Dhatt & Touzot, cap. 2):
%
%  Vertici   :  1(-1,-1,-1)  3(1,-1,-1)  5(1,1,-1)  7(-1,1,-1)
%              13(-1,-1, 1) 15(1,-1, 1) 17(1,1, 1) 19(-1,1, 1)
%  Medi ||xi  :  2(0,-1,-1)  6(0,1,-1) 14(0,-1,1) 18(0,1,1)
%  Medi ||eta :  4(1,0,-1)   8(-1,0,-1)16(1,0,1)  20(-1,0,1)
%  Medi ||zita:  9(-1,-1,0) 10(1,-1,0) 11(1,1,0)  12(-1,1,0)
%
% Mappatura coordinate naturali -> geometria del cilindro:
%   xi   -> direzione circonferenziale (angolo theta)
%   eta  -> direzione assiale          (asse Z del cilindro)
%   zita -> direzione radiale          (spessore, da R-h/2 a R+h/2)
%
% Il cilindro ha asse lungo Z; la sezione giace nel piano XY.
%
% INPUT:
%   R        raggio della superficie media                       [m]
%   h        spessore di parete                                  [m]
%   L        lunghezza del cilindro                              [m]
%   n_circ   n. elementi in direzione circonferenziale (>=2)
%   n_ax     n. elementi in direzione assiale          (>=1)
%   n_thick  n. elementi nello spessore                (>=1)
%   ro       densita' del materiale                              [kg/m^3]
%   ni       coefficiente di Poisson                            [-]
%   E        modulo di Young                                     [Pa]
%   k_pen    rigidezza molle di penalita' per i vincoli SS       [N/m^3]
%            Suggerito: 1e3..1e6 * E/h.  Se 0 o vuoto, nessun vincolo.
%   file_el  nome del file .el da scrivere
%
% OUTPUT:
%   st  struttura del modello, compatibile con LEGGI_MODELLO
%
% Federico Nanni 06-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if nargin < 11
        error('crea_modello_shell: servono 11 argomenti.');
    end
    if n_circ < 2
        error('n_circ deve essere >= 2 per chiudere il cilindro.');
    end

    st.ndxel    = 20;
    st.ndofsxel = st.ndxel*3;

    % --- coordinate naturali dei 20 nodi locali (ordine crea_N_dN) ------
    nat = [ -1 -1 -1;    %  1
             0 -1 -1;    %  2
             1 -1 -1;    %  3
             1  0 -1;    %  4
             1  1 -1;    %  5
             0  1 -1;    %  6
            -1  1 -1;    %  7
            -1  0 -1;    %  8
            -1 -1  0;    %  9
             1 -1  0;    % 10
             1  1  0;    % 11
            -1  1  0;    % 12
            -1 -1  1;    % 13
             0 -1  1;    % 14
             1 -1  1;    % 15
             1  0  1;    % 16
             1  1  1;    % 17
             0  1  1;    % 18
            -1  1  1;    % 19
            -1  0  1];   % 20

    % --- dimensioni della griglia raddoppiata ---------------------------
    NA = 2*n_circ;     % circonferenziale (periodica: indici 0..NA-1)
    NB = 2*n_ax;       % assiale          (indici 0..NB)
    NC = 2*n_thick;    % radiale          (indici 0..NC)

    % --- numerazione globale dei nodi serendipity -----------------------
    gid = zeros(NA, NB+1, NC+1);
    nd  = 0;
    p   = struct('x',{},'y',{},'z',{});
    for c = 0:NC
        r = R - h/2 + h*c/NC;
        for b = 0:NB
            zax = L*b/NB;
            for a = 0:NA-1
                if mod(a,2)+mod(b,2)+mod(c,2) <= 1
                    nd = nd + 1;
                    gid(a+1,b+1,c+1) = nd;
                    theta   = 2*pi*a/NA;
                    p(nd).x = r*cos(theta);
                    p(nd).y = r*sin(theta);
                    p(nd).z = zax;
                end
            end
        end
    end
    st.nd = nd;
    st.p  = p;

    % --- costruzione degli elementi -------------------------------------
    nel = n_circ*n_ax*n_thick;
    el  = struct('indx',{},'idofs',{},'ro',{},'ni',{},'E',{});
    e   = 0;
    for et = 0:n_thick-1
        for eb = 0:n_ax-1
            for ec = 0:n_circ-1
                e = e + 1;
                indx = zeros(20,1);
                for m = 1:20
                    a  = mod(2*ec + nat(m,1) + 1, NA);
                    b  =     2*eb + nat(m,2) + 1;
                    c  =     2*et + nat(m,3) + 1;
                    indx(m) = gid(a+1, b+1, c+1);
                end
                if any(indx == 0)
                    error('Connettivita'' non valida, elemento %d.',e);
                end
                el(e).indx  = indx;
                el(e).idofs = el2idofs(indx, st.ndofsxel);
                el(e).ro    = ro;
                el(e).ni    = ni;
                el(e).E     = E;
            end
        end
    end
    st.nel = nel;
    st.el  = el;

    % --- vincoli  (shear diaphragm) -----------------------------------
    %   facce eta = -1 (z=0) e eta = +1 (z=L)
    %   kx = ky = k_pen,  kz = 0
    if ~isempty(k_pen) && k_pen > 0
        nv = 0;
        vinc = struct('el',{},'u',{},'v',{},'w',{},'k',{});
        for et = 0:n_thick-1
            for ec = 0:n_circ-1
                % faccia z = 0 : eb=0, eta = -1
                e_z0 = et*n_ax*n_circ + 0*n_circ + ec + 1;
                nv = nv + 1;
                vinc(nv).el = e_z0;
                vinc(nv).u  = [-1; 1];
                vinc(nv).v  = [-1; -1];
                vinc(nv).w  = [-1; 1];
                vinc(nv).k  = [k_pen; k_pen; 0];
                % faccia z = L : eb=n_ax-1, eta = +1
                e_zL = et*n_ax*n_circ + (n_ax-1)*n_circ + ec + 1;
                nv = nv + 1;
                vinc(nv).el = e_zL;
                vinc(nv).u  = [-1; 1];
                vinc(nv).v  = [1; 1];
                vinc(nv).w  = [-1; 1];
                vinc(nv).k  = [k_pen; k_pen; 0];
            end
        end
        st.nv   = nv;
        st.vinc = vinc;
    else
        st.nv = 0;
    end

    st.nf = 0;

    % --- scrittura file .el ---------------------------------------------
    pf = fopen(file_el,'w');
    if pf < 0, error('Impossibile aprire %s.',file_el); end

    fprintf(pf,'%d %d %d %d\n', st.nd, st.nel, st.nv, st.nf);

    for i = 1:st.nd
        fprintf(pf,'%.10g %.10g %.10g\n', p(i).x, p(i).y, p(i).z);
    end

    for i = 1:st.nel
        fprintf(pf,'%d ', el(i).indx);
        fprintf(pf,'\n');
        fprintf(pf,'%.10g %.10g %.10g\n', el(i).ro, el(i).ni, el(i).E);
    end

    if st.nv > 0
        for i = 1:st.nv
            fprintf(pf,'%d %.10g %.10g %.10g %.10g %.10g %.10g %.10g %.10g %.10g\n', ...
                st.vinc(i).el, ...
                st.vinc(i).u(1), st.vinc(i).u(2), ...
                st.vinc(i).v(1), st.vinc(i).v(2), ...
                st.vinc(i).w(1), st.vinc(i).w(2), ...
                st.vinc(i).k(1), st.vinc(i).k(2), st.vinc(i).k(3));
        end
    end

    fclose(pf);
end

% =======================================================================
function v = el2idofs(vnod, n)
    v = zeros(n,1);  nn = length(vnod);  k = 0;
    for i = 1:nn
        ii = 3*(vnod(i)-1);
        for j = 1:3
            k = k+1;  v(k) = ii+j;
        end
    end
end
