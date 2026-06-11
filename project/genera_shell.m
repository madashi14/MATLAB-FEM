R   = 1.0;
L   = 4.0;
h   = 0.5;

E   = 210e9;
nu  = 0.30;
rho = 7800;

nx     = 6;
ntheta = 8;
nr     = 1;

ngp = 3;

genera_shell_cilindrico_Hexa20('shell_test.el', ...
    R,L,h,nx,ntheta,nr,E,nu,rho,ngp);

function genera_shell_cilindrico_Hexa20(nomefile,R,L,h,nx,ntheta,nr,E,nu,rho,ngp)
% GENERA_SHELL (script di esempio)
% Script che genera un file .el di un guscio cilindrico discretizzato
% con elementi solidi Hexa20, usando parametri geometrici e materiali
% definiti nelle variabili locali.
%
% Parametri usati:
%   R      = raggio medio [m]
%   L      = lunghezza [m]
%   h      = spessore [m]
%   E, nu, rho = proprieta' materiale
%   nx, ntheta, nr = discretizzazione
%   ngp    = punti di Gauss per direzione
%
% Chiama internamente genera_shell_cilindrico_Hexa20 per generare il file.

    if R <= 0
        error('R deve essere positivo.');
    end

    if L <= 0
        error('L deve essere positivo.');
    end

    if h <= 0
        error('h deve essere positivo.');
    end

    if h >= 2*R
        error('h troppo grande: deve essere h < 2R.');
    end

    if nx < 1 || ntheta < 3 || nr < 1
        error('Servono nx >= 1, ntheta >= 3, nr >= 1.');
    end

    % Numero di divisioni quadratiche.
    % Ogni elemento Hexa20 occupa due intervalli nella griglia parametrica.
    Nx = 2*nx + 1;
    Nt = 2*ntheta;       % periodico: il punto 2*pi coincide con 0
    Nr = 2*nr + 1;

    % Mappa logica -> indice nodo globale.
    % map(ix,it,ir), con:
    % ix = 1,...,Nx
    % it = 1,...,Nt
    % ir = 1,...,Nr
    map = zeros(Nx,Nt,Nr);

    nodi = [];

    id = 0;

    for ix = 1:Nx

        x = (ix-1)/(Nx-1)*L;

        for it = 1:Nt

            theta = -(it-1)/Nt * 2*pi;

            for ir = 1:Nr

                r = R - h/2 + (ir-1)/(Nr-1)*h;

                y = r*cos(theta);
                z = r*sin(theta);

                id = id + 1;

                map(ix,it,ir) = id;

                nodi(id,1) = x;
                nodi(id,2) = y;
                nodi(id,3) = z;

            end
        end
    end

    nd = size(nodi,1);
    nel = nx*ntheta*nr;

    elem = zeros(nel,20);

    e = 0;

    for ex = 1:nx

        ix0 = 2*(ex-1) + 1;
        ix1 = ix0 + 1;
        ix2 = ix0 + 2;

        for et = 1:ntheta

            it0 = 2*(et-1) + 1;
            it1 = it0 + 1;
            it2 = it0 + 2;

            % Periodicità circonferenziale.
            it0 = wrap_theta(it0,Nt);
            it1 = wrap_theta(it1,Nt);
            it2 = wrap_theta(it2,Nt);

            for er = 1:nr

                ir0 = 2*(er-1) + 1;
                ir1 = ir0 + 1;
                ir2 = ir0 + 2;

                e = e + 1;

               % Convenzione locale:
                %
                % csi  -> direzione x
                % eta  -> direzione theta
                % zita -> direzione r
                %
                % Ordine richiesto dal professore:
                %
                % 1  = (-1,-1,-1)
                % 2  = ( 0,-1,-1)
                % 3  = ( 1,-1,-1)
                % 4  = ( 1, 0,-1)
                % 5  = ( 1, 1,-1)
                % 6  = ( 0, 1,-1)
                % 7  = (-1, 1,-1)
                % 8  = (-1, 0,-1)
                %
                % 9  = (-1,-1, 0)
                % 10 = ( 1,-1, 0)
                % 11 = ( 1, 1, 0)
                % 12 = (-1, 1, 0)
                %
                % 13 = (-1,-1, 1)
                % 14 = ( 0,-1, 1)
                % 15 = ( 1,-1, 1)
                % 16 = ( 1, 0, 1)
                % 17 = ( 1, 1, 1)
                % 18 = ( 0, 1, 1)
                % 19 = (-1, 1, 1)
                % 20 = (-1, 0, 1)
                
                n1  = map(ix0,it0,ir0);
                n3  = map(ix2,it0,ir0);
                n5  = map(ix2,it2,ir0);
                n7  = map(ix0,it2,ir0);
                
                n13 = map(ix0,it0,ir2);
                n15 = map(ix2,it0,ir2);
                n17 = map(ix2,it2,ir2);
                n19 = map(ix0,it2,ir2);
                
                n2  = map(ix1,it0,ir0);
                n4  = map(ix2,it1,ir0);
                n6  = map(ix1,it2,ir0);
                n8  = map(ix0,it1,ir0);
                
                n9  = map(ix0,it0,ir1);
                n10 = map(ix2,it0,ir1);
                n11 = map(ix2,it2,ir1);
                n12 = map(ix0,it2,ir1);
                
                n14 = map(ix1,it0,ir2);
                n16 = map(ix2,it1,ir2);
                n18 = map(ix1,it2,ir2);
                n20 = map(ix0,it1,ir2);
                
                elem(e,:) = [n1 n2 n3 n4 n5 n6 n7 n8 ...
                             n9 n10 n11 n12 ...
                             n13 n14 n15 n16 n17 n18 n19 n20];
            end
        end
    end

    nvinc = 0;
    nforz = 0;

    fid = fopen(nomefile,'w');

    if fid == -1
        error('Impossibile aprire il file di output.');
    end

    fprintf(fid,'%d %d %d %d \n',nd,nel,nvinc,nforz);

    for i = 1:nd
        fprintf(fid,'%.16e %.16e %.16e\n',nodi(i,1),nodi(i,2),nodi(i,3));
    end

    for e = 1:nel
        fprintf(fid,'%d ',elem(e,1:19));
        fprintf(fid,'%d\n',elem(e,20));
        fprintf(fid,'%.16e %.16e %.16e\n',rho,nu,E);
    end

    fclose(fid);

    fprintf('\nFile generato correttamente: %s\n',nomefile);
    fprintf('Numero nodi     nd  = %d\n',nd);
    fprintf('Numero elementi nel = %d\n',nel);
    fprintf('Elementi: nx x ntheta x nr = %d x %d x %d\n',nx,ntheta,nr);
    fprintf('Raggio medio R = %.6g\n',R);
    fprintf('Lunghezza   L = %.6g\n',L);
    fprintf('Spessore    h = %.6g\n',h);
    fprintf('h/R           = %.6g\n\n',h/R);

end


function it = wrap_theta(it,Nt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WRAP_THETA
%
% Gestisce la periodicità lungo la circonferenza.
% Gli indici theta vanno da 1 a Nt.
% Se si supera Nt, si ritorna all'inizio.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    it = mod(it-1,Nt) + 1;

end