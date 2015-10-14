// Compute sd2 = sum of x²+y² with x,y position of occurrences of color col of 4x4 texels
// ECAM - Bruxelles, GEI, F. Gueuning  150224

varying vec2 tcoord;
uniform sampler2D tex0; // texture where  r:x(lsb),  g:x(msb),  b:y,  a:col
uniform vec2 texelsize; // size of texel of tex0
uniform float idcol; // This is the only color considered here

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
    float sd2 = 0.0; // count
    vec4 c;
    float sx;
    
    
    // assuming size(texture_from) = (4x4) * size(texture_to)
    for(float offsetx = -1.5; offsetx < 2.; offsetx++)
    {
        for(float offsety = -1.5; offsety < 2.; offsety++)
        {
            //if (all(equal(col, texture2D(tex0, tcoord+vec2(offsetx, offsety)*texelsize))))
            // position = tcoord+vec2(offsetx, offsety)*texelsize;
            // floor(tcoord * texturesize2 + .5)/texturesize2  more accurate position than tcoord
            c = texture2D(tex0, tcoord + texelsize*vec2(offsetx, offsety));
            if (abs(c.a-idcol) < 0.0019531250) // 1/512
                sx = c.r+c.g*256.;
                sd2 += sx*sx + c.b*c.b;
        }
    }
    gl_FragColor = encode32int(sd2*65025.); // convert from float to rgba
}

