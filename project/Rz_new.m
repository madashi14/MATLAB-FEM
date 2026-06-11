function R = Rz_new(th)
% RZ_NEW
% Calcola la matrice di rotazione attorno all'asse Z di un angolo th (in radianti).
%
% La rotazione segue la convenzione destra: applicata al vettore colonna
% [x; y; z], ruota x e y mantenendo z invariato.
%
% INPUT:
%   th : angolo di rotazione in radianti
%
% OUTPUT:
%   R  : matrice di rotazione 3x3 attorno all'asse Z
R = [cos(th) -sin(th) 0;
    sin(th) cos(th) 0;
    0 0 1];
end
