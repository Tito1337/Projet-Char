// Detect if texel is inside one of up to 4 color ranges
// ECAM - Bruxelles, GEI, F. Gueuning  150210

varying vec2 tcoord;
uniform sampler2D tex0;
uniform sampler2D tex1;
uniform sampler2D tex2;

uniform vec4 min0; // Min (of first range to test) for color divided by its divby component
uniform vec4 max0; // Max
uniform vec4 col0; // Color to attribute to texel if it is detected inside first range
uniform vec4 min1;
uniform vec4 max1;
uniform vec4 col1;
uniform vec4 min2;
uniform vec4 max2;
uniform vec4 col2;
uniform vec4 min3; // Min (of last possible range to test) for color divided by its divby component
uniform vec4 max3; // Max
uniform vec4 col3; // Color to attribute to texel if it is detected inside last possible range
uniform ivec4 divby; // for each of the up to 4 colors, the divby (0-3) means :
                     //  1  divide components by  r
                     //  2                        g
                     //  3                        b
                     //  0  previous was the last color to test

int detectCol(vec4 pix, int Divby, vec4 Min, vec4 Max, vec4 Col) {
    // Detect if color of pix (with components other than Divby divided by component Divby) is between Min and Max
    vec4 pixrel;
    pixrel = pix;
    if (Divby==1) { // Divide by r
        if (pix.r >= Min.r) { // g,b relative to r
            pixrel.g = pix.g / pix.r;
            pixrel.b = pix.b / pix.r;
        }
        else return(0);
    }
    else if (Divby==2) { // Divide by g 
        if (pix.g >= Min.g) { // r,b relative to g
            pixrel.r = pix.r / pix.g;
            pixrel.b = pix.b / pix.g;
        }
        else return(0);
    }
    else if (Divby==3) { // Divide by b
        if (pix.b >= Min.b) { // r,g relative to b
            pixrel.r = pix.r / pix.b;
            pixrel.g = pix.g / pix.b;
        }
        else return(0);
    }
    if (all(greaterThanEqual(pixrel, Min))) {
        if (all(lessThanEqual(pixrel, Max))) {
            gl_FragColor = Col; // Color detected
            return(1);
        }
    }
    return(0);
}

void main(void) 
{
	float y = texture2D(tex0,tcoord).r;
	float u = texture2D(tex1,tcoord).r;
	float v = texture2D(tex2,tcoord).r;

	vec4 pix;
	// res.r = (y + (1.370705 * (v-0.5)));
	// res.g = (y - (0.698001 * (v-0.5)) - (0.337633 * (u-0.5)));
	// res.b = (y + (1.732446 * (u-0.5)));
    pix.r = (y + (1.403 * (v-0.5)));
    pix.g = (y - (0.714 * (v-0.5)) - (0.344 * (u-0.5)));
    pix.b = (y + (1.773 * (u-0.5)));
	pix.a = 1.0;
    pix = clamp(pix,vec4(0),vec4(1));

    if (divby.x>0) { // if first color to detect is defined
        if (detectCol(pix, divby.x, min0, max0, col0)==0) { // if first color not detected
            if (divby.y>0) { // if second color is defined
                if (detectCol(pix, divby.y, min1, max1, col1)==0) { // if second not detected
                    if (divby.z>0) { // if third is defined
                        if (detectCol(pix, divby.z, min2, max2, col2)==0) {
                            if (divby.w>0) { // if last is defined
                                if (detectCol(pix, divby.w, min3, max3, col3)==0) {
                                    //gl_FragColor = clamp(pix,vec4(0),vec4(1));
                                    gl_FragColor = pix;
                                }
                            }
                            else gl_FragColor = pix;
                        }
                    }
                    else gl_FragColor = pix;
                }
            }
            else gl_FragColor = pix;
        }
    }
    else gl_FragColor = pix;
}
