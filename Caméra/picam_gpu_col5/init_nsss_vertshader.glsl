// init_nsss_vertshader.glsl - vertex shader used here essentially to compute coordinates to send to fragment shader
// ECAM - Bruxelles, GEI, F. Gueuning  150302
attribute vec4 vertex;
uniform vec2 offset; // probably (-1., -1.)
uniform vec2 scale;  // probably ( 2.,  2.)
uniform vec2 texturesize; // probably (384., 256.)
// For varying, vertex shader computes only one value at each vertex. Values are then interpolated by opengl
//   between vertices in order to be given to fragment shader for each fragment.
varying highp vec2 tcoord;  // current texel coordinates
varying highp vec2 cxry;    // cx: current column between 0 and texturesize.x-1)
                      // ry: current row ( between 0 and texturesize.y-1)
void main(void) 
{
	vec4 pos = vertex;
	tcoord.xy = pos.xy;
  cxry = floor(pos.xy * texturesize);
	pos.xy = pos.xy*scale+offset;
	gl_Position = pos;
}
