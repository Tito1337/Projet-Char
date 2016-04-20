// gng  This version is based on graphics.cpp from Chris Cummings
// ref: http://robotblogging.blogspot.be/2013/10/gpu-accelerated-camera-processing-on.html
// Color detection + statistics (N, sX, sY, sD²)

#define MAIN_TEXTURE_WIDTH 768
#define MAIN_TEXTURE_HEIGHT 512

#include <stdio.h>
#include <unistd.h>
#include "camera.h"
#include "graphics.h"
#include <time.h>
#include <curses.h>
#include <complex>
#include <fstream>


// for text
#include <ft2build.h>  // need  include_directories(/usr/include/freetype2)  in file  CMakeLists.txt
#include FT_FREETYPE_H

#define TEXTURE_GRID_COLS 4
#define TEXTURE_GRID_ROWS 4
#define PSEUDOMIPMAPLEVELS 6

#define IDCOL0 0.996078431372549  // 254./255.
#define IDCOL1 0.992156862745098  // 253./255.
#define IDCOL2 0.988235294117647  // 252./255.
#define IDCOL3 0.984313725490196  // 251./255.

typedef struct xref_tb  // gng : inspired from RaspiCLI.h
{
   char mode[15];
   MMAL_PARAM_AWBMODE_T mmal_mode;
} XREF_TB;

typedef struct xref_te  // gng : inspired from RaspiCLI.h
{
   char mode[15];
   MMAL_PARAM_EXPOSUREMODE_T mmal_mode;
} XREF_TE;

typedef struct xyb_tb  // gng - Jeremy Bartholomeus
{
   float Xb;
   float Yb;
} XYB_TB;

typedef struct xref_tm // Jeremy Bartholomeus
{
   char mode[15];
} XREF_TM;

XREF_TB awb_map[] =
{
   {"off         ",  MMAL_PARAM_AWBMODE_OFF},   // char *mode, int mmal_mode
   {"auto        ",  MMAL_PARAM_AWBMODE_AUTO},
   {"sun         ",  MMAL_PARAM_AWBMODE_SUNLIGHT},
   {"cloud       ",  MMAL_PARAM_AWBMODE_CLOUDY},
   {"shade       ",  MMAL_PARAM_AWBMODE_SHADE},
   {"tungsten    ",  MMAL_PARAM_AWBMODE_TUNGSTEN},
   {"fluorescent ",  MMAL_PARAM_AWBMODE_FLUORESCENT},
   {"incandescent",  MMAL_PARAM_AWBMODE_INCANDESCENT},
   {"flash       ",  MMAL_PARAM_AWBMODE_FLASH},
   {"horizon     ",  MMAL_PARAM_AWBMODE_HORIZON}
};

XREF_TE  exposure_map[] =
{
   {"auto        ",  MMAL_PARAM_EXPOSUREMODE_AUTO},
   {"night       ",  MMAL_PARAM_EXPOSUREMODE_NIGHT},
   {"nightpreview",  MMAL_PARAM_EXPOSUREMODE_NIGHTPREVIEW},
   {"backlight   ",  MMAL_PARAM_EXPOSUREMODE_BACKLIGHT},
   {"spotlight   ",  MMAL_PARAM_EXPOSUREMODE_SPOTLIGHT},
   {"sports      ",  MMAL_PARAM_EXPOSUREMODE_SPORTS},
   {"snow        ",  MMAL_PARAM_EXPOSUREMODE_SNOW},
   {"beach       ",  MMAL_PARAM_EXPOSUREMODE_BEACH},
   {"verylong    ",  MMAL_PARAM_EXPOSUREMODE_VERYLONG},
   {"fixedfps    ",  MMAL_PARAM_EXPOSUREMODE_FIXEDFPS},
   {"antishake   ",  MMAL_PARAM_EXPOSUREMODE_ANTISHAKE},
   {"fireworks   ",  MMAL_PARAM_EXPOSUREMODE_FIREWORKS}
};

