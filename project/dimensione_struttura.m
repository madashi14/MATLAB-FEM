function L=dimensione_struttura(nodi)
% DIMENSIONE_STRUTTURA
% Calcola la dimensione caratteristica della struttura come la diagonale
% del parallelepipedo di ingombro (bounding box) dell'insieme dei nodi.
%
% E' usata per scalare i modi propri e le deformate nella visualizzazione.
%
% INPUT:
%   nodi : array di strutture con campi .x, .y, .z (coordinate dei nodi)
%
% OUTPUT:
%   L : dimensione caratteristica [m], calcolata come
%       L = sqrt(dx^2 + dy^2 + dz^2) dove dx, dy, dz sono le
%       estensioni della struttura lungo i tre assi
    nd=length(nodi);
    x=zeros(nd,1);
    y=zeros(nd,1);
    z=zeros(nd,1);
    
    for i=1:nd
        x(i)=nodi(i).x;
        y(i)=nodi(i).y;
        z(i)=nodi(i).z;
    end
    dx=max(x)-min(x);
    dy=max(y)-min(y);
    dz=max(z)-min(z);
    L=sqrt(dx^2+dy^2+dz^2);
end