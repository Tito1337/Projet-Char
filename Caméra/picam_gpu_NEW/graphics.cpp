// gng  This version is based on graphics.cpp from Chris Cummings
// ref: http://robotblogging.blogspot.be/2013/10/gpu-accelerated-camera-processing-on.html
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <assert.h>
#include <unistd.h>
#include <iostream>
#include "bcm_host.h"
#include "graphics.h"

#define check() assert(glGetError() == 0)

uint32_t GScreenWidth;
uint32_t GScreenHeight;
EGLDisplay GDisplay;
EGLSurface GSurface;
EGLContext GContext;

GfxShader GSimpleVS;
GfxShader GSimpleFS;
GfxShader GYUVFS;
GfxShader GGngdetectcolFS;
GfxProgram GSimpleProg;
GfxProgram GYUVProg;
GfxProgram GGngdetectcolProg;
GfxProgram FixedColorProg;
GfxShader FixedColorFS;
GLuint GQuadVertexBuffer;
GLuint GVertexBuffer;
GfxShader GCol_sxsy0_FS;
GfxProgram GCol_sxsy0_Prog;
GfxShader GinitCol_nsss_cccc_FS;
GfxShader GinitCol_nsss_cccc_VS;
GfxProgram GinitCol_nsss_cccc_Prog;
GfxShader GCol_k_cccc_FS;
GfxProgram GCol_k_cccc_Prog;
GfxShader GCol_sum4_d4_d4_FS;
GfxProgram GCol_sum4_d4_d4_Prog;


