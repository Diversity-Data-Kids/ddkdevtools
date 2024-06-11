#' @name check_geoid10
#' @title check_geoid10
#' @author Clemens Noelke
#'
#' @description
#' Checks if dt contains only census tracts as defined for the 2010 census.
#' Between 2010 and 2019, there were some changes in census tract FIPS codes.
#' This function loads the 2010 census tract FIPS codes From DDK.TRACTS and checks
#' if dt contains any census tract FIPS codes that did not exist in 2010.
#' The function returns a data table with the following columns: geoid, data1, data2
#' data1 indicates if an observation was included in the test data table dt
#' data2 indicates if an observation was included in the reference data table.
#' If data2 is NA, the observation was not included in the reference data table
#' and therefore is not a 2010 census tract.
#'
#' Will always load the reference data table DDK.TRACTS from SQL database.
#'
#' @param dt Data table to be tested. Must contain a column named geoid containing
#' 11-character census tract FIPS codes.

check_geoid10 <- function(dt=NULL) {

  # Load reference table, only returns single column (geoid) with 2010 data
  ref <- SQL_load("DDK", "TRACTS", columns="geoid", filter="year=2010", overwrite=T, noisily=F)

  # Test merge, returning merge variables data1 and data2
  dt <- check_merge(dt, ref, "geoid", "outer", abort=F, keep_merge_vars=T, noisily=F)

  # Subset
  dt <- dt[, .(geoid, data1, data2)]

  # Print test results
  if (nrow(dt[is.na(data2)])>0) warning("dt has non-2010 geoids. Use is.na(data2) to identify non-2010 geoids.")
  else print("dt has only 2010 geoids.")

  return(dt)

}
