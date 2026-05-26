function s=crea_modello_fem(s)
    [xg,wg]= gauleg(-1.,1.,s.ng);
    s.N= s.nd*3;
    s.M= zeros(s.N);     s.K= zeros(s.N);
    coord=zeros(20,3);
    Kq=zeros(60,60); Mq=zeros(60,60);
    for q=1:s.nel
        eq= s.el(q);
        indx=eq.indx;        idofs= eq.idofs;
        coord(:,1) = [s.p(indx).x]';
        coord(:,2) = [s.p(indx).y]';
        coord(:,3) = [s.p(indx).z]';
        Dq=matxD(eq.ni,eq.E);
        for i=1:s.ng
            ui= xg(i);  wui= wg(i);
            for j=1:s.ng
                vj= xg(j);  wvj= wg(j);
                for k=1:s.ng
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
end