void InitGraphics()
{
	bcm_host_init();
	int32_t success = 0;
	EGLBoolean result;
	EGLint num_config;

	static EGL_DISPMANX_WINDOW_T nativewindow;

	DISPMANX_ELEMENT_HANDLE_T dispman_element;
	DISPMANX_DISPLAY_HANDLE_T dispman_display;
	DISPMANX_UPDATE_HANDLE_T dispman_update;
	VC_RECT_T dst_rect;
	VC_RECT_T src_rect;

	static const EGLint attribute_list[] =
	{
		EGL_RED_SIZE, 8,
		EGL_GREEN_SIZE, 8,
		EGL_BLUE_SIZE, 8,
		EGL_ALPHA_SIZE, 8,
		EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
		EGL_NONE
	};

	static const EGLint context_attributes[] = 
	{
		EGL_CONTEXT_CLIENT_VERSION, 2,
		EGL_NONE
	};
	EGLConfig config;

	// get an EGL display connection
	GDisplay = eglGetDisplay(EGL_DEFAULT_DISPLAY);
	assert(GDisplay!=EGL_NO_DISPLAY);
	check();

	// initialize the EGL display connection
	result = eglInitialize(GDisplay, NULL, NULL);
	assert(EGL_FALSE != result);
	check();

	// get an appropriate EGL frame buffer configuration
	result = eglChooseConfig(GDisplay, attribute_list, &config, 1, &num_config);
	assert(EGL_FALSE != result);
	check();

	// get an appropriate EGL frame buffer configuration
	result = eglBindAPI(EGL_OPENGL_ES_API);
	assert(EGL_FALSE != result);
	check();

	// create an EGL rendering context
	GContext = eglCreateContext(GDisplay, config, EGL_NO_CONTEXT, context_attributes);
	assert(GContext!=EGL_NO_CONTEXT);
	check();

	// create an EGL window surface
	success = graphics_get_display_size(0 /* LCD */, &GScreenWidth, &GScreenHeight);
	assert( success >= 0 );

	dst_rect.x = GScreenWidth*1/16;
	dst_rect.y = GScreenHeight*2/16;
	dst_rect.width = GScreenWidth*14/16;
	dst_rect.height = GScreenHeight*14/16;

	src_rect.x = 0;
	src_rect.y = 0;
	src_rect.width = GScreenWidth << 16;
	src_rect.height = GScreenHeight << 16;        
	
	printf("dst_rect:   width=%d   height=%d\n", dst_rect.width, dst_rect.height);
	printf("src_rect:   width=%d   height=%d\n", src_rect.width, src_rect.height);

	dispman_display = vc_dispmanx_display_open( 0 /* LCD */);
	dispman_update = vc_dispmanx_update_start( 0 );

	dispman_element = vc_dispmanx_element_add ( dispman_update, dispman_display,
		0/*layer*/, &dst_rect, 0/*src*/,
		&src_rect, DISPMANX_PROTECTION_NONE, 0 /*alpha*/, 0/*clamp*/, (DISPMANX_TRANSFORM_T)0/*transform*/);

	nativewindow.element = dispman_element;
	nativewindow.width = GScreenWidth;
	nativewindow.height = GScreenHeight;
	vc_dispmanx_update_submit_sync( dispman_update );

	check();

	GSurface = eglCreateWindowSurface( GDisplay, config, &nativewindow, NULL );
	assert(GSurface != EGL_NO_SURFACE);
	check();

	// connect the context to the surface
	result = eglMakeCurrent(GDisplay, GSurface, GSurface, GContext);
	assert(EGL_FALSE != result);
	check();

	// Set background color and clear buffers
	glClearColor(0.15f, 0.25f, 0.35f, 1.0f);
	glClear( GL_COLOR_BUFFER_BIT );

	//load the test shaders
    GSimpleVS.LoadVertexShader("simplevertshader.glsl");
    GSimpleFS.LoadFragmentShader("simplefragshader.glsl");
    GSimpleProg.Create(&GSimpleVS,&GSimpleFS);
    GGngdetectcolFS.LoadFragmentShader("gngdetectcolfragshader.glsl"); // gng
    GGngdetectcolProg.Create(&GSimpleVS,&GGngdetectcolFS);
    FixedColorFS.LoadFragmentShader("fixedcolorfragshader.glsl"); // gng
    FixedColorProg.Create(&GSimpleVS,&FixedColorFS);
	GYUVFS.LoadFragmentShader("yuvfragshader.glsl");
	GYUVProg.Create(&GSimpleVS,&GYUVFS);
    GCol_sxsy0_FS.LoadFragmentShader("col2sxsy_fragshader.glsl");
    GCol_sxsy0_Prog.Create(&GSimpleVS,&GCol_sxsy0_FS);
    GinitCol_nsss_cccc_FS.LoadFragmentShader("init_nsss_cccc_fragsh.glsl");
    GinitCol_nsss_cccc_VS.LoadVertexShader("init_nsss_vertshader.glsl");
    GinitCol_nsss_cccc_Prog.Create(&GinitCol_nsss_cccc_VS,&GinitCol_nsss_cccc_FS);
    GCol_k_cccc_FS.LoadFragmentShader("col_k_cccc_fragsh.glsl");
    GCol_k_cccc_Prog.Create(&GSimpleVS,&GCol_k_cccc_FS);
    GCol_sum4_d4_d4_FS.LoadFragmentShader("sum4_d4_d4_fragsh.glsl");
    GCol_sum4_d4_d4_Prog.Create(&GSimpleVS,&GCol_sum4_d4_d4_FS);
	check();

	//create an ickle vertex buffer
	static const GLfloat quad_vertex_positions[] = {
		0.0f, 0.0f,	1.0f, 1.0f,
		1.0f, 0.0f, 1.0f, 1.0f,
		0.0f, 1.0f, 1.0f, 1.0f,
		1.0f, 1.0f, 1.0f, 1.0f
	};
	glGenBuffers(1, &GQuadVertexBuffer);
	check();
	glBindBuffer(GL_ARRAY_BUFFER, GQuadVertexBuffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(quad_vertex_positions), quad_vertex_positions, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	check();
    
    glGenBuffers(1, &GVertexBuffer); // Used in DrawPolygon
    check();
}

void BeginFrame(bool CheckGL)
{
	// Prepare viewport
	glViewport ( 0, 0, GScreenWidth, GScreenHeight );
	if (CheckGL) check();

	// Clear the background
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	if (CheckGL) check();
}

void EndFrame(bool CheckGL)
{
	eglSwapBuffers(GDisplay,GSurface);
	if (CheckGL) check();
}

void ReleaseGraphics()
{

}

// printShaderInfoLog
// From OpenGL Shading Language 3rd Edition, p215-216
// Display (hopefully) useful error messages if shader fails to compile
void printShaderInfoLog(GLint shader)
{
	int infoLogLen = 0;
	int charsWritten = 0;
	GLchar *infoLog;

	glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLogLen);

	if (infoLogLen > 0)
	{
		infoLog = new GLchar[infoLogLen];
		// error check for fail to allocate memory omitted
		glGetShaderInfoLog(shader, infoLogLen, &charsWritten, infoLog);
		std::cout << "InfoLog : " << std::endl << infoLog << std::endl;
		delete [] infoLog;
	}
}

