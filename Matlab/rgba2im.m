function Im = rgba2im(filename)
% Conversion of image from picam in binary rgba format to rgb
% IN:  filename  ex: 'col_detected.rgba'
%                default: 'col_detected.rgba' in current directory
%                The file is assumed in ratio 3/2
% OUT: Im        image in format (height, width, 3)

if nargin<1
   filename = 'col_detected.rgba';
end
fid = fopen(filename);
if fid<1
   disp(['Error: unable to open file  ' filename])
   brol
end
Im1 = fread(fid);
Len = length(Im1);
base = sqrt(Len/24);
if round(Len)~=Len
   disp('Error: the file is not a binary RGBA image with 3/2 ratio')
   brol
end
Im2 = reshape(Im1, 4, size(Im1,1)/4)';
Im3 = reshape(Im2, 3*base, 2*base, 4);
Im = Im3(:,:,1)';
Im(:,:,2) = Im3(:,:,2)';
Im(:,:,3) = Im3(:,:,3)';
%graphics_toolkit('fltk')
Im = uint8(Im);
image(Im)
