function fig = plotta_modello_nodi_elementi(vel,nodi,fig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTTA_MODELLO
%
% da commentare do nuovo
%
% Federico Nanni, Samuele Tocco. 02-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    vs='Quanti punti per spigolo vuoi plottare?';
    ancora=1;
    xmax=10000;
    xmin=2;
    xdef=100;
    while ancora
        N=query_integer_d(vs,xmin,xmax,xdef);
        ancora=0;
    end

    fig = set_fig(fig,'Plot meshatura');

    hold on
    grid on
    axis equal
    view(3)


    xlabel('x')
    ylabel('y')
    zlabel('z')

    for i = 1:length(vel)
        plotta_el(vel(i),nodi,N);
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



    hold off

end



function plotta_el(el,p,N)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTTA_EL
%
% Plotta i 12 spigoli di un elemento Hexa20 usando il mapping
% isoparametrico.
%
% Per ogni spigolo:
%   - si fissa una coppia di coordinate naturali;
%   - si fa variare la terza tra -1 e 1;
%   - si trasforma ogni punto naturale in coordinate globali con par2pto;
%   - si disegna lo spigolo con plot3.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    plot3(X,Y,Z,'k-');

    % Spigolo 2: eta = 1, zita = -1, csi variabile
    eta = 1; zita = -1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        csi = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,'k-');

    % Spigolo 3: eta = -1, zita = 1, csi variabile
    eta = -1; zita = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        csi = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,'k-');

    % Spigolo 4: eta = 1, zita = 1, csi variabile
    eta = 1; zita = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        csi = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,'k-');


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
    plot3(X,Y,Z,'k-');

    % Spigolo 6: csi = 1, zita = -1, eta variabile
    csi = 1; zita = -1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        eta = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,'k-');

    % Spigolo 7: csi = -1, zita = 1, eta variabile
    csi = -1; zita = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        eta = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,'k-');

    % Spigolo 8: csi = 1, zita = 1, eta variabile
    csi = 1; zita = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        eta = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,'k-');


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
    plot3(X,Y,Z,'k-');

    % Spigolo 10: csi = 1, eta = -1, zita variabile
    csi = 1; eta = -1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        zita = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,'k-');

    % Spigolo 11: csi = 1, eta = 1, zita variabile
    csi = 1; eta = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        zita = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,'k-');

    % Spigolo 12: csi = -1, eta = 1, zita variabile
    csi = -1; eta = 1;
    X = zeros(N,1); Y = zeros(N,1); Z = zeros(N,1);
    for i = 1:N
        zita = par(i);
        pto = par2pto(csi,eta,zita,el,p);
        X(i) = pto.x; Y(i) = pto.y; Z(i) = pto.z;
    end
    plot3(X,Y,Z,'k-');

end

