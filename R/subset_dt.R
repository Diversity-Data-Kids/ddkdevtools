#' @name subset_dt
#' @title subset_dt
#' @author Clemens Noelke
#'
#' @description
#' easy way to subset a data.table by column names without data.table syntax
#'
#' @param dt data.table
#' @param cols character vector of column names

subset_dt <- function(dt=NULL, cols=NULL) {

  # Check that cols exist in both datasets
  names_dt <- names(dt)
  for(k in 1:length(cols)) {
    if ( any( str_detect(names_dt, cols[k]) )==F ) stop(paste0(cols[k], " is not in dt"))
  }
  rm(k)

  # Check that dt is a data.table
  if ( all(class(dt)==c("data.table","data.frame"))==F ) stop("dt is not a data.table")

  return(dt[,..cols])

}
