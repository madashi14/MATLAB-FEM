function s=assembla_forza(s,ng)
% ASSEMBLA_FORZA
% Assembla il vettore globale delle forze nodali equivalenti per tutte le
% condizioni di carico superficiale presenti nel modello.
%
% Per ogni carico superficiale definito nel modello (s.F):
%   1. Identifica l'elemento e i suoi nodi.
%   2. Estrae le coordinate nodali.
%   3. Calcola il vettore forza elementale integrando con quadratura di Gauss.
%   4. Aggiunge il contributo alla posizione corretta nel vettore globale.
%
% Il vettore forza viene inizializzato a zero ad ogni chiamata.
%
% INPUT:
%   s  : struttura del modello FEM (nodi, elementi, carichi)
%   ng : numero di punti di Gauss per direzione
%
% OUTPUT:
%   s  : struttura aggiornata con il campo s.Forza (ndof x 1)
ndof=3*s.nd;
s.Forza=zeros(ndof,1);
[xg,wg]=gauleg(-1,1,ng);

for i=1:s.nf
    f=s.F(i);
    indx_el=f.el;
    el=s.el(indx_el);
    indx=el.indx;
    idofs=el.idofs;
    coord(:,1) = [s.p(indx).x]';
    coord(:,2) = [s.p(indx).y]';
    coord(:,3) = [s.p(indx).z]';
    fe=forza_elemento(f,coord,xg,wg);
    s.Forza(idofs)=s.Forza(idofs)+fe;
    
end
end

function fe=forza_elemento(forza,coord,xg,wg)
fe=zeros(60,1);
toll=1e-12;
u_fisso = abs(forza.u(2) - forza.u(1)) < toll;
v_fisso = abs(forza.v(2) - forza.v(1)) < toll;
w_fisso = abs(forza.w(2) - forza.w(1)) < toll;

n_fissi = u_fisso + v_fisso + w_fisso;

if n_fissi ~= 1
    error('Forza superficiale non valida: deve essere fissa una sola coordinata naturale.');
end

t=[forza.p(1), forza.p(2),forza.p(3)]';

if u_fisso
    u0=forza.u(1);
    for i=1:length(xg)
        vi=xg(i);
        wvi=wg(i);
        for j=1:length(xg)
            vj=xg(j);
            wvj=wg(j);
            dfe=forza_gauss_superficie(u0,vi,vj,coord,t,'u');
            fe=fe+dfe*wvj*wvi;
        end
    end
elseif v_fisso
    v0=forza.v(1);
    for i=1:length(xg)
        vi=xg(i);
        wvi=wg(i);
        for j=length(xg)
            vj=xg(j);
            wvj=wg(j);
            dfe=forza_gauss_superficie(vi,v0,vj,coord,t,'v');
            fe=fe+dfe*wvj*wvi;
        end
    end
elseif w_fisso
    w0=forza.w(1);
    for i=1:length(xg)
        vi=xg(i);
        wvi=wg(i);
        for j=length(xg)
            vj=xg(j);
            wvj=wg(j);
            dfe=forza_gauss_superficie(vi,vj,w0,coord,t,'w');
            fe=fe+dfe*wvj*wvi;
        end
    end
end


end

function dfe=forza_gauss_superficie(u,v,w,coord,t,tipo_sup)

[Jprod,N]=crea_N_dN_new(u,v,w);
Js=Jprod*coord;
switch tipo_sup
    case 'u'
        t1=Js(2,:);
        t2=Js(3,:);

    case 'v'
        t1=Js(1,:);
        t2=Js(3,:);

    case 'w'
        t1=Js(1,:);
        t2=Js(2,:);
end
Jsup=norm(cross(t1,t2));
dfe=N.'*t*Jsup;
end
