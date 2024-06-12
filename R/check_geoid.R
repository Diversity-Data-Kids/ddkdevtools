#' @name check_geoid
#' @title check_geoid
#' @author Clemens Noelke
#'
#' @description
#' Checks if dt contains only census tracts as defined for the 2010 (or 2020) census in the 50+1 US states.
#'
#' This function loads the 2010 (2020) census tract FIPS codes From DDK.TRACTS and checks
#' if dt contains any census tract FIPS codes that did not exist in 2010 (2020) in the 50+1 US states.
#' The function returns a data table with the following columns: geoid, data1, data2
#' data1 indicates if an observation was included in the test data table dt
#' data2 indicates if an observation was included in the reference data table.
#' If data2 is NA, the observation was not included in the reference data table
#' and therefore is not a 2010 (2020) census tract.
#'
#' Will always load the reference data table DDK.TRACTS from SQL database.
#'
#' @param dt Data table to be tested. Must contain a column named geoid containing
#' 11-character census tract FIPS codes.
#' @param year Integer with 4-digit calendar year for reference table, usually 2010 or 2020.

check_geoid <- function(dt=NULL, year=NULL) {

  # Checks
  if(is.null(dt))   stop("dt is required")
  if(is.null(year)) stop("year is required")

  # Load reference table, only returns single column (geoid) with 2010 data
  ref <- SQL_load("DDK", "TRACTS", columns="geoid", filter=paste0("year=", year), overwrite=T, noisily=F)

  # Test merge, returning merge variables data1 and data2
  dt <- check_merge(dt, ref, "geoid", "outer", abort=F, keep_merge_vars=T, noisily=F)

  # Subset
  dt <- dt[, .(geoid, data1, data2)]

  # Print test results
  if (nrow(dt[is.na(data2)])>0) warning(paste0("dt has non-", year," census tract FIPS codes. Use chk[, .N, by=.(data1, data2)] to tabulate and is.na(data2) to filter those from the return data table."))
  else print(paste0("dt has only ", year, " census tract FIPS codes."))

  return(dt)

}
