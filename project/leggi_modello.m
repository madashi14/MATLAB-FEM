function [st,file] = leggi_modello(loc_dir)
% LEGGI_MODELLO
% Legge un file .el contenente la descrizione di un modello FEM a elementi
% solidi Hexa20, apre una finestra di selezione file e popola la struttura st.
%
% Formato file .el:
%   Prima riga: nd nel nv nf (nodi, elementi, vincoli, forzanti)
%   nd righe: x y z (coordinate nodali)
%   nel blocchi: indici 20 nodi, poi ro ni E (materiale)
%   nv blocchi: el u(2) v(2) w(2) k(3) (vincolo elastico)
%   nf blocchi: el u(2) v(2) w(2) p(3) (carico superficiale)
%
% INPUT:
%   loc_dir : cartella di default per la finestra di selezione file
%
% OUTPUT:
%   st   : struttura modello con campi nd, nel, nv, nf, p, el, vinc, F
%   file : percorso completo del file .el caricato

    st.ndxel= 20;  st.ndofsxel= st.ndxel*3;
    [file,~]= query_file(loc_dir,'*.el','r','Open *.el file');
    st.file=file;
    pf = fopen(file,'r');
    st.nd = fscanf(pf,'%d',1);    % Numero nodi
    st.nel = fscanf(pf,'%d',1);     % Numero elementi Totali
    st.nv = fscanf(pf,'%d',1);     % Numero vincoli
    st.nf = fscanf(pf,'%d',1);     % Numero forzanti
   

    for i=1:st.nd
        p(i).x= fscanf(pf,'%f',1);
        p(i).y= fscanf(pf,'%f',1);
        p(i).z= fscanf(pf,'%f',1);
    end
    st.p=p; clear p;

    for i=1:st.nel
        el(i).indx= fscanf(pf,'%d',st.ndxel);
        el(i).idofs= el2idofs(el(i).indx,st.ndofsxel);
        el(i).ro= fscanf(pf,'%f',1);
        el(i).ni= fscanf(pf,'%f',1);
        el(i).E= fscanf(pf,'%f',1);
    end
    st.el=el;  clear el;
    
    if st.nv>0
        for i=1:st.nv
            vinc(i).el= fscanf(pf,'%d',1);
            vinc(i).u= fscanf(pf,'%f',2);
            vinc(i).v= fscanf(pf,'%f',2);
            vinc(i).w= fscanf(pf,'%f',2);
            vinc(i).k= fscanf(pf,'%f',3);
        end
        st.vinc= vinc; clear vinc
    end
    if st.nf>0
        for i=1:st.nf
            F(i).el= fscanf(pf,'%d',1);
            F(i).u= fscanf(pf,'%f',2);
            F(i).v= fscanf(pf,'%f',2);
            F(i).w= fscanf(pf,'%f',2);
            F(i).p= fscanf(pf,'%f',3);
        end
        st.F= F; clear F;
    end
    fclose(pf);
end


function  v= el2idofs(vnod,n)
    v=zeros(n,1);  nn=length(vnod);
    k=0;
    for i=1:nn
        ndi= vnod(i);   ii= 3*(ndi-1);
        for j=1:3
          k=k+1;   v(k)= ii+j;
        end
    end
end


