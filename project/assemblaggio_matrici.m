function A = assemblaggio_matrici(A,Ai,indx)
% ASSEMBLAGGIO_MATRICI
% Assembla la matrice elementale Ai nella matrice globale A secondo la
% mappa dei gradi di liberta' indx.
%
% Per ogni coppia (i,j) di indici locali, aggiunge Ai(i,j) alla
% posizione globale A(indx(i), indx(j)).
%
%
% INPUT:
%   A    : matrice globale sparsa (ndof x ndof)
%   Ai   : matrice elementale (n x n)
%   indx : vettore degli indici globali dei gdl dell'elemento (n x 1)
%
% OUTPUT:
%   A : matrice globale aggiornata
    n = length(indx);
    for i=1:n
        ii= indx(i);
        for j=1:n
            jj= indx(j);
            A(ii,jj) = A(ii,jj) + Ai(i,j);
        end
    end
end



