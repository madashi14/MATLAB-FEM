close all hidden
clc
clear all
fig = 0;
mydir = './modelli';
s = [];
stit = 'Modellazione a Elementi finiti';
vs = {'Leggi modello', ...
      'Plotta Modello', ...
      'Plotta Modi propri',...
      'Verifica analitica shell',...
      'Crea Shell',...
      'Calcola Risposta Forzata',...
      'Plotta risposta forzata con chirp',...
      'Ruota Modello', ...
      'Cambia numero Gauss point',...
      'Chiudi Finestre',...
      'Esci'};
ripeti = 1;
while ripeti
    scelta = menu(stit, vs);
    switch scelta
        case 1
            s = leggi_modello(mydir);
            ng = get_Ngauss();
            s = crea_modello_fem(s,ng);
            s = calcola_modello_modale(s);
        case 2
            if isempty(s)
                error_window('Devi prima leggere il modello.', 'logo.jpg');
            else
                fig = various_plot(s,fig);
            end
        case 3
            if isempty(s)
                error_window('Devi prima leggere il modello.', 'logo.jpg');
            else
                fig = plotta_modi(s,fig);
            end
        case 4
            if isempty(s)
                error_window('Devi prima leggere il modello.', 'logo.jpg');
            elseif ~isfield(s,'file') || ~contains(lower(s.file), 'shell')
                print_window( ...
                    {'Il modello che stai esaminando non e'' uno shell.', ...
                     '', ...
                     'La verifica analitica (Blevins, Donnell)', ...
                     'e'' applicabile solo a modelli il cui nome', ...
                     'file contiene "shell".'}, ...
                    'Verifica non applicabile');
            else
                confronta_freq_shell(s, s.freq, s.file);
            end
        case 5
            R_sh  = query_double_d('Raggio medio R [m]', 0.01, 100, 1.0);
            h_sh  = query_double_d('Spessore h [m]', 1e-4, R_sh, 0.05);
            L_sh  = query_double_d('Lunghezza L [m]', 0.01, 1000, 4.0);
            nc_sh = query_integer_d('N. elementi in circonferenza', 2, 200, 12);
            na_sh = query_integer_d('N. elementi in direzione assiale', 1, 200, 8);
            nt_sh = query_integer_d('N. elementi nello spessore', 1, 10, 1);
            ro_sh = query_double_d('Densita'' [kg/m^3]', 1, 30000, 7800);
            ni_sh = query_double_d('Coefficiente di Poisson', 0, 0.5, 0.3);
            E_sh  = query_double_d('Modulo di Young [Pa]', 1e6, 1e13, 2.1e11);
            kp_sh = query_double_d('Rigidezza penalita'' k_pen [N/m^3]', 0, 1e30, 1e6*E_sh/h_sh);
            nome_default = 'shell_ss.el';
            risposta = inputdlg( ...
                {'Nome file .el (deve contenere "shell" per la verifica analitica):'}, ...
                'Salva modello', 1, {nome_default});
            if isempty(risposta)
                error('!!');
            end
            nome_file_sh = char(risposta);
            if ~endsWith(nome_file_sh, '.el')
                nome_file_sh = [nome_file_sh '.el'];
            end
            if ~contains(lower(nome_file_sh), 'shell')
                print_window( ...
                    {'Attenzione: il nome file non contiene "shell".', ...
                     'La verifica analitica non sara'' disponibile.'}, ...
                    'Avviso');
            end
            s = crea_modello_shell(R_sh, h_sh, L_sh, nc_sh, na_sh, nt_sh, ...
                ro_sh, ni_sh, E_sh, kp_sh, nome_file_sh);
            print_window( ...
                {sprintf('Shell creato: %s', nome_file_sh), ...
                 '', ...
                 sprintf('Nodi: %d,  Elementi: %d,  Vincoli: %d', s.nd, s.nel, s.nv), ...
                 sprintf('R=%.4g  h=%.4g  L=%.4g', R_sh, h_sh, L_sh), ...
                 sprintf('Mesh: %dx%dx%d', nc_sh, na_sh, nt_sh)}, ...
                'Shell creato');
        case 6
            [risp,fig] = risposta_forzata(s,fig);
        case 7
            if isempty(risp)
                error_window('Devi prima calcolare risposta forzata.', 'logo.jpg');
            else
                verifica_chirp_frf(risp, s)
            end
        case 8
            if isempty(s)
                error_window('Devi prima leggere il modello.','logo.jpg');
            else
                s=rotate_model(s,ng);
            end
        case 9
            ng = get_Ngauss(true);
        case 10
            close all hidden
        case 11
            ripeti = 0;
        case 0
            ripeti = 0;
        otherwise
            msg = sprintf('Opzione %d non implementata', scelta);
            error_window(msg, 'logo.jpg');
    end
end


function [x,w]= gauleg(x1,x2,n)

	DMACHEPS= 1.0e-16;
	m=(n+1)/2;
	xm=0.5*(x2+x1);
	xl=0.5*(x2-x1);
	for i=1:m
      z=cos(pi*(i-0.25)/(n+0.5));
      ancora= 1;
	 while ancora
		p1=1.0;
			p2=0.0;
			for j=1:n
				p3=p2;
				p2=p1;
            		p1=((2.0*j-1.0)*z*p2-(j-1.0)*p3)/j;
         		end
			pp=n*(z*p1-p2)/(z*z-1.0);
			z1=z;
			z=z1-p1/pp;
      	if abs(z-z1) <= DMACHEPS
           	ancora= 0;
         	end
     	end
	x(i)=xm-xl*z;
	x(n+1-i)=xm+xl*z;
	w(i)=2.0*xl/((1.0-z*z)*pp*pp);
	w(n+1-i)=w(i);
end


function [st,file] = leggi_modello(loc_dir)

    st.ndxel= 20;  st.ndofsxel= st.ndxel*3;
    [file,~]= query_file(loc_dir,'*.el','r','Open *.el file');
    st.file=file;
    pf = fopen(file,'r');
    st.nd = fscanf(pf,'%d',1);
    st.nel = fscanf(pf,'%d',1);
    st.nv = fscanf(pf,'%d',1);
    st.nf = fscanf(pf,'%d',1);

    for i=1:st.nd
        p(i).x= fscanf(pf,'%f',1);
        p(i).y= fscanf(pf,'%f',1);
        p(i).z= fscanf(pf,'%f',1);
    end
    st.p=p; clear p;

    for i=1:st.nel
        el(i).indx= fscanf(pf,'%d',st.ndxel);
        el(i).idofs= el2idofs(el(i).indx,st.ndofsxel);
        el(i).ro= fscanf(pf,'%f',1);
        el(i).ni= fscanf(pf,'%f',1);
        el(i).E= fscanf(pf,'%f',1);
    end
    st.el=el;  clear el;

    if st.nv>0
        for i=1:st.nv
            vinc(i).el= fscanf(pf,'%d',1);
            vinc(i).u= fscanf(pf,'%f',2);
            vinc(i).v= fscanf(pf,'%f',2);
            vinc(i).w= fscanf(pf,'%f',2);
            vinc(i).k= fscanf(pf,'%f',3);
        end
        st.vinc= vinc; clear vinc
    end
    if st.nf>0
        for i=1:st.nf
            F(i).el= fscanf(pf,'%d',1);
            F(i).u= fscanf(pf,'%f',2);
            F(i).v= fscanf(pf,'%f',2);
            F(i).w= fscanf(pf,'%f',2);
            F(i).p= fscanf(pf,'%f',3);
        end
        st.F= F; clear F;
    end
    fclose(pf);
end

function  v= el2idofs(vnod,n)
    v=zeros(n,1);  nn=length(vnod);
    k=0;
    for i=1:nn
        ndi= vnod(i);   ii= 3*(ndi-1);
        for j=1:3
          k=k+1;   v(k)= ii+j;
        end
    end
end


function N = get_Ngauss(reset)

persistent N_saved

if nargin < 1
    reset = false;
end

if reset
    N_saved = [];
end

if isempty(N_saved)

    vs = 'Con quanti punti di Guass vuoi integrare?';
    xmin = 1;
    xmax = 5;
    xdef = 3;

    N_saved = query_integer_d(vs, xmin, xmax, xdef);
   if isempty(N_saved), return; end

end

N = N_saved;

end


function D = matxD(v,E)

zer=zeros(3); k=(1-2*v)/2;
vec=[k,k,k];
dg=diag(vec);
mat=[1-v v v; v 1-v v; v v 1-v];
mat2=[mat zer; zer dg];
a=E/((1+v)*(1-2*v));
D=a*mat2;
end


function [Jprod,N] = crea_N_dN_new(xi_gp, eta_gp, zita_gp)

Jprod = zeros(3,20);
N     = zeros(3,60);

N1   =  1/8*(1-xi_gp)*(1-eta_gp)*(1-zita_gp)*(-2-xi_gp-eta_gp-zita_gp);
dN1x = -1/8*(1-eta_gp)*(1-zita_gp)*(-1-2*xi_gp-eta_gp-zita_gp);
dN1e = -1/8*(1-xi_gp) *(1-zita_gp)*(-1-xi_gp-2*eta_gp-zita_gp);
dN1z = -1/8*(1-eta_gp)*(1-xi_gp) *(-1-xi_gp-eta_gp-2*zita_gp);

N2   =  1/4*(1-xi_gp^2)*(1-eta_gp)*(1-zita_gp);
dN2x = -1/2*xi_gp*(1-eta_gp)*(1-zita_gp);
dN2e = -1/4*(1-xi_gp^2)*(1-zita_gp);
dN2z = -1/4*(1-xi_gp^2)*(1-eta_gp);