XREF_TM set_map[] =  // affichage des modes de prises de données (mesures ou etalonage)  Jérémy Bartholomeus
{
   {"Mesurements"},
   {"Calibration"}
};

char tmpbuff[MAIN_TEXTURE_WIDTH*MAIN_TEXTURE_HEIGHT*4];

bool CheckGL = true;

void getimobj(int icolor, uint32_t* tex, int level, int r0, int nr, int *cFirst, int *cLast, uint32_t *n, uint32_t *sx, uint32_t *sy, uint32_t *sd2) {
   /*
    * IN:  icolor   index of color  [0-3]
    *      tex      texture content from col_nsss_cccc_textures[level]
    *      level    level of tex  [0-5]         0:384x256(96x64)  1:192x128(48x32)  2:96x64(24x16)  3:48x32(12x8)  4:24x16(6x4)  5:12x8(3x2)
    *      r0       first row of polygon where to add n, sx, sy and sd2
    *      nr       number of rows of polygon
    *      cFirst   pointer to index of first colum of polygon for first row, indices must be given in a vector cFirst[nr]
    *      cLast    pointer to index of last colum of polygon for first row, indices must be given in a vector cLast[nr]
    *      n        where to add n       note:  first row of tex :   n0   n1   n2   n3   n0   n1   n2 ...   where 0, 1, 2, 3 is icolor
    *      sx       where to add sx             2d                  sx0  sx1  sx2  sx3  sx0  sx1  sx2 ...
    *      sy       where to add sy             3d                  sy0  sy1  sy2  sy3  sy0  sy1  sy2 ...
    *      sd2      where to add sd²            4th                sd²0 sd²1 sd²2 sd²3 sd²0 sd²1 sd²2 ...
    */
    int W = MAIN_TEXTURE_WIDTH>>(level+1);
    int r;
    int c;
    for (int ir=0; ir<nr; ir++) {
        for (int ic = cFirst[ir]; ic<=cLast[ir]; ic++) {
            c = ic*4+icolor;
            r = (r0+ir)*4;
            *n += tex[r*W + c];
            *sx += tex[(r+1)*W + c];
            *sy += tex[(r+2)*W + c];
            *sd2 += tex[(r+3)*W + c];
        }
    }
}

void interestZoneOutline(int level, int r0, int nr, int* cFirst, int* cLast, GLfloat* vertices) {
   /* Bouw polygon around image zone
    * IN:  level    level of tex  [0-5]         0:384x256(96x64)  1:192x128(48x32)  2:96x64(24x16)  3:48x32(12x8)  4:24x16(6x4)  5:12x8(3x2)
    *      r0       first row of polygon where to add n, sx, sy and sd2
    *      nr       number of rows of polygon  Attention! per row, 16 float in vertices !
    *      cFirst   pointer to index of first colum of polygon for first row, indices must be given in a vector cFirst[nr]
    *      cLast    pointer to index of last colum of polygon for first row, indices must be given in a vector cLast[nr]
    * OUT: vertices points of polygon, 2*2*nr points xyzw = 16*nr elements
    */
    float sW = 1.0 / (MAIN_TEXTURE_WIDTH>>(level+3)); //  2.0/12 for level 3
    float sH = 1.0 / (MAIN_TEXTURE_HEIGHT>>(level+3)); // 2.0/8 for level 3
    for (int k=0; k<nr; k++) {
        vertices[8*k]   = float(cFirst[k])*sW; // x between 0 and +1
        vertices[8*k+1] = float(r0+k)*sH; // y between 0 and +1
        vertices[8*k+2] = 1.0; // z
        vertices[8*k+3] = 1.0; // w
        vertices[8*k+4] = float(cFirst[k])*sW; // x between 0 and +1
        vertices[8*k+5] = float(r0+k+1)*sH; // y between 0 and +1
        vertices[8*k+6] = 1.0; // z
        vertices[8*k+7] = 1.0; // w
    }
    for (int k=0; k<nr; k++) {
        vertices[8*(k+nr)]   = float(cLast[nr-1-k]+1)*sW; // x between 0 and +1
        vertices[8*(k+nr)+1] = float(r0+nr-k)*sH; // y between 0 and +1
        vertices[8*(k+nr)+2] = 1.0; // z
        vertices[8*(k+nr)+3] = 1.0; // w
        vertices[8*(k+nr)+4] = float(cLast[nr-1-k]+1)*sW; // x between 0 and +1
        vertices[8*(k+nr)+5] = float(r0+nr-k-1)*sH; // y between 0 and +1
        vertices[8*(k+nr)+6] = 1.0; // z
        vertices[8*(k+nr)+7] = 1.0; // w
    }
}

