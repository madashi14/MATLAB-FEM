function fig = plotta_modello_nodi_elementi(vel,nodi,fig)
% PLOTTA_MODELLO_NODI_ELEMENTI
% Disegna la mesh del modello FEM con la numerazione di nodi e elementi.
% Per ogni elemento disegna i 12 spigoli e posiziona il numero dell'elemento
% al suo centro geometrico (origine delle coordinate naturali). Per ogni
% nodo disegna un pallino nero e il suo numero in rosso.
%
% INPUT:
%   vel  : array di strutture elemento (s.el)
%   nodi : array di strutture nodo con campi .x, .y, .z
%   fig  : indice della figura corrente
%
% OUTPUT:
%   fig : indice della nuova figura aperta

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