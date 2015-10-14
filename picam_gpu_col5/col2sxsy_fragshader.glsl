// Detect if texel is inside one of up to 4 color ranges
// ECAM - Bruxelles, GEI, F. Gueuning  150224

varying vec2 tcoord;
uniform sampler2D tex0; // texture with colors detected (one is col)
uniform vec2 texturesize; // size of texture of tex0 (no more used)

void main(void) 
{
    vec4 col = texture2D(tex0, tcoord);
    if (col.a <1.) // if color detected
    {
        vec4 xycol;
        xycol.a = col.a; // color id
        //X xycol.b = tcoord.y; // y coord assuming texturesize.y = 256
        //X float x = floor(tcoord.x*texturesize.x);
        xycol.b = gl_FragCoord.y/255.; // y coord assuming < texturesize.y <= 256
        float x = gl_FragCoord.x;
        if (x < 256.)
        {
            xycol.r = x/255.; // x coord on 2 bytes
            xycol.g = 0.;
        }
            else
        {
            xycol.g = floor(x/256.);
            xycol.r = (x-256.*xycol.g)/255.;
            xycol.g = xycol.g/255.;
        }
        gl_FragColor = xycol; // r: x(lsb),  g: x(msb),  b: y,  a: color id
                              // x between 0 and 767 : 255.*(r+256.*b)
                              // y between 0 and 255 : 255.*b
    }
    else gl_FragColor = vec4(1.);
}