bool GfxShader::LoadVertexShader(const char* filename)
{
	//cheeky bit of code to read the whole file into memory
	assert(!Src);
	FILE* f = fopen(filename, "rb");
	assert(f);
	fseek(f,0,SEEK_END);
	int sz = ftell(f);
	fseek(f,0,SEEK_SET);
	Src = new GLchar[sz+1];
	fread(Src,1,sz,f);
	Src[sz] = 0; //null terminate it!
	fclose(f);

	//now create and compile the shader
	GlShaderType = GL_VERTEX_SHADER;
	Id = glCreateShader(GlShaderType);
	glShaderSource(Id, 1, (const GLchar**)&Src, 0);
	glCompileShader(Id);
	check();

	//compilation check
	GLint compiled;
	glGetShaderiv(Id, GL_COMPILE_STATUS, &compiled);
	if(compiled==0)
	{
		printf("Failed to compile vertex shader %s:\n%s\n", filename, Src);
		printShaderInfoLog(Id);
		glDeleteShader(Id);
		return false;
	}
	else
	{
		//printf("Compiled vertex shader %s:\n%s\n", filename, Src);
        printf("Compiled vertex shader %s:\n", filename);
	}

	return true;
}

bool GfxShader::LoadFragmentShader(const char* filename)
{
	//cheeky bit of code to read the whole file into memory
	assert(!Src);
	FILE* f = fopen(filename, "rb");
	assert(f);
	fseek(f,0,SEEK_END);
	int sz = ftell(f);
	fseek(f,0,SEEK_SET);
	Src = new GLchar[sz+1];
	fread(Src,1,sz,f);
	Src[sz] = 0; //null terminate it!
	fclose(f);

	//now create and compile the shader
	GlShaderType = GL_FRAGMENT_SHADER;
	Id = glCreateShader(GlShaderType);
	glShaderSource(Id, 1, (const GLchar**)&Src, 0);
	glCompileShader(Id);
	check();

	//compilation check
	GLint compiled;
	glGetShaderiv(Id, GL_COMPILE_STATUS, &compiled);
	if(compiled==0)
	{
		printf("Failed to compile fragment shader %s:\n%s\n", filename, Src);
		printShaderInfoLog(Id);
		glDeleteShader(Id);
		return false;
	}
	else
	{
		//printf("Compiled fragment shader %s:\n%s\n", filename, Src);
        printf("Compiled fragment shader %s:\n", filename);
	}

	return true;
}

bool GfxProgram::Create(GfxShader* vertex_shader, GfxShader* fragment_shader)
{
	VertexShader = vertex_shader;
	FragmentShader = fragment_shader;
	Id = glCreateProgram();
	glAttachShader(Id, VertexShader->GetId());
	glAttachShader(Id, FragmentShader->GetId());
	glLinkProgram(Id);
	check();
	printf("Created program id %d from vs %d and fs %d\n", GetId(), VertexShader->GetId(), FragmentShader->GetId());

	// Prints the information log for a program object
	char log[1024];
	glGetProgramInfoLog(Id,sizeof log,NULL,log);
	printf("%d:program:\n%s\n", Id, log);

	return true;	
}

void DrawTextureRect(GfxTexture* texture, float x0, float y0, float x1, float y1, bool CheckGL, GfxTexture* render_target)
{
	if(render_target)
	{
		glBindFramebuffer(GL_FRAMEBUFFER,render_target->GetFramebufferId());
		glViewport ( 0, 0, render_target->GetWidth(), render_target->GetHeight() );
		if (CheckGL) check();
	}

	glUseProgram(GSimpleProg.GetId());	if (CheckGL) check();

	glUniform2f(glGetUniformLocation(GSimpleProg.GetId(),"offset"),x0,y0);
	glUniform2f(glGetUniformLocation(GSimpleProg.GetId(),"scale"),x1-x0,y1-y0);
	glUniform1i(glGetUniformLocation(GSimpleProg.GetId(),"tex"), 0);
	if (CheckGL) check();

	glBindBuffer(GL_ARRAY_BUFFER, GQuadVertexBuffer);	if (CheckGL) check();
	glBindTexture(GL_TEXTURE_2D,texture->GetId());	if (CheckGL) check();

	GLuint loc = glGetAttribLocation(GSimpleProg.GetId(),"vertex");
	glVertexAttribPointer(loc, 4, GL_FLOAT, 0, 16, 0);	if (CheckGL) check();
	glEnableVertexAttribArray(loc);	if (CheckGL) check();
	glDrawArrays ( GL_TRIANGLE_STRIP, 0, 4 ); if (CheckGL) check();

	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindTexture(GL_TEXTURE_2D, 0);
	if(render_target)
	{
		//glFinish();	check();
		//glFlush(); check();
		glBindFramebuffer(GL_FRAMEBUFFER,0);
		glViewport ( 0, 0, GScreenWidth, GScreenHeight );
	}
}