N3   =  1/8*(1+xi_gp)*(1-eta_gp)*(1-zita_gp)*(-2+xi_gp-eta_gp-zita_gp);
dN3x =  1/8*(1-eta_gp)*(1-zita_gp)*(-1+2*xi_gp-eta_gp-zita_gp);
dN3e = -1/8*(1+xi_gp) *(1-zita_gp)*(-1+xi_gp-2*eta_gp-zita_gp);
dN3z = -1/8*(1-eta_gp)*(1+xi_gp) *(-1+xi_gp-eta_gp-2*zita_gp);

N4   =  1/4*(1-eta_gp^2)*(1+xi_gp)*(1-zita_gp);
dN4x =  1/4*(1-eta_gp^2)*(1-zita_gp);
dN4e = -1/2*eta_gp*(1+xi_gp)*(1-zita_gp);
dN4z = -1/4*(1-eta_gp^2)*(1+xi_gp);

N5   =  1/8*(1+xi_gp)*(1+eta_gp)*(1-zita_gp)*(-2+xi_gp+eta_gp-zita_gp);
dN5x =  1/8*(1+eta_gp)*(1-zita_gp)*(-1+2*xi_gp+eta_gp-zita_gp);
dN5e =  1/8*(1+xi_gp) *(1-zita_gp)*(-1+xi_gp+2*eta_gp-zita_gp);
dN5z = -1/8*(1+eta_gp)*(1+xi_gp) *(-1+xi_gp+eta_gp-2*zita_gp);

N6   =  1/4*(1-xi_gp^2)*(1+eta_gp)*(1-zita_gp);
dN6x = -1/2*xi_gp*(1+eta_gp)*(1-zita_gp);
dN6e =  1/4*(1-xi_gp^2)*(1-zita_gp);
dN6z = -1/4*(1-xi_gp^2)*(1+eta_gp);

N7   =  1/8*(1-xi_gp)*(1+eta_gp)*(1-zita_gp)*(-2-xi_gp+eta_gp-zita_gp);
dN7x = -1/8*(1+eta_gp)*(1-zita_gp)*(-1-2*xi_gp+eta_gp-zita_gp);
dN7e =  1/8*(1-xi_gp) *(1-zita_gp)*(-1-xi_gp+2*eta_gp-zita_gp);
dN7z = -1/8*(1+eta_gp)*(1-xi_gp) *(-1-xi_gp+eta_gp-2*zita_gp);

N8   =  1/4*(1-eta_gp^2)*(1-xi_gp)*(1-zita_gp);
dN8x = -1/4*(1-eta_gp^2)*(1-zita_gp);
dN8e = -1/2*eta_gp*(1-xi_gp)*(1-zita_gp);
dN8z = -1/4*(1-eta_gp^2)*(1-xi_gp);

N9   =  1/4*(1-zita_gp^2)*(1-xi_gp)*(1-eta_gp);
dN9x = -1/4*(1-zita_gp^2)*(1-eta_gp);
dN9e = -1/4*(1-zita_gp^2)*(1-xi_gp);
dN9z = -1/2*zita_gp*(1-xi_gp)*(1-eta_gp);

N10   =  1/4*(1-zita_gp^2)*(1+xi_gp)*(1-eta_gp);
dN10x =  1/4*(1-zita_gp^2)*(1-eta_gp);
dN10e = -1/4*(1-zita_gp^2)*(1+xi_gp);
dN10z = -1/2*zita_gp*(1+xi_gp)*(1-eta_gp);

N11   =  1/4*(1-zita_gp^2)*(1+xi_gp)*(1+eta_gp);
dN11x =  1/4*(1-zita_gp^2)*(1+eta_gp);
dN11e =  1/4*(1-zita_gp^2)*(1+xi_gp);
dN11z = -1/2*zita_gp*(1+xi_gp)*(1+eta_gp);

N12   =  1/4*(1-zita_gp^2)*(1-xi_gp)*(1+eta_gp);
dN12x = -1/4*(1-zita_gp^2)*(1+eta_gp);
dN12e =  1/4*(1-zita_gp^2)*(1-xi_gp);
dN12z = -1/2*zita_gp*(1-xi_gp)*(1+eta_gp);

N13   =  1/8*(1-xi_gp)*(1-eta_gp)*(1+zita_gp)*(-2-xi_gp-eta_gp+zita_gp);
dN13x = -1/8*(1-eta_gp)*(1+zita_gp)*(-1-2*xi_gp-eta_gp+zita_gp);
dN13e = -1/8*(1-xi_gp) *(1+zita_gp)*(-1-xi_gp-2*eta_gp+zita_gp);
dN13z =  1/8*(1-eta_gp)*(1-xi_gp) *(-1-xi_gp-eta_gp+2*zita_gp);

N14   =  1/4*(1-xi_gp^2)*(1-eta_gp)*(1+zita_gp);
dN14x = -1/2*xi_gp*(1-eta_gp)*(1+zita_gp);
dN14e = -1/4*(1-xi_gp^2)*(1+zita_gp);
dN14z =  1/4*(1-xi_gp^2)*(1-eta_gp);

N15   =  1/8*(1+xi_gp)*(1-eta_gp)*(1+zita_gp)*(-2+xi_gp-eta_gp+zita_gp);
dN15x =  1/8*(1-eta_gp)*(1+zita_gp)*(-1+2*xi_gp-eta_gp+zita_gp);
dN15e = -1/8*(1+xi_gp) *(1+zita_gp)*(-1+xi_gp-2*eta_gp+zita_gp);
dN15z =  1/8*(1-eta_gp)*(1+xi_gp) *(-1+xi_gp-eta_gp+2*zita_gp);

N16   =  1/4*(1-eta_gp^2)*(1+xi_gp)*(1+zita_gp);
dN16x =  1/4*(1-eta_gp^2)*(1+zita_gp);
dN16e = -1/2*eta_gp*(1+xi_gp)*(1+zita_gp);
dN16z =  1/4*(1-eta_gp^2)*(1+xi_gp);

N17   =  1/8*(1+xi_gp)*(1+eta_gp)*(1+zita_gp)*(-2+xi_gp+eta_gp+zita_gp);
dN17x =  1/8*(1+eta_gp)*(1+zita_gp)*(-1+2*xi_gp+eta_gp+zita_gp);
dN17e =  1/8*(1+xi_gp) *(1+zita_gp)*(-1+xi_gp+2*eta_gp+zita_gp);
dN17z =  1/8*(1+eta_gp)*(1+xi_gp) *(-1+xi_gp+eta_gp+2*zita_gp);

N18   =  1/4*(1-xi_gp^2)*(1+eta_gp)*(1+zita_gp);
dN18x = -1/2*xi_gp*(1+eta_gp)*(1+zita_gp);
dN18e =  1/4*(1-xi_gp^2)*(1+zita_gp);
dN18z =  1/4*(1-xi_gp^2)*(1+eta_gp);

N19   =  1/8*(1-xi_gp)*(1+eta_gp)*(1+zita_gp)*(-2-xi_gp+eta_gp+zita_gp);
dN19x = -1/8*(1+eta_gp)*(1+zita_gp)*(-1-2*xi_gp+eta_gp+zita_gp);
dN19e =  1/8*(1-xi_gp) *(1+zita_gp)*(-1-xi_gp+2*eta_gp+zita_gp);
dN19z =  1/8*(1+eta_gp)*(1-xi_gp) *(-1-xi_gp+eta_gp+2*zita_gp);

N20   =  1/4*(1-eta_gp^2)*(1-xi_gp)*(1+zita_gp);
dN20x = -1/4*(1-eta_gp^2)*(1+zita_gp);
dN20e = -1/2*eta_gp*(1-xi_gp)*(1+zita_gp);
dN20z =  1/4*(1-eta_gp^2)*(1-xi_gp);

Nvec = [N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20];
for q = 1:20
    N(1, 3*q-2) = Nvec(q);
    N(2, 3*q-1) = Nvec(q);
    N(3, 3*q  ) = Nvec(q);
end

Jprod(1,:) = [dN1x, dN2x, dN3x, dN4x, dN5x, dN6x, dN7x, dN8x, dN9x, dN10x, ...
              dN11x,dN12x,dN13x,dN14x,dN15x,dN16x,dN17x,dN18x,dN19x,dN20x];
Jprod(2,:) = [dN1e, dN2e, dN3e, dN4e, dN5e, dN6e, dN7e, dN8e, dN9e, dN10e, ...
              dN11e,dN12e,dN13e,dN14e,dN15e,dN16e,dN17e,dN18e,dN19e,dN20e];
Jprod(3,:) = [dN1z, dN2z, dN3z, dN4z, dN5z, dN6z, dN7z, dN8z, dN9z, dN10z, ...
              dN11z,dN12z,dN13z,dN14z,dN15z,dN16z,dN17z,dN18z,dN19z,dN20z];

end


function [B] = Assembla_B(Js,Jprod,ndxel)

dN_glob=(Js)^(-1)*Jprod;
B = zeros(6,60);
   for q=1:ndxel
       B(1,3*q-2)=dN_glob(1,q);
       B(2,3*q-1)=dN_glob(2,q);
       B(3,3*q)=dN_glob(3,q);
       B(4,3*q-2)=dN_glob(2,q);
       B(4,3*q-1)=dN_glob(1,q);
       B(5,3*q-1)=dN_glob(3,q);
       B(5,3*q)=dN_glob(2,q);
       B(6,3*q-2)=dN_glob(3,q);
       B(6,3*q)=dN_glob(1,q);
   end
end


