#Function that iterates over adm level starting with the most detailed and
#update cl so it is in line with pa.
harmonize_cl <- function(df, ac, param) {
  if (param$solve_level == 0) {
    for (i in param$adm_level:0) {
      problem_adm <- check_cl(df = df, adm_lvl =  i, ac, param)
      df <- update_cl(df, problem_adm = problem_adm, adm_lvl = i)
    }
  }
  if (param$solve_level == 1) {
    for (i in param$adm_level:1) {
      problem_adm <- check_cl(df = df, adm_lvl =  i, ac, param)
      df <- update_cl(df, problem_adm = problem_adm, adm_lvl = i)
    }
  }
  return(df)
}
