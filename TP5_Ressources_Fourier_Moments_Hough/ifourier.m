function v = ifourier(c,N,M)

% tfd inverse 
% c : vecteur des descripteurs c (de degré -(N-1)/2 à (N-1)/2)
% N : nbre de coef pour la reconstruction du signal (N<=length(c))
% M : nbre de points traités

% Auteur: Isabelle QUIDU
% Annee : 2014
% ENSTA Bretagne, France

if (round(N/2) == N/2)
  disp('N doit etre impair!!!')
  N = N+1;
end
if (N>length(c))
  disp('N  trop gd !!!')
  return;
end

% %%%%%%%%%%%%%%%%%%%%%%%%%
% base 
% %%%%%%%%%%%%%%%%%%%%%%%%%
omega = exp(2*1j*pi/M);

% %%%%%%%%%%%%%%%%%%%%%%%%%
%  coefficients
% %%%%%%%%%%%%%%%%%%%%%%%%%
L = length(c);  % nb impair car 2K coeff + k=0
indN = [-(N-1)/2 : (N-1)/2]' ;
for ii = 1:M
  V = c((L-1)/2 + 1 +indN).*((omega^(ii-1)).^(indN));
  v(ii) = sum(V);  
end
