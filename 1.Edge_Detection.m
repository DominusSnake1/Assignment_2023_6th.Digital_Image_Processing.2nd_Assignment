pkg load image

clc;close all;clear all;

function finalEdges = otsuThresholding(image, rows, columns)
  rows = imfilter(image, rows);
  columns = imfilter(image, columns);

  finalEdges = round(sqrt((double(rows).^2 + double(columns).^2)));
  Gimage = uint8(finalEdges);
  finalEdges = im2bw(Gimage, "Otsu");
end

function sobelImage = sobelFilter(image)
  columns = [1 2 1; 0 0 0; -1 -2 -1];
  rows =    [-1 0 1; -2 0 2; -1 0 1];

  sobelImage = otsuThresholding(image, rows, columns);
end

function robertsImage = robertsFilter(image)
  columns = [-1 0 0; 0 1 0; 0 0 0];
  rows =    [0 0 -1; 0 1 0; 0 0 0];

  robertsImage = otsuThresholding(image, rows, columns);
end

function prewittImage = prewittFilter(image)
  columns = [1 1 1; 0 0 0; -1 -1 -1];
  rows =    [-1 0 1; -1 0 1; -1 0 1];

  prewittImage = otsuThresholding(image, rows, columns);
end

function kirschImage = kirschFilter(image, T)
  kirschMask1 = [-3 -3 -3; -3 0 -3; 5 5 5] / 15;
  kirschMask2 = [-3 -3 -3; 5 0 -3; 5 5 -3] / 15;
  kirschMask3 = [5 -3 -3; 5 0 -3; 5 -3 -3] / 15;
  kirschMask4 = [5 5 -3; 5 0 -3; -3 -3 -3] / 15;
  kirschMask5 = [5 5 5; -3 0 -3; -3 -3 -3] / 15;
  kirschMask6 = [-3 5 5; -3 0 5; -3 -3 -3] / 15;
  kirschMask7 = [-3 -3 5; -3 0 5; -3 -3 5] / 15;
  kirschMask8 = [-3 -3 -3; -3 0 5; -3 5 5] / 15;

  B = imfilter(image, kirschMask1);
  B = max(B, imfilter(image, kirschMask2, 'replicate'));
  B = max(B, imfilter(image, kirschMask3, 'replicate'));
  B = max(B, imfilter(image, kirschMask4, 'replicate'));
  B = max(B, imfilter(image, kirschMask5, 'replicate'));
  B = max(B, imfilter(image, kirschMask6, 'replicate'));
  B = max(B, imfilter(image, kirschMask7, 'replicate'));
  B = max(B, imfilter(image, kirschMask8, 'replicate'));

  kirschImage = im2uint8(B > T);
end

function logImage = logFilter(image, sigma, T)
  sigma = 1.4;
  filtersize = 2 * ceil(3 * sigma) + 1;
  siz = (filtersize-1) / 2;
  std2 = sigma ^ 2;
  [x,y] = meshgrid(-siz:siz, -siz:siz);
  arg = -(x.*x + y.*y)/(2 * std2);
  h = exp(arg);
  h(h<eps*max(h(:))) = 0;
  sumh = sum(h(:));
  if sumh ~= 0
    h = h/sumh;
  end
  h1 = h.*(x.*x+y.*y- std2)/(std2^2);
  h = h1 - sum(h1(:))/(filtersize^2);

  logImage = imfilter(image, h);
  logImage(logImage < T) = 0;
  logImage(logImage >= T) = 255;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

butterflyImage = rgb2gray(imread('butterfly.jpg'));
cameramanImage = imread('cameraman.bmp');
lennaImage = imread('lenna.bmp');

figure(1);
subplot(1, 3, 1);
imshow(butterflyImage); title("[Butterfly] Original Image in grayscale");
subplot(1, 3, 2);
imshow(cameramanImage); title("[Cameraman] Original Image");
subplot(1, 3, 3);
imshow(lennaImage); title("[Lenna] Original Image");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

butterflySobel = sobelFilter(butterflyImage);
cameramanSobel = sobelFilter(cameramanImage);
lennaSobel = sobelFilter(lennaImage);

figure(2);
subplot(1, 3, 1);
imshow(butterflySobel); title("[Butterfly] Sobel Filter");
subplot(1, 3, 2);
imshow(cameramanSobel); title("[Cameraman] Sobel Filter");
subplot(1, 3, 3);
imshow(lennaSobel); title("[Lenna] Sobel Filter");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

butterflyRoberts = robertsFilter(butterflyImage);
cameramanRoberts = robertsFilter(cameramanImage);
lennaRoberts = robertsFilter(lennaImage);

figure(3);
subplot(1, 3, 1);
imshow(butterflyRoberts); title("[Butterfly] Roberts Filter");
subplot(1, 3, 2);
imshow(cameramanRoberts); title("[Cameraman] Roberts Filter");
subplot(1, 3, 3);
imshow(lennaRoberts); title("[Lenna] Roberts Filter");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

butterflyPrewitt = prewittFilter(butterflyImage);
cameramanPrewitt = prewittFilter(cameramanImage);
lennaPrewitt = prewittFilter(lennaImage);

figure(4);
subplot(1, 3, 1);
imshow(butterflyPrewitt); title("[Butterfly] Prewitt Filter");
subplot(1, 3, 2);
imshow(cameramanPrewitt); title("[Cameraman] Prewitt Filter");
subplot(1, 3, 3);
imshow(lennaPrewitt); title("[Lenna] Prewitt Filter");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

T = 50;
butterflyKirsch = kirschFilter(butterflyImage, T);
cameramanKirsch = kirschFilter(cameramanImage, T);
lennaKirsch = kirschFilter(lennaImage, T);

figure(5);
subplot(1, 3, 1);
imshow(butterflyKirsch); title(['[Butterfly] Kirsch Filter with T = ', num2str(T)]);
subplot(1, 3, 2);
imshow(cameramanKirsch); title(['[Cameraman] Kirsch Filter with T = ', num2str(T)]);
subplot(1, 3, 3);
imshow(lennaKirsch); title(['[Lenna] Kirsch Filter with T = ', num2str(T)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sigma = 1.5;
T = 4;
butterflyLog = logFilter(butterflyImage, sigma, T);
cameramanLog = logFilter(cameramanImage, sigma, T);
lennaLog = logFilter(lennaImage, sigma, T);

figure(6);
subplot(1, 3, 1);
imshow(butterflyLog); title(['[Butterfly] LoG filter with T = ', num2str(T), ' and σ = ', num2str(sigma)]);
subplot(1, 3, 2);
imshow(cameramanLog); title(['[Cameraman] LoG filter with T = ', num2str(T), ' and σ = ', num2str(sigma)]);
subplot(1, 3, 3);
imshow(lennaLog); title(['[Lenna] LoG filter with T = ', num2str(T), ' and σ = ', num2str(sigma)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

butterflyCanny = edge(butterflyImage, "Canny");
cameramanCanny = edge(cameramanImage, "Canny");
lennaCanny = edge(lennaImage, "Canny");

figure(7);
subplot(1, 3, 1);
imshow(butterflyCanny); title("[Butterfly] Canny filter");
subplot(1, 3, 2);
imshow(cameramanCanny); title("[Cameraman] Canny filter");
subplot(1, 3, 3);
imshow(lennaCanny); title("[Lenna] Canny filter");
