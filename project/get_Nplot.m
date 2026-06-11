function Nplot = get_Nplot(reset)
% GET_NPLOT
% Restituisce il numero di punti da usare per la visualizzazione di
% ogni spigolo degli elementi (risoluzione del plot isoparametrico).
% Il valore e' memorizzato in una variabile persistente: la prima volta
% (o dopo un reset) viene chiesto all'utente tramite finestra di dialogo;
% le volte successive viene restituito senza richiedere nuovamente l'input.
%
% INPUT:
%   reset : (opzionale) se true, cancella il valore memorizzato e
%           richiede nuovamente l'input all'utente
%
% OUTPUT:
%   Nplot : numero di punti per spigolo (intero, tipicamente 10-100)

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