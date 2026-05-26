function [dK,dN]=add_gauss_contribution(ui,vj,coord,s,D,eq)
xi=ui;
eta=vj;
zita=wk;
[dN,N]=crea_N_dN(xi,eta,zita,s);
Js=dN*coord;
detJ=det(Js);
B=Assembla_B(Js,dN,s);
dK=B'*D*B*detJ;
dM=eq.rho*N'*N

end