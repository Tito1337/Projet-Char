function rgba =  encode32int(f) % assume uint given as float
if (f<256.)
	rgba = [f/255., 0., 0., 0.];
elseif (f<65536.) 
	H = floor(f/256.);
	rgba = [(f-H*256.)/255., H/255., 0., 0.];
elseif (f<16777216.) 
	H = floor(f/65536.);
	M = floor((f-H*65536.)/256.);
	rgba = [(f-H*65536.-M*256.)/255., M/255., H/255., 0.];
elseif (f>=4294967296.)
	rgba = ones(1,4); % replace it by float conversion (in the future)
else
	H = floor(f/16777216.);
	M = floor((f-H*16777216.)/65536.);
	L = floor((f-H*16777216.-M*65536.)/256.);
	rgba = [(f-H*16777216.-M*65536.-L*256.)/255., L/255., M/255., H/255.];
end

% float decode32int(vec4 rgba) {
%     if (rgba.a == 0.) {
%         if (rgba.b == 0.) {
%             if (rgba.g == 0.) return rgba.r*255.;
%             else return (rgba.g*256. + rgba.r)*255.;
%         }
%         else return ((rgba.b*256. + rgba.g)*256. + rgba.r)*255.;
%     }
%     else return (((rgba.a*256. + rgba.b)*256. + rgba.g)*256. + rgba.r)*255.;
