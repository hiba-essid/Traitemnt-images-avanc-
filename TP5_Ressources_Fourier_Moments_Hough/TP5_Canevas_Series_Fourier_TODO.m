% Mise en œuvre de la décomposition en série de Fourier

% Auteur: Isabelle QUIDU
% Annee : 2016
% ENSTA Bretagne, France

close all; clear all;

% lecture de l'image et passage en double entre 0 et 1
I = im2double(TODO);
figure, imshow(TODO), title('image initiale')

% estimation de l'axe principal
axePrincipal = TODO

% détection morphologique du contour
se = TODO;
Ie = imerode(I,se);
Ic = I-Ie;
figure, imshow(Ic)

% suivi de contour
[x0,y0] = find(TODO);  % coordonnées des pixels du contour détecté (attention : coordonnées 'image MatLab', c-a-d x le long des lignes, y le long des colonnes)
ctr = bwtraceboundary(Ic,[x0(1) y0(1)],'NE',8,length(x0)+1,'clockwise');
xi = TODO;
yi = TODO; 

% coordonnees du centre de gravite de la forme codee 1
xg = TODO;
yg = TODO;

% centrage des coordonnées par rapport au centre de gravité
xi = TODO;
yi = TODO; 

% TF des pts de contour
nbCoeff = TODO; % nb de coefficients calculés (chiffre impair! cf cours)
[cI,M] = fourier(TODO); % cI est un vecteur ligne
[cJ,M] = fourier(TODO);  

% application d'une rotation pour remettre la silhouette dans l'axe par transformation affine sur les descripteurs
A = TODO; % matrice de rotation
cX = A*[cI'; cJ']; % application de la rotation => nouveaux coefficients de Fourier
cI = cX(1,:)';
cJ = cX(2,:)';

% transformée de Fourier inverse pour revenir aux coordonnées spatiales
xi = real(ifourier(TODO)); % d'abord sur dim x
xi = round(TODO); % après translation du xi précédent vers le repère d’origine 
yi = TODO; % idem sur dim y

% Synthèse nouvelle image
Ic = zeros(size(Ic,1),size(Ic,2)); % même dimension que l’image de départ
Index = sub2ind(size(Ic),...
    max(1,min(size(Ic,1),xi)),...
    max(1,min(size(Ic,2),yi)));
Ic(Index) = 1;

% post-traitement et remplissage de la silhouette
Ic = double(bwmorph(TODO)); % fermeture du contour
Ic = imfill(Ic); % remplissage
figure, imshow(Ic), title('image finale')
colormap(gray)