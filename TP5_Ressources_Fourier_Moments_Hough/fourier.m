function [c,M] = fourier(v,N)

% calcul des descripteurs de Fourier quelle que soit la longueur du vecteur v
% N = nb de descripteurs souhaités au total
% Sortie: vecteur des descripteurs c (de degrés -(N-1)/2 à (N-1)/2), longueur M du vecteur v d'entrée

% Auteur: Isabelle QUIDU
% Annee : 2014
% ENSTA Bretagne, France

% précaution si N est pair
if (round(N/2) == N/2)
  disp('N doit etre impair!!!')
  N = N+1;
end
M = length(v);

% %%%%%%%%%%%%%%%%%%%%%%%%%
% base 
% %%%%%%%%%%%%%%%%%%%%%%%%%
omega = exp(-2*1j*pi/M);


% %%%%%%%%%%%%%%%%%%%%%%%%%
%  descripteurs
% %%%%%%%%%%%%%%%%%%%%%%%%% 
for kk = [-(N-1)/2 : (N-1)/2] % boucle sur les indices des coefficients de Fourier
  C = v.*(omega.^((0:length(v)-1)').^kk);
  c(kk+((N-1)/2)+1,1) = (sum(C))/M;
end