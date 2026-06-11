function s=crea_modello_fem(s,ng)
% CREA_MODELLO_FEM
% Assembla le matrici globali di rigidezza K e massa M del modello FEM
% con elementi solidi Hexa20, usando quadratura di Gauss di ordine ng.
%
% Per ogni elemento:
%   1. Estrae coordinate nodali e matrice costitutiva D.
%   2. Esegue il ciclo triplo sui punti di Gauss (i,j,k).
%   3. Accumula i contributi elementali dK e dM con add_gauss_contribution.
%   4. Assembla le matrici elementali in quelle globali sparse.
% Dopo l'assemblaggio delle matrici:
%   - Se ci sono vincoli elastici, chiama assembla_vinc.
%   - Se ci sono carichi superficiali, chiama assembla_forza.
%
% INPUT:
%   s  : struttura modello con nodi (s.p), elementi (s.el), materiale
%   ng : numero di punti di Gauss per direzione
%
% OUTPUT:
%   s : struttura aggiornata con s.K, s.M, e opzionalmente s.Forza
     
    [xg,wg]= gauleg(-1.,1.,ng);
    s.N= s.nd*3;
    s.M = sparse(s.N, s.N);
    s.K = sparse(s.N, s.N);
    coord=zeros(20,3);
    Kq=sparse(60,60); Mq=sparse(60,60);
    for q=1:s.nel
        Kq=sparse(60,60); Mq=sparse(60,60);
        eq= s.el(q);
        indx=eq.indx;        idofs= eq.idofs;
        coord(:,1) = [s.p(indx).x]';
        coord(:,2) = [s.p(indx).y]';
        coord(:,3) = [s.p(indx).z]';
        Dq=matxD(eq.ni,eq.E);
        for i=1:ng
            ui= xg(i);  wui= wg(i);
            for j=1:ng
                vj= xg(j);  wvj= wg(j);
                for k=1:ng
                    wk= xg(k);  wwk= wg(k);
                    [dK,dM] = add_gauss_contribution(ui,vj,wk,coord,Dq,eq.ro,s.ndxel);
                    Kq= Kq+wui*wvj*wwk*dK;
                    Mq= Mq+wui*wvj*wwk*dM;
                    clear wk; clear wwk;
                end
                clear vj; clear wvj; 
            end
            clear ui; clear wui;
        end
         
        s.K= assemblaggio_matrici(s.K,Kq,idofs);
        s.M= assemblaggio_matrici(s.M,Mq,idofs);
    end

    if s.nv>0
        s=assembla_vinc(s,ng);
    end

    if s.nf>0
        s=assembla_forza(s,ng);
    end

end

