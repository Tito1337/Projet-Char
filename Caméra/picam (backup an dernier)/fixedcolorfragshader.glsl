uniform vec4 col;
varying vec2 tcoord;  // current texel coordinates
void main(void) 
{
    gl_FragColor = col;
}