void objectPosition(int icolor, uint32_t* tex, int level, int r0, int nr, int* cFirst, int* cLast, float k10max, int textcolor, int rtext, int ctext, XYB_TB centroid) {
   /* Bouw polygon around zone of interest, compute position of object, draw it and print results
    * IN:  icolor    index of color  [0-3]
    *      tex       texture content from col_nsss_cccc_textures[level]
    *      level     level of tex  [0-5]         0:384x256(96x64)  1:192x128(48x32)  2:96x64(24x16)  3:48x32(12x8)  4:24x16(6x4)  5:12x8(3x2)
    *      r0        first row of polygon where to add n, sx, sy and sd2
    *      nr        number of rows of polygon
    *      cFirst    pointer to index of first colum of polygon for first row, indices must be given in a vector cFirst[nr]
    *      cLast     pointer to index of last colum of polygon for first row, indices must be given in a vector cLast[nr]
    *      k10max    max of k10 to consider object detected and display green cross
    *      textcolor number of color for text 3:red, 5:green, 7:blue
    *      rtext     first row for text (between 6 and 8)
    *      ctext     first column for text
    *      centroid  struct .Xb  .Yb
    */

    // draw outline of zone of interest
    float colwhite[4] = {1.0, 1.0, 1.0, 1.0};
    float colgreen[4] = {.0, 1.0, .0, 1.0};
    float colblack[4] = {.0, .0, .0, 1.0};
    GLfloat vertices[nr*16];
    interestZoneOutline(level, r0, nr, cFirst, cLast, vertices); // compute vertices of outline
    int polylength = nr*4; // 4 segments per row for outline of interest zone
    DrawPolygon(vertices, polylength, GL_LINE_LOOP, 1, colwhite, CheckGL); // draw outline of interest zone

    // Compute position of object
    uint32_t  n=0; uint32_t  sx=0;  uint32_t  sy=0; uint32_t  sd2=0;
    float   f_n=0; float   f_sx=0;  float   f_sy=0; float   f_sd2=0;
    centroid.Xb = 0;
    centroid.Yb = 0;
    float k10 = 0.0;
    getimobj(icolor, tex, level, r0, nr, cFirst, cLast, &n, &sx, &sy, &sd2);
    if (n>0) {
        f_n = n;  f_sx = sx;  f_sy = sy;  f_sd2 = sd2;
        centroid.Xb = f_sx/f_n;
        centroid.Yb = f_sy/f_n;
      //position(centroid.Xb, centroid.Yb);
        k10 = 62.831853 * (f_sd2 - (f_sx*f_sx + f_sy*f_sy)/f_n ) / (f_n*f_n);

        // draw centroid
        float dx=5.0/MAIN_TEXTURE_WIDTH;
        float dy=5.0/MAIN_TEXTURE_HEIGHT;
        float XbNorm = centroid.Xb*2.0/MAIN_TEXTURE_WIDTH; // divided by image width
        float YbNorm = centroid.Yb*2.0/MAIN_TEXTURE_HEIGHT; // divided by image height

        GLfloat vertices[16] = {
            XbNorm-dx, YbNorm, 1.0f, 1.0f,
            XbNorm+dx, YbNorm, 1.0f, 1.0f,
            XbNorm, YbNorm-dy, 1.0f, 1.0f,
            XbNorm, YbNorm+dy, 1.0f, 1.0f
        };
        int polylength = 4; // 4 points (2* 2segments)
        if (k10<=k10max) { // if detection OK
            DrawPolygon(vertices, polylength, GL_LINES, 5, colgreen, CheckGL); // draw green cross
            DrawPolygon(vertices, polylength, GL_LINES, 2, colblack, CheckGL); // draw green cross
        }
        else DrawPolygon(vertices, polylength, GL_LINES, 1, colwhite, CheckGL); // draw cross at centroid
    }
    attron(COLOR_PAIR(textcolor));
    mvprintw(rtext, ctext, "    Object:   n = %d,  position = (%3.1f, %3.1f),  k10 = %2.1f       ", n, centroid.Xb, centroid.Yb, k10); // gng: perhaps problem with \n if I well understand  http://repo.hackerzvoice.net/depot_madchat/coding/c/c.scene/cs3/CS3-08.html
    attroff(COLOR_PAIR(textcolor));
}

