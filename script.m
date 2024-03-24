im1 = imread("image1.jpg");
im2 = imread("image2.jpg");

figure(1)
imshow(im1);
for j=1:4
    zoom on;
    pause();
    zoom off;
    [x1(j),y1(j)]=ginput(1);
    zoom out;
end
 
figure(2)
imshow(im2);
for j=1:4
    zoom on;
    pause();
    zoom off;
    [x2(j),y2(j)]=ginput(1);
    zoom out;
end

save("pt1", "x1", "y1");
save("pt2", "x2", "y2");
load("pt1");
load("pt2");

%%
close all
H = computeHomography(x1, y1, x2, y2);
inverse_H = inv(H);

tform = projtform2d(inverse_H);
RO = imref2d(size(im1));
B = imwarp(im2, tform, 'OutputView', RO);

zeroPixels = B == 0;
B(zeroPixels) = im1(zeroPixels);

C = imfuse(im1, B, 'blend', 'Scaling', 'joint');
C = imsharpen(C);

imwrite(C,"image_non_reflexes.jpg")
imshow(C)

function H = computeHomography(x1, y1, x2, y2)
    M = [];
    for i = 1:4
        M = [M;
             x1(i), y1(i), 1, 0, 0, 0, -x2(i)*x1(i), -x2(i)*y1(i), -x2(i);
             0, 0, 0, x1(i), y1(i), 1, -y2(i)*x1(i), -y2(i)*y1(i), -y2(i)];
    end
    [~, ~, V] = svd(M);
    h = V(:,end);
    H = reshape(h, 3, 3)';
    H = H / H(3,3);
end