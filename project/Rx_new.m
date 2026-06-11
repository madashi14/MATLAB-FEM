function R = Rx_new(th)
% RX_NEW
% Calcola la matrice di rotazione attorno all'asse X di un angolo th (in radianti).
%
% La rotazione segue la convenzione destra: applicata al vettore colonna
% [x; y; z], ruota y e z mantenendo x invariato.
%
% INPUT:
%   th : angolo di rotazione in radianti
%
% OUTPUT:
%   R  : matrice di rotazione 3x3 attorno all'asse X
R = [1 0 0 ;
    0 cos(th) -sin(th);
    0 sin(th) cos(th)];
end