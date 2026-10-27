%% ========== APPLICATION 1 : extraction des chiffres ==========
clear; close all; clc;

% Lecture et histogramme
I = imread('code_postal.png');
if size(I,3) == 3, I = rgb2gray(I); end
I = double(I);
figure; imshow(I,[]); title('Image');
figure; imhist(uint8(I)); title('Histogramme');

% Suppression du cadre noir (sans boucle)
r = find(mean(I,2) > 0.5*mean(I(:)));
c = find(mean(I,1) > 0.5*mean(I(:)));
Ic = I(r(1)+1:r(end)-1, c(1)+1:c(end)-1);
figure; imshow(Ic,[]); title('Image rognee');

%% Filtrage moyenneur 3x3
h = fspecial('average',3);
If = imfilter(Ic,h,'replicate');
figure;
subplot(1,2,1); imshow(Ic,[]); title('Rognee');
subplot(1,2,2); imshow(If,[]); title('Moyenneur 3x3');

%% Segmentation : seuil (fond = 0, chiffres = 1)
seuil = graythresh(uint8(If))*255;   % ou seuil manuel lu sur l'histogramme
BW_nf = Ic < seuil;
BW_f  = If < seuil;
figure;
subplot(1,2,1); imshow(BW_nf); title('Non filtree');
subplot(1,2,2); imshow(BW_f);  title('Filtree 3x3');

%% Influence de la taille / du type de filtre
filtres = {fspecial('average',3), fspecial('average',5), ...
           fspecial('average',7), fspecial('average',11), ...
           fspecial('gaussian',3,0.8)};
noms = {'Moy 3x3','Moy 5x5','Moy 7x7','Moy 11x11','Gauss 3x3'};
figure;
for k = 1:numel(filtres)
    Ik = imfilter(Ic,filtres{k},'replicate');
    subplot(2,3,k); imshow(Ik < seuil); title(noms{k});
end
subplot(2,3,6); imshow(medfilt2(Ic,[3 3]) < seuil); title('Median 3x3');

%% Choix du traitement
If = imfilter(Ic,fspecial('average',5),'replicate');
seuil = graythresh(uint8(If))*255;
BW = If < seuil;
figure; imshow(BW); title('Segmentation retenue');

%% Etiquetage
[L,n] = bwlabel(BW,8);
figure; imagesc(L); axis image; colormap(jet); colorbar; title('Etiquetage');

% Fond a 1 et objets a 0 : le fond devient un objet connexe (etiquette 1)
% et les chiffres ne sont plus etiquetes comme objets
[L_inv,~] = bwlabel(~BW,8);
figure; imagesc(L_inv); axis image; colormap(jet); colorbar; title('Etiquetage inverse');

%% Aires et imagettes
stats = regionprops(L,'Area','Image','BoundingBox');
Liste_aire = [stats.Area];
seuil_aire = 0.25*max(Liste_aire);
Liste_indice_pertinent = find(Liste_aire > seuil_aire);

% Tri de gauche a droite
bbox = vertcat(stats(Liste_indice_pertinent).BoundingBox);
[~,ordre] = sort(bbox(:,1));
Liste_indice_pertinent = Liste_indice_pertinent(ordre);
nb = numel(Liste_indice_pertinent);

imagettes = cell(1,nb);
figure;
for k = 1:nb
    img = stats(Liste_indice_pertinent(k)).Image;
    imagettes{k} = padarray(img,[1 1]);        % cadre noir
    subplot(1,nb,k); imshow(imagettes{k});
    title(sprintf('Zone indice : %d',k));
end

%% ========== APPLICATION 2 : cavites ==========
% Chiffre '9' (indice 2)
[parametre, X, map] = calc_cavites(imagettes{2});
figure;
subplot(1,2,1); imshow(X,map); title('Cavites du 9');
subplot(1,2,2); plot(parametre,'r*'); grid on; xlabel('E W S N C');

