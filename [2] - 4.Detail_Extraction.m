clear all; close all; clc;

pkg load image;

function randomImages = pickFiveRandomImages(imageFolder)
    image_files = dir(fullfile(imageFolder, '*.jpg'));
    random = randperm(length(image_files), 5);

    randomImages = image_files(random);
end

function [imX] = makeImage(x)
    x = double(x);
    minX = min(min(x));
    maxX = max(max(x));
    scalex = maxX - minX;
    imX = uint8(floor((x - minX) * 255 / scalex));
end

function [imageLBP, imageContrast] = processImage(imageGrayscale)
    [M, N] = size(imageGrayscale);
    Inew = zeros(M + 2, N + 2);
    C = zeros(M, N);
    Maska = zeros(3, 3);
    LBP = Inew;
    Inew(2:M+1, 2:N+1) = double(imageGrayscale);

    for i = 2:M+1
        for j = 2:N+1
            T = Inew(i, j);
            Maska = Inew(i-1:i+1, j-1:j+1);
            Maska(2, 2) = 0;
            C2 = sum(sum(Maska));
            B = find(Maska > T);
            empty_B = sum(sum(B));

            if empty_B > 0
                C1 = sum(sum(Maska(B)));
                Maska(1:3, 1:3) = 0;
                Maska(B) = 1;
                number_1 = sum(sum(Maska));
            else
                C1 = 0;
                Maska(1:3, 1:3) = 0;
                number_1 = 0;
            end

            LBP(i, j) = Maska(1, 1)*2^7 + Maska(1, 2)*2^6 + Maska(1, 3)*2^5 ...
                + Maska(2, 3)*2^4 + Maska(3, 3)*2^3 + Maska(3, 2)*2^2 ...
                + Maska(3, 1)*2^1 + Maska(2, 1)*2^0;

            C2 = C2 - C1;

            if number_1 > 0
                if 8 - number_1 > 0
                    C(i, j) = (C1 / number_1) - (C2 / (8 - number_1));
                else
                    C(i, j) = C1 / number_1;
                end
            else
                C(i, j) = -(C2 / (8 - number_1));
            end
        end
    end

    imageLBP = uint8(LBP(2:M+1, 2:N+1));
    imageContrast = makeImage(C);
end

function similarity_L1 = getSimilarity_L1(f1, f2)
    similarity_L1 = sum(abs(f1 - f2));
end

function similarity_L2 = getSimilarity_L2(f1, f2)
    similarity_L2 = sqrt(sum(abs(f1 - f2).^2));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imageFolder = './Flower Image Dataset';

randomImages = pickFiveRandomImages(imageFolder);

featureVectors = cell(5, 1);

for i = 1:5
    img = imread(fullfile(imageFolder, randomImages(i).name));
    imageGrayscale = rgb2gray(img);

    [imageLBP, imageContrast] = processImage(imageGrayscale);
    featureVectors{i} = imageContrast(:);

    figure('name', randomImages(i).name);
    subplot(2, 2, 1);
    imshow(imageGrayscale); title('Original Image in Grayscale')
    subplot(2, 2, 2);
    imshow(imageLBP); title('LBP Image')
    subplot(2, 2, 3);
    hist(double(imageContrast(:)), 256); title('Normalized Brightness Histogram')
    subplot(2, 2, 4);
    hist(double(imageLBP(:)), 256); title('Normalized LBP Texture Histogram')
end

for i = 1:4
    for j = i+1:5
        f1 = featureVectors{i};
        f2 = featureVectors{j};

        similarity_L1 = getSimilarity_L1(f1, f2);
        fprintf('L1 Similarity between Image %d and Image %d: %.2f\n', i, j, similarity_L1);

        similarity_L2 = getSimilarity_L2(f1, f2);
        fprintf('L2 Similarity between Image %d and Image %d: %.2f\n\n', i, j, similarity_L2);
    end
end