void DrawPolygon(GLfloat* vertices, int polylength, GLenum  mode, GLfloat LineWidth, float* col, bool CheckGL)
{/* mode  Specifies what kind of primitives to render. Symbolic constants
          GL_POINTS, 
          GL_LINE_STRIP, GL_LINE_LOOP, GL_LINES,
          GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, GL_TRIANGLES,
          GL_QUAD_STRIP, GL_QUADS,
          GL_POLYGON are accepted.
    */
    float x0=-1; // same as in DrawTextureRect but initialized to standard values
    float y0=-1;
    float x1=1;
    float y1=1; 
    glUseProgram(FixedColorProg.GetId()); if (CheckGL) check();
    glUniform2f(glGetUniformLocation(FixedColorProg.GetId(),"offset"),x0,y0);
    glUniform2f(glGetUniformLocation(FixedColorProg.GetId(),"scale"),x1-x0,y1-y0);
    glUniform4f(glGetUniformLocation(FixedColorProg.GetId(),"col"),col[0],col[1],col[2],col[3]);
    
    glBindBuffer(GL_ARRAY_BUFFER, GVertexBuffer);

//    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);
    glBufferData(GL_ARRAY_BUFFER, polylength*4*sizeof(vertices[0]), vertices, GL_DYNAMIC_DRAW);
    GLuint loc = glGetAttribLocation(FixedColorProg.GetId(),"vertex");
    glVertexAttribPointer(loc, 4, GL_FLOAT, 0, 16, 0);  if (CheckGL) check();
    glEnableVertexAttribArray(loc); if (CheckGL) check();
    glLineWidth(LineWidth);
    glDrawArrays ( mode, 0, polylength ); if (CheckGL) check();

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    if (CheckGL) check();

}

void DrawGngdetectcolRect(GfxTexture* ytexture, GfxTexture* utexture, GfxTexture* vtexture
    , float x0, float y0, float x1, float y1, bool CheckGL, GfxTexture* render_target
    , ColorParam *colpar)
{  // based on DrawYUVTextureRect
    if(render_target)
    {
        glBindFramebuffer(GL_FRAMEBUFFER,render_target->GetFramebufferId());
        glViewport ( 0, 0, render_target->GetWidth(), render_target->GetHeight() );
        if (CheckGL) check();
    }

    glUseProgram(GGngdetectcolProg.GetId()); if (CheckGL) check();

    glUniform2f(glGetUniformLocation(GGngdetectcolProg.GetId(),"offset"),x0,y0);
    glUniform2f(glGetUniformLocation(GGngdetectcolProg.GetId(),"scale"),x1-x0,y1-y0);
    glUniform1i(glGetUniformLocation(GGngdetectcolProg.GetId(),"tex0"), 0);
    glUniform1i(glGetUniformLocation(GGngdetectcolProg.GetId(),"tex1"), 1);
    glUniform1i(glGetUniformLocation(GGngdetectcolProg.GetId(),"tex2"), 2);
    glUniform4f(glGetUniformLocation(GGngdetectcolProg.GetId(),"min0"), colpar[0].getMin(0), colpar[0].getMin(1), colpar[0].getMin(2), colpar[0].getMin(3));
    glUniform4f(glGetUniformLocation(GGngdetectcolProg.GetId(),"max0"), colpar[0].getMax(0), colpar[0].getMax(1), colpar[0].getMax(2), colpar[0].getMax(3));
    glUniform4f(glGetUniformLocation(GGngdetectcolProg.GetId(),"col0"), colpar[0].getCol(0), colpar[0].getCol(1), colpar[0].getCol(2), colpar[0].getCol(3));
    glUniform4f(glGetUniformLocation(GGngdetectcolProg.GetId(),"min1"), colpar[1].getMin(0), colpar[1].getMin(1), colpar[1].getMin(2), colpar[1].getMin(3));
    glUniform4f(glGetUniformLocation(GGngdetectcolProg.GetId(),"max1"), colpar[1].getMax(0), colpar[1].getMax(1), colpar[1].getMax(2), colpar[1].getMax(3));
    glUniform4f(glGetUniformLocation(GGngdetectcolProg.GetId(),"col1"), colpar[1].getCol(0), colpar[1].getCol(1), colpar[1].getCol(2), colpar[1].getCol(3));
    glUniform4f(glGetUniformLocation(GGngdetectcolProg.GetId(),"min2"), colpar[2].getMin(0), colpar[2].getMin(1), colpar[2].getMin(2), colpar[2].getMin(3));
    glUniform4f(glGetUniformLocation(GGngdetectcolProg.GetId(),"max2"), colpar[2].getMax(0), colpar[2].getMax(1), colpar[2].getMax(2), colpar[2].getMax(3));
    glUniform4f(glGetUniformLocation(GGngdetectcolProg.GetId(),"col2"), colpar[2].getCol(0), colpar[2].getCol(1), colpar[2].getCol(2), colpar[2].getCol(3));
    glUniform4f(glGetUniformLocation(GGngdetectcolProg.GetId(),"min3"), colpar[3].getMin(0), colpar[3].getMin(1), colpar[3].getMin(2), colpar[3].getMin(3));
    glUniform4f(glGetUniformLocation(GGngdetectcolProg.GetId(),"max3"), colpar[3].getMax(0), colpar[3].getMax(1), colpar[3].getMax(2), colpar[3].getMax(3));
    glUniform4f(glGetUniformLocation(GGngdetectcolProg.GetId(),"col3"), colpar[3].getCol(0), colpar[3].getCol(1), colpar[3].getCol(2), colpar[3].getCol(3));
    glUniform4i(glGetUniformLocation(GGngdetectcolProg.GetId(),"divby"), colpar[0].getMain(), colpar[1].getMain(), colpar[2].getMain(), colpar[3].getMain());
    if (CheckGL) check();

    glBindBuffer(GL_ARRAY_BUFFER, GQuadVertexBuffer);   if (CheckGL) check();
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D,ytexture->GetId()); if (CheckGL) check();
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D,utexture->GetId()); if (CheckGL) check();
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D,vtexture->GetId()); if (CheckGL) check();
    glActiveTexture(GL_TEXTURE0);

    GLuint loc = glGetAttribLocation(GGngdetectcolProg.GetId(),"vertex");
    glVertexAttribPointer(loc, 4, GL_FLOAT, 0, 16, 0);  if (CheckGL) check();
    glEnableVertexAttribArray(loc); if (CheckGL) check();
    glDrawArrays ( GL_TRIANGLE_STRIP, 0, 4 ); if (CheckGL) check();

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);

    if(render_target)
    {
        //glFinish();   check();
        //glFlush(); check();
        glBindFramebuffer(GL_FRAMEBUFFER,0);
        glViewport ( 0, 0, GScreenWidth, GScreenHeight );
    }
}

