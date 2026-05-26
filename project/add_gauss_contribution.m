function [dK,dM] = add_gauss_contribution(ui,vj,wk,coord,D,ro,ndxel)

    [Jprod,N] = crea_N_dN(ui,vj,wk,ndxel);

    Js = Jprod * coord;

    detJ = det(Js);

    B = Assembla_B(Js,Jprod,ndxel);

    dK = B' * D * B * detJ;
    dM = ro * N' * N * detJ;

end