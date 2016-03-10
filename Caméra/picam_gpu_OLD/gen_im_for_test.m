% Generate image 768x512 for test
im1 = ones(512,1)*(1:13:13*768) + (0:23:23*511)'*ones(1,768);
im1(:,:,2) = ones(512,1)*(0:767) + (0:511)'*ones(1,768);
im1(:,:,3) = ones(512,1)*(767:-1:0) + (511:-1:0)'*ones(1,768);
im2=uint8(mod(im1,256));
figure,subplot(211),image(im2), subplot(212), image(im2(:,:,[1 1 1]))
imwrite(im2, 'im_color_for_test.png')
imwrite(im2(:,:,1), 'im_nb_for_test.png')
