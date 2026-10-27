%% TP1 - Application 1 : extraction des dendrites

clear; close all; clc;

%% Lecture
I = imread("C:\Users\MSI\Downloads\fichiersTE1_2023\neurones-et-dendrites.jpg");
if size(I,3) == 3, I = rgb2gray(I); end
I = im2double(I);

%% Element structurant : disque (structures isotropes), R entre demi-largeur
%  d'une dendrite et rayon d'un soma
R  = 6;
se = strel('disk', R);

%% Top-hat classique
Iouv = imopen(I, se);
TH   = I - Iouv;

%% Top-hat par reconstruction
Irec  = imreconstruct(imerode(I, se), I);
THrec = I - Irec;

%% Binarisation et nettoyage
BW = imbinarize(THrec, graythresh(THrec));
BW = bwareaopen(BW, 30);
Dendrites = THrec .* BW;

BWsoma = bwareaopen(imbinarize(Irec, graythresh(Irec)), 200);

%% Affichage
figure('Name','Application 1','Color','w');
subplot(2,3,1), imshow(I,[]),         title('Image originale');
subplot(2,3,2), imshow(Iouv,[]),      title(sprintf('Ouverture classique (R=%d)',R));
subplot(2,3,3), imshow(TH,[]),        title('Top-hat classique');
subplot(2,3,4), imshow(Irec,[]),      title('Ouverture par reconstruction');
subplot(2,3,5), imshow(THrec,[]),     title('Top-hat par reconstruction');
subplot(2,3,6), imshow(Dendrites,[]), title('Dendrites extraites');

%% Mesures d'efficacite
fprintf('Energie residuelle dans les somas : %.1f %%\n', ...
    100*sum(THrec(BWsoma))/sum(I(BWsoma)));

stats = regionprops(BW, 'MajorAxisLength', 'MinorAxisLength');
elong = [stats.MajorAxisLength] ./ max([stats.MinorAxisLength], eps);
fprintf('Objets conserves : %d | elongation mediane = %.1f\n', numel(stats), median(elong));

Squel = bwmorph(BW, 'skel', Inf);
fprintf('Longueur du squelette : %d pixels\n', nnz(Squel));

figure('Name','Verification','Color','w');
subplot(1,3,1), imshow(BWsoma), title('Somas (elimines)');
subplot(1,3,2), imshow(BW),     title('Dendrites binarisees');
subplot(1,3,3), imshow(Squel),  title('Squelette');

%% Influence du rayon
figure('Name','Influence de R','Color','w');
Rtest = [2 4 6 10 16];
for k = 1:numel(Rtest)
    sek = strel('disk', Rtest(k));
    Tk  = I - imreconstruct(imerode(I,sek), I);
    subplot(1,numel(Rtest),k), imshow(Tk,[]), title(sprintf('R = %d', Rtest(k)));
end