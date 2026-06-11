function N = get_Ngauss(reset)
% GET_NGAUSS
% Restituisce il numero di punti di Gauss per direzione da usare
% nell'integrazione numerica. Il valore e' memorizzato in una variabile
% persistente: la prima volta (o dopo un reset) viene chiesto all'utente
% tramite finestra di dialogo; le volte successive viene restituito
% il valore memorizzato senza richiedere nuovamente l'input.
%
% INPUT:
%   reset : (opzionale) se true, cancella il valore memorizzato e
%           richiede nuovamente l'input all'utente
%
% OUTPUT:
%   N : numero di punti di Gauss per direzione (intero, tipicamente 2-5)

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