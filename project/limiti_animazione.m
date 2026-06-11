function [xlim0,ylim0,zlim0] = limiti_animazione(nodi,risp,scale_factor)
% LIMITI_ANIMAZIONE
% Calcola i limiti degli assi (xlim, ylim, zlim) per l'animazione della
% risposta forzata, tenendo conto delle deformazioni massime scalate.
%
% Aggiunge un margine del 10% della dimensione massima del bounding box
% per evitare che la mesh esca dai bordi durante l'animazione.
%
% INPUT:
%   nodi         : array di strutture nodo con campi .x, .y, .z
%   risp         : struttura risposta con risp.x (matrice nt x ndof degli spostamenti)
%   scale_factor : fattore di scala applicato agli spostamenti
%
% OUTPUT:
%   xlim0, ylim0, zlim0 : vettori [min, max] per i tre assi

nd = length(nodi);

x0 = zeros(nd,1);
y0 = zeros(nd,1);
z0 = zeros(nd,1);

for i = 1:nd
    x0(i) = nodi(i).x;
    y0(i) = nodi(i).y;
    z0(i) = nodi(i).z;
end

% Massimo spostamento scalato della risposta
max_def = max_response_disp(risp.x) * scale_factor;

xmin = min(x0) - max_def;
xmax = max(x0) + max_def;

ymin = min(y0) - max_def;
ymax = max(y0) + max_def;

zmin = min(z0) - max_def;
zmax = max(z0) + max_def;

% Margine grafico
Lx = xmax - xmin;
Ly = ymax - ymin;
Lz = zmax - zmin;

L = max([Lx,Ly,Lz]);

if L < eps
    L = 1;
end

margine = 0.1*L;

xlim0 = [xmin-margine xmax+margine];
ylim0 = [ymin-margine ymax+margine];
zlim0 = [zmin-margine zmax+margine];

end