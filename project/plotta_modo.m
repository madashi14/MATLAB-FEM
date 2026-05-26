function fig=plotta_modo(vel,nodi,fn,modo,N,options,fig)
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
fig = plotta_modello(vel,nodi,N,options,fig);
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