function [dK,dM] = add_gauss_contribution(ui,vj,wk,coord,D,ro,ndxel)

    [Jprod,N] = crea_N_dN_new(ui,vj,wk);

    Js = Jprod * coord;

    detJ = det(Js);
    if detJ <= 0
        fprintf('\nERRORE: detJ = %.16e\n', detJ);
        fprintf('Gauss point: xi = %.6f, eta = %.6f, zita = %.6f\n', ui, vj, wk);
        disp('Coordinate elemento:');
        disp(coord);
        error('Jacobiano negativo o nullo: controlla ordine nodi Hexa20');
    end

    B = Assembla_B(Js,Jprod,ndxel);

    dK = B' * D * B * detJ;
    dM = ro * N' * N * detJ;

end


function A = assemblaggio_matrici(A,Ai,indx)

    n = length(indx);
    for i=1:n
        ii= indx(i);
        for j=1:n
            jj= indx(j);
            A(ii,jj) = A(ii,jj) + Ai(i,j);
        end
    end
end


function s=crea_modello_fem(s,ng)

    [xg,wg]= gauleg(-1.,1.,ng);
    s.N= s.nd*3;
    s.M = sparse(s.N, s.N);
    s.K = sparse(s.N, s.N);
    coord=zeros(20,3);
    Kq=sparse(60,60); Mq=sparse(60,60);
    for q=1:s.nel
        Kq=sparse(60,60); Mq=sparse(60,60);
        eq= s.el(q);
        indx=eq.indx;        idofs= eq.idofs;
        coord(:,1) = [s.p(indx).x]';
        coord(:,2) = [s.p(indx).y]';
        coord(:,3) = [s.p(indx).z]';
        Dq=matxD(eq.ni,eq.E);
        for i=1:ng
            ui= xg(i);  wui= wg(i);
            for j=1:ng
                vj= xg(j);  wvj= wg(j);
                for k=1:ng
                    wk= xg(k);  wwk= wg(k);
                    [dK,dM] = add_gauss_contribution(ui,vj,wk,coord,Dq,eq.ro,s.ndxel);
                    Kq= Kq+wui*wvj*wwk*dK;
                    Mq= Mq+wui*wvj*wwk*dM;
                    clear wk; clear wwk;
                end
                clear vj; clear wvj;
            end
            clear ui; clear wui;
        end

        s.K= assemblaggio_matrici(s.K,Kq,idofs);
        s.M= assemblaggio_matrici(s.M,Mq,idofs);
    end

    if s.nv>0
        s=assembla_vinc(s,ng);
    end

    if s.nf>0
        s=assembla_forza(s,ng);
    end

end


function s=assembla_vinc(s,ng)

    for i=1:s.nv
        vinc=s.vinc(i);
        eq=s.el(vinc.el);
        indx=eq.indx;
        idofs=eq.idofs;
        coord(:,1) = [s.p(indx).x]';
        coord(:,2) = [s.p(indx).y]';
        coord(:,3) = [s.p(indx).z]';

        Kv=crea_vinc_elastico(vinc,coord,ng,s.ndxel);

        s.K=assemblaggio_matrici(s.K,Kv,idofs);
    end

end


function Kv = crea_vinc_elastico(vinc,coord,ng,ndxel)

    Kv = zeros(ndxel*3,ndxel*3);

    toll = 1.e-12;

    u_fisso = abs(vinc.u(2)-vinc.u(1)) < toll;
    v_fisso = abs(vinc.v(2)-vinc.v(1)) < toll;
    w_fisso = abs(vinc.w(2)-vinc.w(1)) < toll;

    n_fissi = u_fisso + v_fisso + w_fisso;

    if n_fissi ~= 1
        error('Il vincolo elastico deve essere applicato su una faccia: una sola coordinata naturale deve essere fissa.');
    end

    Ks = diag(vinc.k);

    if u_fisso

        u0 = vinc.u(1);

        [xv,wv] = gauleg(vinc.v(1),vinc.v(2),ng);
        [xw,ww] = gauleg(vinc.w(1),vinc.w(2),ng);

        for j = 1:ng
            vj = xv(j);
            wvj = wv(j);

            for k = 1:ng
                wk = xw(k);
                wwk = ww(k);

                dKv = add_gauss_contribution_vincolo(u0,vj,wk,coord,Ks,'u');

                Kv = Kv + wvj*wwk*dKv;

            end
        end

    elseif v_fisso

        v0 = vinc.v(1);

        [xu,wu] = gauleg(vinc.u(1),vinc.u(2),ng);
        [xw,ww] = gauleg(vinc.w(1),vinc.w(2),ng);

        for i = 1:ng
            ui = xu(i);
            wui = wu(i);

            for k = 1:ng
                wk = xw(k);
                wwk = ww(k);

                dKv = add_gauss_contribution_vincolo(ui,v0,wk,coord,Ks,'v');

                Kv = Kv + wui*wwk*dKv;

            end
        end

    elseif w_fisso

        w0 = vinc.w(1);

        [xu,wu] = gauleg(vinc.u(1),vinc.u(2),ng);
        [xv,wv] = gauleg(vinc.v(1),vinc.v(2),ng);

        for i = 1:ng
            ui = xu(i);
            wui = wu(i);

            for j = 1:ng
                vj = xv(j);
                wvj = wv(j);

                dKv = add_gauss_contribution_vincolo(ui,vj,w0,coord,Ks,'w');

                Kv = Kv + wui*wvj*dKv;

            end
        end

    end

end


function dKv = add_gauss_contribution_vincolo(ui,vj,wk,coord,Ks,faccia)

[Jprod,N] = crea_N_dN_new(ui,vj,wk);

Js = Jprod * coord;

dx_du = Js(1,:);
dx_dv = Js(2,:);
dx_dw = Js(3,:);

switch faccia

    case 'u'
        dGamma = norm(cross(dx_dv,dx_dw));

    case 'v'
        dGamma = norm(cross(dx_du,dx_dw));

    case 'w'
        dGamma = norm(cross(dx_du,dx_dv));

    otherwise
        error('Faccia non riconosciuta.');

end

dKv = N' * Ks * N * dGamma;

end


function s=assembla_forza(s,ng)

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


function s = calcola_modello_modale(s)

    n_modi = query_integer_d('Numero modi da calcolare', 1, 200, 20);
    if isempty(n_modi), return; end
    [Vs,D] = eigs(s.K, s.M, n_modi, 'smallestabs');
    Vs = real(Vs);
    D  = real(D);
    lambda = condiziona(diag(D));
    s.freq = sqrt(lambda)/(2*pi);
    s.freq(s.freq < 0.01) = 0;
    [s.freq,idx]=sort(s.freq);
    s.V=Vs(:,idx);

end

function x= condiziona(x)
n= length(x); xmax= max(abs(x));  tol= xmax*1e-16;
for i=1:n
    if x(i)<tol
        x(i)=0.;
    end
end
end


function st = crea_modello_shell(R, h, L, n_circ, n_ax, n_thick, ro, ni, E, k_pen, file_el)

    if nargin < 11
        error('crea_modello_shell: servono 11 argomenti.');
    end
    if n_circ < 2
        error('n_circ deve essere >= 2 per chiudere il cilindro.');
    end

    st.ndxel    = 20;
    st.ndofsxel = st.ndxel*3;

    nat = [ -1 -1 -1;
             0 -1 -1;
             1 -1 -1;
             1  0 -1;
             1  1 -1;
             0  1 -1;
            -1  1 -1;
            -1  0 -1;
            -1 -1  0;
             1 -1  0;
             1  1  0;
            -1  1  0;
            -1 -1  1;
             0 -1  1;
             1 -1  1;
             1  0  1;
             1  1  1;
             0  1  1;
            -1  1  1;
            -1  0  1];

    NA = 2*n_circ;
    NB = 2*n_ax;
    NC = 2*n_thick;

    gid = zeros(NA, NB+1, NC+1);
    nd  = 0;
    p   = struct('x',{},'y',{},'z',{});
    for c = 0:NC
        r = R - h/2 + h*c/NC;
        for b = 0:NB
            zax = L*b/NB;
            for a = 0:NA-1
                if mod(a,2)+mod(b,2)+mod(c,2) <= 1
                    nd = nd + 1;
                    gid(a+1,b+1,c+1) = nd;
                    theta   = 2*pi*a/NA;
                    p(nd).x = r*cos(theta);
                    p(nd).y = r*sin(theta);
                    p(nd).z = zax;
                end
            end
        end
    end
    st.nd = nd;
    st.p  = p;

    nel = n_circ*n_ax*n_thick;
    el  = struct('indx',{},'idofs',{},'ro',{},'ni',{},'E',{});
    e   = 0;
    for et = 0:n_thick-1
        for eb = 0:n_ax-1
            for ec = 0:n_circ-1
                e = e + 1;
                indx = zeros(20,1);
                for m = 1:20
                    a  = mod(2*ec + nat(m,1) + 1, NA);
                    b  =     2*eb + nat(m,2) + 1;
                    c  =     2*et + nat(m,3) + 1;
                    indx(m) = gid(a+1, b+1, c+1);
                end
                if any(indx == 0)
                    error('Connettivita'' non valida, elemento %d.',e);
                end
                el(e).indx  = indx;
                el(e).idofs = el2idofs_shell(indx, st.ndofsxel);
                el(e).ro    = ro;
                el(e).ni    = ni;
                el(e).E     = E;
            end
        end
    end
    st.nel = nel;
    st.el  = el;

    if ~isempty(k_pen) && k_pen > 0
        nv = 0;
        vinc = struct('el',{},'u',{},'v',{},'w',{},'k',{});
        for et = 0:n_thick-1
            for ec = 0:n_circ-1
                e_z0 = et*n_ax*n_circ + 0*n_circ + ec + 1;
                nv = nv + 1;
                vinc(nv).el = e_z0;
                vinc(nv).u  = [-1; 1];
                vinc(nv).v  = [-1; -1];
                vinc(nv).w  = [-1; 1];
                vinc(nv).k  = [k_pen; k_pen; 0];
                e_zL = et*n_ax*n_circ + (n_ax-1)*n_circ + ec + 1;
                nv = nv + 1;
                vinc(nv).el = e_zL;
                vinc(nv).u  = [-1; 1];
                vinc(nv).v  = [1; 1];
                vinc(nv).w  = [-1; 1];
                vinc(nv).k  = [k_pen; k_pen; 0];
            end
        end
        st.nv   = nv;
        st.vinc = vinc;
    else
        st.nv = 0;
    end

    st.nf = 0;

    pf = fopen(file_el,'w');
    if pf < 0, error('Impossibile aprire %s.',file_el); end

    fprintf(pf,'%d %d %d %d\n', st.nd, st.nel, st.nv, st.nf);

    for i = 1:st.nd
        fprintf(pf,'%.10g %.10g %.10g\n', p(i).x, p(i).y, p(i).z);
    end

    for i = 1:st.nel
        fprintf(pf,'%d ', el(i).indx);
        fprintf(pf,'\n');
        fprintf(pf,'%.10g %.10g %.10g\n', el(i).ro, el(i).ni, el(i).E);
    end

    if st.nv > 0
        for i = 1:st.nv
            fprintf(pf,'%d %.10g %.10g %.10g %.10g %.10g %.10g %.10g %.10g %.10g\n', ...
                st.vinc(i).el, ...
                st.vinc(i).u(1), st.vinc(i).u(2), ...
                st.vinc(i).v(1), st.vinc(i).v(2), ...
                st.vinc(i).w(1), st.vinc(i).w(2), ...
                st.vinc(i).k(1), st.vinc(i).k(2), st.vinc(i).k(3));
        end
    end

    fclose(pf);
