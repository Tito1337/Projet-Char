// sum4_d4_d4_fragshader
// ECAM - Bruxelles, GEI, F. Gueuning  150301
// sum 4 corresponding texels from texture of size 2x2x size of target texture (example for Nc1)
//     Nc0  <Nc1>  Nc2   Nc3     Nc0  <Nc1>  Nc2   Nc3
//    SXc0  SXc1  SXc2  SXc3    SXc0  SXc1  SXc2  SXc3
//    SYc0  SYc1  SYc2  SYc3    SYc0  SYc1  SYc2  SYc3               Nc0  <Nc1>  Nc2   Nc3
//   SD2c0 SD2c1 SD2c2 SD2c3   SD2c0 SD2c1 SD2c2 SD2c3     -->      SXc0  SXc1  SXc2  SXc3
//     Nc0  <Nc1>  Nc2   Nc3     Nc0  <Nc1>  Nc2   Nc3              SYc0  SYc1  SYc2  SYc3
//    SXc0  SXc1  SXc2  SXc3    SXc0  SXc1  SXc2  SXc3             SD2c0 SD2c1 SD2c2 SD2c3
//    SYc0  SYc1  SYc2  SYc3    SYc0  SYc1  SYc2  SYc3
//   SD2c0 SD2c1 SD2c2 SD2c3   SD2c0 SD2c1 SD2c2 SD2c3


varying vec2 tcoord;
uniform sampler2D tex0;
uniform vec2 texelsize;

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
    float idcol_ = floor(mod(gl_FragCoord.x+.1, 4.)); // it seems more reliable to add .1
      //  if 0, get  -0.5 and 3.5
      //     1       -1.5     2.5
      //     2       -2.5     1.5
      //     3       -3.5     0.5
    float nxyd = floor(mod(gl_FragCoord.y+.1, 4.)); //   ... because mod(x,y) having to give 0.0 with x>0 has produced a mysterious result !?
    float s = 0.0; // sum

    s  = decode32int(texture2D(tex0, tcoord + vec2(-0.5-idcol_,-0.5-nxyd)*texelsize));
    s += decode32int(texture2D(tex0, tcoord + vec2( 3.5-idcol_,-0.5-nxyd)*texelsize));
    s += decode32int(texture2D(tex0, tcoord + vec2(-0.5-idcol_, 3.5-nxyd)*texelsize));
    s += decode32int(texture2D(tex0, tcoord + vec2( 3.5-idcol_, 3.5-nxyd)*texelsize));
    gl_FragColor = encode32int(s); // convert from float (considered as int32) to rgba
}
