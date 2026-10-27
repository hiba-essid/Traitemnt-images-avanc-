function [Liste_chiffre, in_binaire] = localise_Chiffres(in)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                          %                             %
%%   Author  :  Jean-Christophe Cexus       %                             %
%%              Oct. 2023.                  %         ENSTA - Bretagne    %
%%                                          %                             %
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Etape de localisation des chiffres en utilisant les caractéristiques de
% l'images avec les differents chiffres (on ne traite pas le bas de
% l'image)
% Cette fonction est a utiliser avec l'image : Digits_Image.jpg
% Cette fonction necessite que :
% - les chiffres doivent être blancs sur fond noir
% - pas de pixels isolés (donc pas de bruit) 
% - le cadre de l'image doit être NOIR pas de pixels blancs (voir la fin
% de code ou le cadre de l'image est traité)
% Pour la varaible position = [x1,y1,x2,y2]: vecteur comprenant (x1,y1) 
% du point en haut à gauche et (x2,y2) du point en bas à droite

% mise au format double de l'image si jmais en uint8
in = double(in);

% Histogramme de l'image
[counts, x] = imhist(uint8(in), 256);

% Seuillage binaire (chiffre à 1 (blanc) / fond à 0 (noir))
seuil = 100;
in    = in < seuil;

in_binaire = double(in); 

% Estimation des profils en x et en y
profil_x = sum(in, 2);
profil_y = sum(in, 1);

% % Affichage
% figure;
% subplot(221); imshow(in,[]);   title(' Image');
% subplot(222); plot(x, counts); title(' Histogramme');
% subplot(223); imshow(in, []);  title(' binaire');
% subplot(224); hold on; grid on; 
% plot(1:length(profil_x), profil_x, 'r.'); 
% plot(1:length(profil_y), profil_y, 'b.'); 
% legend(' Profil_x', 'Profil_y');

% Seuillage des profils
seuil_P  = 700;
indice_x = find(profil_x > seuil_P);
indice_y = find(profil_y > seuil_P);

% % Extraction d'une imagette
% ind_x = 5; % indice de ligne (selection du chiffre)
% ind_y = 8; % indice de colonne (numero position du chiffre sur la ligne)
% pos   = [indice_x(ind_x), indice_y(ind_y), indice_x(ind_x+1), indice_y(ind_y+1)];
% 
% % Extraction de l'imagette
% img = in(pos(1):pos(3),pos(2):pos(4));
% img = img(2:end-1,2:end-1);
% 
% figure; 
% imshow(img);   title(' imagette extraite');

%% Construction de la liste de toutes les imagettes
% on ne traite pas la derniere ligne
Liste_chiffre.label    = [];
Liste_chiffre.position = [];
Liste_chiffre.Imagette = [];

compteur = 1;
for ind_x = 1:length(indice_x)-2
    
    for ind_y = 1:length(indice_y)-1
        display([' Traitement ligne: ', num2str(ind_x), ' Colonne: ', num2str(ind_y)]);
        
        % Etiquette
        Liste_chiffre(compteur).label = ind_x - 1; 
        
        % Position
        pos = [indice_x(ind_x), indice_y(ind_y), indice_x(ind_x+1), indice_y(ind_y+1)];
        Liste_chiffre(compteur).position = pos;
        
        % Imagette
        img = in_binaire(pos(1):pos(3),pos(2):pos(4));
        img = img(2:end-1,2:end-1);
        Liste_chiffre(compteur).Imagette = img;

        compteur = compteur +1;
        clc;
    end
end