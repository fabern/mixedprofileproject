/////////////////////////////////////////////////////////////
// start suggestion Copilot
/////////////////////////////////////////////////////////////
//#include <Rcpp.h>
//
// extern "C" {
//   void myfortran_(int* x);
// }
//
// using namespace Rcpp;
//
// // [[Rcpp::export]]
// void call_fortran(int x) {
//   myfortran_(&x);
// }
/////////////////////////////////////////////////////////////
// end suggestion Copilot
/////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////
// biomee
/////////////////////////////////////////////////////////////
#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <Rmath.h>
#include <R_ext/Rdynload.h>

void biomee_f_( // this directly declares C-compatible function name that matches bind(C, name = "biomee_f_")
    double *params_siml,
    int    *nt_daily,
    int    *n_lu,
    double *x,
    double *init_lu,
    double *output_daily_tile
);

// C wrapper function for biomee
extern SEXP biomee_f_C(
    SEXP params_siml,
    SEXP init_lu,
    SEXP n_daily,
    SEXP x
){

  // Number of time steps (same in forcing and output)
  int nt_daily = asInteger(n_daily);
  double x_val = asReal(x);  // Convert SEXP to double
  int n_lu;
  SEXP Rdim;

  // Extracting array dimensions (they need to be passed to fortran separately)
  // To extract the 1st dimension size: x = asInteger(Rdim);
  // To extract the nth dimension size: x = INTEGER(Rdim)[n-1]
  Rdim = getAttrib(init_lu,R_DimSymbol);
  n_lu = asInteger(Rdim);

  // Output list
  SEXP out_list = PROTECT( allocVector(VECSXP, 1) );

  /******* Output sub-lists *******/
  SEXP output_daily_tile             = PROTECT( alloc3DArray(REALSXP, nt_daily,  36, n_lu) );
  /****************/

  // Fortran subroutine call
  biomee_f_(
      REAL(params_siml),
      &nt_daily,
      &n_lu,
      &x_val,  // Pass address of converted double value
      REAL(init_lu),
      REAL(output_daily_tile)
  );

  SET_VECTOR_ELT(out_list, 0, output_daily_tile);

  UNPROTECT(2);

  return out_list;
}

/////////////////////////////////////////////////////////////
// Declarations for all functions
/////////////////////////////////////////////////////////////
static const R_CallMethodDef CallEntries[] = {
  {"biomee_f_C",   (DL_FUNC) &biomee_f_C,   4},  // Number of arguments of the C wrapper function for biomee (the SEXP variables, not the output)
  { NULL,          NULL,                    0 }
};

void R_init_mixedprofileproject(DllInfo *dll)
{
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
