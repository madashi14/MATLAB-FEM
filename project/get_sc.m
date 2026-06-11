function sc = get_sc(reset)
% GET_SC
% Restituisce il fattore di scala (scale factor) usato per amplificare
% la deformazione nella visualizzazione dei modi propri e della risposta.
% Il valore e' memorizzato in una variabile persistente: la prima volta
% (o dopo un reset) viene chiesto all'utente tramite finestra di dialogo;
% le volte successive viene restituito senza richiedere nuovamente l'input.
%
% INPUT:
%   reset : (opzionale) se true, cancella il valore memorizzato e
%           richiede nuovamente l'input all'utente
%
% OUTPUT:
%   sc : fattore di scala adimensionale (default 0.1)

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