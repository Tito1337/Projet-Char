// gng  This version is based on graphics.cpp from Chris Cummings
// ref: http://robotblogging.blogspot.be/2013/10/gpu-accelerated-camera-processing-on.html
#pragma once

#include "GLES2/gl2.h"
#include "EGL/egl.h"
#include "EGL/eglext.h"
#include "lodepng.h"

void InitGraphics();
void ReleaseGraphics();
void BeginFrame(bool CheckGL);
void EndFrame(bool CheckGL);

class GfxShader
{
	GLchar* Src;
	GLuint Id;
	GLuint GlShaderType;

public:

	GfxShader() : Src(NULL), Id(0), GlShaderType(0) {}
	~GfxShader() { if(Src) delete[] Src; }

	bool LoadVertexShader(const char* filename);
	bool LoadFragmentShader(const char* filename);
	GLuint GetId() { return Id; }
};

class GfxProgram
{
	GfxShader* VertexShader;
	GfxShader* FragmentShader;
	GLuint Id;

public:

	GfxProgram() {}
	~GfxProgram() {}

	bool Create(GfxShader* vertex_shader, GfxShader* fragment_shader);
	GLuint GetId() { return Id; }
};

class GfxTexture
{
	int Width;
	int Height;
	GLuint Id;
	bool IsRGBA;

	GLuint FramebufferId;
public:

	GfxTexture() : Width(0), Height(0), Id(0), FramebufferId(0) {}
	~GfxTexture() {}

	bool CreateRGBA(int width, int height, const void* data = NULL);
	bool CreateGreyScale(int width, int height, const void* data = NULL);
	bool GenerateFrameBuffer();
	void SetPixels(const void* data, bool CheckGL);
	GLuint GetId() { return Id; }
	GLuint GetFramebufferId() { return FramebufferId; }
	int GetWidth() {return Width;}
	int GetHeight() {return Height;}
	void Save(const char* fname);
  void getuint32Texture(uint32_t* tex);
};

class ColorParam {  // gng
    float Min[4]; // Min for color divided by its divby component
    float Max[4]; // Max
    float Col[4]; // Color to attribute to pixel if it is detected inside last possible range
    int   Divby;  // divby[currcol] is 0 : previous was the last color to test)
                  //                   1 : divide components g and b by r
                  //                   2 :                   r     b    g
                  //                   3 :                   r     g    b
public:
    void setMin(int i, float min);
    void setMin(float minR, float minG, float minB, float minA);
    void setMax(int i, float max);
    void setMax(float maxR, float maxG, float maxB, float maxA);
    void setCol(int i, float col);
    void setCol(float R, float G, float B, float A);
    void setMain(int divby);
    float getMin(int i);
    float getMax(int i);
    float getCol(int i);
    int getMain();
};

void SaveFrameBuffer(const char* fname);

void DrawGngdetectcolRect(GfxTexture* ytexture, GfxTexture* utexture, GfxTexture* vtexture
    , float x0, float y0, float x1, float y1, bool CheckGL, GfxTexture* render_target
    , ColorParam *colpar);
void InitCol_sxsy0_TextureRect(GfxTexture* Coltexture, float x0, float y0, float x1, float y1, bool CheckGL, GfxTexture* render_target);
void DrawTextureRect(GfxTexture* texture, float x0, float y0, float x1, float y1, bool CheckGL, GfxTexture* render_target);
void DrawPolygon(GLfloat* vertices, int polylength, GLenum  mode, GLfloat LineWidth, float* col, bool CheckGL);
void DrawYUVTextureRect(GfxTexture* ytexture, GfxTexture* utexture, GfxTexture* vtexture, float x0, float y0, float x1, float y1, bool CheckGL, GfxTexture* render_target);
void Init_nsss_cccc_TextureRect(GfxTexture* Coltexture, float x0, float y0, float x1, float y1, bool CheckGL, GfxTexture* render_target);
void Col_k_cccc_TextureRect(GfxTexture* col_nsss_cccc_texture, float x0, float y0, float x1, float y1, bool CheckGL, GfxTexture* render_target);
void Sum4_d4_d4_TextureRect(GfxTexture* previoustexture, float x0, float y0, float x1, float y1, bool CheckGL, GfxTexture* render_target);
