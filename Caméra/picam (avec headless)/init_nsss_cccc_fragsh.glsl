// init_nsss_cccc_fragshader
// from each 4x4 texels of col_sxsy0_texture, compute 4x4 periodic texture, each being
//     Nc0   Nc1   Nc2   Nc3
//    SXc0  SXc1  SXc2  SXc3
//    SYc0  SYc1  SYc2  SYc3
//   SD2c0 SD2c1 SD2c2 SD2c3
// ECAM - Bruxelles, GEI, F. Gueuning  150301

precision highp float;
varying highp vec2 tcoord;  // current texel coordinates
varying highp vec2 cxry;    // cx: current column between 0 and texturesize.x-1)
                      // ry: current row ( between 0 and texturesize.y-1)
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

void main(void) 
{

	float cx4 = floor(mod(cxry.x, 4.));    // color num for current texel : (0. 1. 2. or 3., without floor: 0.5, 1.5, ...)
	float ry4 = floor(mod(cxry.y, 4.));    // vertical position in 4x4 square
                                  //     0.: N,  1.:SX, 2.:SY, 3.:SD²
	vec4 ry4_4 = vec4(0.);
	if (ry4<.5) ry4_4[0] = 1.;
	if ((ry4>.5)&&(ry4<1.5)) ry4_4[1] = 1.;
	if ((ry4>1.5)&&(ry4<2.5)) ry4_4[2] = 1.;
	if ((ry4>2.5)&&(ry4<3.5)) ry4_4[3] = 1.;
	
	vec4 c;
	float X = 0.;
	float Y = 0.;
	float idc; // will be near 254. if current color detected
	float detec; // will be at 1. if current color detected
	vec4 res = vec4(0.); // N, SX, SY, SD2
	
	// Nested loops and nested if have been limited because it seems that they are not really accepted by GPU,
	// probably because parallel process between texels is not about instruction decoding but about alu usage.
	// In this case, parallel process would be limited to same instruction for all texels processed at the same time.

	for(float x = 0.; x < 4.; x++)
	{
		for(float y = 0.; y < 4.; y++)
		{
			c = texture2D(tex0, tcoord + texelsize*vec2(x-cx4, y-ry4));
			idc = c.a * 255. + cx4; // is near 254 if current color detected
			detec = step(253.8, idc) * step(idc, 254.2);  // step(edge, Tx)
			res[0] += detec; // N
			X = detec * (c.r+c.g*256.);
			Y = detec * (c.b);
			res[1] += X; // SX
			res[2] += Y; // SY
			res[3] += X*X + Y*Y; // SD2
		}
	}
	
	// Only one of  N, SX, SY, SD2  will be stored for current texel and only for one of colors c0, c1, c2 and c3
	// but surprisingly, an error occurs if I try to use if  with a last test different of
	// if () gl_FragColor=...; else gl_FragColor = ...;
	// and only 2 exclusives is not sufficient for me because I have 4 or 5. Therefore if is not usefull for choice of
	// N, SX, SY or SD2
	// To work around this issue, I sum products with only one not null.
	/*  Surprisingly, for no error with if, I need something like this where the last "if else" destroys previous work !? :
	if (ry4<0.5) // N
		res = encode32int(N); // convert from float to rgba
	if ((ry4>0.5)&&(ry4<1.5)) // if SX
		res = encode32int(SX*255.); // convert from float to rgba
	if ((ry4>1.5)&&(ry4<2.5)) // if SY
		res = encode32int(SY*255.); // convert from float to rgba
	if ((ry4>2.5)&&(ry4<3.5)) // if SD2
		res = encode32int(SD2*65025.); // convert from float to rgba
	else
		res = vec4(1.); // error  
	*/
	res[1] *= 255.; // SX
	res[2] *= 255.; // SY
	res[3] *= 65025.; // SD2
	gl_FragColor = encode32int(dot(res, ry4_4));

//  // test :  2 equivalent algorithms : use of cx4, ry4  or use of a
//  vec2 a = gl_FragCoord.xy;
//  a = floor(mod(a+vec2(.1), 4.)); // 0., 1., 2., 3., 0. 1., ... (without +vec2(.1) :  0., 1., 2., 3., 4. 1., ...)
//  gl_FragColor = vec4(cx4/8., ry4/8., a.x/8., a.y/8.); // for test
}
