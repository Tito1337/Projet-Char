// Compute sum(float converted in rgba) of 2x2 texels
// float can be any of n, sx, sy ,sd2
// ECAM - Bruxelles, GEI, F. Gueuning  150221

varying vec2 tcoord;
uniform sampler2D tex0; // texture from which 4 values must be summed
uniform vec2 texelsize; // size of texel of tex0
uniform vec2 texturesize2; // 2 * size of texture of tex0

vec4 encode32int(float f) { // assume uint given as float
    if (f<256.) return vec4(f/255., 0., 0., 0.);
    if (f<65536.) {
        float H = floor(f/256.);
        return vec4((f-H*256.)/255., H/255., 0., 0.);
    }
    if (f<16777216.) {
        float H = floor(f/65536.);
        float M = floor((f-H*65536.)/256.);
        return vec4((f-H*65536.-M*256.)/255., M/255., H/255., 0.);
    }
    if (f>=4294967296.) return vec4(1.) ; // replace it by float conversion (in the future)
    float H = floor(f/16777216.);
    float M = floor((f-H*16777216.)/65536.);
    float L = floor((f-H*16777216.-M*65536.)/256.);
    return vec4((f-H*16777216.-M*65536.-L*256.)/255., L/255., M/255., H/255.);
}
float decode32int(vec4 rgba) {
    if (rgba.a == 0.) {
        if (rgba.b == 0.) {
            if (rgba.g == 0.) return rgba.r*255.;
            else return (rgba.g*256. + rgba.r)*255.;
        }
        else return ((rgba.b*256. + rgba.g)*256. + rgba.r)*255.;
    }
    else return (((rgba.a*256. + rgba.b)*256. + rgba.g)*256. + rgba.r)*255.;
}

void main(void) 
{
	float s;
	//vec2 position;
    s  = decode32int(texture2D(tex0, tcoord + vec2(-0.5,-0.5)*texelsize));
    s += decode32int(texture2D(tex0, tcoord + vec2( 0.5,-0.5)*texelsize));
    s += decode32int(texture2D(tex0, tcoord + vec2(-0.5, 0.5)*texelsize));
    s += decode32int(texture2D(tex0, tcoord + vec2( 0.5, 0.5)*texelsize));
    gl_FragColor = encode32int(s); // convert from float (considered as int32) to rgba
}