void InitCol_sxsy0_TextureRect(GfxTexture* Coltexture, float x0, float y0, float x1, float y1, bool CheckGL, GfxTexture* render_target)
{
    if(render_target)
    {
        glBindFramebuffer(GL_FRAMEBUFFER,render_target->GetFramebufferId());
        glViewport ( 0, 0, render_target->GetWidth(), render_target->GetHeight() );
        if (CheckGL) check();
    }

    glUseProgram(GCol_sxsy0_Prog.GetId()); if (CheckGL) check();

    glUniform2f(glGetUniformLocation(GCol_sxsy0_Prog.GetId(),"offset"),x0,y0);
    glUniform2f(glGetUniformLocation(GCol_sxsy0_Prog.GetId(),"scale"),x1-x0,y1-y0);
    glUniform1i(glGetUniformLocation(GCol_sxsy0_Prog.GetId(),"tex0"), 0);
    glUniform2f(glGetUniformLocation(GCol_sxsy0_Prog.GetId(),"texturesize"), Coltexture->GetWidth(), Coltexture->GetHeight());
    if (CheckGL) check();

    glBindBuffer(GL_ARRAY_BUFFER, GQuadVertexBuffer);   if (CheckGL) check();
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D,Coltexture->GetId()); if (CheckGL) check();
    glActiveTexture(GL_TEXTURE0);

    GLuint loc = glGetAttribLocation(GCol_sxsy0_Prog.GetId(),"vertex");
    glVertexAttribPointer(loc, 4, GL_FLOAT, 0, 16, 0);  if (CheckGL) check();
    glEnableVertexAttribArray(loc); if (CheckGL) check();
    glDrawArrays ( GL_TRIANGLE_STRIP, 0, 4 ); if (CheckGL) check();

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);

    if(render_target)
    {
        glBindFramebuffer(GL_FRAMEBUFFER,0);
        glViewport ( 0, 0, GScreenWidth, GScreenHeight );
    }
}


