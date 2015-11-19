function im = rgbaread(filename, WHratio)
% read rgba file containing uint32 placed on rgba (LSB on r)
% F. Gueuning, 2015  ECAM - Bruxelles
% 150225
% IN:   filename     ex: 'col_sxsy0.rgba'  or  'col_sxsy0'
%       WHratio      ratio between width and height, def: 3/2
% OUT:  im           uint8 image, size: [H * WHratio,  H,  4]
%                                       with  Len = Length(data)
%                                             H = sqrt(Len/WHratio/4)
% ex:  im = rgbaread('col_sxsy0', 3/2)
%
% ex of specific usage :
% im = rgbaread('col_sxsy0', 3/2);
% a0=im(:,:,4);
% a=a0(a0<255);size(a)          % ans =  10321           1
% b=a((1-(a==251))>0);size(b)   % ans =   5449           1
% c=b((1-(b==254))>0);size(c)   % ans =      0           1

if nargin<2, WHratio = 3/2; end
if isempty(findstr(lower(filename), 'rgba'))
	fid=fopen([filename '.rgba']);
else
	fid=fopen(filename);
end
im_=fread(fid);
fclose(fid);

Len = length(im_);
H = sqrt(Len/WHratio/4);

im__ = uint8(reshape(reshape(im_,4, Len/4)', H*WHratio, H, 4));

im = im__(:,:,1)';
im(:,:,2) = im__(:,:,2)';
im(:,:,3) = im__(:,:,3)';
im(:,:,4) = im__(:,:,4)';

