


function fig=plotta_modo(vel,nodi,fn,modo,N,options,fig)
% PLOTTA_MODO
% Disegna la deformata di un modo proprio scalando gli spostamenti
% di un fattore fisso (sc=0.1) relativo alla dimensione della struttura.
% Modifica le coordinate dei nodi aggiungendo il modo scalato e poi
% chiama plotta_modello.
%
% INPUT:
%   vel     : array di strutture elemento
%   nodi    : array di strutture nodo
%   fn      : frequenza propria del modo [Hz]
%   modo    : vettore autovettore (ndof x 1)
%   N       : numero di punti per spigolo
%   options : opzioni aggiuntive (non usato)
%   fig     : indice figura corrente
%
% OUTPUT:
%   fig : indice della figura aperta
sc=0.1;
L= dimensione_struttura(nodi);  scale_factor= sc*L;
wmax=max_mode_disp(modo);
modo= modo*scale_factor/wmax;
nd= length(nodi);
for i=1:nd
    ii=(i-1)*3;
    nodi(i).x= nodi(i).x+modo(ii+1);
    nodi(i).y= nodi(i).y+modo(ii+2);
    nodi(i).z= nodi(i).z+modo(ii+3);
end
fig = plotta_modello(vel,nodi,fig);
end


function w=max_mode_disp(v)
nv= length(v);  n=nv/3;
k=0;  w=-1;
for i=1:n
    ii= (i-1)*3;
    Li=norm(v(ii+1:ii+3));
    if Li>w  w=Li; end
end
end