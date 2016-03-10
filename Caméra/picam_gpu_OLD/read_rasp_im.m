% Get files at format uint8 rgbargba... first line, second line,...
% F. Gueuning, 2015  ECAM - Bruxelles
% 150217
fid=fopen('tex_rgb_0hi.rgba'); % assumed 768x512x3
im0_=fread(fid);
fclose(fid);
fid=fopen('tex_rgb_1hi.rgba'); % assumed 384x256x3
im1_=fread(fid);
fclose(fid);
fid=fopen('tex_rgb_2mid.rgba'); % assumed 192x128x3
im2_=fread(fid);
fclose(fid);
fid=fopen('tex_rgb_3low.rgba'); % assumed 96x64x3
im3_=fread(fid);
fclose(fid);
fid=fopen('tex_rgb_4low.rgba'); % assumed 48x32x3
im4_=fread(fid);
fclose(fid);

% make standard image  Row x Column x Compo
im0__ = uint8(reshape(reshape(im0_,4, length(im0_)/4)', 768, 512, 4));
im0t = im0__(:,:,1)'; im0t(:,:,2) = im0__(:,:,2)'; im0t(:,:,3) = im0__(:,:,3)';
im1__ = uint8(reshape(reshape(im1_,4, length(im1_)/4)', 384, 256, 4));
im1t = im1__(:,:,1)'; im1t(:,:,2) = im1__(:,:,2)'; im1t(:,:,3) = im1__(:,:,3)';
im2__ = uint8(reshape(reshape(im2_,4, length(im2_)/4)', 192, 128, 4));
im2t = im2__(:,:,1)'; im2t(:,:,2) = im2__(:,:,2)'; im2t(:,:,3) = im2__(:,:,3)';
im3__ = uint8(reshape(reshape(im3_,4, length(im3_)/4)', 96, 64, 4));
im3t = im3__(:,:,1)'; im3t(:,:,2) = im3__(:,:,2)'; im3t(:,:,3) = im3__(:,:,3)';
im4__ = uint8(reshape(reshape(im4_,4, length(im4_)/4)', 48, 32, 4));
im4t = im4__(:,:,1)'; im4t(:,:,2) = im4__(:,:,2)'; im4t(:,:,3) = im4__(:,:,3)';

clear fid im0_ im0__ im1_ im1__ im2_ im2__ im3_ im3__ im4_ im4__

figure
subplot(221), image(im0t), title('im0t'), subplot(222), image(im1t), title('im1t')
subplot(337), image(im2t), title('im2t'), subplot(338), image(im3t), title('im3t'), subplot(339), image(im4t), title('im4t')