void DrawYUVTextureRect(GfxTexture* ytexture, GfxTexture* utexture, GfxTexture* vtexture, float x0, float y0, float x1, float y1, bool CheckGL, GfxTexture* render_target)
{
	if(render_target)
	{
		glBindFramebuffer(GL_FRAMEBUFFER,render_target->GetFramebufferId());
		glViewport ( 0, 0, render_target->GetWidth(), render_target->GetHeight() );
		if (CheckGL) check();
	}

	glUseProgram(GYUVProg.GetId());	if (CheckGL) check();

	glUniform2f(glGetUniformLocation(GYUVProg.GetId(),"offset"),x0,y0);
	glUniform2f(glGetUniformLocation(GYUVProg.GetId(),"scale"),x1-x0,y1-y0);
	glUniform1i(glGetUniformLocation(GYUVProg.GetId(),"tex0"), 0);
	glUniform1i(glGetUniformLocation(GYUVProg.GetId(),"tex1"), 1);
	glUniform1i(glGetUniformLocation(GYUVProg.GetId(),"tex2"), 2);
    // gng  test to see exact offset between higher and lower size texture
    //glUniform2f(glGetUniformLocation(GYUVProg.GetId(),"ytexelsize"),1.f/ytexture->GetWidth(),1.f/ytexture->GetHeight());
	if (CheckGL) check();

	glBindBuffer(GL_ARRAY_BUFFER, GQuadVertexBuffer);	if (CheckGL) check();
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D,ytexture->GetId());	if (CheckGL) check();
	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_2D,utexture->GetId());	if (CheckGL) check();
	glActiveTexture(GL_TEXTURE2);
	glBindTexture(GL_TEXTURE_2D,vtexture->GetId());	if (CheckGL) check();
	glActiveTexture(GL_TEXTURE0);

	GLuint loc = glGetAttribLocation(GYUVProg.GetId(),"vertex");
	glVertexAttribPointer(loc, 4, GL_FLOAT, 0, 16, 0);	if (CheckGL) check();
	glEnableVertexAttribArray(loc);	if (CheckGL) check();
	glDrawArrays ( GL_TRIANGLE_STRIP, 0, 4 ); if (CheckGL) check();

	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindTexture(GL_TEXTURE_2D, 0);

	if(render_target)
	{
		//glFinish();	check();
		//glFlush(); check();
		glBindFramebuffer(GL_FRAMEBUFFER,0);
		glViewport ( 0, 0, GScreenWidth, GScreenHeight );
	}
}

void Init_nsss_cccc_TextureRect(GfxTexture* Coltexture, float x0, float y0, float x1, float y1, bool CheckGL, GfxTexture* render_target)
{
    if(render_target)
    {
        glBindFramebuffer(GL_FRAMEBUFFER,render_target->GetFramebufferId());
        glViewport ( 0, 0, render_target->GetWidth(), render_target->GetHeight() );
        if (CheckGL) check();
    }

    glUseProgram(GinitCol_nsss_cccc_Prog.GetId()); if (CheckGL) check();

    glUniform2f(glGetUniformLocation(GinitCol_nsss_cccc_Prog.GetId(),"offset"),x0,y0);
    glUniform2f(glGetUniformLocation(GinitCol_nsss_cccc_Prog.GetId(),"scale"),x1-x0,y1-y0);
    glUniform1i(glGetUniformLocation(GinitCol_nsss_cccc_Prog.GetId(),"tex0"), 0);
    glUniform2f(glGetUniformLocation(GinitCol_nsss_cccc_Prog.GetId(),"texelsize"),1.f/Coltexture->GetWidth(),1.f/Coltexture->GetHeight());
    glUniform2f(glGetUniformLocation(GinitCol_nsss_cccc_Prog.GetId(),"texturesize"),Coltexture->GetWidth(),Coltexture->GetHeight());
    if (CheckGL) check();

    glBindBuffer(GL_ARRAY_BUFFER, GQuadVertexBuffer);   if (CheckGL) check();
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D,Coltexture->GetId()); if (CheckGL) check();
    glActiveTexture(GL_TEXTURE0);

    GLuint loc = glGetAttribLocation(GinitCol_nsss_cccc_Prog.GetId(),"vertex");
    glVertexAttribPointer(loc, 4, GL_FLOAT, 0, 16, 0);  if (CheckGL) check();
    glEnableVertexAttribArray(loc); if (CheckGL) check();
    glDrawArrays ( GL_TRIANGLE_STRIP, 0, 4 ); if (CheckGL) check();

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);

    if(render_target)
    {
        glBindFramebuffer(GL_FRAMEBUFFER,0);
        glViewport ( 0, 0, GScreenWidth, GScreenHeight );
    }
}

