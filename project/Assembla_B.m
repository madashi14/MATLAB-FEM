function [B] = Assembla_B(Js,Jprod,ndxel)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ASSEMBLA_B
%
% Costruisce la matrice B deformazioni-spostamenti dell'elemento Hexa20.
%
% La funzione trasforma le derivate delle funzioni di forma dalle
% coordinate naturali alle coordinate globali tramite il Jacobiano:
%
%       dN_glob = inv(J) * dN_nat
%
% dove:
%   Js    : matrice Jacobiana dell'elemento
%   Jprod : derivate delle funzioni di forma rispetto a xi, eta, zita
%
% La matrice B lega il vettore degli spostamenti nodali al vettore delle
% deformazioni:
%
%       epsilon = B * u
%
% con:
%
%       epsilon = [eps_x eps_y eps_z gamma_xy gamma_yz gamma_xz]^T
%
% INPUT:
%   Js    : matrice Jacobiana 3x3
%   Jprod : matrice 3x20 delle derivate naturali delle funzioni di forma
%   st    : struttura del modello FEM
%
% OUTPUT:
%   B     : matrice deformazioni-spostamenti 6x60
%
% Riferimento bibliografico:
%   Cook, R. D., Malkus, D. S., & Plesha, M. E.
%   Concepts and Applications of Finite Element Analysis,
%   Third Edition, John Wiley & Sons.
%
% Federico Nanni 10-2026
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dN_glob=(Js)^(-1)*Jprod;
B = zeros(6,60);
   for q=1:ndxel
       B(1,3*q-2)=dN_glob(1,q);
       B(2,3*q-1)=dN_glob(2,q);
       B(3,3*q)=dN_glob(3,q);
       B(4,3*q-2)=dN_glob(2,q);
       B(4,3*q-1)=dN_glob(1,q);
       B(5,3*q-1)=dN_glob(3,q);
       B(5,3*q)=dN_glob(2,q);
       B(6,3*q-2)=dN_glob(3,q);
       B(6,3*q)=dN_glob(1,q);
   end
end

