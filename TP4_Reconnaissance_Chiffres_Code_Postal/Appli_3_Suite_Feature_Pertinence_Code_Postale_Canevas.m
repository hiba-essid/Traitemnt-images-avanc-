%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                          %                             %
%%   Author  :  Jean-Christophe Cexus       %                             %
%%              Oct. 2023.                  %         ENSTA - Bretagne    %
%%                                          %                             %
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  Application 3 : CANEVAS Suite - Extraction d'attributs
% Analyse de la pertinence des parametres cavites sur des chiffres
% Pour chaque chiffre :
% - Extraction de l'imagette
% - Estimation des 5 parametres de cavitées
% Pour l'ensemble des parametres : 
% - Visualisation des différents parametres
% - Etude par analyse en Composantes Principales (ACP) et visualisation
%
% Utilise les methodes : localise_Chiffres, cavites et acp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extraction de l'ensemble des imagettes
close all; clear; clc; 

% Lecture de l'image
%TODO

% Affichage
%TODO

% Localisation de tous les chiffres dans l'image
% Extraction des imagettes et binarisation de l'image initiale in
%  Creation d'une structure comprennant pour chaque element  :
%  - label    : etiquette du chiffre
%  - position : position du rectangle de l'imagette
%  - Imagette : imagette binaire du chiffre
%TODO

%% Estimation des 5 Paramètres cavités pour les 9 chiffres 3 
Liste_Indice_3 = %TODO liste indices ?:?
param_3        = zeros(length(Liste_Indice_3), 5);
figure;
for ind = 1:length(Liste_Indice_3)
    % Extraction de l'imagette
    %TODO
    % Estimation des parametres cavites de l'imagette
    [X, map, param_3(ind,:)] = TODO
    
    % Affichage de l'imagette
    %TODO
end

% Visualisation des valeurs de chaque paramètre cavité
figure; 
for p=1:5
    subplot(2,3,p); hold on; grid on; 
    titre = sprintf('%i ème paramètre',p);
    plot(param_3(:,p),'*-');
    title(titre);
    xlabel('Numéro des chiffres');
    ylabel('valeur du paramètre');
end

%% Estimation des 5 Paramètres cavités pour les 9 chiffres 5 
Liste_Indice_5 = %TODO
param_5        = %TODO
%TODO
%TODO
%TODO
%TODO

%% Estimation des 5 Paramètres cavités pour les 9 chiffres 0 
Liste_Indice_0 = %TODO
param_0        = %TODO
%TODO
%TODO

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analyse de la pertinence par visualisation des valeurs de chaque
% paramètre cavité
param = [param_3; param_0; param_5]; % Matrice des parametres (Attributs)

figure; 
for p=1:5
    subplot(2,3,p); hold on; grid on; 
    titre = sprintf('%i ème paramètre',p);
    plot(param(:,p),'*-');
    title(titre);
    xlabel('numéro des chiffres : 1-9 : 3 ; 10-18 : 0 ; 19-27 : 5');
    ylabel('valeur du paramètre');
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analyse de la pertinence par Analyse en Composante Principale (ACP) et 
% visualisation de la projection selon les trois projections principales
% Projection par Analyse en Composantes Principales
[kmat, attributs_projO] = acp(param', 3);

%%Affichage
figure; hold on; grid on; view(3);
plot3(attributs_projO(1,:),attributs_projO(2,:),attributs_projO(3,:),'xr');

% Affichage avec les 3 classes ici pour chiffres 3
figure; hold on; grid on; view(3);
plot3(attributs_projO(1,1:9),attributs_projO(2,1:9),attributs_projO(3,1:9),'ok');
%TODO pour le chiffre 0
%TODO pour le chiffre 5
legend('chiffres 3','chiffres 0','chiffres 5');

%% Comparaison avec le code postal pour les chiffre 3 et 0 
load tab_parametre.mat
figure; 
for p=1:5
    subplot(2,3,p); hold on; grid on; 
    titre = sprintf('%i ème paramètre',p);
    plot(param(:,p),'*-');
    hold on; 
    plot(30, tab_parametre(p,4),'rd'); % chiffre 3 du code postal
    plot(31, tab_parametre(p,5),'gs'); % chiffre 0 du code postal
    title(titre);
    xlabel('numéro des chiffres : 1-9 : 3 ; 10-18 : 0 ; 19-27 : 5');
    ylabel('valeur du paramètre');
end

% bon et bien j'ai pas fait plus perso ... il est tard ! ;-)