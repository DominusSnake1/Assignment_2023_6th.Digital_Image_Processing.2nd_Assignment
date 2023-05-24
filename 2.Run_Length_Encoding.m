pkg load image

clc;close all;clear all;

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

level_butterfly = graythresh(butterflyImage);
binary_butterfly = im2bw(butterflyImage, level_butterfly);

level_cameraman = graythresh(cameramanImage);
binary_cameraman = im2bw(cameramanImage, level_cameraman);

level_lenna = graythresh(lennaImage);
binary_lenna = im2bw(lennaImage, level_lenna);

figure(1);
subplot(2, 3, 1);
imshow(butterflyImage); title('Αρχική - butterfly');
subplot(2, 3, 4);
imshow(binary_butterfly); title('Δυαδική - butterfly');
subplot(2, 3, 2);
imshow(cameramanImage); title('Αρχική - cameraman');
subplot(2, 3, 5);
imshow(binary_cameraman); title('Δυαδική - cameraman');
subplot(2, 3, 3);
imshow(lennaImage); title('Αρχική - lenna');
subplot(2, 3, 6);
imshow(binary_lenna); title('Δυαδική - lenna')
