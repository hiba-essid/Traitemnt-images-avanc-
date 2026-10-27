%% TP5 - Application 2 : Template matching (domaine spatial vs corrélation de phase)
% Une ou plusieurs figures par question du TP (titres "Q1", "Q2", ...).
clear; close all; clc;

%% ===================== Q1 : image et template =====================
Io = im2double(imread('text.png'));
T  = Io(32:45, 88:98);                    % lettre 'a' de "watershed"
[h, w] = size(T);

figure('Name', 'Q1 : image et template');
subplot(1,2,1); imshow(Io); title('Image originale');
hold on; rectangle('Position', [88 32 w h], 'EdgeColor', 'y', 'LineWidth', 1.5);
subplot(1,2,2); imshow(T, 'InitialMagnification', 'fit'); title(sprintf('Template %dx%d', h, w));

% Seuils de détection (adaptés après observation des mesh et des maxima affichés)
seuilNCC = 0.90;     % seuil absolu (normxcorr2 dans [-1, 1])
seuilPC  = 0.50;     % seuil relatif au maximum de la corrélation de phase

%% ===================== Q2 : domaine spatial (normxcorr2) =====================
tic;
C1 = normxcorr2(T, Io);
tNCC = toc;

% a. visualisation
figure('Name', 'Q2a : corrélation spatiale');
mesh(C1); axis tight; xlabel('colonne'); ylabel('ligne'); zlabel('NCC');
title('Q2a : normxcorr2(T, Io)');

% b. adaptation du seuil : maxima locaux triés + plan de seuil
afficherMaxima(C1, 'NCC');
figure('Name', 'Q2b : seuil NCC');
subplot(1,2,1);
v = sort(C1(imregionalmax(C1)), 'descend');
stem(v(1:min(20,end)), 'filled'); hold on; yline(seuilNCC, 'r--', 'seuil', 'LineWidth', 1.5);
xlabel('rang du maximum local'); ylabel('valeur'); grid on;
title('20 plus grands maxima locaux');
subplot(1,2,2); imshow(C1 >= seuilNCC); title(sprintf('NCC \\geq %.2f', seuilNCC));
sgtitle('Q2b : choix du seuil de détection');

% c. nombre et localisation (le pic est au coin bas-droit du template -> correction)
pk1    = detecterPics(C1, seuilNCC);
posNCC = pk1 - [h w] + 1;                 % coin haut-gauche dans l'image
fprintf('\nQ2c : %d ''a'' détectés par normxcorr2\n', size(posNCC,1));
disp(array2table(posN ...
CC, 'VariableNames', {'ligne','colonne'}));

% d. visualisation des détections
figure('Name', 'Q2d : détections NCC');
imshow(Io); hold on; dessinerBoites(posNCC, h, w, 'g');
title(sprintf('Q2d : %d ''a'' détectés (normxcorr2)', size(posNCC,1)));

%% ===================== Q3 : domaine fréquentiel (corrélation de phase) =====================
tic;
C2 = correlationPhase(Io, T);
tPC = toc;

% a. visualisation et comparaison
figure('Name', 'Q3a : corrélation de phase');
subplot(1,2,1); mesh(C1); axis tight; title('normxcorr2 (Q2)');
subplot(1,2,2); mesh(C2); axis tight; title('Corrélation de phase');
sgtitle('Q3a : comparaison des surfaces de corrélation');

% b. adaptation du seuil
afficherMaxima(C2/max(C2(:)), 'PC normalisée');
figure('Name', 'Q3b : seuil PC');
subplot(1,2,1);
v = sort(C2(imregionalmax(C2)), 'descend') / max(C2(:));
stem(v(1:min(20,end)), 'filled'); hold on; yline(seuilPC, 'r--', 'seuil', 'LineWidth', 1.5);
xlabel('rang du maximum local'); ylabel('valeur / max'); grid on;
title('20 plus grands maxima locaux');
subplot(1,2,2); imshow(C2 >= seuilPC*max(C2(:))); title(sprintf('PC \\geq %.2f max', seuilPC));
sgtitle('Q3b : choix du seuil de détection');

% c. nombre et localisation (pic en (dy+1, dx+1) = coin haut-gauche)
posPC = detecterPics(C2, seuilPC*max(C2(:)));
fprintf('\nQ3c : %d ''a'' détectés par corrélation de phase\n', size(posPC,1));
disp(array2table(posPC, 'VariableNames', {'ligne','colonne'}));

figure('Name', 'Q3c : détections PC');
imshow(Io); hold on; dessinerBoites(posPC, h, w, 'r');
title(sprintf('Q3c : %d ''a'' détectés (corrélation de phase)', size(posPC,1)));

%% ===================== Q4 : évaluation des performances =====================
R(1) = struct('cas', 'Original', 'rsbNCC', rsb(C1), 'rsbPC', rsb(C2), ...
              'nNCC', size(posNCC,1), 'nPC', size(posPC,1), 'tNCC', tNCC, 'tPC', tPC);
afficherBilan(R(1), 'Q4 : image originale');

%% ===================== Q5 : bruit blanc gaussien (variance 0.5) =====================
rng(0);
In = imnoise(Io, 'gaussian', 0, 0.5);
R(2) = evaluer(In, T, 0.35, 0.60, 'Q5 : image bruitée (variance 0.5)', 'Bruit');

%% ===================== Q6 : changement d'illumination =====================
Ii = Io;
illum = 0.5*linspace(-1,1,size(Ii,1)) + 0.5;
illum = repmat(illum, size(Ii,2), 1);
Ii = Ii .* illum;
R(3) = evaluer(Ii, T, 0.90, 0.50, 'Q6 : illumination modifiée', 'Illumination');

