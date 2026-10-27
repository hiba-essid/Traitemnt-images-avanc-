function [X, map, param] = cavites(img)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                          %                             %
%%   Author  :  Jean-Christophe Cexus       %                             %
%%              Oct. 2023.                  %         ENSTA - Bretagne    %
%%                                          %                             %
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fonction de détection des cavités
%
% Explications sur le programme:
% G. Burel, "Introduction au traitement d'images: simulation
%            sous Matlab", Hermès, 2001
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[nbligs,nbcols] = size(img);
E = [ones(1,nbcols) zeros(1,nbcols-1)];
E = fliplr(E);  % pour compenser l'inversion Matlab
W = fliplr(E);
S = [ones(nbligs,1); zeros(nbligs-1,1)];
S = flipud(S);  % pour compenser l'inversion Matlab
N = flipud(S);

% Dilatations par des demi-droites
dilE = imdilate(img, E);
dilW = imdilate(img, W);
dilS = imdilate(img, S);
dilN = imdilate(img, N);

% Calcul des cavites
CE = (dilE) & (~dilW) & (dilS) & (dilN) & (~img);
CW = (~dilE) & (dilW) & (dilS) & (dilN) & (~img);
CS = (dilE) & (dilW) & (dilS) & (~dilN) & (~img);
CN = (dilE) & (dilW) & (~dilS) & (dilN) & (~img);
CC = (dilE) & (dilW) & (dilS) & (dilN) & (~img);

% indice de la couleurs en fonction du type de la cavités (en lien avec le
% nombre de ligne de map)
X = ones(size(img));% noir
X(find(img>0))=2;   % gris
X(find(CE>0))=3;    % rouge
X(find(CW>0))=4;    % vert
X(find(CS>0))=5;    % bleu
X(find(CN>0))=6;    % jaune
X(find(CC>0))=7;    % violet

% La map pour l'affichage avec un imshow
map = [0 0 0; 0.7 0.7 0.7; 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1];

% Extraction des parametres
surfCE = sum(sum(CE));
surfCW = sum(sum(CW));
surfCS = sum(sum(CS));
surfCN = sum(sum(CN));
surfCC = sum(sum(CC));
surf  = surfCE +surfCW +surfCS +surfCN +surfCC +1;
param = [surfCE surfCW surfCS surfCN surfCC]' / surf;
