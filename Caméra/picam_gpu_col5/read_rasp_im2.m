% Get files at format uint8 rgbargba... first line, second line,...
% F. Gueuning, 2015  ECAM - Bruxelles
% 190217
for i=0:6
	fid=fopen(['tex_coordx_' num2str(i) '.rgba']); % assumed 768/2^(i+2) x 512/2^(i+2) x 4
	im(i+1).xrgba=fread(fid);
	fclose(fid);
	im__ = uint8(reshape(reshape(im(i+1).xrgba,4, length(im(i+1).xrgba)/4)', 768/2^(i+2), 512/2^(i+2), 4));
	im(i+1).x = im__(:,:,1)'; im(i+1).x(:,:,2) = im__(:,:,2)'; im(i+1).x(:,:,3) = im__(:,:,3)'; im(i+1).x(:,:,4) = im__(:,:,4)';

	fid=fopen(['tex_coordy_' num2str(i) '.rgba']); % assumed 768/2^i x 512/2^i x 4
	im(i+1).yrgba=fread(fid);
	fclose(fid);
	im__ = uint8(reshape(reshape(im(i+1).yrgba,4, length(im(i+1).yrgba)/4)', 768/2^(i+2), 512/2^(i+2), 4));
	im(i+1).y = im__(:,:,1)'; im(i+1).y(:,:,2) = im__(:,:,2)'; im(i+1).y(:,:,3) = im__(:,:,3)'; im(i+1).y(:,:,4) = im__(:,:,4)';

end
clear fid im__

%figure
%subplot(221), image(im0t), title('im0t'), subplot(222), image(im1t), title('im1t')
%subplot(337), image(im2t), title('im2t'), subplot(338), image(im3t), title('im3t'), subplot(339), image(im4t), title('im4t')
