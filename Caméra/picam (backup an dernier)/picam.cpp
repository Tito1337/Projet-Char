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
void object_robot_position (int rtext, int ctext, XYB_TB centroid) // Jérémy Bartholomeus			Fonction calculant la position de l'objet détecté depuis le plan de la caméra vers le plan du robot
{
		
		float Width = 0.00945;			// taille pixel
		float Height= 0.01063;
		float H 	= 0;				// hauteur des pièces
		float F 	= 3.6;				//distance focale
		float k2 	= 0;				// distortion
		float cmax 	= 384; 				// nbr pixel
		float	rmax 	= 256;
		float	dc0 	= 0;				//règlage centre caméra
		float	dr0 	= 0;
		float ABC1 	= -0.0012759;			// coord plan // a la table
		float ABC2 	= 2.476168e-4;
		float ABC3 	= 0.00143828;
		float	m11 =  -0.5937; float	m12 =  0.5180;	float	m13 = -0.6158; 	float	m14 =   580.8245;  // matrice rotation
		float	m21 =  -0.4630; float	m22 = -0.8458; 	float	m23 = -0.2651; 	float	m24 =   451.9903;
		float	m31 =  -0.6582; float	m32 =  0.1277; 	float	m33 =  0.7419; 	float	m34 =   515.8467;
		float	m41 =   	 0; float 	m42 = 		0;	float	m43 =    	0;	float	m44 =		   1;

		float RealC	= (( centroid.Xb  - cmax/2. ) - dc0)*Width;
		float ImgC	= (( (rmax-centroid.Yb)  - rmax/2. ) - dr0)*Height;
		std::complex<double> A(RealC, ImgC);
		//float A1 = abs(A) * ( 1 + k2*abs(A)) * 
		
		float y = std::real(-A);
		float z = std::imag(-A);

		float k = ( (-1.) / ((ABC1 * F) + (ABC2 * y) + (ABC3 * z)));
		float objco_x = k * F;
		float objco_y = k * y;
		float objco_z = k * z;
		
		float objro_x = m11 * objco_x + m12 * objco_y + m13 * objco_z + m14 * 1.;
		float objro_y = m21 * objco_x + m22 * objco_y + m23 * objco_z + m24 * 1.;
		float objro_z = m31 * objco_x + m32 * objco_y + m33 * objco_z + m34 * 1.;
		
		
		mvprintw(rtext, ctext + 70, "    position objet robot = (%3.1f, %3.1f) ",objro_x, objro_y);
		
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
	object_robot_position (rtext, ctext, centroid);
}

