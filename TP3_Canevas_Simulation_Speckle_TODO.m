% simulation d'image cohérente à l'aide d'une PSF gaussienne
close all; clear all;

%% création PSF gaussienne bidimensionnelle et visualisation
sPSF = [39 39]; % Size of nxn PSF matrix
[X0,Y0] = meshgrid(TODO); % 2-D grid coordinates
x = [TODO]; % [max, m_x, sigma_x, m_y, sigma_y]
PSF = x(1)*exp( -((X0-x(2)).^2/(2*x(3)^2) + (Y0-x(4)).^2/(2*x(5)^2) ));
Y = TODO; % y-coordinates (row-wise)
X = TODO; % x-coordinates (column-wise)
% figure, imagesc(X,Y,PSF), title('PSF'), axis tight, xlabel('x (pixels)'), ylabel('y (pixels)')
figure, mesh(X,Y,PSF), title('PSF'), axis tight, xlabel('x (pixels)'), ylabel('y (pixels)')

%% résolution 
FWHMx = TODO;% en pixels       % Full width half maximum, give an estimate of the resolution in pixels (to be multiplied by the size of a pixel to have it in mm)
FWHMy = TODO; % en pixels        

%% application de la PSF au bruit blanc complexe homogène : simulation du speckle
%
N = 512; % Size of NxN complex white noise matrix
A = TODO; % random amplitude
Phi = TODO; % random phase
Ie = A .*exp(1i*Phi); % complex noisy image
% maxi = max(Ie(:));
% Ie(N/2,N/2) = 10*maxi; Ie(N/2,N/2+5)= 10*maxi; % visible if dx>FWHMx or dy>FWHMy; % lower discrimination along y than along x

Is = imfilter(TODO); % simulated coherent image
figure,
subplot(1,3,1), imagesc(abs(Ie)), title('amplitude de l''image bruit blanc'), axis ij equal tight, xlabel('x (pixels)'), ylabel('y (pixels)'), colormap(gray)
subplot(1,3,2), imagesc(abs(Is)), title('amplitude de l''image cohérente'), axis ij equal tight, xlabel('x (pixels)'), ylabel('y (pixels)'), colormap(gray)
subplot(1,3,3), histogram(abs(Is(:)),'Normalization','pdf'), title('distribution de l''image cohérente') % obs: les 4 histogrammes s'additionnent
hold on

%% estimation des paramètres de la loi de rayleigh et ajustement
a = TODO; % law parameter
x = TODO; % input vector of Rayleigh law
y = TODO; % out vector of Rayleigh law
plot(x,y,'r')

%% application de la PSF au bruit blanc complexe avec 4 niveaux moyens différents
%
N = 512; % Size of NxN image matrix
A = TODO; % random amplitude
Phi = TODO; % random phase
Ie = A .*exp(1i*Phi); % complex noisy image
Ie(1:N/4,:) = Ie(1:N/4,:)/4;
Ie(N/4+1:N/2,:) = Ie(N/4+1:N/2,:) /2;
Ie(N/2+1:3*N/4,:) = Ie(N/2+1:3*N/4,:)*3/4;

Is = imfilter(TODO); % simulated coherent image
figure,
subplot(1,2,1), imagesc(abs(Ie)), title('image synthétique'), axis ij equal tight, xlabel('x (pixels)'), ylabel('y (pixels)'), colormap(gray)
subplot(1,2,2), imagesc(abs(Is)), title('image cohérente'), axis ij equal tight, xlabel('x (pixels)'), ylabel('y (pixels)'), colormap(gray)

%% vérif bruit multiplicatif
I1 = TODO; % first region
I2 = TODO; % second region
I3 = TODO; % third region
I4 = TODO; % last region
[n,x] = hist(Is(:),256);
[n1,x1] = hist(I1(:),256);
[n2,x2] = hist(I2(:),256);
[n3,x3] = hist(I3(:),256);
[n4,x4] = hist(I4(:),256);
figure, plot(x,n,x1,n1,x2,n2,x3,n3,x4,n4)
legend('Ie','I1','I2','I3','I4')

% mean and standard deviation for each region
m1 = TODO; s1 = TODO;
m2 = TODO; s2 = TODO;
m3 = TODO; s3 = TODO;
m4 = TODO; s4 = TODO;
cv = [TODO] % the four variation coefficients
cvth = TODO; 

