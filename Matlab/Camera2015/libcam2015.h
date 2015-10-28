//
// MATLAB Compiler: 4.4 (R2006a)
// Date: Thu Apr 23 02:15:11 2015
// Arguments: "-B" "macro_default" "-W" "cpplib:libcam2015" "-T" "link:lib"
// "xfyz2objco.m" 
//

#ifndef __libcam2015_h
#define __libcam2015_h 1

#if defined(__cplusplus) && !defined(mclmcr_h) && defined(__linux__)
#  pragma implementation "mclmcr.h"
#endif
#include "mclmcr.h"
#include "mclcppclass.h"
#ifdef __cplusplus
extern "C" {
#endif

#if defined(__SUNPRO_CC)
/* Solaris shared libraries use __global, rather than mapfiles
 * to define the API exported from a shared library. __global is
 * only necessary when building the library -- files including
 * this header file to use the library do not need the __global
 * declaration; hence the EXPORTING_<library> logic.
 */

#ifdef EXPORTING_libcam2015
#define PUBLIC_libcam2015_C_API __global
#else
#define PUBLIC_libcam2015_C_API /* No import statement needed. */
#endif

#define LIB_libcam2015_C_API PUBLIC_libcam2015_C_API

#elif defined(_HPUX_SOURCE)

#ifdef EXPORTING_libcam2015
#define PUBLIC_libcam2015_C_API __declspec(dllexport)
#else
#define PUBLIC_libcam2015_C_API __declspec(dllimport)
#endif

#define LIB_libcam2015_C_API PUBLIC_libcam2015_C_API


#else

#define LIB_libcam2015_C_API

#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_libcam2015_C_API 
#define LIB_libcam2015_C_API /* No special import/export declaration */
#endif

extern LIB_libcam2015_C_API 
bool MW_CALL_CONV libcam2015InitializeWithHandlers(mclOutputHandlerFcn error_handler,
                                                   mclOutputHandlerFcn print_handler);

extern LIB_libcam2015_C_API 
bool MW_CALL_CONV libcam2015Initialize(void);

extern LIB_libcam2015_C_API 
void MW_CALL_CONV libcam2015Terminate(void);


extern LIB_libcam2015_C_API 
bool MW_CALL_CONV mlxXfyz2objco(int nlhs, mxArray *plhs[],
                                int nrhs, mxArray *prhs[]);

#ifdef __cplusplus
}
#endif

#ifdef __cplusplus

/* On Windows, use __declspec to control the exported API */
#if defined(_MSC_VER) || defined(__BORLANDC__)

#ifdef EXPORTING_libcam2015
#define PUBLIC_libcam2015_CPP_API __declspec(dllexport)
#else
#define PUBLIC_libcam2015_CPP_API __declspec(dllimport)
#endif

#define LIB_libcam2015_CPP_API PUBLIC_libcam2015_CPP_API

#else

#if !defined(LIB_libcam2015_CPP_API)
#if defined(LIB_libcam2015_C_API)
#define LIB_libcam2015_CPP_API LIB_libcam2015_C_API
#else
#define LIB_libcam2015_CPP_API /* empty! */ 
#endif
#endif

#endif

extern LIB_libcam2015_CPP_API void MW_CALL_CONV xfyz2objco(int nargout
                                                           , mwArray& objco
                                                           , const mwArray& xf
                                                           , const mwArray& imyz
                                                           , const mwArray& ref);

#endif

#endif
