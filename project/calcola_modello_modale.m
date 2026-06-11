function s = calcola_modello_modale(s)
% CALCOLA_MODELLO_MODALE
% Calcola il modello modale della struttura risolvendo il problema agli
% autovalori generalizzato K*V = M*V*Lambda.
%
% Chiede all'utente quanti modi calcolare, poi usa eigs() per trovare
% i modi a frequenza piu' bassa. I risultati vengono ordinati in
% frequenza crescente.
%
% Frequenze negative o quasi-nulle (< 0.01 Hz) vengono azzerate
% (sono artefatti numerici dei modi rigidi).
%
% INPUT:
%   s : struttura con s.K (rigidezza) e s.M (massa) gia' assemblate
%
% OUTPUT:
%   s : struttura aggiornata con:
%         s.freq : vettore delle frequenze proprie [Hz], ordinate
%         s.V    : matrice degli autovettori (modi propri), colonne ordinate
    n_modi = query_integer_d('Numero modi da calcolare', 1, 200, 20);
    if isempty(n_modi), return; end
    [Vs,D] = eigs(s.K, s.M, n_modi, 'smallestabs');
    Vs = real(Vs);
    D  = real(D);
    lambda = condiziona(diag(D));
    s.freq = sqrt(lambda)/(2*pi);
    s.freq(s.freq < 0.01) = 0;
    [s.freq,idx]=sort(s.freq);
    s.V=Vs(:,idx);

end

function x= condiziona(x)
n= length(x); xmax= max(abs(x));  tol= xmax*1e-16;
for i=1:n
    if x(i)<tol
        x(i)=0.;
    end
end
end
