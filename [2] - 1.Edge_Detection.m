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

butterflyImage = imread('butterfly.jpg');
cameramanImage = imread('cameraman.bmp');
lennaImage = imread('lenna.bmp');

if size(butterflyImage, 3) > 1
    butterflyImage = rgb2gray(butterflyImage);
end
if size(cameramanImage, 3) > 1
    cameramanImage = rgb2gray(cameramanImage);
end
if size(lennaImage, 3) > 1
    lennaImage = rgb2gray(lennaImage);
end

TKirsch = 50;
sigma = 3;
TLog = 4;

butterflySobel = sobelFilter(butterflyImage);
butterflyRoberts = robertsFilter(butterflyImage);
butterflyPrewitt = prewittFilter(butterflyImage);
butterflyKirsch = kirschFilter(butterflyImage, TKirsch);
butterflyLog = logFilter(butterflyImage, sigma, TLog);
butterflyCanny = edge(butterflyImage, "Canny");

cameramanSobel = sobelFilter(cameramanImage);
cameramanRoberts = robertsFilter(cameramanImage);
cameramanPrewitt = prewittFilter(cameramanImage);
cameramanKirsch = kirschFilter(cameramanImage, TKirsch);
cameramanLog = logFilter(cameramanImage, sigma, TLog);
cameramanCanny = edge(cameramanImage, "Canny");

lennaSobel = sobelFilter(lennaImage);
lennaRoberts = robertsFilter(lennaImage);
lennaPrewitt = prewittFilter(lennaImage);
lennaKirsch = kirschFilter(lennaImage, TKirsch);
lennaLog = logFilter(lennaImage, sigma, TLog);
lennaCanny = edge(lennaImage, "Canny");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1);
subplot(1, 3, 1);
imshow(butterflyImage); title("Original Image");
subplot(1, 3, 2);
imshow(cameramanImage); title("Original Image");
subplot(1, 3, 3);
imshow(lennaImage); title("Original Image");

figure(2);
subplot(2, 3, 1);
imshow(butterflySobel); title("Sobel Filter");
subplot(2, 3, 2);
imshow(butterflyRoberts); title("Roberts Filter");
subplot(2, 3, 3);
imshow(butterflyPrewitt); title("Prewitt Filter");
subplot(2, 3, 4);
imshow(butterflyKirsch); title(['Kirsch Filter with T = ', num2str(TKirsch)]);
subplot(2, 3, 5);
imshow(butterflyLog); title(['LoG filter with T = ', num2str(TLog), ' and σ = ', num2str(sigma)]);
subplot(2, 3, 6);
imshow(butterflyCanny); title("Canny filter");

figure(3);
subplot(2, 3, 1);
imshow(cameramanSobel); title("Sobel Filter");
subplot(2, 3, 2);
imshow(cameramanRoberts); title("Roberts Filter");
subplot(2, 3, 3);
imshow(cameramanPrewitt); title("Prewitt Filter");
subplot(2, 3, 4);
imshow(cameramanKirsch); title(['Kirsch Filter with T = ', num2str(TKirsch)]);
subplot(2, 3, 5);
imshow(cameramanLog); title(['LoG filter with T = ', num2str(TLog), ' and σ = ', num2str(sigma)]);
subplot(2, 3, 6);
imshow(cameramanCanny); title("Canny filter");

figure(4);
subplot(2, 3, 1);
imshow(lennaSobel); title("Sobel Filter");
subplot(2, 3, 2);
imshow(lennaRoberts); title("Roberts Filter");
subplot(2, 3, 3);
imshow(lennaPrewitt); title("Prewitt Filter");
subplot(2, 3, 4);
imshow(lennaKirsch); title(['Kirsch Filter with T = ', num2str(TKirsch)]);
subplot(2, 3, 5);
imshow(lennaLog); title(['LoG filter with T = ', num2str(TLog), ' and σ = ', num2str(sigma)]);
subplot(2, 3, 6);
imshow(lennaCanny); title("Canny filter");
