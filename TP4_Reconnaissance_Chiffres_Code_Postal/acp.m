function [kmat, pes] = acp(pen, seuil)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                          %                             %
%%   Author  :  Jean-Christophe Cexus       %                             %
%%              Oct. 2023.                  %         ENSTA - Bretagne    %
%%                                          %                             %
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analyse en Composantes Principales
%
% [kmat,pes]=acp(pen,seuil);
%
% pen   - matrice des vecteurs a projeter
% seuil - si superieur à 1, represente la dimension de l'espace de projection
%         si inferieur à 1, represente le pourcentage de l'inertie conservée
% kmat  - matrice de projection
% pes   - matrice des vecteurs projetes
%
%
% Exemple:
% pen=randn(3,1000);
% [kmat,pes]=acp(pen,2);
% figure;plot3(pen(1,:),pen(2,:),pen(3,:),'xr')
% grid;xlabel('x');ylabel('y');ylabel('z')
% title('Vecteurs dans l''espace initial')
% figure;plot(pes(1,:),pes(2,:),'xr')
% grid;xlabel('p_1');ylabel('p_2')
% title('Vecteurs projetes par ACP')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[nrc, nrv] = size(pen);
xr   = pen';
moy  = mean(xr);
sigx = cov(xr);             % Matrice de Covariance de xr
[vectp,valp] = eig(sigx);   % Matrice et Valeurs propres de sigx
valpVeri     = trace(sigx);
vlpr         = diag(valp);  % Valeurs propres de sigx
[ld,idx]     = sort(vlpr);  % tri des valeurs propres par ordre croissant
somValPropre = sum(vlpr);   % inertie totale (= trace(sigx))

% Selection des axes principaux
idx = flipud(idx);
ld  = flipud(ld);       % tri des valeurs propres suivant l'ordre décroissant
vectps = vectp(:,idx);  % tri des vecteurs propres suivant l'ordre décroissant des valeurs propres
if seuil<1
    ldns = cumsum(ld);
    ldns = ldns/somValPropre; % pourcentage d'énergie conservée en fonction du nombre d'axes principaux conservés
    idxc = find(ldns>=seuil); % nombre d'axes principaux à conserver pour conserver 'seuil' % d'énergie
    ns   = idxc(1);
else
    ns = seuil;
end

% Affichage
figure;
stem(ld); grid
xlabel('Index'); ylabel('Valeur propre')
title('Distribution des valeurs propres')

disp('Valeurs propres: ')
disp(ld');

% Projection
kmat = vectps(:,1:ns).'; % base de projection contenant les ns vecteurs propres de plus forte valeur propre
pes  = kmat*pen;         % projection des données de départ sur les ns axes principaux