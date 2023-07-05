pkg load image

clc;close all;clear all;

function imageEncoded = lengthEncoding(imageBinary)
    [height, width] = size(imageBinary);
    imageEncoded = zeros(height, width);

    for row = 1:height
        runLength = 0;

        for column = 1:width
            if imageBinary(row, column) == 1
                runLength = runLength + 1;

                if column == width
                    for column = 1:width
                        if runLength >= column
                            imageEncoded(row, column) = 1;
                        else
                            imageEncoded(row, column) = 0;
                        end
                    end
                end
            end
        end
    end
end


function finalEdges = otsuThresholding(image)
  level = graythresh(image, 'Otsu');
  finalEdges = im2bw(image, level);
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

butterflyBinary = otsuThresholding(butterflyImage);
cameramanBinary = otsuThresholding(cameramanImage);
lennaBinary = otsuThresholding(lennaImage);

butterflyEncoded = lengthEncoding(butterflyBinary);
cameramanEncoded = lengthEncoding(cameramanBinary);
lennaEncoded = lengthEncoding(lennaBinary);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1);
subplot(2, 3, 1);
imshow(butterflyImage); title('Original - butterfly');
subplot(2, 3, 4);
imshow(butterflyBinary); title('Binary - butterfly');
subplot(2, 3, 2);
imshow(cameramanImage); title('Original - cameraman');
subplot(2, 3, 5);
imshow(cameramanBinary); title('Binary - cameraman');
subplot(2, 3, 3);
imshow(lennaImage); title('Original - lenna');
subplot(2, 3, 6);
imshow(lennaBinary); title('Binary - lenna');

figure(2);
subplot(1, 3, 1);
imshow(butterflyEncoded); title('Encoded - Butterfly');
subplot(1, 3, 2);
imshow(cameramanEncoded); title('Encoded - Cameraman');
subplot(1, 3, 3);
imshow(lennaEncoded); title('Encoded - Lenna');