end

function v = el2idofs_shell(vnod, n)
    v = zeros(n,1);  nn = length(vnod);  k = 0;
    for i = 1:nn
        ii = 3*(vnod(i)-1);
        for j = 1:3
            k = k+1;  v(k) = ii+j;
        end
    end
end


function fig = various_plot(s,fig)

    stit = 'Tipologia Plot';

    vs = {'Mesh', ...
          'Mesh + nodi', ...
          'Mesh + nodi + Numerazione Elementi', ...
          'Cambia numero punti plottati',...
          'Chiudi Finestre',...
          'Esci'};

    ripeti = 1;

    while ripeti

        scelta = menu(stit, vs);

        switch scelta

            case 1
                if isempty(s)
                    error_window('Devi prima leggere il modello.', 'logo.jpg');
                else
                    fig = plotta_modello(s.el,s.p,fig,'k-');
                    hold on
                    plotta_facce_vincolate_e_caricate(s);
                end

            case 2
                if isempty(s)
                    error_window('Devi prima leggere il modello.', 'logo.jpg');
                else
                    fig = plotta_modello_nodi(s.el,s.p,fig);
                    hold on
                    plotta_facce_vincolate_e_caricate(s);
                end

            case 3
                if isempty(s)
                    error_window('Devi prima leggere il modello.', 'logo.jpg');
                else
                    fig = plotta_modello_nodi_elementi(s.el,s.p,fig);
                    hold on
                   plotta_facce_vincolate_e_caricate(s);
                end

            case 4
                get_Nplot(true);

            case 5
                close all hidden

            case 6
                ripeti=0;
        end
    end
end


function fig = plotta_modi(s,fig)

    vs='Quante frequenze vuoi stampare?';
    ancora=1;
    xmax=min(100,length(s.freq));
    xmin=1;
    xdef=10;
    while ancora
        n=query_integer_d(vs,xmin,xmax,xdef);
        ancora=0;
    end
    if isempty(n)
        return
    end
    stit=sprintf('Prime %d Frequenze Proprie',n);
    for i=1:n
        str{i}=sprintf('%d Freq Propria: %.4e [Hz]', i, s.freq(i));
    end
    print_window(str,stit);
    fig = 0;

    while ask_yes('Vuoi plottare un modo proprio?','si','no')
        ripeti=1;
        while ripeti
            scelta=menu('Che tipo di plot vuoi?', 'Massima deformazione', ...
                'Animato','Cambia numero punti plottati', ...
                'Cambia scale factor',...
                'Chiudi Finestre','Esci');
            switch scelta
                case 1
                    imodo = query_integer_d('Quale modo vuoi plottare?',1,length(s.freq),1);
                    if isempty(imodo)
                        return
                    end
                    modo=s.V(:,imodo);
                    vel=s.el;
                    nodi=s.p;
                    freq=s.freq(imodo);
                    fig=plotta_modo_max_def(modo,vel,nodi,freq,imodo,fig);
                case 2
                    imodo = query_integer_d('Quale modo vuoi animare?',1,length(s.freq),1);
                    if isempty(imodo)
                        return
                    end
                    modo=s.V(:,imodo);
                    vel=s.el;
                    nodi=s.p;
                    freq=s.freq(imodo);
                    fig=plotta_modo_animato(modo,vel,nodi,freq,imodo,fig);

                case 3
                    get_Nplot(true);
                case 4
                     get_sc(true);
                case 5
                    close all hidden
                case 6
                    ripeti=0;

            end
        end

    end
end


function [out,fig]= risposta_forzata(st,fig)

switch(menu('Risposta forzata',{'via Modello strutturale','via Modello modale'}));
    case 1
        [out,fig]=risposta_forzata_strutturale(st,fig);

    case 2
        [out,fig]=risposta_forzata_modale(st,fig);

    otherwise
        return
end

end


function [risp,fig] = risposta_forzata_strutturale(s,fig)

    vel=s.el;
    nodi=s.p;
    if ~s.nf
        risp = [];
        error_window('No Forces !!!','logo.jpg');
        return
    end

    M = s.M;
    K = s.K;

    if isfield(s,'C') && ~isempty(s.C)
        C = s.C;
    else
        C = zeros(size(M));
    end

    n = size(M,1);

    F0 = s.Forza(:);

    if length(F0) ~= n
        error('Dimensione errata: s.Forza deve avere dimensione ndof x 1.');
    end

    ft = scegli_forzante_temporale();

    T = ft.t(:);

    x0  = zeros(n,1);
    dx0 = zeros(n,1);
    y0  = [x0; dx0];

    [odesol,options] = scelta_ode_solver();

    [t,y] = odesol(@(t,y) ode_forzata_strutturale(t,y,M,C,K,F0,ft), ...
                   T,y0,options);

    risp.t  = t;
    risp.y  = y;
    risp.x  = y(:,1:n);
    risp.dx = y(:,n+1:2*n);
    risp.F0 = F0;
    risp.ft = ft;

    fig = plotta_risposta_forzata_animata(risp,vel,nodi,fig);

end

function dydt = ode_forzata_strutturale(t,y,M,C,K,F0,ft)

    n = size(M,1);

    x  = y(1:n);
    dx = y(n+1:2*n);

    alfa = interp1(ft.t,ft.x,t,'linear',0);

    Ft = F0 * alfa;

    ddx = M \ (Ft - C*dx - K*x);

    dydt = [dx; ddx];

end


