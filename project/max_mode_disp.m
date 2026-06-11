function w=max_mode_disp(v)
% MAX_MODE_DISP
% Calcola lo spostamento massimo presente nel vettore modale v.
% Il vettore v contiene i tre gradi di liberta' traslazionali (ux, uy, uz)
% per ogni nodo, disposti in sequenza. Per ogni nodo calcola la norma
% euclidea del vettore spostamento e restituisce il massimo.
%
% Usata per normalizzare la scala dei modi nei plot.
%
% INPUT:
%   v : vettore modale di dimensione 3*nd (spostamenti nodali)
%
% OUTPUT:
%   w : massimo spostamento nodale (norma euclidea massima)
nv= length(v);  n=nv/3;  w=0;
for i=1:n
    ii= (i-1)*3;
    Li=norm(v(ii+1:ii+3));
    if Li>w  w=Li; end
end
end