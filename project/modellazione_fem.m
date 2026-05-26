close all hidden
clc
clear

fig = 0;
mydir = './modelli';
s = [];

stit = 'Modellazione a Elementi finiti';

vs = {'Leggi modello', ...
      'Plotta Modello', ...
      'Analisi Modale', ...
      'Ruota Modello', ...
      'Chiudi Finestre',...
      'Esci'};

ripeti = 1;

while ripeti

    scelta = menu(stit, vs);

    switch scelta

        case 1
            s = leggi_modello(mydir);
            s = crea_modello_fem(s);

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
                s = analisi_modale(s);
                % anima_modo(s);
            end


        case 4
            if isempty(s)
                error_window('Devi prima leggere il modello.', 'logo.jpg');
            else
                s = rotate_model(s);
            end

        case 5
            close all hidden
        case 6
            ripeti=0;
            

        case 0
            ripeti = 0;

        otherwise
            msg = sprintf('Opzione %d non implementata', scelta);
            error_window(msg, 'logo.jpg');

    end
end