function [risp,fig] = risposta_forzata_modale(s,fig)

    vel  = s.el;
    nodi = s.p;

    if ~s.nf
        risp = [];
        error_window('No Forces !!!','logo.jpg');
        return
    end

    V     = s.V;
    freq  = s.freq(:);
    ndof  = size(V,1);

    idx_flex = find(freq > 0.1);
    V_flex   = V(:, idx_flex);
    omega    = 2*pi*freq(idx_flex);
    nmodi    = length(omega);

    mm = diag(V_flex' * s.M * V_flex);
    km = diag(V_flex' * s.K * V_flex);

    zeta = query_double_d('Smorzamento modale zeta', 0, 1, 0.01);
    cm   = 2*zeta*omega(:) .* mm;

    F0   = s.Forza(:);
    Fm   = V_flex' * F0;

    ft = scegli_forzante_temporale();
    T  = ft.t(:);

    q0 = zeros(2*nmodi, 1);

    [odesol, options] = scelta_ode_solver();

    [t, yq] = odesol(@(t,y) ode_modale(t, y, mm, cm, km, Fm, ft), ...
                      T, q0, options);

    q  = yq(:, 1:nmodi);
    dq = yq(:, nmodi+1:2*nmodi);

    x  = q  * V_flex';
    dx = dq * V_flex';

    risp.t  = t;
    risp.y  = [x dx];
    risp.x  = x;
    risp.dx = dx;
    risp.F0 = F0;
    risp.ft = ft;

    fig = plotta_risposta_forzata_animata(risp, vel, nodi, fig);

end

function dydt = ode_modale(t, y, mm, cm, km, Fm, ft)

    n  = length(mm);
    q  = y(1:n);
    dq = y(n+1:2*n);

    alpha = interp1(ft.t, ft.x, t, 'linear', 0);

    ddq = (Fm*alpha - cm.*dq - km.*q) ./ mm;

    dydt = [dq; ddq];
end


function sig = scegli_forzante_temporale()

    v = {'Random', ...
         'Armonica', ...
         'Serie armoniche', ...
         'Serie armoniche smorzate', ...
         'Chirp', ...
         'Pseudo impulso', ...
         'Esci'};

    scelta = menu('Scegli forzante temporale',v);

    switch scelta
        case 1
            sig = genera_segnale_casuale();

        case 2
            sig = genera_segnale_armonico();

        case 3
            sig = genera_serie_armoniche();

        case 4
            sig = genera_serie_armoniche_smorzate();

        case 5
            sig = genera_segnale_chirp();

        case 6
            sig = genera_segnale_pseudo_impulso_area();

        otherwise
            error('Scelta forzante annullata.');
    end

    sig.t = (0:sig.N-1)/sig.fc;

end

function    s=genera_segnale_casuale()
    stitle= 'Genera segnale random';
    vs= {'N','fc [Hz]','Amin', 'Amax'};
    ancora= 1;
    xmin= [2,1e-6,-1e6,-1.e6];
    xmax= [100000000,1e6,1e6,1.e6];
    xdef= [1024,1000.,-100,100.];
    while ancora
        out= query_multiple_exit(stitle,vs,xmin,xmax,xdef);
        s.N= out(1); s.fc= out(2); Amin= out(3); Amax= out(4);
        if Amax>Amin  ancora=0; end
    end
    tmax= (s.N-1)/s.fc; t= linspace(0,tmax,s.N);
    s.x= Amin+(Amax-Amin)*rand(size(t));

end

function    s=genera_segnale_armonico()
    stitle= 'Genera segnale armonico';
    vs= {'N','fc [Hz]','Amplitude', 'Frequency [Hz]', 'Phase [deg]'};
    xmin= [2,1e-6,1e-6,1.e-6,0.];
    xmax= [100000000,1e6,1e10,1.e5,360.];
    xdef= [1024,1000.,10.,100.,30.];
    out= query_multiple_exit(stitle,vs,xmin,xmax,xdef);
    s.N= out(1); s.fc= out(2); A= out(3); w= 2*pi*out(4); ph= pi*out(5)/180;
    tmax= (s.N-1)/s.fc; t= linspace(0,tmax,s.N);
    s.x= A*sin(w*t+ph);

end

function    s=genera_serie_armoniche()
    stitle= 'Genera segnale serie armoniche';
    vs= {'N','fc [Hz]','Numero componenti','Amin','Amax',...
        'fmin [Hz]', 'fmax [Hz]'};
    ancora= 1;
    xmin= [2,1e-6,1,1e-6,1e-6,1e-6,1e-6];
    xmax= [100000000,1e6,1000,1e6,1e6,1e5,1e5];
    xdef= [1024,1000.,10,1.,10.,1,400.];
    while ancora
        out= query_multiple_exit(stitle,vs,xmin,xmax,xdef);
        s.N= out(1); s.fc= out(2); n= out(3);
        Amin= out(4); Amax= out(5);
        wmin= 2*pi*out(6); wmax= 2*pi*out(7);
        if Amax>Amin & wmax>wmin
            ancora=0;
        end
    end

    tmax= (s.N-1)/s.fc; t= linspace(0,tmax,s.N);
    vA= Amin+(Amax-Amin)*rand(n,1);
    vw= wmin+(wmax-wmin)*rand(n,1);
    vph= -pi+2*pi*rand(n,1);
    s.x= zeros(size(t));
    for i=1:n
        s.x= s.x+vA(i)*sin(vw(i)*t+vph(i));
    end

end

function    s=genera_serie_armoniche_smorzate()
    stitle= 'Genera segnale serie armoniche smorzate';
    vs= {'N','fc [Hz]','Numero componenti','Amin','Amax',...
        'fmin [Hz]', 'fmax [Hz]', 'zita min [%]', 'zita max [%]'};
    ancora= 1;
    xmin= [2,1e-6,1,1e-6,1e-6,1e-6,1e-6,1e-3,1e-3];
    xmax= [100000000,1e6,1000,1e6,1e6,1e5,1e5,100.,100.];
    xdef= [1024,1000.,10,1.,10.,1,400.,1.e-3,1.e-2];
    while ancora
        out= query_multiple_exit(stitle,vs,xmin,xmax,xdef);
        s.N= out(1); s.fc= out(2); n= out(3);
        Amin= out(4); Amax= out(5);
        wmin= 2*pi*out(6); wmax= 2*pi*out(7);
        zmin= out(8); zmax= out(9);
        if Amax>Amin & wmax>wmin & zmax>zmin &wmax<pi*s.fc
            ancora=0;
        end
    end

    tmax= (s.N-1)/s.fc; t= linspace(0,tmax,s.N);
    vA= Amin+(Amax-Amin)*rand(n,1);
    vw= wmin+(wmax-wmin)*rand(n,1);
    vzita= zmin+(zmax-zmin)*rand(n,1);
    vph= -pi+2*pi*rand(n,1);
    s.x= zeros(size(t));
    for i=1:n
        s.x= s.x+vA(i)*exp(-vzita(i)*vw(i)*t).*sin(vw(i)*t+vph(i));
    end

end

function s=genera_segnale_chirp()
    stitle= 'Genera segnale chirp';
    vs= {'N','fc [Hz]','f0 [Hz}','f1 [Hz]'};
    ancora= 1;
    xmin= [2,1e-6,0.,1e-6];
    xmax= [100000000,1e6,1e6,1e6];
    xdef= [1024,1000.,0.,100.];
    while ancora
        out= query_multiple_exit(stitle,vs,xmin,xmax,xdef);
        s.N= out(1); s.fc= out(2); f0= out(3); f1= out(4);
        fmax= 0.5*s.fc;
        if f1<fmax & f0<f1
            ancora=0;
        end
    end
    time= linspace(0,(s.N-1)/s.fc,s.N);
    s.x= chirp(time,f0,time(end),f1);
    s.X= fft(s.x);
    s.tipo='chirp';
    s.f0   = f0;
    s.f1   = f1;

end

function s = genera_segnale_pseudo_impulso_area()

stitle = 'Genera segnale pseudo impulso';

vs = {'N','fc [Hz]','Impulso I','t0 [s]','dt impulso [s]'};

xmin = [2, 1e-6, -1e10, 0, 1e-12];
xmax = [100000000, 1e6, 1e10, 1e10, 1e10];
xdef = [1024, 1000., 1., 0.01, 0.001];

ancora = 1;

while ancora

    out = query_multiple_exit(stitle,vs,xmin,xmax,xdef);

    if isempty(out)
        out = xdef;
    end

    s.N  = round(out(1));
    s.fc = out(2);
    Iimp = out(3);
    t0   = out(4);
    dt   = out(5);

    tmax = (s.N-1)/s.fc;

    if t0 >= 0 && t0 < tmax && dt > 0 && t0+dt <= tmax
        ancora = 0;
    else
        error_window('Pseudo impulso fuori dal range temporale','logo.jpg');
    end

end

tmax = (s.N-1)/s.fc;
t = linspace(0,tmax,s.N);

A = Iimp/dt;

s.x = zeros(size(t));
indx = t >= t0 & t <= t0+dt;
s.x(indx) = A;

s.t = t;

end


function [sol,opt] = scelta_ode_solver()

    vsol = {'ode45','ode15s','ode23','ode113','ode23t','ode23tb','ode23s'};

    is = menu('Scelta solutore ODE',vsol);

    if is == 0
        is = 1;
    end

    sol = str2func(vsol{is});

    RelTol = 1e-3;
    AbsTol = 1e-6;

    vstr = {'AbsTol','RelTol'};
    xmin = [eps,eps];
    xmax = [1e10,1];
    xdef = [AbsTol,RelTol];

    out = query_multiple_exit('Ode Options',vstr,xmin,xmax,xdef);

    if isempty(out)
        out = xdef;
    end

    AbsTol = out(1);
    RelTol = out(2);

    opt = odeset('RelTol',RelTol,'AbsTol',AbsTol);

end


function fig = plotta_risposta_forzata_animata(risp,vel,nodi,fig)

    sc = get_sc();
    L = dimensione_struttura(nodi);
    wmax = max_response_disp(risp.x);
    if wmax < eps
        scale_factor = 1;
    else
        scale_factor = sc*L/wmax;
    end
    [xlim0,ylim0,zlim0] = limiti_animazione(nodi,risp,scale_factor);
    nd = length(nodi);
    N = get_Nplot();
    nt = length(risp.t);
    nframe = 80;
    ncycle = 1;
    fig = set_fig(fig,'Risposta forzata animata');
    set(fig,'Toolbar','figure')
    set(fig,'MenuBar','figure')
    if nt > nframe
        vk = round(linspace(1,nt,nframe));
    else
        vk = 1:nt;
    end
    for c = 1:ncycle
        for iframe = 1:length(vk)
            if ~ishandle(fig)
                return
            end
            k = vk(iframe);
            xk = risp.x(k,:)' * scale_factor;
            nodi_def = nodi;
            for i = 1:nd
                ii = (i-1)*3;
                nodi_def(i).x = nodi(i).x + xk(ii+1);
                nodi_def(i).y = nodi(i).y + xk(ii+2);
                nodi_def(i).z = nodi(i).z + xk(ii+3);
            end
            cla
            hold on
            for i = 1:length(vel)
                plotta_el(vel(i), nodi, N, 'k--');
            end
            for i = 1:length(vel)
                plotta_el(vel(i), nodi_def, N, 'r-');
            end
            grid on
            view(3)
            xlim(xlim0); ylim(ylim0); zlim(zlim0);
            drawnow
        end
    end
end


function verifica_chirp_frf(risp, s)

    if isempty(risp) || isempty(risp.x)
        error_window('Nessuna risposta disponibile.', 'logo.jpg');
        return
    end

    if ~isfield(risp, 'ft') || ~isfield(risp.ft, 'tipo') || ~strcmp(risp.ft.tipo, 'chirp')
        print_window({'La verifica FRF richiede la forzante di tipo chirp.', ...
                      'Selezionare prima il chirp come forzante temporale.'}, ...
                     'Tipo forzante non valido');
        return
    end

    ndof   = size(risp.x, 2);
    n_nodi = ndof / 3;

    while 1
        switch menu('FRF Chirp', {'Seleziona nodo e plotta FRF', 'Esci'})
            case 0
                break
            case 1
                fig_nodi = plotta_modello_nodi(s.el, s.p, 0);
                hold on
                plotta_facce_vincolate_e_caricate(s);
                hold off

                print_window( ...
                    {'Il modello e'' stato plottato con la', ...
                     'numerazione dei nodi.', '', ...
                     'Ruota la figura per identificare', ...
                     'il nodo su cui eseguire la FRF,', ...
                     'poi premi OK per continuare.'}, ...
                    'Scegli nodo');

                    nodo = query_integer_d('Numero nodo per la FRF', 1, n_nodi, 1);

                if isempty(nodo), continue; end

                dir = menu('Direzione spostamento', ...
                           'x (dof 1)', 'y (dof 2)', 'z (dof 3)');
                if dir == 0, continue; end

                frf_plot(risp, s, nodo, dir, fig_nodi);

            case 2
                break
        end
    end
end

function frf_plot(risp, s, nodo, dir, fig)

    dirs  = {'x', 'y', 'z'};
    idof  = (nodo - 1)*3 + dir;

    dt   = 1 / risp.ft.fc;
    N    = risp.ft.N;
    fc   = risp.ft.fc;

    X    = fft(risp.x(:, idof)) / N;
    F    = fft(risp.ft.x)       / N;
    freq = (0:N-1) * fc / N;
    H    = X ./ F;

    f_max_plot = min(risp.ft.f1 * 1.1, fc / 2);
    idx        = freq > 0 & freq <= f_max_plot;

    fn = s.freq;

    fig_title = sprintf('FRF - Nodo %d, dir. %s', nodo, dirs{dir});
    fig = set_fig(fig, fig_title);

    subplot(2, 1, 1)
    semilogy(freq(idx), abs(H(idx)), 'b-', 'LineWidth', 1.2)
    hold on
    for k = 1:length(fn)
        if fn(k) <= f_max_plot
            xline(fn(k), 'r--', 'LineWidth', 0.8);
        end
    end
    hold off
    xlabel('Frequenza [Hz]')
    ylabel('|H(f)|  [m / N norm.]')
    legend('FRF  |X/F|', 'Frequenze proprie', 'Location', 'northeast')
    grid on

    subplot(2, 1, 2)
    plot(freq(idx), abs(F(idx)), 'k-', 'LineWidth', 1.2)
    xlabel('Frequenza [Hz]')
    ylabel('|F(f)|  [N norm.]')
    title('Spettro della forzante (chirp)')
    grid on

    drawnow
end


function confronta_freq_shell(st, freq_fem, nome_file)

    if ~contains(lower(nome_file), 'shell')
        print_window( ...
            {'Il modello che stai esaminando non e'' uno shell.', ...
             '', ...
             sprintf('File caricato: %s', nome_file), ...
             '', ...
             'La verifica analitica (Blevins, Donnell)', ...
             'e'' applicabile solo a modelli il cui nome', ...
             'file contiene "shell".'}, ...
            'Verifica non applicabile');
        return
    end

    nd = st.nd;
    x  = zeros(nd,1);
    y  = zeros(nd,1);
    z  = zeros(nd,1);
    for i = 1:nd
        x(i) = st.p(i).x;
        y(i) = st.p(i).y;
        z(i) = st.p(i).z;
    end

    r_all = sqrt(x.^2 + y.^2);
    R     = (max(r_all) + min(r_all)) / 2;
    h     = max(r_all) - min(r_all);
    L     = max(z) - min(z);

    ro = st.el(1).ro;
    ni = st.el(1).ni;
    E  = st.el(1).E;

    i_max = 20;
    j_max = 5;
    [freq_tab, f_min, ij_min] = freq_analitica_shell(R, h, L, ro, ni, E, i_max, j_max);

    f_an = [];
    for j = 1:j_max
        if ~isnan(freq_tab(1,j))
            f_an(end+1) = freq_tab(1,j);
        end
    end
    for i = 1:i_max
        for j = 1:j_max
            if ~isnan(freq_tab(i+1,j))
                f_an(end+1) = freq_tab(i+1,j);
                f_an(end+1) = freq_tab(i+1,j);
            end
        end
    end
    f_an = sort(f_an(:));

    toll_zero = 1e-2;
    freq_fem  = freq_fem(freq_fem > toll_zero);
    freq_fem  = sort(freq_fem(:));

    n_confronto = min([length(freq_fem), length(f_an), 20]);

    str = {};
    str{end+1} = 'Confronto frequenze: FEM vs Donnell (analitico)';
    str{end+1} = '';
    str{end+1} = sprintf('File: %s', nome_file);
    str{end+1} = sprintf('R = %.4g m,  h = %.4g m,  L = %.4g m', R, h, L);
    str{end+1} = sprintf('h/R = %.4g,  L/R = %.4g', h/R, L/R);
    str{end+1} = sprintf('ro = %.4g,  ni = %.4g,  E = %.4g', ro, ni, E);
    str{end+1} = sprintf('Fondamentale analitica: %.4f Hz  (i=%d, j=%d)', ...
                          f_min, ij_min(1), ij_min(2));
    str{end+1} = '';
    str{end+1} = 'Nota: ogni modo analitico con i>=1 e'' doppio (cos/sin)';
    str{end+1} = '';
    str{end+1} = '  Modo     f_FEM [Hz]   f_anal [Hz]   err [%]';
    str{end+1} = '  ----     ----------   -----------   -------';

    err_vec = zeros(n_confronto, 1);
    for im = 1:n_confronto
        err = (freq_fem(im) - f_an(im)) / f_an(im) * 100;
        err_vec(im) = abs(err);
        str{end+1} = sprintf('  %4d     %10.3f   %11.3f   %+7.2f', ...
                              im, freq_fem(im), f_an(im), err);
    end

    str{end+1} = '';
    str{end+1} = sprintf('Errore medio: %.2f %%', mean(err_vec));

    print_window(str, 'Verifica analitica shell');
end


function [freq_tab, f_min, ij_min] = freq_analitica_shell(R, h, L, ro, ni, E, i_max, j_max)

    if nargin < 7 || isempty(i_max),  i_max = 20;  end
    if nargin < 8 || isempty(j_max),  j_max = 5;   end

    k = h^2 / (12*R^2);
    c_freq = 1/(2*pi*R) * sqrt(E / (ro*(1-ni^2)));

    freq_tab = zeros(i_max+1, j_max);
    f_min    = Inf;
    ij_min   = [0, 1];

    for j = 1:j_max
        xi = j*pi*R / L;
        for i = 0:i_max
            s = i^2 + xi^2;

            K2 = 1 + 0.5*(3 - ni)*s + k*s^2;
            K1 = 0.5*(1 - ni) * ( (3 + 2*ni)*xi^2 + i^2 + s^2 ...
                 + (3 - ni)/(1 - ni) * k * s^3 );
            K0 = 0.5*(1 - ni) * ( (1 - ni^2)*xi^4 + k*s^4 );

            p   = [1, -K2, K1, -K0];
            rad = roots(p);
            rad = real(rad(abs(imag(rad)) < 1e-12*max(abs(rad)+1)));
            rad = rad(rad > 0);

            if isempty(rad)
                freq_tab(i+1, j) = NaN;
                continue
            end

            lambda_min = sqrt(min(rad));
            f_ij       = lambda_min * c_freq;

            freq_tab(i+1, j) = f_ij;

            if f_ij < f_min
                f_min  = f_ij;
                ij_min = [i, j];
            end
        end
    end

    str = {};
    str{end+1} = 'Frequenze analitiche - Donnell shell theory';
    str{end+1} = '';
    str{end+1} = sprintf('R = %.4g m,  h = %.4g m,  L = %.4g m', R, h, L);
    str{end+1} = sprintf('h/R = %.4g,  L/R = %.4g,  k = %.4e', h/R, L/R, k);
    str{end+1} = sprintf('ro = %.4g kg/m3,  ni = %.4g,  E = %.4g Pa', ro, ni, E);
    str{end+1} = '';

    riga = '  i\j  ';
    for j = 1:j_max
        riga = [riga, sprintf('   j=%-5d', j)];
    end
    str{end+1} = riga;

    sep = '  -----';
    for j = 1:j_max
        sep = [sep, '----------'];
    end
    str{end+1} = sep;

    for i = 0:i_max
        riga = sprintf('  i=%2d ', i);
        for j = 1:j_max
            f = freq_tab(i+1, j);
            if isnan(f)
                riga = [riga, sprintf('   %8s', '---')];
            else
                riga = [riga, sprintf('  %8.2f', f)];
            end
        end
        str{end+1} = riga;
    end

    str{end+1} = '';
    str{end+1} = sprintf('Frequenza fondamentale:  f_min = %.4f Hz   (i=%d, j=%d)', ...
                          f_min, ij_min(1), ij_min(2));

    print_window(str, 'Frequenze analitiche shell');
end


function st = rotate_model(st,ng, thx, thy, thz)

    if nargin < 3
        thx = 0;
        thy = 0;
        thz = 0;
    end

    stitle = 'Ruota Modello';

    theta = char(952);
    vs = { [theta '_x'], [theta '_y'], [theta '_z'] };

    xmin = [0., 0., 0.];
    xmax = [360, 360, 360];
    xdef = [thx, thy, thz];

    out = query_multiple_exit(stitle, vs, xmin, xmax, xdef);

    thx = deg2rad(out(1));
    thy = deg2rad(out(2));
    thz = deg2rad(out(3));

    Rx = Rx_new(thx);
    Ry = Ry_new(thy);
    Rz = Rz_new(thz);

    R = Rx * Ry * Rz;

    nodes = zeros(st.nd,3);

    for i = 1:st.nd
        nodes(i,1) = st.p(i).x;
        nodes(i,2) = st.p(i).y;
        nodes(i,3) = st.p(i).z;
    end

    nodes_rot = (R * nodes')';

    for i = 1:st.nd
        st.p(i).x = nodes_rot(i,1);
        st.p(i).y = nodes_rot(i,2);
        st.p(i).z = nodes_rot(i,3);
    end
 st=crea_modello_fem(st,ng);
 st=calcola_modello_modale(st);
end


function fig = plotta_modello(vel,nodi,fig,stile)

    N = get_Nplot();

    fig = set_fig(fig,'Plot mesh');

    hold on
    grid on
    axis equal
    view(3)

    set(fig,'Toolbar','figure')
    set(fig,'MenuBar','figure')

    xlabel('x')
    ylabel('y')
    zlabel('z')

    for i = 1:length(vel)
        plotta_el(vel(i),nodi,N,stile);
    end

    axis equal
    view(3)

    rotate3d(fig,'on')
    zoom(fig,'off')
    pan(fig,'off')

    drawnow

    hold off

end


function fig = plotta_modello_nodi(vel,nodi,fig)

    N = get_Nplot();
    fig = set_fig(fig,'Plot mesh con indx nodi');

    hold on
    grid on
    axis equal
    view(3)

    set(fig,'Toolbar','figure')
    set(fig,'MenuBar','figure')

    xlabel('x')
    ylabel('y')
    zlabel('z')

    for i = 1:length(vel)
        plotta_el(vel(i),nodi,N,'k-');
    end

    for i = 1:length(nodi)

        plot3(nodi(i).x,nodi(i).y,nodi(i).z,'ko', ...
            'MarkerFaceColor','k', ...
            'MarkerSize',5);

        text(nodi(i).x,nodi(i).y,nodi(i).z, ...
            ['  ' num2str(i)], ...
            'FontSize',8, ...
            'Color','r');

    end

    axis equal
    view(3)

    rotate3d(fig,'on')
    zoom(fig,'off')
    pan(fig,'off')

    drawnow
    hold off

end


function fig = plotta_modello_nodi_elementi(vel,nodi,fig)

    N = get_Nplot();

    fig = set_fig(fig,'Plot mesh con indx nodi e elementi');

    hold on
    grid on
    axis equal
    view(3)

    set(fig,'Toolbar','figure')
    set(fig,'MenuBar','figure')

    xlabel('x')
    ylabel('y')
    zlabel('z')

    for i = 1:length(vel)

        plotta_el(vel(i),nodi,N,'k-');

        pto = par2pto(0,0,0,vel(i),nodi);

        text(pto.x,pto.y,pto.z, ...
            num2str(i), ...
            'FontSize',10, ...
            'Color','b', ...
            'FontWeight','bold', ...
            'HorizontalAlignment','center');

    end

    for i = 1:length(nodi)

        plot3(nodi(i).x,nodi(i).y,nodi(i).z,'ko', ...
            'MarkerFaceColor','k', ...
            'MarkerSize',5);

        text(nodi(i).x,nodi(i).y,nodi(i).z, ...
            ['  ' num2str(i)], ...
            'FontSize',8, ...
            'Color','r');

    end

    axis equal
    view(3)

    rotate3d(fig,'on')
    zoom(fig,'off')
    pan(fig,'off')

    drawnow
    hold off

end


function plotta_modello_corrente(vel,nodi,N,stile)

    hold on
    grid on

    view(3)
    xlabel('x')
    ylabel('y')
    zlabel('z')
    for i = 1:length(vel)
        plotta_el(vel(i),nodi,N,stile);
    end

    view(3)
    rotate3d(gcf,'on')
    zoom(gcf,'off')
    pan(gcf,'off')
    drawnow
end


function plotta_el(el,p,N,stile)

   par = linspace(-1,1,N);

    eta = -1; zita = -1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        csi = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    eta = 1; zita = -1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        csi = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    eta = -1; zita = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        csi = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    eta = 1; zita = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        csi = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    csi = -1; zita = -1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        eta = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    csi = 1; zita = -1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        eta = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    csi = -1; zita = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        eta = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    csi = 1; zita = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        eta = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    csi = -1; eta = -1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        zita = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    csi = 1; eta = -1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        zita = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    csi = 1; eta = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        zita = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    csi = -1; eta = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        zita = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

end


function fig=plotta_modo_max_def(modo,vel,nodi,f,m,fig)

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

function L=dimensione_struttura_local(nodi)
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


function fig=plotta_modo_animato(modo,vel,nodi,f,m,fig)

sc = get_sc();
L= dimensione_struttura(nodi);  scale_factor= sc*L;
wmax=max_mode_disp(modo);
modo= modo*scale_factor/wmax;
nd= length(nodi);
N = get_Nplot();
nframe=40;
fig = set_fig(fig, sprintf('Modo #%d - f=%f [Hz]',m,f));
set(fig,'Toolbar','figure')
set(fig,'MenuBar','figure')
xn = [nodi.x]; yn = [nodi.y]; zn = [nodi.z];
max_def = max_mode_disp(modo) ;
margine = 0.1 * L;
xlim0 = [min(xn)-max_def-margine, max(xn)+max_def+margine];
ylim0 = [min(yn)-max_def-margine, max(yn)+max_def+margine];
zlim0 = [min(zn)-max_def-margine, max(zn)+max_def+margine];
ncycle=5;
ncycle = 5;
for c = 1:ncycle
    for iframe = 1:nframe
        if ~ishandle(fig)
            return
        end
        theta = 2*pi*(iframe-1)/nframe;
        alpha = sin(theta);
        nodi_def = nodi;
        for i = 1:nd
            ii = (i-1)*3;
            nodi_def(i).x = nodi(i).x + alpha*modo(ii+1);
            nodi_def(i).y = nodi(i).y + alpha*modo(ii+2);
            nodi_def(i).z = nodi(i).z + alpha*modo(ii+3);
        end
        cla
        hold on
        for i = 1:length(vel)
            plotta_el(vel(i), nodi, N, 'k--');
        end
        for i = 1:length(vel)
            plotta_el(vel(i), nodi_def, N, 'r-');
        end
        grid on
        view(3)
        xlim(xlim0); ylim(ylim0); zlim(zlim0);
        drawnow
    end
end

end


function plotta_facce_vincolate_e_caricate(st)

    nv = 0;  nf = 0;
    if isfield(st,'nv'),  nv = st.nv;  end
    if isfield(st,'nf'),  nf = st.nf;  end
    if nv == 0 && nf == 0,  return;  end

    N     = get_Nplot();
    N_arr = 5;
    par   = linspace(-1, 1, N);
    par_a = linspace(-0.8, 0.8, N_arr);
    toll  = 1e-12;
    hold on

    for iv = 1:nv
        v  = st.vinc(iv);
        el = st.el(v.el);
        xp = [];  yp = [];  zp = [];

        [xp, yp, zp] = campiona_faccia(v.u, v.v, v.w, el, st.p, par, toll);
        if isempty(xp),  continue;  end

        patch(xp, yp, zp, [0 0.8 0], ...
              'FaceAlpha', 0.25, ...
              'EdgeColor', [0 0.6 0], ...
              'LineStyle', '--', ...
              'LineWidth', 1.5);
    end

    if nf > 0
        L_str = dimensione_struttura(st.p);

        for q = 1:nf
            v  = st.F(q);
            el = st.el(v.el);
            px = v.p(1);  py = v.p(2);  pz = v.p(3);
            p_norm = sqrt(px^2 + py^2 + pz^2);
            if p_norm < 1e-30,  continue;  end

            ux = px/p_norm;  uy = py/p_norm;  uz = pz/p_norm;
            scale = 0.15 * L_str;

            u_fisso = abs(v.u(2) - v.u(1)) < toll;
            v_fisso = abs(v.v(2) - v.v(1)) < toll;
            w_fisso = abs(v.w(2) - v.w(1)) < toll;

            Xo = [];  Yo = [];  Zo = [];
            for ia = 1:N_arr
                for ib = 1:N_arr
                    a = par_a(ia);  b = par_a(ib);
                    if u_fisso
                        pto = par2pto(v.u(1), a, b, el, st.p);
                    elseif v_fisso
                        pto = par2pto(a, v.v(1), b, el, st.p);
                    elseif w_fisso
                        pto = par2pto(a, b, v.w(1), el, st.p);
                    else
                        continue
                    end
                    Xo(end+1) = pto.x;
                    Yo(end+1) = pto.y;
                    Zo(end+1) = pto.z;
                end
            end

            if isempty(Xo),  continue;  end

            quiver3(Xo, Yo, Zo, ...
                    ux*scale*ones(size(Xo)), ...
                    uy*scale*ones(size(Yo)), ...
                    uz*scale*ones(size(Zo)), ...
                    0, ...
                    'Color', [0.85 0 0], ...
                    'LineWidth', 1.5, ...
                    'MaxHeadSize', 0.5);
        end
    end

    hold off
end

function [xp, yp, zp] = campiona_faccia(u_range, v_range, w_range, el, p, par, toll)
    xp = [];  yp = [];  zp = [];
    N  = length(par);

    u_fisso = abs(u_range(2) - u_range(1)) < toll;
    v_fisso = abs(v_range(2) - v_range(1)) < toll;
    w_fisso = abs(w_range(2) - w_range(1)) < toll;

    if u_fisso
        u0 = u_range(1);
        for i = 1:N,    pto=par2pto(u0,par(i),-1,el,p); xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = 1:N,    pto=par2pto(u0,1,par(i),el,p);  xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = N:-1:1, pto=par2pto(u0,par(i),1,el,p);  xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = N:-1:1, pto=par2pto(u0,-1,par(i),el,p); xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end

    elseif v_fisso
        v0 = v_range(1);
        for i = 1:N,    pto=par2pto(par(i),v0,-1,el,p); xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = 1:N,    pto=par2pto(1,v0,par(i),el,p);  xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = N:-1:1, pto=par2pto(par(i),v0,1,el,p);  xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = N:-1:1, pto=par2pto(-1,v0,par(i),el,p); xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end

    elseif w_fisso
        w0 = w_range(1);
        for i = 1:N,    pto=par2pto(par(i),-1,w0,el,p); xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = 1:N,    pto=par2pto(1,par(i),w0,el,p);  xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = N:-1:1, pto=par2pto(par(i),1,w0,el,p);  xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
        for i = N:-1:1, pto=par2pto(-1,par(i),w0,el,p); xp(end+1)=pto.x; yp(end+1)=pto.y; zp(end+1)=pto.z; end
    end
end

function L = dimensione_struttura(nodi)
    nd = length(nodi);
    x  = [nodi.x];  y = [nodi.y];  z = [nodi.z];
    L  = sqrt((max(x)-min(x))^2 + (max(y)-min(y))^2 + (max(z)-min(z))^2);
end


function pto = par2pto(csi,eta,zita,el,p)

    vN = vN_Hexa20(csi,eta,zita);

    pto.x = 0;
    pto.y = 0;
    pto.z = 0;

    for i = 1:20

        ig = el.indx(i);

        pto.x = pto.x + vN(i)*p(ig).x;
        pto.y = pto.y + vN(i)*p(ig).y;
        pto.z = pto.z + vN(i)*p(ig).z;

    end

end

function vN = vN_Hexa20(xi,eta,zita)

    vN = zeros(20,1);

    vN(1) = 1/8*(1-xi)*(1-eta)*(1-zita)*(-2-xi-eta-zita);

    vN(3) = 1/8*(1+xi)*(1-eta)*(1-zita)*(-2+xi-eta-zita);

    vN(5) = 1/8*(1+xi)*(1+eta)*(1-zita)*(-2+xi+eta-zita);

    vN(7) = 1/8*(1-xi)*(1+eta)*(1-zita)*(-2-xi+eta-zita);

    vN(13) = 1/8*(1-xi)*(1-eta)*(1+zita)*(-2-xi-eta+zita);

    vN(15) = 1/8*(1+xi)*(1-eta)*(1+zita)*(-2+xi-eta+zita);

    vN(17) = 1/8*(1+xi)*(1+eta)*(1+zita)*(-2+xi+eta+zita);

    vN(19) = 1/8*(1-xi)*(1+eta)*(1+zita)*(-2-xi+eta+zita);

    vN(2) = 1/4*(1-xi^2)*(1-eta)*(1-zita);

    vN(6) = 1/4*(1-xi^2)*(1+eta)*(1-zita);

    vN(14) = 1/4*(1-xi^2)*(1-eta)*(1+zita);

    vN(18) = 1/4*(1-xi^2)*(1+eta)*(1+zita);

    vN(4) = 1/4*(1+xi)*(1-eta^2)*(1-zita);

    vN(8) = 1/4*(1-xi)*(1-eta^2)*(1-zita);

    vN(16) = 1/4*(1+xi)*(1-eta^2)*(1+zita);

    vN(20) = 1/4*(1-xi)*(1-eta^2)*(1+zita);

    vN(9) = 1/4*(1-xi)*(1-eta)*(1-zita^2);

    vN(10) = 1/4*(1+xi)*(1-eta)*(1-zita^2);

    vN(11) = 1/4*(1+xi)*(1+eta)*(1-zita^2);

    vN(12) = 1/4*(1-xi)*(1+eta)*(1-zita^2);

end


function Nplot = get_Nplot(reset)

persistent Nplot_saved

if nargin < 1
    reset = false;
end

if reset
    Nplot_saved = [];
end

if isempty(Nplot_saved)

    vs = 'Quanti punti per spigolo vuoi plottare?';
    xmin = 2;
    xmax = 10000;
    xdef = 100;

    Nplot_saved = query_integer_d(vs, xmin, xmax, xdef);
    if isempty(Nplot_saved), return; end

end

Nplot = Nplot_saved;

end


function sc = get_sc(reset)

persistent sc_saved

if nargin < 1
    reset = false;
end

if reset
    sc_saved = [];
end

if isempty(sc_saved)

    vs = 'Inserisci scale factor per il plot';
    xmin = 0;
    xmax = 100;
    xdef = 0.1;

    sc_saved = query_double_d(vs, xmin, xmax, xdef);
    if isempty(sc_saved), return; end

end

sc = sc_saved;

end


function [xlim0,ylim0,zlim0] = limiti_animazione(nodi,risp,scale_factor)

nd = length(nodi);

x0 = zeros(nd,1);
y0 = zeros(nd,1);
z0 = zeros(nd,1);

for i = 1:nd
    x0(i) = nodi(i).x;
    y0(i) = nodi(i).y;
    z0(i) = nodi(i).z;
end

max_def = max_response_disp(risp.x) * scale_factor;

xmin = min(x0) - max_def;
xmax = max(x0) + max_def;

ymin = min(y0) - max_def;
ymax = max(y0) + max_def;

zmin = min(z0) - max_def;
zmax = max(z0) + max_def;

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


function wmax = max_response_disp(X)

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


function w=max_mode_disp_standalone(v)
nv= length(v);  n=nv/3;  w=0;
for i=1:n
    ii= (i-1)*3;
    Li=norm(v(ii+1:ii+3));
    if Li>w  w=Li; end
end
end


function L=dimensione_struttura_standalone(nodi)
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


function R = Rx_new(th)

R = [1 0 0 ;
    0 cos(th) -sin(th);
    0 sin(th) cos(th)];
end


function R = Ry_new(th)

R = [cos(th) 0 sin(th) ;
    0 1 0;
    -sin(th) 0 cos(th)];
end


function R = Rz_new(th)

R = [cos(th) -sin(th) 0;
    sin(th) cos(th) 0;
    0 0 1];
end


function [file,name]= query_file(dir,mask,permission,title)

    if nargin<4
        title= 'Get File';
    end
    if  nargin <3
        permission= 'r';
    end
    if nargin<2
        mask= '.*';
    end
    if  nargin<1
        dir= '.\';
    end

    switch permission
        case 'r'
            [fname,fpath]= uigetfile(sprintf('%s\\%s',dir,mask),title);
        case 'w'
            [fname,fpath]= uiputfile(sprintf('%s\\%s',dir,mask),title);
        otherwise
            errordlg('Error in query_file()');
    end
    if ischar(fpath) && ischar(fname)
        file=sprintf('%s%s',fpath, fname);
        indx= strfind(fname,mask);
        if ~isempty(indx)
            name= fname(1:indx-1);
        else
            name= fname;
        end
    else
        file= [];  name=[];
    end
end


function x= query_integer_d(s,xmin,xmax,xdef)

ss= sprintf('%s [%d,%d]: ',s,xmin,xmax);

while(1)
	answer= char(inputdlg(ss,'Query',1,cellstr(sprintf('%d',xdef))));
	if(length(answer)==0)
	   x = []; return;
	end
   x= sscanf(answer,'%d');
   if x<=xmax & x>=xmin
   	break
   end
end
return


function x = query_double_d(s,xmin,xmax,xdef)

ss = sprintf('%s [%g,%g]: ',s,xmin,xmax);

while 1

    answer = inputdlg(ss,'Query',1,cellstr(sprintf('%g',xdef)));

    if isempty(answer)
        x = []; return;
    end

    answer = char(answer);

    x = sscanf(answer,'%f');

    if ~isempty(x) && x <= xmax && x >= xmin
        break
    end

end

end


function x= query_multiple_exit(stitle,s,xmin,xmax,xdef)

    lineNo= 1;
    n= length(xmin);
    for i=1:n
        if isfinite(xdef(i))
            def(i)= cellstr(sprintf('%f',xdef(i)));
        else
            def(i)= cellstr(sprintf(''));
        end
        ss(i)= cellstr(sprintf('%s [%f,%f]: ',char(s(i)),xmin(i),xmax(i)));
    end

    again= 1;
    while again
        again= 0;
        answer= char(inputdlg(ss,stitle,lineNo,def));
        if(isempty(answer))
            x=[];  break
        end
        x= str2num(answer);
        for i=1:n
            if x(i)>xmax(i) | x(i)<xmin(i)
                again= 1;
                break
            end
        end
    end
end


function print_window(str,stit)
   msgbox(str,stit);
return


function error_window(msg,icon_file)

    if nargin<2 | ~exist(icon_file)
        msgbox(msg,'Error','error');
    else
        msgbox(msg,'Error','custom',imread(icon_file));
    end
end


function fig= set_fig(fig,title)

    fig= fig+1; figure(fig);
    set(gcf,'Name',title,'NumberTitle','off');
end


function x= ask_yes(s,yes,no)
    ss= sprintf('%s [%s,%s]: ',s,yes,no);
    answer=questdlg(s,'Query',yes,no,yes);
    if strcmp(answer,no)
        x=0;
    else
        x=1;
    end
end
