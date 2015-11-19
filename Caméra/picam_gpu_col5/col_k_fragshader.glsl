// Compute k (we could say "coefficient de compacité" from n, sx, sy, sd2
// ECAM - Bruxelles, GEI, F. Gueuning  150222
// K = 2*pi * ( ΣD2 - ( (ΣX)2 + (ΣY)2 ) / N ) / N²
// Pour un disque parfait, K vaudrait 1, il semble que si K est supérieur à environ 5, il ne s'agit
// vraiment pas d'une pièce massive (à tester).

varying vec2 tcoord;
uniform sampler2D tex0; // texture col_n
uniform sampler2D tex1; // texture col_sx
uniform sampler2D tex2; // texture col_sy
uniform sampler2D tex3; // texture col_sd2

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
    // K = 2*pi * ( ΣD2 - ( (ΣX)2 + (ΣY)2 ) / N ) / N²
    float n = decode32int(texture2D(tex0, tcoord));
    float sx = decode32int(texture2D(tex1, tcoord));
    float sy = decode32int(texture2D(tex2, tcoord));
    float sd2 = decode32int(texture2D(tex3, tcoord));
    float k10 = floor(62.831853 * (sd2 - (sx*sx + sy*sy)/n ) / (n*n)); //  floor(10*K)
    gl_FragColor = encode32int(k10); // convert from float (considered as int32) to rgba
}