void Col_k_cccc_TextureRect(GfxTexture* col_nsss_cccc_texture, float x0, float y0, float x1, float y1, bool CheckGL, GfxTexture* render_target)
{
    if(render_target)
    {
        glBindFramebuffer(GL_FRAMEBUFFER,render_target->GetFramebufferId());
        glViewport ( 0, 0, render_target->GetWidth(), render_target->GetHeight() );
        if (CheckGL) check();
    }

    glUseProgram(GCol_k_cccc_Prog.GetId()); if (CheckGL) check();

    glUniform2f(glGetUniformLocation(GCol_k_cccc_Prog.GetId(),"offset"),x0,y0);
    glUniform2f(glGetUniformLocation(GCol_k_cccc_Prog.GetId(),"scale"),x1-x0,y1-y0);
    glUniform1i(glGetUniformLocation(GCol_k_cccc_Prog.GetId(),"tex0"), 0);
    glUniform1f(glGetUniformLocation(GCol_k_cccc_Prog.GetId(),"texelsizey"),1.f/col_nsss_cccc_texture->GetHeight());
    if (CheckGL) check();

    glBindBuffer(GL_ARRAY_BUFFER, GQuadVertexBuffer);   if (CheckGL) check();
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D,col_nsss_cccc_texture->GetId()); if (CheckGL) check();
    glActiveTexture(GL_TEXTURE0);

    GLuint loc = glGetAttribLocation(GCol_k_cccc_Prog.GetId(),"vertex");
    glVertexAttribPointer(loc, 4, GL_FLOAT, 0, 16, 0);  if (CheckGL) check();
    glEnableVertexAttribArray(loc); if (CheckGL) check();
    glDrawArrays ( GL_TRIANGLE_STRIP, 0, 4 ); if (CheckGL) check();

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);

    if(render_target)
    {
        glBindFramebuffer(GL_FRAMEBUFFER,0);
        glViewport ( 0, 0, GScreenWidth, GScreenHeight );
    }
}


void Sum4_d4_d4_TextureRect(GfxTexture* previoustexture, float x0, float y0, float x1, float y1, bool CheckGL, GfxTexture* render_target)
{
    if(render_target)
    {
        glBindFramebuffer(GL_FRAMEBUFFER,render_target->GetFramebufferId());
        glViewport ( 0, 0, render_target->GetWidth(), render_target->GetHeight() );
        if (CheckGL) check();
    }

    glUseProgram(GCol_sum4_d4_d4_Prog.GetId());
    if (CheckGL) check();

    glUniform2f(glGetUniformLocation(GCol_sum4_d4_d4_Prog.GetId(),"offset"),x0,y0);
    glUniform2f(glGetUniformLocation(GCol_sum4_d4_d4_Prog.GetId(),"scale"),x1-x0,y1-y0);
    glUniform1i(glGetUniformLocation(GCol_sum4_d4_d4_Prog.GetId(),"tex0"), 0);
    glUniform2f(glGetUniformLocation(GCol_sum4_d4_d4_Prog.GetId(),"texelsize"),1.f/previoustexture->GetWidth(),1.f/previoustexture->GetHeight());
    if (CheckGL) check();

    glBindBuffer(GL_ARRAY_BUFFER, GQuadVertexBuffer);
    if (CheckGL) check();
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D,previoustexture->GetId());
    if (CheckGL) check();
    glActiveTexture(GL_TEXTURE0);

    GLuint loc = glGetAttribLocation(GCol_sum4_d4_d4_Prog.GetId(),"vertex");
    glVertexAttribPointer(loc, 4, GL_FLOAT, 0, 16, 0);
    if (CheckGL) check();
    glEnableVertexAttribArray(loc);
    if (CheckGL) check();
    glDrawArrays ( GL_TRIANGLE_STRIP, 0, 4 );
    if (CheckGL) check();

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);

    if(render_target)
    {
        glBindFramebuffer(GL_FRAMEBUFFER,0);
        glViewport ( 0, 0, GScreenWidth, GScreenHeight );
    }
}


bool GfxTexture::CreateRGBA(int width, int height, const void* data)
{
	Width = width;
	Height = height;
	glGenTextures(1, &Id);
	check();
	glBindTexture(GL_TEXTURE_2D, Id);
	check();
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, Width, Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
	check();
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, (GLfloat)GL_NEAREST);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, (GLfloat)GL_NEAREST);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, (GLfloat)GL_MIRRORED_REPEAT);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, (GLfloat)GL_MIRRORED_REPEAT);
	check();
	glBindTexture(GL_TEXTURE_2D, 0);
	IsRGBA = true;
	return true;
}

