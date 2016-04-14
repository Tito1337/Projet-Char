// nsss_cccc_fragshader
// from each 4x4 texels of col_sxsy0_texture, compute 4x4 periodic texture, each being
//     Nc0   Nc1   Nc2   Nc3
//    SXc0  SXc1  SXc2  SXc3
//    SYc0  SYc1  SYc2  SYc3
//   SD2c0 SD2c1 SD2c2 SD2c3
// ECAM - Bruxelles, GEI, F. Gueuning  150301

varying vec2 tcoord;
uniform sampler2D tex0; // texture with colors detected (one is col)
uniform vec2 texturesize; // size of texture of tex0

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

void main(void) 
{
    float idcol = floor(mod(gl_FragCoord.x+.1, 4.)); // it seems more reliable to add .1
    float nxyd = floor(mod(gl_FragCoord.y+.1, 4.)); //   ... because mod(x,y) having to give 0.0 with x>0 has produced a mysterious result !?
    vec4 c;

    if (nxyd==0.) // if N
    {
        c.r = 0.;
    }
    else if (nxyd==1.) // if SX
    {
        c.r = 1.;
    }
    else if (nxyd==2.) // if SY
    {
        c.r = 2.;
    }
    else if (nxyd==3.) // if SD2
    {
        c.r = 3.;
    }
    else // zut
    {
        c.r = 127.;
    }
    

    if (idcol==0.)
    {
        c.b = 0.;
    }
    else if (idcol==1.)
    {
        c.b = 1.;
    }
    else if (idcol==2.)
    {
        c.b = 2.;
    }
    else if (idcol==3.)
    {
        c.b = 3.;
    }
    else // zut
    {
        c.b = 127.;
    }


    gl_FragColor = c/255.;
}
