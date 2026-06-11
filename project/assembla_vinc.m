function s=assembla_vinc(s,ng)
% ASSEMBLA_VINC
% Aggiunge il contributo di rigidezza dei vincoli elastici alla matrice
% di rigidezza globale del modello.
%
% Per ogni vincolo elastico superficiale (s.vinc):
%   1. Identifica l'elemento vincolato.
%   2. Calcola la matrice di rigidezza del vincolo elastico distribuito
%      integrando con quadratura di Gauss sulla faccia vincolata.
%   3. Assembla il contributo nella matrice globale s.K.
%
% I vincoli elastici simulano condizioni al contorno di tipo soft spring
% (penalita'), utili ad esempio per vincoli simply-supported su shell.
%
% INPUT:
%   s  : struttura del modello FEM con s.K inizializzata
%   ng : numero di punti di Gauss per direzione
%
% OUTPUT:
%   s  : struttura con s.K aggiornata con i contributi dei vincoli
    for i=1:s.nv
        vinc=s.vinc(i);
        eq=s.el(vinc.el);
        indx=eq.indx;
        idofs=eq.idofs;
        coord(:,1) = [s.p(indx).x]';
        coord(:,2) = [s.p(indx).y]';
        coord(:,3) = [s.p(indx).z]';

        Kv=crea_vinc_elastico(vinc,coord,ng,s.ndxel);

        s.K=assemblaggio_matrici(s.K,Kv,idofs);
    end

end


function Kv = crea_vinc_elastico(vinc,coord,ng,ndxel)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREA_VINCOLO_ELASTICO
%
% Calcola la matrice di rigidezza equivalente di un vincolo elastico
% distribuito su una faccia di un elemento Hexa20.
%
% Il vincolo letto da file ha struttura:
%
%   vinc.el      = indice elemento
%   vinc.u       = [u1; u2]
%   vinc.v       = [v1; v2]
%   vinc.w       = [w1; w2]
%   vinc.k       = [kx; ky; kz]
%
% La matrice calcolata è:
%
%   Kv = int_Gamma N' * Ks * N dGamma
%
% dove:
%
%   Ks = diag([kx ky kz])
%
% Federico NannI 01-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Kv = zeros(ndxel*3,ndxel*3);

    toll = 1.e-12;

    u_fisso = abs(vinc.u(2)-vinc.u(1)) < toll;
    v_fisso = abs(vinc.v(2)-vinc.v(1)) < toll;
    w_fisso = abs(vinc.w(2)-vinc.w(1)) < toll;

    n_fissi = u_fisso + v_fisso + w_fisso;

    if n_fissi ~= 1
        error('Il vincolo elastico deve essere applicato su una faccia: una sola coordinata naturale deve essere fissa.');
    end

    Ks = diag(vinc.k);

    if u_fisso

        u0 = vinc.u(1);

        [xv,wv] = gauleg(vinc.v(1),vinc.v(2),ng);
        [xw,ww] = gauleg(vinc.w(1),vinc.w(2),ng);

        for j = 1:ng
            vj = xv(j);
            wvj = wv(j);

            for k = 1:ng
                wk = xw(k);
                wwk = ww(k);

                dKv = add_gauss_contribution_vincolo(u0,vj,wk,coord,Ks,'u');
   

                Kv = Kv + wvj*wwk*dKv;

            end
        end

    elseif v_fisso

        v0 = vinc.v(1);

        [xu,wu] = gauleg(vinc.u(1),vinc.u(2),ng);
        [xw,ww] = gauleg(vinc.w(1),vinc.w(2),ng);

        for i = 1:ng
            ui = xu(i);
            wui = wu(i);

            for k = 1:ng
                wk = xw(k);
                wwk = ww(k);

                dKv = add_gauss_contribution_vincolo(ui,v0,wk,coord,Ks,'v');
         
                Kv = Kv + wui*wwk*dKv;

            end
        end

    elseif w_fisso

        w0 = vinc.w(1);

        [xu,wu] = gauleg(vinc.u(1),vinc.u(2),ng);
        [xv,wv] = gauleg(vinc.v(1),vinc.v(2),ng);

        for i = 1:ng
            ui = xu(i);
            wui = wu(i);

            for j = 1:ng
                vj = xv(j);
                wvj = wv(j);

                dKv = add_gauss_contribution_vincolo(ui,vj,w0,coord,Ks,'w');
       

                Kv = Kv + wui*wvj*dKv;

            end
        end

    end

end


function dKv = add_gauss_contribution_vincolo(ui,vj,wk,coord,Ks,faccia)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD_GAUSS_CONTRIBUTION_VINCOLO
%
% Calcola il contributo infinitesimo di rigidezza del vincolo elastico
% in un punto di Gauss superficiale.
%
%   dKv = N' * Ks * N * dGamma
%
% dove dGamma è il Jacobiano superficiale.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Jprod,N] = crea_N_dN_new(ui,vj,wk);

Js = Jprod * coord;

dx_du = Js(1,:);
dx_dv = Js(2,:);
dx_dw = Js(3,:);

switch faccia

    case 'u'
        dGamma = norm(cross(dx_dv,dx_dw));

    case 'v'
        dGamma = norm(cross(dx_du,dx_dw));

    case 'w'
        dGamma = norm(cross(dx_du,dx_dv));

    otherwise
        error('Faccia non riconosciuta.');

end

dKv = N' * Ks * N * dGamma;


end