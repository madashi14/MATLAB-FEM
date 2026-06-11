function x = query_double_d(s,xmin,xmax,xdef)
% QUERY_DOUBLE_D
% Mostra una finestra di dialogo e chiede all'utente di inserire un
% numero reale (double) compreso nell'intervallo [xmin, xmax].
% Ripete la richiesta finche' il valore non e' valido.
% Termina con errore se l'utente preme Annulla.
%
% INPUT:
%   s    : stringa con la descrizione della variabile
%   xmin : valore minimo accettabile
%   xmax : valore massimo accettabile
%   xdef : valore di default proposto
%
% OUTPUT:
%   x : valore reale inserito dall'utente

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