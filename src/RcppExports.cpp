// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <RcppEigen.h>
#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif


RcppExport SEXP _rcpp_module_boot_stan_fit4beta_zero_one_mod();
RcppExport SEXP _rcpp_module_boot_stan_fit4or_fairness_mod();
RcppExport SEXP _rcpp_module_boot_stan_fit4poisson_zero_mod();
RcppExport SEXP _rcpp_module_boot_stan_fit4pp_error_mod();
RcppExport SEXP _rcpp_module_boot_stan_fit4pp_taint_mod();

static const R_CallMethodDef CallEntries[] = {
    {"_rcpp_module_boot_stan_fit4beta_zero_one_mod", (DL_FUNC) &_rcpp_module_boot_stan_fit4beta_zero_one_mod, 0},
    {"_rcpp_module_boot_stan_fit4or_fairness_mod", (DL_FUNC) &_rcpp_module_boot_stan_fit4or_fairness_mod, 0},
    {"_rcpp_module_boot_stan_fit4poisson_zero_mod", (DL_FUNC) &_rcpp_module_boot_stan_fit4poisson_zero_mod, 0},
    {"_rcpp_module_boot_stan_fit4pp_error_mod", (DL_FUNC) &_rcpp_module_boot_stan_fit4pp_error_mod, 0},
    {"_rcpp_module_boot_stan_fit4pp_taint_mod", (DL_FUNC) &_rcpp_module_boot_stan_fit4pp_taint_mod, 0},
    {NULL, NULL, 0}
};

RcppExport void R_init_jfa(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
