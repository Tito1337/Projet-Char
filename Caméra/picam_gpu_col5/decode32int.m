function f = decode32int(rgba)
r=1;g=2;b=3;a=4;
if (rgba(a) == 0.)
	if (rgba(b) == 0.)
		if (rgba(g) == 0.)
			f = rgba(r)*255.;
		else
			f = (rgba(g)*256. + rgba(r))*255.;
		end
	else
		f = ((rgba(b)*256. + rgba(g))*256. + rgba(r))*255.;
	end
else
	f = (((rgba(a)*256. + rgba(b))*256. + rgba(g))*256. + rgba(r))*255.;
end
% vec4 encode32int(float f) { // assume uint given as float
%     if (f<256.) return vec4(f/255., 0., 0., 0.);
%     if (f<65536.) {
%         float H = floor(f/256.);
%         return vec4((f-H*256.)/255., H/255., 0., 0.);
%     }
%     if (f<16777216.) {
%         float H = floor(f/65536.);
%         float M = floor((f-H*65536.)/256.);
%         return vec4((f-H*65536.-M*256.)/255., M/255., H/255., 0.);
%     }
%     if (f>=4294967296.) return vec4(1.) ; // replace it by float conversion (in the future)
%     float H = floor(f/16777216.);
%     float M = floor((f-H*16777216.)/65536.);
%     float L = floor((f-H*16777216.-M*65536.)/256.);
%     return vec4((f-H*16777216.-M*65536.-L*256.)/255., L/255., M/255., H/255.);
% }