//entry point
int main(int argc, const char **argv) {
   char fromkeyb[50];
   ColorParam colpar[4];
   int currcol; // current editable col (selected with 'x', 'y', 'z' or 'w')
   int currcomp; // current editable component (selected with 'r', 'g' or 'b')
   int currminmax; // current editable by '<' or '>' is: 0:min 1:max
   float step = 0.01; // step for min or max change
   char filename[200];
   InitGraphics(); //init graphics and the camera

   // Christophe De Wolf : Load filters from file
   if(argc < 2) {
      printf("ERREUR : Veuillez fournir un fichier de filtre en argument\r\n");
      return 1;
   }

   std::ifstream infile(argv[1]);
   int colMain;
   float colMinR, colMinG, colMinB, colMaxR, colMaxG, colMaxB;

   infile >> colMain >> colMinR >> colMinG >> colMinB >> colMaxR >> colMaxG >> colMaxB;
   printf("Settings 0 : %d %f %f %f %f %f %f\r\n", colMain, colMinR, colMinG, colMinB, colMaxR, colMaxG, colMaxB);
   colpar[0].setCol ( 1 , 0 , 0 , IDCOL0 ); // rgba: RED  alpha indicates color number
   colpar[0].setMain(colMain); // 1:r, 2:g, 3:b, 0:not used  Other components are divided by main
   colpar[0].setMin (colMinR, colMinG, colMinB, 0 ); // rgba  G and B relative to R
   colpar[0].setMax (colMaxR, colMaxG, colMaxB, 1 ); // rgba  G and B relative to R

   infile >> colMain >> colMinR >> colMinG >> colMinB >> colMaxR >> colMaxG >> colMaxB;
   printf("Settings 1 : %d %f %f %f %f %f %f\r\n", colMain, colMinR, colMinG, colMinB, colMaxR, colMaxG, colMaxB);
   colpar[1].setCol ( 0 , .6, 0 , IDCOL1 ); // rgba: GREEN
   colpar[1].setMain(colMain); // 1:r, 2:g, 3:b, 0:not used  Other components are divided by main
   colpar[1].setMin (colMinR, colMinG, colMinB, 0 ); // rgba  G and B relative to R
   colpar[1].setMax (colMaxR, colMaxG, colMaxB, 1 ); // rgba  G and B relative to R

   infile >> colMain >> colMinR >> colMinG >> colMinB >> colMaxR >> colMaxG >> colMaxB;
   printf("Settings 2 : %d %f %f %f %f %f %f\r\n", colMain, colMinR, colMinG, colMinB, colMaxR, colMaxG, colMaxB);
   colpar[2].setCol ( 0 , 0 , 1 , IDCOL2 ); // rgba: BLUE
   colpar[2].setMain(colMain); // 1:r, 2:g, 3:b, 0:not used  Other components are divided by main
   colpar[2].setMin (colMinR, colMinG, colMinB, 0 ); // rgba  G and B relative to R
   colpar[2].setMax (colMaxR, colMaxG, colMaxB, 1 ); // rgba  G and B relative to R

   infile >> colMain >> colMinR >> colMinG >> colMinB >> colMaxR >> colMaxG >> colMaxB;
   printf("Settings 3 : %d %f %f %f %f %f %f\r\n", colMain, colMinR, colMinG, colMinB, colMaxR, colMaxG, colMaxB);
   colpar[3].setCol ( 1,  0,  1 , IDCOL3 ); // rgba: BLACK
   colpar[3].setMain(colMain); // 1:r, 2:g, 3:b, 0:not used  Other components are divided by main
   colpar[3].setMin (colMinR, colMinG, colMinB, 0 ); // rgba  G and B relative to R
   colpar[3].setMax (colMaxR, colMaxG, colMaxB, 1 ); // rgba  G and B relative to R

   CCamera* cam = StartCamera(MAIN_TEXTURE_WIDTH, MAIN_TEXTURE_HEIGHT,15,1,false); // 15 frames/s

   //create 4 textures of decreasing size
   GfxTexture ytexture,utexture,vtexture,rgbtexture,rgbtextures[10]
               ,gngdetectcoltexture, col_sxsy0_texture
               ,col_nsss_cccc_textures[PSEUDOMIPMAPLEVELS],col_k_cccc_textures[PSEUDOMIPMAPLEVELS];
   uint32_t* tex32nssscccc[PSEUDOMIPMAPLEVELS];
   ytexture.CreateGreyScale(MAIN_TEXTURE_WIDTH,MAIN_TEXTURE_HEIGHT);
   utexture.CreateGreyScale(MAIN_TEXTURE_WIDTH/2,MAIN_TEXTURE_HEIGHT/2);
   vtexture.CreateGreyScale(MAIN_TEXTURE_WIDTH/2,MAIN_TEXTURE_HEIGHT/2);

   GfxTexture yreadtexture,ureadtexture,vreadtexture;
   yreadtexture.CreateRGBA(MAIN_TEXTURE_WIDTH,MAIN_TEXTURE_HEIGHT);
   yreadtexture.GenerateFrameBuffer();
   ureadtexture.CreateRGBA(MAIN_TEXTURE_WIDTH/2,MAIN_TEXTURE_HEIGHT/2);
   ureadtexture.GenerateFrameBuffer();
   vreadtexture.CreateRGBA(MAIN_TEXTURE_WIDTH/2,MAIN_TEXTURE_HEIGHT/2);
   vreadtexture.GenerateFrameBuffer();

   GfxTexture* texture_grid[TEXTURE_GRID_COLS*TEXTURE_GRID_ROWS];
   memset(texture_grid,0,sizeof(texture_grid));
   int next_texture_grid_entry = 0;

   // gng detectcol texture
   gngdetectcoltexture.CreateRGBA(MAIN_TEXTURE_WIDTH/2,MAIN_TEXTURE_HEIGHT/2); // 384x256
   gngdetectcoltexture.GenerateFrameBuffer();
   texture_grid[next_texture_grid_entry++] = &gngdetectcoltexture;

   // texture with  a:detected col or 255,  b:y(0-255),  r:x(lsb) g:x(msb) 
   col_sxsy0_texture.CreateRGBA(MAIN_TEXTURE_WIDTH/2,MAIN_TEXTURE_HEIGHT/2); // 384x256
   col_sxsy0_texture.GenerateFrameBuffer();

   for(int i = 0; i < PSEUDOMIPMAPLEVELS; i++)
   {
     // example: for main 768x512 and 6 levels, create from 96x64 up to 3x2 blocs 4x4
     //   one bloc is :     Nc0    Nc1    Nc2    Nc3
     //                    ΣXc0   ΣXc1   ΣXc2   ΣXc3         texture is from  384x256
     //    (c0: color0)    ΣYc0   ΣYc1   ΣYc2   ΣYc3                    up to  12x8
     //                   ΣD²c0  ΣD²c1  ΣD²c2  ΣD²c3
     col_nsss_cccc_textures[i].CreateRGBA(MAIN_TEXTURE_WIDTH>>(i+1),MAIN_TEXTURE_HEIGHT>>(i+1));
     col_nsss_cccc_textures[i].GenerateFrameBuffer();
     tex32nssscccc[i] = (uint32_t*)malloc((MAIN_TEXTURE_WIDTH>>(i+1))*(MAIN_TEXTURE_HEIGHT>>(i+1))*4); // for texture extraction after process
   }

   for(int i = 2; i < PSEUDOMIPMAPLEVELS; i++)  // not defined before i=2
   {
     // computed from col_nsss_cccc_textures but one value of k for each [Nc.;ΣXc.;ΣYc.;ΣD²c.]
     col_k_cccc_textures[i].CreateRGBA(MAIN_TEXTURE_WIDTH>>(i+1),MAIN_TEXTURE_HEIGHT>>(i+3));
     col_k_cccc_textures[i].GenerateFrameBuffer();
   }

   float texture_grid_col_size = 2.f/TEXTURE_GRID_COLS;
   float texture_grid_row_size = 2.f/TEXTURE_GRID_ROWS;

   printf("Running frame loop\n");

   //read start time
   long int start_time;
   long int time_difference;
   time_t start_time_t;
   time_t time_diff;
   struct timespec gettime_now;
   clock_gettime(CLOCK_REALTIME, &gettime_now);
   start_time = gettime_now.tv_nsec ;
   start_time_t = gettime_now.tv_sec ;
   double total_time_s = 0;

   initscr();      /* initialize the curses library */
   start_color();  /* Start color for characters on screen */
   init_pair(1, COLOR_MAGENTA, COLOR_BLACK); // 1: not selected x, y, z or w
   init_pair(2, COLOR_MAGENTA, COLOR_WHITE); // 2:     selected x, y, z or w
   init_pair(3, COLOR_RED, COLOR_BLACK);     // 3: not selected red
   init_pair(4, COLOR_RED, COLOR_WHITE);     // 4:     selected red
   init_pair(5, COLOR_GREEN, COLOR_BLACK);   // 5: not selected green
   init_pair(6, COLOR_GREEN, COLOR_WHITE);   // 6:     selected green
   init_pair(7, COLOR_BLUE, COLOR_BLACK);    // 7: not selected blue
   init_pair(8, COLOR_BLUE, COLOR_WHITE);    // 8:     selected blue
   int iColPair;

   keypad(stdscr, TRUE);  /* enable keyboard mapping */
   nonl();         /* tell curses not to do NL->CR/NL on output */
   cbreak();       /* take input chars one at a time, no wait for \n */
   clear();
   nodelay(stdscr, TRUE);

   char colxyzw[5] = "xyzw";
   char colrgba[5] = "RGBA";
   currcol=0; // current editable col (selected with 'x', 'y', 'z' or 'w')
   currcomp=0; // current editable component (selected with 'r', 'g' or 'b')
   currminmax=0; // current editable by '<' or '>' is: 0:min 1:max

   int awbmode = 1; // gng
   int exposuremode = 0; // gng

   // Main loop
   while(true) {
      //spin until we have a camera frame
      const void* frame_data; int frame_sz;
      while(!cam->BeginReadFrame(0,frame_data,frame_sz)) {};

      //lock the chosen frame buffer, and copy it directly into the corresponding open gl texture
      {
         const uint8_t* data = (const uint8_t*)frame_data;
         int ypitch = MAIN_TEXTURE_WIDTH;
         int ysize = ypitch*MAIN_TEXTURE_HEIGHT;
         int uvpitch = MAIN_TEXTURE_WIDTH/2;
         int uvsize = uvpitch*MAIN_TEXTURE_HEIGHT/2;
         int upos = ysize;
         int vpos = upos+uvsize;
         ytexture.SetPixels(data, CheckGL);
         utexture.SetPixels(data+upos, CheckGL);
         vtexture.SetPixels(data+vpos, CheckGL);
         cam->EndReadFrame(0);
      }

      //begin frame, draw the texture then end frame (the bit of maths just fits the image to the screen while maintaining aspect ratio)
      BeginFrame(CheckGL);
      float aspect_ratio = float(MAIN_TEXTURE_WIDTH)/float(MAIN_TEXTURE_HEIGHT);
      float screen_aspect_ratio = 1280.f/720.f;
      //these are just here so we can access the yuv data cpu side - opengles doesn't let you read grey ones cos they can't be frame buffers!
      DrawTextureRect(&ytexture,-1,-1,1,1,CheckGL, &yreadtexture);
      DrawTextureRect(&utexture,-1,-1,1,1,CheckGL, &ureadtexture);
      DrawTextureRect(&vtexture,-1,-1,1,1,CheckGL, &vreadtexture);
      //X150225 DrawYUVTextureRect(&ytexture,&utexture,&vtexture,-1.f,-1.f,1.f,1.f,CheckGL, &rgbtexture);

      DrawGngdetectcolRect(&ytexture,&utexture,&vtexture,-1,-1,1,1,CheckGL, &gngdetectcoltexture, colpar); // see graphics.cpp gng
      //X150416 InitCol_sxsy0_TextureRect(&gngdetectcoltexture,-1,-1,1,1,CheckGL, &col_sxsy0_texture);
      InitCol_sxsy0_TextureRect(&gngdetectcoltexture,-1,1,1,-1,CheckGL, &col_sxsy0_texture);

      // Statistic process for centroid
      Init_nsss_cccc_TextureRect(&col_sxsy0_texture,-1.f,-1.f,1.f,1.f,CheckGL, &col_nsss_cccc_textures[0]);
      for(int texidx = 1; texidx<PSEUDOMIPMAPLEVELS; texidx++) {
         Sum4_d4_d4_TextureRect(&col_nsss_cccc_textures[texidx-1],-1.f,-1.f,1.f,1.f,CheckGL, &col_nsss_cccc_textures[texidx]);
         col_nsss_cccc_textures[texidx].getuint32Texture(tex32nssscccc[texidx]);
      }
      // col_k_textures
      for(int texidx = 2; texidx<PSEUDOMIPMAPLEVELS; texidx++)
         Col_k_cccc_TextureRect(&col_nsss_cccc_textures[texidx],-1.f,-1.f,1.f,1.f,CheckGL, &col_k_cccc_textures[texidx]);

      if(GfxTexture* tex = texture_grid[0]) { // Jérémy Bartholomeus
         //X150416 DrawTextureRect(tex,-1,-1,1,1,CheckGL, NULL);
         DrawTextureRect(tex,-1,1,1,-1,CheckGL, NULL);

         // zone of interest  (for a green object)
         int level = 1; // (48x24)
         int r0=0;     // first row of polygonal zone where is object
         int cFirst[] = { 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
                          0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
                          0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
                          0,  0};
         int cLast[]  = {47, 47, 47, 47, 47, 47, 47, 47, 47, 47,
                         47, 47, 47, 47, 47, 47, 47, 47, 47, 47,
                         47, 47, 47, 47, 47, 47, 47, 47, 47, 47,
                         47, 47};
         int nr = sizeof(cFirst)/sizeof(cFirst[0]);
         int icolor=1; // 1: second color for object to detect (green)
         int k10max = 20;
         int textcolor = 5; // 3:red, 5:green, 7:blue
         int rtext = 7;
         int ctext = 10;
         XYB_TB centroid[1];
         objectPosition(icolor, tex32nssscccc[level], level, r0, nr, cFirst, cLast, k10max, textcolor, rtext, ctext, centroid[0]);
      }
      EndFrame(CheckGL);
      CheckGL = false; // no more check
   }

   // Exit routines
   StopCamera();
   endwin();
}
