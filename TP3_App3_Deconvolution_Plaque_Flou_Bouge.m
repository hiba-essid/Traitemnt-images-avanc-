clear; close all; clc

load plaquAutoPack.mat            % Ib, estimated_nsr
Ib = im2double(Ib);
nsr = estimated_nsr(1);
fprintf('NSR estime = %g\n', nsr);

%% 1. Type de degradation et parametres
figure; imshow(Ib); title('Image degradee')

S = log(1 + abs(fftshift(fft2(Ib))));
figure; imagesc(S); colormap gray; axis image; title('log |TF| : stries = sinc')

theta = 0:179;
R = radon(S - mean(S(:)), theta);
figure; plot(theta, var(R)); xlabel('theta (deg)'); ylabel('variance de la projection')
title('Orientation des stries du spectre')
[~, k] = max(var(R));
fprintf('Angle des stries (Radon) = %d deg -> flou de bouge ~ perpendiculaire\n', theta(k));
% Longueur L : periode des zeros du sinc dans le spectre, N/L (N = taille image)

%% 2. Comparaison des 3 methodes, PSF exacte (13,45)
PSF = fspecial('motion', 13, 45);
figure; imshow(Ib); title('Selectionner la plaque (rectangle puis double-clic)')
[~, rect] = imcrop;  close
compare(Ib, PSF, nsr, rect, 'Q2 - PSF exacte : motion(13,45)');

%% 3. PSF legerement erronee (14,45)
PSF2 = fspecial('motion', 14, 45);
compare(Ib, PSF2, nsr, rect, 'Q3 - PSF erronee : motion(14,45)');

%% 4. Deconvolution aveugle
INITPSF = ones(size(PSF));
[Jb, PSFe] = deconvblind(Ib, INITPSF, 30);

figure
subplot(1,2,1); imagesc(PSF);  axis image; colorbar; title('PSF reelle')
subplot(1,2,2); imagesc(PSFe); axis image; colorbar; title('PSF estimee')

[Jb2, PSFe2] = deconvblind(Ib, PSFe, 30);

figure
subplot(2,2,1); imshow(Ib);  title('Degradee')
subplot(2,2,2); imshow(Jb);  title('Aveugle (init = 1)')
subplot(2,2,3); imshow(Jb2); title('Aveugle (init = PSF estimee)')
subplot(2,2,4); imagesc(PSFe2); axis image; title('PSF re-estimee')

%% fonction locale
function compare(Ib, PSF, nsr, rect, nom)
    np = nsr*var(Ib(:))*numel(Ib);              % puissance de bruit pour deconvreg
    J1 = deconvwnr(Ib, PSF, nsr);
    [J2, lag] = deconvreg(Ib, PSF, np);
    J3 = deconvlucy(Ib, PSF, 20);
    im  = {J1, J2, J3};
    tit = {'Wiener (deconvwnr)', sprintf('Hunt (deconvreg, \\lambda=%.2g)', lag), ...
           'Lucy-Richardson (deconvlucy, 20 it.)'};

    % une figure par methode : image entiere + zoom plaque
    for k = 1:3
        figure('Name', [nom ' - ' tit{k}])
        subplot(1,2,1); imshow(im{k}); title(tit{k})
        subplot(1,2,2); imshow(imcrop(im{k}, rect)); title('Zoom plaque')
    end

    % comparaison : zoom plaque cote a cote
    figure('Name', [nom ' - comparaison'], 'Position', [50 50 1400 400])
    subplot(1,4,1); imshow(imcrop(Ib, rect)); title('Degradee')
    for k = 1:3
        subplot(1,4,k+1); imshow(imcrop(im{k}, rect)); title(tit{k}, 'FontSize', 9)
    end
    sgtitle(nom)
end