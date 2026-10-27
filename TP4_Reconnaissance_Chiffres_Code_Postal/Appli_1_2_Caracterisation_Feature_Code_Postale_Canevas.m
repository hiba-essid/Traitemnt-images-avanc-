%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                          %                             %
%%   Author  :  Jean-Christophe Cexus       %                             %
%%              Oct. 2023.                  %         ENSTA - Bretagne    %
%%                                          %                             %
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    TD - CANEVAS Segmentation et classification d'images
% (Application 1)
% Canevas Code postale : Extraction des chiffres
% (Application 2)
% Canevas Code postale : Caractérisation des chiffres par 
% l'etude des cavitées (introduction à la classification)
%
% Utilise les methodes : cavites
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% Application 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Segmentation et Extraction des chiffres
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clear; clc;

%% Chargement de l'image
in = imread('code_postal.png');
in = double(rgb2gray(in));

% Histogramme de l'image
%TODO

% Affichage image et histogramme
%TODO

%% Pré-traitement de l'image : Extraction du cadre
% Extraction du cadre noire de l'image qui ne sert  à rien (risque de nous
% ennuyer pour la suite du traitement) (9 lignes et 9 colonnes à droite, à
% gauche , en haut , en bas)
out_rognee = in(5:(size(in,1)-5), 5:(size(in,2)-5));
size(out_rognee);
%TODO histogramme sur image rognée

% Affichage image rognée et son histogramme
%TODO 

%% Pré-traitement de l'image : Filtrage passe bas
% Fitrage du fond de l'image par un filtre moyenneur (3x3)
%TODO filtrage
%TODO histogramme sur image filtrée

% Affichage filtrage et histogramme
%TODO 

%% Segmentation de l'image (binarisation) par approche 'manuelle' sur l'histogramme
seuil              = %TODO 
out_rogne_binaire  = %TODO 
out_filtre_binaire = %TODO 

% Affichage segmentation sur image avant et après filtrage
%TODO 

%% Post-traitement : On conserve que les zones pertinentes
% Etiquetage des zones
%TODO 

% Affichage des zones
figure;
%TODO 

%% Post-traitement : Estimation des aires de chaque zones avec l'imagette associée
stats = %TODO Sortie de regionprops ici on utilise uniquement Area et Image
Liste_aire  = cat(1, stats.Area); % concatenation des surfaces
nuobj = numel(stats);             % nombre de zones dans l'image

% Affichage des differences "are" des différents objets identifiés
figure;
plot(1:nuobj, Liste_aire, 'r.');
xlabel(' indice de la zone'); ylabel('Surfaces de la zone')

% Définition d'un seuil permettant de ne retenir que les objets
% interessants
seuil_aire_pertinent =  300;

% Affichage avec selection des zones pertinentes
k = 1; % un compteur pour affichage des zones
for indice = 1: nuobj
    
    % Extraction des zones les plus grandes (les chiffres)
    if Liste_aire(indice) > seuil_aire_pertinent
        
        subplot(3,3,k);
        imshow(out_label == indice, []);
        xlabel(['Aire: ', num2str(Liste_aire(indice)), ' pixels']);
        title(['Zone indice : ', num2str(indice)]);
        k=k+1; % Compteur pour les subplot
    end

end

%% Etude spécifique pour un chiffre : Extraction d'une imagette associée à une zone pertinente
% L'imagette est un peu plus grande que la zone pour eviter des effets de
% bords pour la zone (creation d'un cadre autour de la zone extraite)
indice_pertinent = 2;
imagette_pertinente = %TODO

zone_pertinente    = zeros(size(imagette_pertinente)+2);
zone_pertinente(2:end-1,2:end-1) = imagette_pertinente;

% Affichage de la zone pertinente
figure; imshow(zone_pertinente, []); 

%% Généralisation à tous les chiffres : Extraction et affichage des zones pertinentes
Liste_indice_pertinent = %TODO

% Affichage avec selection des zones pertinentes (on ne sauvegarde pas les
% imagettes ici - pas d'interet ici)
figure;
for indice = 1: length(Liste_indice_pertinent)
    
    % Extraction des imagettespertinentes en fonciton de
    % Liste_indice_pertinent et ajout du "cadre noir" pour la
    % zone_pertinente
    imagette_pertinente = %TODO
    zone_pertinente     = %TODO
    zone_pertinente(2:end-1,2:end-1) = %TODO
    
    % Affichage
    subplot(2,3,indice);
    imshow(zone_pertinente);
    title(['Zone indice : ', num2str(indice)]);
    
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% Application 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Caractérisation des chiffres par leurs cavités
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Etude spécifique pour un chiffre : Extraction du chiffre 9
indice_pertinent = 2;
imagette_pertinente = stats(indice_pertinent).Image;

% Creation d'un cadre autour de la zone extraite
zone_pertinente    = zeros(size(imagette_pertinente)+2);
zone_pertinente(2:end-1,2:end-1) = imagette_pertinente;

% Affichage de la zone pertinente
figure; imshow(zone_pertinente, []); axis off;

%% Estimation des parametres cavités pour le chiffre 9 via cavite.m
img = %TODO
[X, map, parametre] = %TODO
parametre'

% Affichage des parametres cavite à l'aide d'un plot mais aussi de imshow(X, map);
%TODO

%% Généralisation à tous les chiffres : Estimation des parametres 
% Extraction et affichage des zones pertinentes(pour rappel)
Liste_indice_pertinent 

tab_parametre = zeros(5, 5); % initialisation de la sauvegarde

% Affichage avec selection des zones pertinentes
p = 1; % Compteur pour affichage avec subplot
figure;
for indice = 1: length(Liste_indice_pertinent)
    
    % Extraction des imagettes
    %TODO
    
    % Estimation des parametres cavités
    %TODO
    
    % Affichage des imagettes (colonne de gauche) : imshow
    subplot(5,2,p);
    %TODO
    
    % Affichage des parametres (colonne de droite) : plot
    subplot(5,2,p+1);
    %TODO
    
    % Compteur pour affichage
    p=p+2;
    
    % Sauvegarde : chauque colonne correspondant à la description "cavité"
    % d'un chiffre
    tab_parametre(:,indice) = parametre;
end
save tab_parametre.mat tab_parametre; % sauvegarde .mat


