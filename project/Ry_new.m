function R = Ry_new(th)
% RY_NEW
% Calcola la matrice di rotazione attorno all'asse Y di un angolo th (in radianti).
%
% La rotazione segue la convenzione destra: applicata al vettore colonna
% [x; y; z], ruota x e z mantenendo y invariato.
%
% INPUT:
%   th : angolo di rotazione in radianti
%
% OUTPUT:
%   R  : matrice di rotazione 3x3 attorno all'asse Y
R = [cos(th) 0 sin(th) ;
    0 1 0;
    -sin(th) 0 cos(th)];
end
