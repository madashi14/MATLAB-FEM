function plotta_el(el,p,N,stile)
% PLOTTA_EL
% Traccia i 12 spigoli di un elemento Hexa20 usando il mapping
% isoparametrico, in modo che ogni spigolo curvo venga rappresentato
% esattamente dalla geometria dell'elemento.
%
% Per ogni spigolo, fissa due coordinate naturali ai valori +-1 e
% fa variare la terza da -1 a +1 campionando N punti, trasformando
% ogni punto con par2pto e disegnando con plot3.
%
% INPUT:
%   el    : struttura elemento con el.indx (indici nodali globali)
%   p     : array dei nodi con campi .x, .y, .z
%   N     : numero di punti di campionamento per spigolo
%   stile : stringa stile MATLAB per plot3 (es. 'k-', 'r--')
%
% OUTPUT:
%   nessun output; disegna nella figura corrente

   par = linspace(-1,1,N);

    % =====================================================================
    % SPIGOLI PARALLELI A CSI
    % =====================================================================

    % Spigolo 1: eta = -1, zita = -1, csi variabile
    eta = -1; zita = -1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        csi = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    % Spigolo 2: eta = 1, zita = -1, csi variabile
    eta = 1; zita = -1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        csi = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    % Spigolo 3: eta = -1, zita = 1, csi variabile
    eta = -1; zita = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        csi = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    % Spigolo 4: eta = 1, zita = 1, csi variabile
    eta = 1; zita = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        csi = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);


    % =====================================================================
    % SPIGOLI PARALLELI A ETA
    % =====================================================================

    % Spigolo 5: csi = -1, zita = -1, eta variabile
    csi = -1; zita = -1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        eta = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    % Spigolo 6: csi = 1, zita = -1, eta variabile
    csi = 1; zita = -1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        eta = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    % Spigolo 7: csi = -1, zita = 1, eta variabile
    csi = -1; zita = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        eta = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    % Spigolo 8: csi = 1, zita = 1, eta variabile
    csi = 1; zita = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        eta = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);


    % =====================================================================
    % SPIGOLI PARALLELI A ZITA
    % =====================================================================

    % Spigolo 9: csi = -1, eta = -1, zita variabile
    csi = -1; eta = -1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        zita = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    % Spigolo 10: csi = 1, eta = -1, zita variabile
    csi = 1; eta = -1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        zita = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    % Spigolo 11: csi = 1, eta = 1, zita variabile
    csi = 1; eta = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        zita = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

    % Spigolo 12: csi = -1, eta = 1, zita variabile
    csi = -1; eta = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        zita = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,stile);

end