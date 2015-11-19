//
// MATLAB Compiler: 4.4 (R2006a)
// Date: Thu Apr 23 02:15:11 2015
// Arguments: "-B" "macro_default" "-W" "cpplib:libcam2015" "-T" "link:lib"
// "xfyz2objco.m" 
//

#include <stdio.h>
#define EXPORTING_libcam2015 1
#include "libcam2015.h"
#ifdef __cplusplus
extern "C" {
#endif

extern mclComponentData __MCC_libcam2015_component_data;

#ifdef __cplusplus
}
#endif


static HMCRINSTANCE _mcr_inst = NULL;


#if defined( _MSC_VER) || defined(__BORLANDC__) || defined(__WATCOMC__) || defined(__LCC__)
#include <windows.h>

static char path_to_dll[_MAX_PATH];

BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, void *pv)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        char szDllPath[_MAX_PATH];
        char szDir[_MAX_DIR];
        if (GetModuleFileName(hInstance, szDllPath, _MAX_PATH) > 0)
        {
             _splitpath(szDllPath, path_to_dll, szDir, NULL, NULL);
            strcat(path_to_dll, szDir);
        }
	else return FALSE;
    }
    else if (dwReason == DLL_PROCESS_DETACH)
    {
    }
    return TRUE;
}
#endif
static int mclDefaultPrintHandler(const char *s)
{
    return fwrite(s, sizeof(char), strlen(s), stdout);
}

static int mclDefaultErrorHandler(const char *s)
{
    int written = 0, len = 0;
    len = strlen(s);
    written = fwrite(s, sizeof(char), len, stderr);
    if (len > 0 && s[ len-1 ] != '\n')
        written += fwrite("\n", sizeof(char), 1, stderr);
    return written;
}


/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_libcam2015_C_API 
#define LIB_libcam2015_C_API /* No special import/export declaration */
#endif

LIB_libcam2015_C_API 
bool MW_CALL_CONV libcam2015InitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler
)
{
    if (_mcr_inst != NULL)
        return true;
    if (!mclmcrInitialize())
        return false;
    if (!mclInitializeComponentInstance(&_mcr_inst,
                                        &__MCC_libcam2015_component_data,
                                        true, NoObjectType, LibTarget,
                                        error_handler, print_handler))
        return false;
    return true;
}

LIB_libcam2015_C_API 
bool MW_CALL_CONV libcam2015Initialize(void)
{
    return libcam2015InitializeWithHandlers(mclDefaultErrorHandler,
                                            mclDefaultPrintHandler);
}

LIB_libcam2015_C_API 
void MW_CALL_CONV libcam2015Terminate(void)
{
    if (_mcr_inst != NULL)
        mclTerminateInstance(&_mcr_inst);
}


LIB_libcam2015_C_API 
bool MW_CALL_CONV mlxXfyz2objco(int nlhs, mxArray *plhs[],
                                int nrhs, mxArray *prhs[])
{
    return mclFeval(_mcr_inst, "xfyz2objco", nlhs, plhs, nrhs, prhs);
}

LIB_libcam2015_CPP_API 
void MW_CALL_CONV xfyz2objco(int nargout, mwArray& objco, const mwArray& xf
                             , const mwArray& imyz, const mwArray& ref)
{
    mclcppMlfFeval(_mcr_inst, "xfyz2objco", nargout,
                   1, 3, &objco, &xf, &imyz, &ref);
}
