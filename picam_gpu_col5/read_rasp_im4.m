function im = read_rasp_im4(im, fieldName, i)% Get files at format uint8 rgbargba... first line, second line,...
% F. Gueuning, 2015  ECAM - Bruxelles
% 150221
% Read 4x4 files from  'col_n_0.rgba'  up to  'col_sd2_6.rgba'
% OUT:  im  struct of length 7 with fields :
%         (1)  for texture 0 (192x128)  up to  (7)  for texture 6 (3x2)
%            .n       matrix of double, size [r,c] of texture, values of n for each texel
%            .nrgba   array of uint8, size [r,c,4], texture content
%            .sx      matrix of double, size [r,c] of texture, values of sx for each texel
%            .sxrgba  array of uint8, size [r,c,4], texture content
%            .sy      matrix of double, size [r,c] of texture, values of sy for each texel
%            .syrgba  array of uint8, size [r,c,4], texture content
%            .sd2     matrix of double, size [r,c] of texture, values of sd2 for each texel
%            .sd2rgba array of uint8, size [r,c,4], texture content
% example of post process
% k=0;i=6, [r,c]=size(im(i).n); 
% for ir=1:r, for ic=1:c,
%    if((im(i).n(ir,ic)>100) & (im(i).k(ir,ic)<70)),
%       k=k+1; disp(sprintf('%d: n=%d, k=%1.1d, (%3.1f, %3.1f)' ...
%          , k, im(i).n(ir,ic), im(i).k(ir,ic)/10, im(i).sx(ir,ic)/im(i).n(ir,ic) ...
%          , im(i).sy(ir,ic)/im(i).n(ir,ic))),
%    end,
% end, end

if nargin==0
	im = struct;
	data = {
		%'tex_coordy_' 'coordy'
		'col_n_'   'n'
		'col_sx_'  'sx'
		'col_sy_'  'sy'
		'col_sd2_' 'sd2'
		'col_k_'   'k'
		};
	for i=0:5
		imSize = [768/2^(i+3), 512/2^(i+3)]; % 96x64, 48x32, 24x16, 12x8, 6x4, 3x2
		%imSize = [24, 16]; % 192x128, 96x64, 48x32, 24x16, 12x8, 6x4, 3x2
		for d = 1:size(data, 1)
			[val,rgba] = read_im_int(data{d, 1}, imSize, i);
			im(i+1).(data{d, 2}) = val;
			im(i+1).([data{d, 2} 'rgba']) = rgba;
		end
		% Calcul xb, yb
		if strmatch('sx', fieldnames(im), 'exact') && strmatch('sy', fieldnames(im), 'exact') && strmatch('n', fieldnames(im), 'exact')
			warning off all
			im(i+1).xb = im(i+1).sx ./ im(i+1).n; % Xbarre
			im(i+1).yb = im(i+1).sy ./ im(i+1).n; % Ybarre
			warning on all
		end
	end
else
	disp_im_int(im, fieldName, i)
end
%________________________________________________________________________________________________
function [val, rgba] = read_im_int(partialName, imSize, index)
% read rgba file containing uint32 placed on rgba (LSB on r)
% IN:   partialName  filename without index and extension,  ex: 'col_n_'
%       imSize       vector (2 elem), size of image [row column],  ex: [512 768] for 768x512
%       index        scalar, if exists
%                       - filename is [partialName num2str(index) '.rgba']
% OUT:  val          matrix of size  imSize     : double = uint32
%       rgba         of size  [imSize 4] : uint8
% ex: im = read_im_int('col_n_', [16 24], 'n', 5)  will read file 'col_n_5.rgba'  and return :
%           rgba of size(16, 24, 4)  
%           val  of size(16, 24)
if nargin<3, index = [];end
fid=fopen([partialName num2str(index) '.rgba']);
im_=fread(fid);
fclose(fid);
im__ = uint8(reshape(reshape(im_,4, length(im_)/4)', imSize(1), imSize(2), 4));
rgba = im__(:,:,1)';
rgba(:,:,2) = im__(:,:,2)';
rgba(:,:,3) = im__(:,:,3)';
rgba(:,:,4) = im__(:,:,4)';
im_ = double(rgba);
val = im_(:,:,1) + 256*( im_(:,:,2) + 256*( im_(:,:,3) + 256*im_(:,:,4) ) );
%________________________________________________________________________________________________
function disp_im_int(im, fieldName, i)
% ex: i=[6, 1 1]; read_rasp_im4(im, 'n', i)
disp(sprintf('im_%d: %d,%d',i(1),i(2),i(3)))
disp(im(i(1)+1).(fieldName)(i(2)+(0:min(end-i(2),9)),i(3)+(0:min(end-i(3),15))))