//entry point
int main(int argc, const char **argv)
{
    char fromkeyb[50];
    ColorParam colpar[4];
    int currcol; // current editable col (selected with 'x', 'y', 'z' or 'w')
    int currcomp; // current editable component (selected with 'r', 'g' or 'b')
    int currminmax; // current editable by '<' or '>' is: 0:min 1:max
    float step; // step for min or max change
    char filename[200];

    //init graphics and the camera
    InitGraphics();
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
	//int selected_texture = -1;
	int selected_texture = 0;
    
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
	bool do_pipeline = false;

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
    
    colpar[0].setCol ( 1 , 0 , 0 , IDCOL0 ); // rgba: RED  alpha indicates color number
    colpar[0].setMain( 1             ); // 1:r, 2:g, 3:b, 0:not used  Other components are divided by main
    colpar[0].setMin ( .3, 0 , 0 , 0 ); // rgba  G and B relative to R
    colpar[0].setMax ( 1 , .5, .5, 1 ); // rgba  G and B relative to R
    
    colpar[1].setCol ( 0 , .6, 0 , IDCOL1 ); // rgba: GREEN
    colpar[1].setMain(     2         ); // 1:r, 2:g, 3:b, 0:not used  Other components are divided by main
    colpar[1].setMin ( 0 , .3, 0 , 0 ); // rgba  R and B relative to G
    colpar[1].setMax ( .5, 1 , .5, 1 ); // rgba  R and B relative to G
    
    colpar[2].setCol ( 0 , 0 , 1 , IDCOL2 ); // rgba: BLUE
    colpar[2].setMain(         3     ); // 1:r, 2:g, 3:b, 0:not used  Other components are divided by main
    colpar[2].setMin ( 0 , 0 , .3, 0 ); // rgba  R and G relative to B
    colpar[2].setMax ( .5, .5, 1 , 1 ); // rgba  R and G relative to B
    
    colpar[3].setCol ( 1,  0,  1 , IDCOL3 ); // rgba: BLACK
    colpar[3].setMain(       2       ); // 1:r, 2:g, 3:b, 0:not used  Other components are divided by main
    colpar[3].setMin ( 0,  0,  0 , 0 ); // rgba  G and B relative to R
    colpar[3].setMax (100, .376, 100,  1 ); // rgba  G and B relative to R
    
    step=0.004; // step for min or max change

    
    // gng Load image FOR TEST only
    const char* testim_filename = "im_color_for_test.png";
    unsigned char* testim_image, testim2;
    if (argc>1) {  // Use test image    ex:  ./picam 1
        //load and decode
        unsigned testim_error;
        size_t testim_width, testim_height;
        testim_error = lodepng_decode32_file(&testim_image, &testim_width, &testim_height, testim_filename);
        if(testim_error) printf("decoder error %u: %s\n", testim_error, lodepng_error_text(testim_error));
        else //the pixels are now in the vector "testim_image", 4 bytes per pixel, ordered RGBARGBA..., use it as texture, draw it, ...
             for (long k=0; k<393216; k++) testim_image[k] = testim_image[k*4]; // place R first (only first color is used for Y)
        
    }
  
  int awbmode = 1; // gng
  int exposuremode = 0; // gng
  int setmode = 0; // Jeremy Bartholomeus
	
	for(int i = 1; i < 100000; i++)
	{
		int ch = getch();
        float Num;
        if (i==1) ch = 'x'; // for selection of first editable detection color
		if(ch != ERR)
		{
            if(ch == 'q')
                break;
            else switch(ch) {
                case 't':
                    selected_texture = (selected_texture+1)%(TEXTURE_GRID_ROWS*TEXTURE_GRID_ROWS);
                    break;
                case 's':
                    selected_texture = -1;
                    break;
                case 'd':
                    do_pipeline = !do_pipeline;
                    break;
                //case 'w': {
                case 'W': {
                    gngdetectcoltexture.Save("col_detected.rgba");
                    col_sxsy0_texture.Save("col_sxsy0.rgba");
                    col_nsss_cccc_textures[0].Save("col_nsss_cccc_0.rgba"); // brut content rgbargbargba... first line, second line, ...
                    col_nsss_cccc_textures[1].Save("col_nsss_cccc_1.rgba"); //   because png content given is not exactly the same as texture content
                    for(int lev = 2; lev <= 5; lev++) // For each level (2 to 5)
                    {
                        sprintf(filename, "col_nsss_cccc_%d.rgba", lev);
                        col_nsss_cccc_textures[lev].Save(filename);
                        sprintf(filename, "col_k_cccc_%d.rgba", lev);
                        col_k_cccc_textures[lev].Save(filename);
                    }
                    break;
                }
                case 'B': { // select next white Balance mode
                    /* {"off",           MMAL_PARAM_AWBMODE_OFF},   // char *mode, int mmal_mode
                       {"auto",          MMAL_PARAM_AWBMODE_AUTO},
                       {"sun",           MMAL_PARAM_AWBMODE_SUNLIGHT},
                       {"cloud",         MMAL_PARAM_AWBMODE_CLOUDY},
                       {"shade",         MMAL_PARAM_AWBMODE_SHADE},
                       {"tungsten",      MMAL_PARAM_AWBMODE_TUNGSTEN},
                       {"fluorescent",   MMAL_PARAM_AWBMODE_FLUORESCENT},
                       {"incandescent",  MMAL_PARAM_AWBMODE_INCANDESCENT},
                       {"flash",         MMAL_PARAM_AWBMODE_FLASH},
                       {"horizon",       MMAL_PARAM_AWBMODE_HORIZON} */
                    awbmode = awbmode++;
                    awbmode = awbmode % (sizeof(awb_map)/sizeof(awb_map[0]));
                    cam->setAWBmode(awb_map[awbmode].mmal_mode);
                    break;
                }
                case 'E': { // select next Exposure mode
                    /*  {"auto",          MMAL_PARAM_EXPOSUREMODE_AUTO},
                        {"night",         MMAL_PARAM_EXPOSUREMODE_NIGHT},
                        {"nightpreview",  MMAL_PARAM_EXPOSUREMODE_NIGHTPREVIEW},
                        {"backlight",     MMAL_PARAM_EXPOSUREMODE_BACKLIGHT},
                        {"spotlight",     MMAL_PARAM_EXPOSUREMODE_SPOTLIGHT},
                        {"sports",        MMAL_PARAM_EXPOSUREMODE_SPORTS},
                        {"snow",          MMAL_PARAM_EXPOSUREMODE_SNOW},
                        {"beach",         MMAL_PARAM_EXPOSUREMODE_BEACH},
                        {"verylong",      MMAL_PARAM_EXPOSUREMODE_VERYLONG},
                        {"fixedfps",      MMAL_PARAM_EXPOSUREMODE_FIXEDFPS},
                        {"antishake",     MMAL_PARAM_EXPOSUREMODE_ANTISHAKE},
                        {"fireworks",     MMAL_PARAM_EXPOSUREMODE_FIREWORKS} */
                    exposuremode = exposuremode++;
                    exposuremode = exposuremode % (sizeof(exposure_map)/sizeof(exposure_map[0]));
                    cam->setEXPOSUREmode(exposure_map[exposuremode].mmal_mode);
                    break;
                }
				case 'M':{ // select acquisition settings
					setmode = setmode++;
					setmode = setmode %(sizeof(set_map)/sizeof(set_map[0]));
					break;
				}
                // Typical keys sequence
                //  - select current color  'x', 'y', 'z' or 'w'
                //  - select color components 'c' (followed by values separated by <enter>)
                //  - select dominant component '1', '2', or '3' (or '0' for end of colors)
                //  - select component 'r', 'g' or 'b' for which modify max or min
                //  - select 'i' (lower min), 'I' (higher min), 'a' (lower max), 'A' (higher max)
                //  - '>' or '<' modify last of min or max by 10*step 
                case 'x': {
                    currcol = 0; // current editable col
                    break;
                }
                case 'y': {
                    currcol = 1;
                    break;
                }
                case 'z': {
                    currcol = 2;
                    break;
                }
                case 'w': {
                    currcol = 3;
                    break;
                }
                case 'r': {
                    currcomp = 0; // current editable component
                    break;
                }
                case 'g': {
                    currcomp = 1;
                    break;
                }
                case 'b': {
                    currcomp = 2;
                    break;
                }
                case 'c': { // replacement color if detection
                    getnstr(fromkeyb, 49);
                    if (strlen(fromkeyb)>0) {
                        sscanf(fromkeyb, "%f", &Num);
                        colpar[currcol].setCol(0, Num);
                    }
                    getnstr(fromkeyb, 49);
                    if (strlen(fromkeyb)>0) {
                        sscanf(fromkeyb, "%f", &Num);
                        colpar[currcol].setCol(1, Num);
                    }
                    getnstr(fromkeyb, 49);
                    if (strlen(fromkeyb)>0) {
                        sscanf(fromkeyb, "%f", &Num);
                        colpar[currcol].setCol(2, Num);
                    }
                    break;
                }
                case 'i': {
                    currminmax = 0;
                    colpar[currcol].setMin(currcomp, colpar[currcol].getMin(currcomp) - step);
                    break;
                }
                case 'I': {
                    currminmax = 0;
                    colpar[currcol].setMin(currcomp, colpar[currcol].getMin(currcomp) + step);
                    break;
                }
                case 'a': {
                    currminmax = 1;
                    colpar[currcol].setMax(currcomp, colpar[currcol].getMax(currcomp) - step);
                    break;
                }
                case 'A': {
                    currminmax = 1;
                    colpar[currcol].setMax(currcomp, colpar[currcol].getMax(currcomp) + step);
                    break;
                }
                case '>': {
                    if (currminmax)
                    {
                        colpar[currcol].setMax(currcomp, colpar[currcol].getMax(currcomp) + 10.0*step);
                    }
                    else
                    {
                        colpar[currcol].setMin(currcomp, colpar[currcol].getMin(currcomp) + 10.0*step);
                    }
                    break;
                }
                case '<': {
                    if (currminmax)
                    {
                        colpar[currcol].setMax(currcomp, colpar[currcol].getMax(currcomp) - 10.0*step);
                    }
                    else
                    {
                        colpar[currcol].setMin(currcomp, colpar[currcol].getMin(currcomp) - 10.0*step);
                    }
                    break;
                }
                case '0' ... '3': colpar[currcol].setMain(ch-'0'); //
                          // divby[currcol] is 0 : previous was the last color to test)
                          //                   1 : divide components g and b by r
                          //                   2 :                   r     b    g
                          //                   3 :                   r     g    b
            }

            mvprintw(1,40, " White Balance mode (key:'B') :  %s,   Exposure mode (key:'E') :  %s,   Settings mode(KEY:'M') : %s " , awb_map[awbmode].mode, exposure_map[exposuremode].mode, set_map[setmode].mode);
            int disprow = 2;
            for (int col=0; col<4; col++) {
                mvprintw(col+disprow,0, " Col %c :  R=%f, G=%f, B=%f    Main=%d   Min%c=%f Max%c=%f   Min%c=%f Max%c=%f   Min%c=%f Max%c=%f"
                    , colxyzw[col], colpar[col].getCol(0), colpar[col].getCol(1), colpar[col].getCol(2)
                    , colpar[col].getMain()
                    , colrgba[0], colpar[col].getMin(0), colrgba[0], colpar[col].getMax(0)
                    , colrgba[1], colpar[col].getMin(1), colrgba[1], colpar[col].getMax(1)
                    , colrgba[2], colpar[col].getMin(2), colrgba[2], colpar[col].getMax(2)
                );
                // on screen colors for characters
                if (col!=currcol) {
                    attron(COLOR_PAIR(1)); // color xyzw not selected
                    mvprintw(col+disprow,5, "%c", colxyzw[col]);
                    attroff(COLOR_PAIR(1));
                }
                else {
                    attron(COLOR_PAIR(2)); // color xyzw selected
                    mvprintw(col+disprow,5, "%c", colxyzw[col]);
                    attroff(COLOR_PAIR(2));
                    // on screen color for i R
                    iColPair = 3 + (!currminmax && (currcomp==0)); // 3: Red not selected, 4: Red selected
                    attron(COLOR_PAIR(iColPair));
                    mvprintw(col+disprow,58, "i");
                    mvprintw(col+disprow,60, "r");
                    attroff(COLOR_PAIR(iColPair));
                    // on screen color for a R
                    iColPair = 3 + (currminmax && (currcomp==0)); // 3: Red not selected, 4: Red selected
                    attron(COLOR_PAIR(iColPair));
                    mvprintw(col+disprow,72, "a");
                    mvprintw(col+disprow,74, "r");
                    attroff(COLOR_PAIR(iColPair));
                    // on screen color for i G
                    iColPair = 5 + (!currminmax && (currcomp==1)); // 5: Green not selected, 6: Green selected
                    attron(COLOR_PAIR(iColPair));
                    mvprintw(col+disprow,88, "i");
                    mvprintw(col+disprow,90, "g");
                    attroff(COLOR_PAIR(iColPair));
                    // on screen color for a G
                    iColPair = 5 + (currminmax && (currcomp==1)); // 5: Green not selected, 6: Green selected
                    attron(COLOR_PAIR(iColPair));
                    mvprintw(col+disprow,102, "a");
                    mvprintw(col+disprow,104, "g");
                    attroff(COLOR_PAIR(iColPair));
                    // on screen color for i B
                    iColPair = 7 + (!currminmax && (currcomp==2)); // 7: Blue not selected, 8: Blue selected
                    attron(COLOR_PAIR(iColPair));
                    mvprintw(col+disprow,118, "i");
                    mvprintw(col+disprow,120, "b");
                    attroff(COLOR_PAIR(iColPair));
                    // on screen color for a B
                    iColPair = 7 + (currminmax && (currcomp==2)); // 7: Blue not selected, 8: Blue selected
                    attron(COLOR_PAIR(iColPair));
                    mvprintw(col+disprow,132, "a");
                    mvprintw(col+disprow,134, "b");
                    attroff(COLOR_PAIR(iColPair));
                }
            }

            mvprintw(0,0,"  ");
            move(0,0);
			refresh();
		}

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
			//int upos = ysize+16*uvpitch;
			//int vpos = upos+uvsize+4*uvpitch;
			int upos = ysize;
			int vpos = upos+uvsize;
			//printf("Frame data len: 0x%x, ypitch: 0x%x ysize: 0x%x, uvpitch: 0x%x, uvsize: 0x%x, u at 0x%x, v at 0x%x, total 0x%x\n", frame_sz, ypitch, ysize, uvpitch, uvsize, upos, vpos, vpos+uvsize);
			if (argc>1) ytexture.SetPixels(testim_image, CheckGL); else // gng FOR TEST ONLY
            ytexture.SetPixels(data, CheckGL);
			utexture.SetPixels(data+upos, CheckGL);
			vtexture.SetPixels(data+vpos, CheckGL);
			cam->EndReadFrame(0);
		}

		//begin frame, draw the texture then end frame (the bit of maths just fits the image to the screen while maintaining aspect ratio)
		BeginFrame(CheckGL);
		float aspect_ratio = float(MAIN_TEXTURE_WIDTH)/float(MAIN_TEXTURE_HEIGHT);
		float screen_aspect_ratio = 1280.f/720.f;
		//X150225 for(int texidx = 0; texidx<levels; texidx++)
		//X150225 	DrawYUVTextureRect(&ytexture,&utexture,&vtexture,-1.f,-1.f,1.f,1.f,CheckGL, &rgbtextures[texidx]);

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

		if(!do_pipeline)
		{
			if(selected_texture == -1)
			{
				for(int row = 0; row < TEXTURE_GRID_ROWS; row++)
				{
					for(int col = 0; col < TEXTURE_GRID_COLS; col++)
					{		
						if(GfxTexture* tex = texture_grid[col+row*TEXTURE_GRID_COLS])
						{
							if ( (row*TEXTURE_GRID_COLS + col) < next_texture_grid_entry) {
                                float colx = -1.f+col*texture_grid_col_size;
                                float rowy = -1.f+row*texture_grid_row_size;
                                DrawTextureRect(tex,colx,rowy,colx+texture_grid_col_size,rowy+texture_grid_row_size,CheckGL, NULL);
                            }
						}				
					}
				}
			}
			else
			{
				if(GfxTexture* tex = texture_grid[selected_texture]) // Jérémy Bartholomeus
                {
					

                   if(setmode == 1) // Jérémy Bartholomeus
				   {
						//X150416 DrawTextureRect(tex,-1,-1,1,1,CheckGL, NULL);
						DrawTextureRect(tex,-1,1,1,-1,CheckGL, NULL);
				   
						// A first zone of interest  (for red object)                //   0 1 2 3 4 5 6 7 8 9¹0¹1
						int level = 1; // 3 = (12x8)   1 = (48x24)                   // 0 . . . . . . . . . . . .
						int r0=25;     // first row of polygonal zone where is object// 1 . . . ? ? ? . . . . . .
						int cFirst[] = {30, 29, 28, 29, 30};                         // 2 . . ? ? ? ? ? . . . . .
						int cLast[]  = {31, 32, 33, 32, 31};                         // 3 . ? ? ? Ø Ø ? ? . . . .
						int nr = sizeof(cFirst)/sizeof(cFirst[0]);                   // 4 . ? ? ? Ø Ø ? ? . . . .
						int icolor=3; // 0: first color for object to detect (red)   // 5 . . ? ? ? ? ? . . . . .
						int k10max = 20;                                             // 6 . . . ? ? ? . . . . . .
						int textcolor = 3; // 3:red, 5:green, 7:blue                 // 7 . . . . . . . . . . . .
						int rtext = 6;
						int ctext = 10;
						XYB_TB centroid[4]; // struct XYB_TB defined above
						objectPosition(icolor, tex32nssscccc[level], level, r0, nr, cFirst, cLast, k10max, textcolor, rtext, ctext, centroid[0]);

						// A second zone of interest  (for a green object)
						level = 1; // (48x24)
						r0=21;     // first row of polygonal zone where is object
						int cFirst1[] = {9, 8,  7, 8, 9};
						int cLast1[]  = {10, 11, 12, 11, 10};
						nr = sizeof(cFirst1)/sizeof(cFirst1[0]);
						icolor=3; // 1: second color for object to detect (green)
						k10max = 20;
						textcolor = 5; // 3:red, 5:green, 7:blue
						rtext = 7;
						ctext = 10;
						objectPosition(icolor, tex32nssscccc[level], level, r0, nr, cFirst1, cLast1, k10max, textcolor, rtext, ctext, centroid[1]);
					
						// A third zone of interest  (for a blue object)
						level = 1; // (48x24)
						r0=8;     // first row of polygonal zone where is object
						int cFirst2[] = {11, 10,  9, 10, 11};
						int cLast2[]  = {12, 13, 14, 13, 12};
						nr = sizeof(cFirst2)/sizeof(cFirst2[0]);
						icolor=3; // 2: third color for object to detect (blue)
						k10max = 20;
						textcolor = 7; // 3:red, 5:green, 7:blue
						rtext = 8;
						ctext = 10;
						objectPosition(icolor, tex32nssscccc[level], level, r0, nr, cFirst2, cLast2, k10max, textcolor, rtext, ctext, centroid[2]);
					
						// A fourth zone of interest (for a black point)
						level = 1;
						r0=14;
						int cFirst3[] = {40, 39, 38, 39, 40};
						int cLast3[]  = {41, 42, 43, 42, 41};
						nr = sizeof(cFirst3)/sizeof(cFirst3[0]);
						icolor=3; // 3: fourth color for object to detect (black)
						k10max = 20;
						textcolor = 7; // 3:red, 5:green, 7:blue
						rtext = 9;
						ctext = 10;
						objectPosition(icolor, tex32nssscccc[level], level, r0, nr, cFirst3, cLast3, k10max, textcolor, rtext, ctext, centroid[3]);
					}
					
					else if(setmode == 0) //Jérémy Bartholomeus
					{
						//X150416 DrawTextureRect(tex,-1,-1,1,1,CheckGL, NULL);
						DrawTextureRect(tex,-1,1,1,-1,CheckGL, NULL);
					
						// zone of interest  (for a green object)
						int level = 1; // (48x24)
						int r0=6;     // first row of polygonal zone where is object
						int cFirst[] = {  1,   1,   1,   1,   1,  1,   1,   1,   1,   1,  1,   1,   1,   1,   1,  1,   1,   1,   1,   1,  1};
						int cLast[]  = {45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45};
						int nr = sizeof(cFirst)/sizeof(cFirst[0]);
						int icolor=1; // 1: second color for object to detect (green)
						int k10max = 20;
						int textcolor = 5; // 3:red, 5:green, 7:blue
						int rtext = 7;
						int ctext = 10;
						XYB_TB centroid[1];
						objectPosition(icolor, tex32nssscccc[level], level, r0, nr, cFirst, cLast, k10max, textcolor, rtext, ctext, centroid[0]);
					}
                }
			}
		}
		else
		{
			/*DrawMedianRect(&ytexture,-1.f,-1.f,1.f,1.f,&mediantexture);
			DrawSobelRect(&mediantexture,-1.f,-1.f,1.f,1.f,&sobeltexture);
			DrawErodeRect(&sobeltexture,-1.f,-1.f,1.f,1.f,&erodetexture);
			//DrawDilateRect(&erodetexture,-1.f,-1.f,1.f,1.f,&dilatetexture);
			DrawThreshRect(&erodetexture,-1.f,-1.f,1.f,1.f,0.05f,0.05f,0.05f,&threshtexture);
			DrawTextureRect(&threshtexture,-1,-1,1,1,NULL);
			*/
		}

		EndFrame(CheckGL);


        //read current time  gng
        if((i%10)==0)
        {
            clock_gettime(CLOCK_REALTIME, &gettime_now);
            time_diff = difftime(gettime_now.tv_sec, start_time_t);
            time_difference = gettime_now.tv_nsec - start_time;
            start_time_t = gettime_now.tv_sec;
            start_time = gettime_now.tv_nsec;
            float fr = float(double(10)/(double(time_diff) + double(time_difference)/1000000000.0));
            mvprintw(0,0,"   Framerate: %g",fr); // gng: perhaps problem with \n if I well understand  http://repo.hackerzvoice.net/depot_madchat/coding/c/c.scene/cs3/CS3-08.html
            move(0,0);
            refresh();
        }
        
        CheckGL = false; // no more check

	}

	StopCamera();

	endwin();
}