%% Tous les chiffres du code postal
tab_parametre = zeros(5,nb);
figure;
for k = 1:nb
    [parametre, X, map] = calc_cavites(imagettes{k});
    tab_parametre(:,k) = parametre;
    subplot(nb,2,2*k-1); imshow(X,map); title(sprintf('Zone indice : %d',k));
    subplot(nb,2,2*k);   plot(parametre,'r*'); grid on; ylim([0 1]);
    xlim([1 5]); set(gca,'XTick',1:5,'XTickLabel',{'E','W','S','N','C'});
end
save tab_parametre.mat tab_parametre;

%% ========== APPLICATION 3 : tous les chiffres ==========
in = imread('Digits_Image.jpg');
in = double(rgb2gray(in));
figure; imshow(in,[]); colorbar;

[Liste_chiffre, in_binaire] = localise_Chiffres(in);

% Chiffre d = indices 9*d+1 : 9*d+9 (ind=28 -> premier '3', ind=36 -> '3' tout a droite)
figure; imshow(Liste_chiffre(28).Imagette,[]); title('ind = 28 : premier 3');
figure; imshow(Liste_chiffre(36).Imagette,[]); title('ind = 36 : 3 le plus a droite');

%% Parametres cavites de tous les chiffres
P = zeros(90,5);
classe = repelem((0:9)',9);
for ind = 1:90
    img = logical(Liste_chiffre(ind).Imagette);
    if mean(img(:)) > 0.5, img = ~img; end
    img = padarray(img,[1 1]);
    P(ind,:) = calc_cavites(img);
end

param_3 = P(28:36,:);
param_0 = P(1:9,:);
param_5 = P(46:54,:);

%% Comparaison 0 / 3 / 5
param = [param_3; param_0; param_5];
figure;
for p = 1:5
    subplot(2,3,p); hold on; grid on;
    plot(param(:,p),'*-');
    title(sprintf('%i eme parametre',p));
    xlabel('Numero des chiffres : 1-9 : 3 ; 10-18 : 0 ; 19-27 : 5');
    ylabel('Valeur du parametre');
end

%% ACP 0 / 3 / 5 (acp.m fourni)
[kmat, attributs_projO] = acp(param',3);
figure; hold on; grid on; view(3);
plot3(attributs_projO(1,1:9),   attributs_projO(2,1:9),   attributs_projO(3,1:9),   'ok');
plot3(attributs_projO(1,10:18), attributs_projO(2,10:18), attributs_projO(3,10:18), '*b');
plot3(attributs_projO(1,19:27), attributs_projO(2,19:27), attributs_projO(3,19:27), '+m');
legend('chiffres 3','chiffres 0','chiffres 5');

%% Question ouverte 1 : ACP sur les 10 chiffres
mu = mean(P); sd = std(P); sd(sd==0) = 1;
Z = (P-mu)./sd;
[~,~,V] = svd(Z,'econ');
proj = Z*V(:,1:3);

figure; hold on; grid on; view(3);
scatter3(proj(:,1),proj(:,2),proj(:,3),40,classe,'filled');
colormap(jet); colorbar; title('ACP - chiffres 0 a 9');

%% Question ouverte 2 : code postal vs base de chiffres
load tab_parametre.mat
Zc = (tab_parametre'-mu)./sd;
projc = Zc*V(:,1:3);

figure; hold on; grid on; view(3);
scatter3(proj(:,1),proj(:,2),proj(:,3),30,classe,'filled');
colormap(jet);
plot3(projc(:,1),projc(:,2),projc(:,3),'kp','MarkerSize',14,'MarkerFaceColor','k');
title('Code postal (etoiles) dans l''espace ACP');

%% Classification par centre de classe le plus proche
M = zeros(10,5);
for d = 0:9
    M(d+1,:) = mean(Z(classe==d,:),1);
end
chiffres_reconnus = zeros(1,size(Zc,1));
for k = 1:size(Zc,1)
    dist = vecnorm(M - Zc(k,:),2,2);
    [~,imin] = min(dist);
    chiffres_reconnus(k) = imin-1;
end
disp(chiffres_reconnus);