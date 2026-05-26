function fig = various_plot(s,fig)
    stit = 'Tipologia Plot';
    
    vs = {'Mesh', ...
          'Mesh + nodi', ...
          'Mesh + nodi + Numerazione Elementi', ...
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
                    fig = plotta_modello(s.el,s.p,fig);
                end
    
    
            case 2
                if isempty(s)
                    error_window('Devi prima leggere il modello.', 'logo.jpg');
                else
                    fig = plotta_modello_nodi(s.el,s.p,fig);
                end
    
            case 3
                if isempty(s)
                    error_window('Devi prima leggere il modello.', 'logo.jpg');
                else
                    s = plotta_modello_nodi_elementi(s.el,s.p,fig);
                end
            case 4
                close all hidden
            case 5
                ripeti=0;
        end
    end
end