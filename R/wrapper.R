#' Run C and Fortran code
#'#'
#' @param x A single integer to be passed into C/Fortran.
#' @export
#' @useDynLib mixedprofileproject
#'
#' @examples
#' \donttest{
#' # Example C/Fortran run
#'
#' call_mixed(
#'   x = 12
#' )
#' }

call_mixed <- function(x) {
  require(tibble)
  require(dplyr)

  ## Prepare input data
  params_siml <- structure(
    list(
      spinupyears = 0, recycle = 1, firstyeartrend = 2009,
      nyeartrend = 251, steps_per_day = 1, do_U_shaped_mortality = TRUE,
      do_closedN_run = FALSE),
    row.names = c(NA, -1L), class = c("tbl_df", "tbl", "data.frame"))
  params_siml <- params_siml |> mutate(spinup = spinupyears > 0)
  init_lu <- data.frame(name=c('primary'), fraction=c(1.0))

  ndayyear <- 365
  n_daily  <- params_siml$nyeartrend * ndayyear

  # init_cohort <- structure(
  #   list(
  #     init_cohort_species = 2, init_cohort_nindivs = 0.05,
  #     init_cohort_bl = 0, init_cohort_br = 0, init_cohort_bsw = 0.05,
  #     init_cohort_bHW = 0, init_cohort_seedC = 0, init_cohort_nsc = 0.05,
  #     lu_index = 0),
  #   class = c("tbl_df", "tbl", "data.frame"), row.names = c(NA,-1L))

  ## C wrapper call (using prepped data)
  biomeeout <- .Call(
    'biomee_f_C',
    params_siml      = as.matrix(prepare_params_siml(params_siml)),
    init_lu          = as.matrix(prepare_init_lu(init_lu)),
    n_daily          = as.integer(n_daily),
    x                = x
  )

  ## Prepare output data
  out <- biomeeout # build_out_biomee()

  return(out)
}

prepare_params_siml <- function(params_siml){
  require(dplyr)

  params_siml <- params_siml %>% select(
    "spinup", # Dummy argument
    "spinupyears",
    "recycle",
    "firstyeartrend",
    "nyeartrend",
    "steps_per_day",
    "do_U_shaped_mortality",
    "do_closedN_run"
  )

  return(params_siml)
}

prepare_init_lu <- function(init_lu){
  require(dplyr)

  if(!'preset' %in% names(init_lu)) {
    init_lu <- init_lu %>% mutate(preset = 'unmanaged')
  }
  if(!'extra_N_input' %in% names(init_lu)) {
    init_lu <- init_lu %>% mutate('extra_N_input' = case_match(
      'preset',
      "cropland" ~ 0.01,
      .default = 0.0
    ))
  }
  if(!'extra_turnover_rate' %in% names(init_lu)) {
    init_lu <- init_lu %>% mutate('extra_turnover_rate' = case_match(
      'preset',
      "cropland" ~ 0.2,
      .default = 0.0
    ))
  }
  if(!'oxidized_litter_fraction' %in% names(init_lu)) {
    init_lu <- init_lu %>% mutate('oxidized_litter_fraction' = case_match(
      'preset',
      "cropland" ~ 0.9,
      "pasture" ~ 0.4,
      .default = 0.0
    ))
  }
  init_lu <- init_lu %>% mutate(
    'vegetated' = case_match(
      'preset',
      "urban" ~ FALSE,
      .default = TRUE
    )
  )
  init_lu <- init_lu %>% select(
    'fraction',
    'vegetated',
    'extra_N_input',
    'extra_turnover_rate',
    'oxidized_litter_fraction'
  )

  return(init_lu)
}
