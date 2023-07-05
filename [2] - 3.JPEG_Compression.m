clear all; close all; clc;

function value = divq(data, Q)
    value = data ./ Q;
end

function value = multip(data, q)
    value = data .* q;
end

function encodedImage = encode(originalImage, Q)
    [height, width] = size(originalImage);
    newHeight = ceil(height / 8) * 8;
    newWidth = ceil(width / 8) * 8;
    originalImage = imresize(originalImage, [newHeight, newWidth]);
    
    originalImage = originalImage - 128;
    encoded = blockproc(originalImage, [8 8], @(block_struct) dct2(block_struct));
    
    encodedImage = blockproc(encoded, [8 8], @(block_struct) divq(block_struct, Q));
end

function decodedImage = decode(originalImage, encodedImage, Q)
    [height, width] = size(originalImage);
    decoded = blockproc(encodedImage, [8 8], @(block_struct) multip(block_struct, Q));
    decoded = blockproc(decoded, [8 8], @(block_struct) idct2(block_struct));
    decodedImage = decoded + 128;
    decodedImage = round(decodedImage);
    decodedImage = decodedImage(1:height, 1:width);
end

function averageCodeLength = huffman(image)
    [height, width] = size(image);
  
    p = imhist(image) / (height * width);
    dict = huffmandict(0:255, p.');
  
    averageCodeLength = 0.0;
    for i = 1:256
        temp = dict{i};
        averageCodeLength = averageCodeLength + numel(temp) * p(i);
    end
end

function ratio = compressionRatio(image, encodedImage)
    originalSize = numel(image);
    encodedSize = numel(encodedImage);
    
    ratio = originalSize / encodedSize;
end

function psnr = calculatePSNR(image, decodedImage)
    mse = mean((image(:) - decodedImage(:)).^2);
    maxIntensity = max(image(:));
    psnr = 10 * log10((maxIntensity^2) / mse);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Q10 = [80 60 50 80 120 200 255 255
       55 60 70 95 130 255 255 255
       70 65 80 120 200 255 255 255
       70 85 110 145 255 255 255 255
       90 110 255 255 255 255 255 255
       120 175 255 255 255 255 255 255
       255 255 255 255 255 255 255 255
       255 255 255 255 255 255 255 255];

Q50 = [16 11 10 16 24 40 51 61
       12 12 14 19 26 58 60 55
       14 13 16 24 40 57 69 56
       14 17 22 29 51 87 80 62
       18 22 37 56 68 109 103 77
       24 35 55 64 81 104 113 92
       49 64 78 87 103 121 120 101
       72 92 95 98 112 100 103 99];

butterflyImage = im2double(imread('butterfly.jpg'));
cameramanImage = im2double(imread('cameraman.bmp'));
lennaImage = im2double(imread('lenna.bmp'));

if size(butterflyImage, 3) > 1
    butterflyImage = rgb2gray(butterflyImage);
end
if size(cameramanImage, 3) > 1
    cameramanImage = rgb2gray(cameramanImage);
end
if size(lennaImage, 3) > 1
    lennaImage = rgb2gray(lennaImage);
end

butterflyEncoded_Q10 = encode(butterflyImage, Q10);
butterflyEncoded_Q50 = encode(butterflyImage, Q50);
butterflyDecoded_Q10 = decode(butterflyImage, butterflyEncoded_Q10, Q10);
butterflyDecoded_Q50 = decode(butterflyImage, butterflyEncoded_Q50, Q50);

butterflyAvgCodeLength_Q10 = huffman(butterflyEncoded_Q10);
butterflyAvgCodeLength_Q50 = huffman(butterflyEncoded_Q50);

butterflyCompressionRatio_Q10 = compressionRatio(butterflyImage, butterflyEncoded_Q10);
butterflyCompressionRatio_Q50 = compressionRatio(butterflyImage, butterflyEncoded_Q50);

butterflyPNSR_Q10 = calculatePSNR(butterflyImage, butterflyDecoded_Q10);
butterflyPNSR_Q50 = calculatePSNR(butterflyImage, butterflyDecoded_Q50);

cameramanEncoded_Q10 = encode(cameramanImage, Q10);
cameramanEncoded_Q50 = encode(cameramanImage, Q50);
cameramanDecoded_Q10 = decode(cameramanImage, cameramanEncoded_Q10, Q10);
cameramanDecoded_Q50 = decode(cameramanImage, cameramanEncoded_Q50, Q50);

cameramanAvgCodeLength_Q10 = huffman(cameramanEncoded_Q10);
cameramanAvgCodeLength_Q50 = huffman(cameramanEncoded_Q50);

cameramanCompressionRatio_Q10 = compressionRatio(cameramanImage, cameramanEncoded_Q10);
cameramanCompressionRatio_Q50 = compressionRatio(cameramanImage, cameramanEncoded_Q50);

cameramanPNSR_Q10 = calculatePSNR(cameramanImage, cameramanDecoded_Q10);
cameramanPNSR_Q50 = calculatePSNR(cameramanImage, cameramanDecoded_Q50);

lennaEncoded_Q10 = encode(lennaImage, Q10);
lennaEncoded_Q50 = encode(lennaImage, Q50);
lennaDecoded_Q10 = decode(lennaImage, lennaEncoded_Q10, Q10);
lennaDecoded_Q50 = decode(lennaImage, lennaEncoded_Q50, Q50);

lennaAvgCodeLength_Q10 = huffman(lennaEncoded_Q10);
lennaAvgCodeLength_Q50 = huffman(lennaEncoded_Q50);

lennaCompressionRatio_Q10 = compressionRatio(lennaImage, lennaEncoded_Q10);
lennaCompressionRatio_Q50 = compressionRatio(lennaImage, lennaEncoded_Q50);

lennaPNSR_Q10 = calculatePSNR(lennaImage, lennaDecoded_Q10);
lennaPNSR_Q50 = calculatePSNR(lennaImage, lennaDecoded_Q50);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1);
subplot(1, 3, 1);
imshow(butterflyImage); title('Original Image');
subplot(1, 3, 2);
imshow(cameramanImage); title('Original Image');
subplot(1, 3, 3);
imshow(lennaImage); title('Original Image');

