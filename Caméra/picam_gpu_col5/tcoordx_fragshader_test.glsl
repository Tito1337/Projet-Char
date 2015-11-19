// gives tcoord.x in rgba format
// ECAM - Bruxelles, GEI, F. Gueuning  190210

varying vec2 tcoord;
uniform sampler2D tex0; // texture with colors detected (one is col)
uniform vec2 texelsize; // size of texel of tex0
uniform vec2 texturesize2; // 2 * size of texture of tex0

//for encode32 and decode32, see
//    http://stackoverflow.com/questions/7059962/how-do-i-convert-a-vec4-rgba-value-to-a-float
//      (version of twerdster not modified by proposition of Arjan)
highp vec4 encode32(highp float f) {
    highp float e =5.0;
    highp float F = abs(f); 
    highp float Sign = step(0.0,-f);
    highp float Exponent = floor(log2(F)); 
    highp float Mantissa = (exp2(- Exponent) * F);
    Exponent = floor(log2(F) + 127.0) + floor(log2(Mantissa));
    highp vec4 rgba;
    rgba[0] = 128.0 * Sign  + floor(Exponent*exp2(-1.0));
    rgba[1] = 128.0 * mod(Exponent,2.0) + mod(floor(Mantissa*128.0),128.0);  
    rgba[2] = floor(mod(floor(Mantissa*exp2(23.0 -8.0)),exp2(8.0)));
    rgba[3] = floor(exp2(23.0)*mod(Mantissa,exp2(-15.0)));
    return rgba;
}
highp float decode32(highp vec4 rgba) {
    highp float Sign = 1.0 - step(128.0,rgba[0])*2.0;
    highp float Exponent = 2.0 * mod(rgba[0],128.0) + step(128.0,rgba[1]) - 127.0; 
    highp float Mantissa = mod(rgba[1],128.0)*65536.0 + rgba[2]*256.0 +rgba[3] + float(0x800000);
    highp float Result =  Sign * exp2(Exponent) * (Mantissa * exp2(-23.0 )); 
    return Result;
}

void main(void) 
{
    float N;
    float H;
    vec4 res;
    N = floor(tcoord.x * texturesize2.x + .5); // + .5 because floor
    H = floor(N/256.);
    res.r = H/255.;
    res.g = (N-256.*H) / 255.;
    N = floor(tcoord.y * texturesize2.y + .5); // + .5 because floor
    H = floor(N/256.);
    res.b = H / 255.;
    res.a = (N-256.*H) / 255.;
    gl_FragColor = res;
    //gl_FragColor = vec4(0.0, 0.25, 0.5, 0.75);
    //float y = texture2D(tex0,tcoord).r;
    //gl_FragColor = clamp(res,vec4(0),vec4(1));
    //gl_FragColor = encode32(tcoord.x);
}