%% Bilan comparatif des trois cas
figure('Name', 'Bilan Q4-Q5-Q6');
cas = categorical({R.cas}); cas = reordercats(cas, {R.cas});
subplot(1,3,1); bar(cas, [[R.rsbNCC]' [R.rsbPC]']); set(gca,'YScale','log');
legend('NCC','PC','Location','best'); title('RSB'); grid on;
subplot(1,3,2); bar(cas, [[R.nNCC]' [R.nPC]']); yline(3, 'k--', 'attendu : 3');
legend('NCC','PC','Location','best'); title('Nombre de ''a'' détectés'); grid on;
subplot(1,3,3); bar(cas, 1000*[[R.tNCC]' [R.tPC]']);
legend('NCC','PC','Location','best'); title('Temps (ms)'); grid on;
sgtitle('Comparaison des deux méthodes');

fprintf('\n%-14s | %-9s %-5s %-9s | %-9s %-5s %-9s\n', 'Cas', 'RSB NCC', 'Nb', 't (ms)', 'RSB PC', 'Nb', 't (ms)');
fprintf('%s\n', repmat('-', 1, 70));
for k = 1:numel(R)
    fprintf('%-14s | %-9.1f %-5d %-9.2f | %-9.1f %-5d %-9.2f\n', R(k).cas, ...
        R(k).rsbNCC, R(k).nNCC, 1000*R(k).tNCC, R(k).rsbPC, R(k).nPC, 1000*R(k).tPC);
end

%% ---------------- Fonctions locales ----------------
function C = correlationPhase(I, T)
% Corrélation de phase (étapes du cours)
F = fft2(I);                               % 1. TF de l'image
G = fft2(T, size(I,1), size(I,2));         % 2. TF du template complété par des zéros
Q = F .* conj(G);                          % 3. interspectre
Q = Q ./ max(abs(Q), eps);                 % 4. normalisation : on ne garde que la phase
C = real(ifft2(Q));                        % 5. TF inverse -> pic(s) de Dirac
end

function r = rsb(C)
% RSB = amplitude carrée du maximum / variance de la corrélation
r = max(C(:))^2 / var(C(:));
end

function R = evaluer(I, T, seuilNCC, seuilPC, titre, nomCas)
% Reprise des questions 2 à 4 sur une image dégradée (template de référence inchangé)
[h, w] = size(T);
tic; C1 = normxcorr2(T, I); tNCC = toc;
tic; C2 = correlationPhase(I, T); tPC = toc;
posNCC = detecterPics(C1, seuilNCC) - [h w] + 1;
posPC  = detecterPics(C2, seuilPC*max(C2(:)));
afficherMaxima(C1, [nomCas ' - NCC']);
afficherMaxima(C2/max(C2(:)), [nomCas ' - PC normalisée']);

figure('Name', titre);
subplot(2,3,1); imshow(I, []); title('Image traitée');
subplot(2,3,2); mesh(C1); axis tight; title('normxcorr2');
subplot(2,3,3); mesh(C2); axis tight; title('Corrélation de phase');
subplot(2,3,5); imshow(I, []); hold on; dessinerBoites(posNCC, h, w, 'g');
title(sprintf('NCC : %d ''a'' (seuil %.2f)', size(posNCC,1), seuilNCC));
subplot(2,3,6); imshow(I, []); hold on; dessinerBoites(posPC, h, w, 'r');
title(sprintf('PC : %d ''a'' (seuil %.2f max)', size(posPC,1), seuilPC));
subplot(2,3,4); axis off;
text(0, 0.5, sprintf(['RSB NCC = %.1f\nRSB PC  = %.1f\n\n' ...
     't NCC = %.2f ms\nt PC  = %.2f ms'], rsb(C1), rsb(C2), 1000*tNCC, 1000*tPC), ...
     'FontName', 'monospaced', 'FontSize', 11);
sgtitle(titre);

R = struct('cas', nomCas, 'rsbNCC', rsb(C1), 'rsbPC', rsb(C2), ...
           'nNCC', size(posNCC,1), 'nPC', size(posPC,1), 'tNCC', tNCC, 'tPC', tPC);
afficherBilan(R, titre);
fprintf('Positions NCC :\n'); disp(array2table(posNCC, 'VariableNames', {'ligne','colonne'}));
fprintf('Positions PC :\n');  disp(array2table(posPC,  'VariableNames', {'ligne','colonne'}));
end

function afficherBilan(R, titre)
fprintf('\n=== %s ===\n', titre);
fprintf('NCC : RSB = %8.1f | %d ''a'' | t = %.2f ms\n', R.rsbNCC, R.nNCC, 1000*R.tNCC);
fprintf('PC  : RSB = %8.1f | %d ''a'' | t = %.2f ms\n', R.rsbPC,  R.nPC,  1000*R.tPC);
end

function pos = detecterPics(C, seuil)
% Un pic par composante connexe au-dessus du seuil (position du maximum)
L = bwlabel(C >= seuil);
n = max(L(:));
pos = zeros(n, 2);
for k = 1:n
    idx = find(L == k);
    [~, m] = max(C(idx));
    [pos(k,1), pos(k,2)] = ind2sub(size(C), idx(m));
end
end

function afficherMaxima(C, nom)
v = sort(C(imregionalmax(C)), 'descend');
fprintf('[%s] 8 plus grands maxima : %s\n', nom, mat2str(v(1:min(8,end))', 3));
end

function dessinerBoites(pos, h, w, couleur)
for k = 1:size(pos,1)
    try
        r = imrect(gca, [pos(k,2) pos(k,1) w h]);   %#ok<IMRECT> fonction demandée dans le TP
        setColor(r, couleur);
    catch
        rectangle('Position', [pos(k,2) pos(k,1) w h], 'EdgeColor', couleur, 'LineWidth', 1.5);
    end
end
end