figure(2);
subplot(2, 2, 1);
imshow(butterflyEncoded_Q10); title('Encoded Image (Q10)');
subplot(2, 2, 2);
imshow(butterflyEncoded_Q50); title('Encoded Image (Q50)');
subplot(2, 2, 3);
imshow(butterflyDecoded_Q10); title('Decoded Image (Q10)');
subplot(2, 2, 4);
imshow(butterflyDecoded_Q50); title('Decoded Image (Q50)');

fprintf('======{ Butterfly }======\n');
fprintf('* Average Code Length:\n');
fprintf('** Q10 = %f\n** Q50 = %f\n', butterflyAvgCodeLength_Q10, butterflyAvgCodeLength_Q50);
fprintf('* Compression Ratio:\n');
fprintf('** Q10 = %f\n** Q50 = %f\n', butterflyCompressionRatio_Q10, butterflyCompressionRatio_Q50);
fprintf('* PSNR:\n');
fprintf('** Q10 = %f\n** Q50 = %f\n\n', butterflyPNSR_Q10, butterflyPNSR_Q50);

figure(3);
subplot(2, 2, 1);
imshow(cameramanEncoded_Q10); title('Encoded Image (Q10)');
subplot(2, 2, 2);
imshow(cameramanEncoded_Q50); title('Encoded Image (Q50)');
subplot(2, 2, 3);
imshow(cameramanDecoded_Q10); title('Decoded Image (Q10)');
subplot(2, 2, 4);
imshow(cameramanDecoded_Q50); title('Decoded Image (Q50)');

fprintf('======{ Cameraman }======\n');
fprintf('* Average Code Length:\n');
fprintf('** Q10 = %f\n** Q50 = %f\n', cameramanAvgCodeLength_Q10, cameramanAvgCodeLength_Q50);
fprintf('* Compression Ratio:\n');
fprintf('** Q10 = %f\n** Q50 = %f\n', cameramanCompressionRatio_Q10, cameramanCompressionRatio_Q50);
fprintf('* PSNR:\n');
fprintf('** Q10 = %f\n** Q50 = %f\n\n', cameramanPNSR_Q10, cameramanPNSR_Q50);

figure(4);
subplot(2, 2, 1);
imshow(lennaEncoded_Q10); title('Encoded Image (Q10)');
subplot(2, 2, 2);
imshow(lennaEncoded_Q50); title('Encoded Image (Q50)');
subplot(2, 2, 3);
imshow(lennaDecoded_Q10); title('Decoded Image (Q10)');
subplot(2, 2, 4);
imshow(lennaDecoded_Q50); title('Decoded Image (Q50)');

fprintf('======{ Lenna }======\n');
fprintf('* Average Code Length:\n');
fprintf('** Q10 = %f\n** Q50 = %f\n', lennaAvgCodeLength_Q10, lennaAvgCodeLength_Q50);
fprintf('* Compression Ratio:\n');
fprintf('** Q10 = %f\n** Q50 = %f\n', lennaCompressionRatio_Q10, lennaCompressionRatio_Q50);
fprintf('* PSNR:\n');
fprintf('** Q10 = %f\n** Q50 = %f\n\n', lennaPNSR_Q10, lennaPNSR_Q50);