bool GfxTexture::CreateGreyScale(int width, int height, const void* data)
{
	Width = width;
	Height = height;
	glGenTextures(1, &Id);
	check();
	glBindTexture(GL_TEXTURE_2D, Id);
	check();
	glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, Width, Height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, data);
	check();
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, (GLfloat)GL_NEAREST);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, (GLfloat)GL_NEAREST);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, (GLfloat)GL_MIRRORED_REPEAT);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, (GLfloat)GL_MIRRORED_REPEAT);
	check();
	glBindTexture(GL_TEXTURE_2D, 0);
	IsRGBA = false;
	return true;
}

bool GfxTexture::GenerateFrameBuffer()
{
	//Create a frame buffer that points to this texture
	glGenFramebuffers(1,&FramebufferId);
	check();
	glBindFramebuffer(GL_FRAMEBUFFER,FramebufferId);
	check();
	glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,Id,0);
	check();
	glBindFramebuffer(GL_FRAMEBUFFER,0);
	check();
	return true;
}

void GfxTexture::SetPixels(const void* data, bool CheckGL)
{
	glBindTexture(GL_TEXTURE_2D, Id);
	if (CheckGL) check();
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, Width, Height, IsRGBA ? GL_RGBA : GL_LUMINANCE, GL_UNSIGNED_BYTE, data);
	if (CheckGL) check();
	glBindTexture(GL_TEXTURE_2D, 0);
	if (CheckGL) check();
}

void SaveFrameBuffer(const char* fname)
{
	void* image = malloc(GScreenWidth*GScreenHeight*4);
	glBindFramebuffer(GL_FRAMEBUFFER,0);
	check();
	glReadPixels(0,0,GScreenWidth,GScreenHeight, GL_RGBA, GL_UNSIGNED_BYTE, image);

	unsigned error = lodepng::encode(fname, (const unsigned char*)image, GScreenWidth, GScreenHeight, LCT_RGBA);
	if(error) 
		printf("error: %d\n",error);

	free(image);

}

void GfxTexture::Save(const char* fname)
{
	void* image = malloc(Width*Height*4);
	glBindFramebuffer(GL_FRAMEBUFFER,FramebufferId);
	check();
	glReadPixels(0,0,Width,Height,IsRGBA ? GL_RGBA : GL_LUMINANCE, GL_UNSIGNED_BYTE, image);
	check();
	glBindFramebuffer(GL_FRAMEBUFFER,0);

    //gng  the png file is not exactly identical to texture content, therefore I save brut content rgbargbargba...
    FILE* file;
    file = fopen(fname, "wb" );
    //if(!file) return 79;
    fwrite((char*)image , 1 , Width*Height*4, file);
    fclose(file);
    
	//unsigned error = lodepng::encode(fname, (const unsigned char*)image, Width, Height, IsRGBA ? LCT_RGBA : LCT_GREY);
	//if(error) 
	//	printf("error: %d\n",error);

	free(image);
}

void GfxTexture::getuint32Texture(uint32_t* tex)
{
  glBindFramebuffer(GL_FRAMEBUFFER,FramebufferId);
  check();
  glReadPixels(0,0,Width,Height,IsRGBA ? GL_RGBA : GL_LUMINANCE, GL_UNSIGNED_BYTE, (void*)tex);
  check();
  glBindFramebuffer(GL_FRAMEBUFFER,0);
  //tex = (uint32_t*)image;
}

void ColorParam::setMin(int i, float min)
{
    Min[i] = min;
}

void ColorParam::setMin(float minR, float minG, float minB, float minA)
{
    Min[0] = minR;
    Min[1] = minG;
    Min[2] = minB;
    Min[3] = minA;
}

void ColorParam::setMax(int i, float max)
{
    Max[i] = max;
}

void ColorParam::setMax(float maxR, float maxG, float maxB, float maxA)
{
    Max[0] = maxR;
    Max[1] = maxG;
    Max[2] = maxB;
    Max[3] = maxA;
}

void ColorParam::setCol(int i, float col)
{
    Col[i] = col;
}

void ColorParam::setCol(float R, float G, float B, float A)
{
    Col[0] = R;
    Col[1] = G;
    Col[2] = B;
    Col[3] = A;
}

void ColorParam::setMain(int divby)
{
    Divby = divby;
}

float ColorParam::getMin(int i)
{
    return Min[i];
}

float ColorParam::getMax(int i)
{
    return Max[i];
}

float ColorParam::getCol(int i)
{
    return Col[i];
}

int ColorParam::getMain()
{
    return Divby;
}
