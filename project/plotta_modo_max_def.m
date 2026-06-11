function fig=plotta_modo_max_def(modo,vel,nodi,f,m,fig)
% PLOTTA_MODO_MAX_DEF
% Disegna il modo proprio alla sua massima deformazione.
% Sovrappone nella stessa figura:
%   - la mesh originale in linea tratteggiata nera (k--)
%   - la mesh deformata in rosso (r-) con lo spostamento scalato
% Lo scale factor e' recuperato con get_sc() e la dimensione
% caratteristica con dimensione_struttura().
%
% INPUT:
%   modo : vettore autovettore (ndof x 1)
%   vel  : array di strutture elemento
%   nodi : array di strutture nodo
%   f    : frequenza propria [Hz]
%   m    : numero del modo
%   fig  : indice figura corrente
%
% OUTPUT:
%   fig : indice della figura aperta

sc = get_sc();
L= dimensione_struttura(nodi);  scale_factor= sc*L;
wmax=max_mode_disp(modo);
modo= modo*scale_factor/wmax;
nd= length(nodi);
N = get_Nplot();
fig = set_fig(fig, sprintf('Modo #%d - f=%f [Hz]',m,f));
hold on
set(fig,'Toolbar','figure')
set(fig,'MenuBar','figure')
plotta_modello_corrente(vel,nodi,N,'k--');

for i=1:nd
    ii=(i-1)*3;
    nodi(i).x= nodi(i).x+modo(ii+1);
    nodi(i).y= nodi(i).y+modo(ii+2);
    nodi(i).z= nodi(i).z+modo(ii+3);
end
plotta_modello_corrente(vel,nodi,N,'r-');
end


function w=max_mode_disp(v)
nv= length(v);  n=nv/3;  w=0;
for i=1:n
    ii= (i-1)*3;
    Li=norm(v(ii+1:ii+3));
    if Li>w  w=Li; end
end
end

function L=dimensione_struttura(nodi)
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