#include <position_objet_robot.h>
#include <cmath>
#include <complex> 

	// on rempli ici toutes les variables fournies par l'étalonnage
	
	Width = 0.0095;		// taille pixel
	Height = 0.0106
	H = 0;					// hauteur des pièces
	F = 3.6;				//distance focale
	k2 = 0;					// distortion
	cmax = 384; 		// nbr pixel
	rmax = 256;
	dc0 = 0;				//règlage centre caméra
	dr0 = 0;
	ABC1 = -0.0013;	// coord plan // a la table
	ABC2 = 1.2801*0.001
	ABC3 = 0.0015;
	m11 =  -0.3321;	m12 = -0.9204;	    m13 = -0.2065; 	m14 =  686.3653;  // matrice rotation
	m21 =   0.7043; 	m22 = -0.3876; 	m23 =  0.5948; 	m24 = -357.4462;
	m31 =  -0.6274;	m32 =  0.0521; 	m33 =  0.7769; 	m34 =   497.0989;
	m41 =   		 0;    m42 = 		    0;		m43 =    	   0;		m44 =				1;
	
	position(float centro_x, float, centro_y)
	{
		RealC	= ((centro_x - cmax)/2 ) - dc0;
		ImgC	= ((centro_y - rmax)/2 ) - dr0;
		float A 	= polar(RealC, ImgC);
		float A1 = A * ( 1 + k2*abs(A1));
		
		float y = real(A1);
		float z = img(A1);

		k = ( (-1) / ((ABC1 * F) + (ABC2 * y) + (ABC3 * z)));
		float objco_x = k * F;
		float objco_y = k * y;
		float objco_z = k * z;
		
		float objro_x = m11 * objco_x + m12 * objco_y + m13 * objco_z + m14 * 1;
		float objro_y = m21 * objco_x + m22 * objco_y + m23 * objco_z + m24 * 1;
		float objro_z = m31 * objco_x + m32 * objco_y + m33 * objco_z + m34 * 1;
	
	}
	
