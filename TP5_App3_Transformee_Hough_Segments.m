%% TP5 - Application 3 : Transformée de Hough (TH) pour la détection de segments
% Une figure par question du TP.
clear; close all; clc;

%% ===================== 1. Exercice préliminaire =====================
%  Espace image                         Espace de Hough
%  1. Point                          -> d. Sinusoïde
%  2. Droite                         -> b. Point
%  3. Points situés sur une droite   -> e. Sinusoïdes passant par un point commun
%  4. Droites concourantes           -> a. Points situés sur une même sinusoïde
%  5. Droites parallèles             -> c. Points de même theta mais de rho différents
% Vérification expérimentale sur des images synthétiques :
n = 101;  c0 = 51;                        % taille des images et centre
E = cell(1,5);
E{1} = false(n);  E{1}(30, 70) = true;                               % 1. un point
E{2} = tracer(false(n), [10 20], [90 80]);                           % 2. une droite
E{3} = false(n);  E{3}(sub2ind([n n], [20 50 80], [25 50 75])) = true; % 3. points alignés
E{4} = false(n);                                                     % 4. droites concourantes
for a = [0 60 120]
    d = 45*[cosd(a) sind(a)];
    E{4} = tracer(E{4}, [c0 c0] - d, [c0 c0] + d);
end
E{5} = false(n);                                                     % 5. droites parallèles
for k = [-30 0 30]
    E{5} = tracer(E{5}, [10 10+k], [90 90+k]);
end
titresIm = {'1. Point', '2. Droite', '3. Points alignés', '4. Droites concourantes', '5. Droites parallèles'};
titresH  = {'d. Sinusoïde', 'b. Point', 'e. Sinusoïdes concourantes', 'a. Points sur une sinusoïde', 'c. Même \theta, \rho différents'};

figure('Name', '1. Exercice préliminaire', 'Position', [50 100 1400 500]);
for k = 1:5
    [Hk, th, rh] = hough(E{k});
    subplot(2,5,k); imshow(imdilate(E{k}, ones(3))); title(titresIm{k});
    subplot(2,5,k+5);
    imshow(log(1 + Hk), [], 'XData', th, 'YData', rh, 'InitialMagnification', 'fit');
    axis on; axis normal; colormap(gca, hot); xlabel('\theta'); ylabel('\rho'); hold on;
    if k == 4   % sinusoïde du point de concours (repère hough : x = col-1, y = lig-1)
        plot(th, (c0-1)*cosd(th) + (c0-1)*sind(th), 'c--', 'LineWidth', 1);
    end
    if any(k == [2 4 5])
        Pk = houghpeaks(Hk, max(1, (k > 2)*3), 'NHoodSize', [11 11]);
        plot(th(Pk(:,2)), rh(Pk(:,1)), 'co', 'MarkerSize', 8, 'LineWidth', 1.5);
    end
    title(titresH{k});
end
sgtitle('1. Correspondances espace image / espace de Hough');

%% ===================== 2.1 Chaîne nominale sur l'image "facile" box =====================
% a. lecture
load imdemos box
I = box;
if size(I,3) == 3, I = rgb2gray(I); end
figure('Name', '2.1a : image box'); imshow(I); title('2.1a : image box');

% b. extraction des contours (Canny : contours fins, fermés, peu sensibles au bruit)
Ib = edge(I, 'canny');
figure('Name', '2.1b : contours');
subplot(1,2,1); imshow(I);  title('Image');
subplot(1,2,2); imshow(Ib); title('2.1b : contours de Canny');

% c. transformée de Hough avec les paramètres par défaut
[H, theta, rho] = hough(Ib);
figure('Name', '2.1c : accumulateur');
afficherAccumulateur(H, theta, rho, []);
title('2.1c : accumulateur de Hough (paramètres par défaut)');

