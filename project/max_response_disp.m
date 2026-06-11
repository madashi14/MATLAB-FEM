function wmax = max_response_disp(X)
% MAX_RESPONSE_DISP
% Calcola il massimo spostamento nodale nell'intera storia temporale
% della risposta forzata.
%
% Scorre tutti gli istanti temporali e tutti i nodi, calcolando la norma
% euclidea [ux, uy, uz] per ogni nodo a ogni istante, e restituisce il
% massimo assoluto trovato.
%
% Usata per normalizzare la scala nell'animazione della risposta forzata.
%
% INPUT:
%   X : matrice (nt x ndof) degli spostamenti nodali nel tempo
%       con ndof = 3*nd
%
% OUTPUT:
%   wmax : massimo spostamento nodale in tutta la storia temporale


[nt,ndof] = size(X);

nd = ndof/3;

wmax = 0;

for k = 1:nt

    for i = 1:nd

        ii = (i-1)*3;

        ux = X(k,ii+1);
        uy = X(k,ii+2);
        uz = X(k,ii+3);

        Li = norm([ux uy uz]);

        if Li > wmax
            wmax = Li;
        end

    end

end

end