% d. cellules ayant le plus de votes
nSeg = 12;                                % nombre de segments attendus (à ajuster à l'image)
P = houghpeaks(H, nSeg, 'Threshold', ceil(0.3*max(H(:))));
figure('Name', '2.1d : pics');
afficherAccumulateur(H, theta, rho, P);
title(sprintf('2.1d : %d pics retenus (seuil = 0.3 max)', size(P,1)));

% e. extraction des segments
lines = houghlines(Ib, theta, rho, P, 'FillGap', 10, 'MinLength', 20);
fprintf('2.1e : %d segments extraits sur box\n', numel(lines));

% f. affichage des segments superposés à l'image
afficherSegments(I, lines, sprintf('2.1f : box - %d segments', numel(lines)));

%% ===================== 2.2 Même chaîne sur hough2.jpg =====================
I2 = imread('hough2.jpg');
if size(I2,3) == 3, I2 = rgb2gray(I2); end

% a. chaîne nominale inchangée -> critique
Ib2 = edge(I2, 'canny');
[H2, theta2, rho2] = hough(Ib2);
P2 = houghpeaks(H2, nSeg, 'Threshold', ceil(0.3*max(H2(:))));
lines2 = houghlines(Ib2, theta2, rho2, P2, 'FillGap', 10, 'MinLength', 20);
fprintf('2.2a : %d segments avec la chaîne nominale\n', numel(lines2));

figure('Name', '2.2a : chaîne nominale', 'Position', [50 100 1300 450]);
subplot(1,3,1); imshow(Ib2); title('Contours (Canny par défaut)');
subplot(1,3,2); afficherAccumulateur(H2, theta2, rho2, P2); title('Accumulateur + pics');
subplot(1,3,3); afficherSegments(I2, lines2, sprintf('%d segments', numel(lines2)), gca);
sgtitle('2.2a : chaîne nominale sur hough2.jpg');

% b. ajustement des paramètres
%   - edge : lissage plus fort (sigma = 2) pour éliminer les contours de texture
%   - hough : pas angulaire plus fin
%   - houghpeaks : plus de pics, seuil plus bas, voisinage de suppression plus large
%   - houghlines : FillGap pour recoller les segments fragmentés, MinLength pour éliminer les petits
Ib2b = edge(I2, 'canny', [], 2);
[H2b, theta2b, rho2b] = hough(Ib2b, 'RhoResolution', 1, 'Theta', -90:0.5:89.5);
P2b = houghpeaks(H2b, 30, 'Threshold', ceil(0.2*max(H2b(:))), 'NHoodSize', [31 31]);
lines2b = houghlines(Ib2b, theta2b, rho2b, P2b, 'FillGap', 20, 'MinLength', 30);
fprintf('2.2b : %d segments après réglage\n', numel(lines2b));

figure('Name', '2.2b : paramètres ajustés', 'Position', [50 100 1300 450]);
subplot(1,3,1); imshow(Ib2b); title('Contours (Canny, \sigma = 2)');
subplot(1,3,2); afficherAccumulateur(H2b, theta2b, rho2b, P2b); title('Accumulateur + pics');
subplot(1,3,3); afficherSegments(I2, lines2b, sprintf('%d segments', numel(lines2b)), gca);
sgtitle('2.2b : chaîne avec paramètres ajustés');

% c. post-traitement : suppression des doublons
%    (la fonction fournie distance_segments.m peut remplacer distSeg ci-dessous)
dmin   = 8;      % distance minimale admissible entre segments (pixels)
angTol = 5;      % écart angulaire max pour des segments "parallèles" (degrés)
lines2c = supprimerDoublons(lines2b, dmin, angTol);
fprintf('2.2c : %d segments après suppression des doublons\n', numel(lines2c));

figure('Name', '2.2c : sans doublons', 'Position', [50 100 1300 450]);
subplot(1,3,1); afficherSegments(I2, lines2,  sprintf('Nominal : %d', numel(lines2)),  gca);
subplot(1,3,2); afficherSegments(I2, lines2b, sprintf('Réglé : %d', numel(lines2b)),   gca);
subplot(1,3,3); afficherSegments(I2, lines2c, sprintf('Sans doublons : %d', numel(lines2c)), gca);
sgtitle(sprintf('2.2c : suppression des doublons (d_{min} = %d px, %d°)', dmin, angTol));

%% ---------------- Fonctions locales ----------------
function E = tracer(E, p1, p2)
% Trace un segment [ligne colonne] p1 -> p2 dans l'image binaire E
m = ceil(2*norm(p2 - p1)) + 1;
r = round(linspace(p1(1), p2(1), m));
c = round(linspace(p1(2), p2(2), m));
ok = r >= 1 & r <= size(E,1) & c >= 1 & c <= size(E,2);
E(sub2ind(size(E), r(ok), c(ok))) = true;
end

function afficherAccumulateur(H, theta, rho, P)
imshow(imadjust(rescale(H)), 'XData', theta, 'YData', rho, 'InitialMagnification', 'fit');
xlabel('\theta (deg)'); ylabel('\rho (pixels)'); axis on; axis normal; hold on;
colormap(gca, hot);
if ~isempty(P)
    plot(theta(P(:,2)), rho(P(:,1)), 's', 'Color', 'c', 'LineWidth', 1.5);
end
end

function afficherSegments(I, lines, titre, ax)
if nargin < 4, figure('Name', titre); ax = gca; end
axes(ax); imshow(I); hold on
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
    plot(xy(1,1), xy(1,2), 'x', 'LineWidth', 2, 'Color', 'yellow');
    plot(xy(2,1), xy(2,2), 'x', 'LineWidth', 2, 'Color', 'red');
end
title(titre);
end

function lines = supprimerDoublons(lines, dmin, angTol)
% Garde le plus long de deux segments quasi parallèles et trop proches
if isempty(lines), return; end
len = arrayfun(@(s) norm(double(s.point1 - s.point2)), lines);
[~, ord] = sort(len, 'descend');
lines = lines(ord);
garder = true(1, numel(lines));
for i = 1:numel(lines)
    if ~garder(i), continue; end
    for j = i+1:numel(lines)
        if ~garder(j), continue; end
        dTheta = abs(lines(i).theta - lines(j).theta);
        dTheta = min(dTheta, 180 - dTheta);
        if dTheta < angTol && distSeg(lines(j), lines(i)) < dmin
            garder(j) = false;
        end
    end
end
lines = lines(garder);
end

function d = distSeg(s, ref)
% Distance moyenne des extrémités du segment s au segment ref
d = (distPointSeg(s.point1, ref.point1, ref.point2) + ...
     distPointSeg(s.point2, ref.point1, ref.point2)) / 2;
end

function d = distPointSeg(p, a, b)
p = double(p); a = double(a); b = double(b);
ab = b - a;
t = max(0, min(1, dot(p - a, ab) / max(dot(ab, ab), eps)));
d = norm(p - (a + t*ab));
end