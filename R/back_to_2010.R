#' @name back_to_2010
#' @title back_to_2010
#' @author Clemens Noelke
#'
#' @description
#' Crosswalks 2011 to 2019 census tract FIPS codes to 2010 census tract FIPS codes.
#' After 2010, the census tracts defined for the 2010 census changed in some states.
#' In almost all instances, those changes did not result in different boundaries,
#' just different FIPS codes (see Appendix 6 to COI 3.0 technical documentation).
#' This function crosswalks the new FIPS codes that appeared between 2011 and 2019
#' back to their 2010 FIPS codes. Only works for 2010 census tracts.
#'
#' The function accepts a data.table as an input and returns a data.table with geoid_new
#' added, containing the 2010 FIPS codes. The rows need to be uniquely identified by geoid_name.
#' The data.table cannot contain the following columns: tract, county, tract_stub, tract_copy.
#'
#' @param dt data.table
#' @param geoid_name name of the column with the 11-digit census tract FIPS code

back_to_2010 <- function(dt=NULL, geoid_name=NULL) {

  ### Checks

  # Check that data1 and data2 don't exist in either data1 and data2
  if ( "county"     %in% colnames(dt)) stop("Column county     already exists in dt")
  if ( "tract_stub" %in% colnames(dt)) stop("Column tract_stub already exists in dt")
  if ( "tract_copy" %in% colnames(dt)) stop("Column tract_copy already exists in dt")

  # Convert data1 and data2 to data.table
  dt <- as.data.table(dt)

  # Rename geoid to tract
  setnames(dt, geoid_name, "tract")
  if (nrow(dt)!=nrow(unique(dt, by="tract"))) stop("Rows not uniquely identified by tract column.")

  # Take backup
  dt$tract_copy <- dt$tract

  ### Recode tract IDs that changed after 2010 back to their 2010 ID
  dt$county     <- substr(dt$tract, 1,5)
  dt$tract_stub <- substr(dt$tract, 6,11)

  # Need to reverse county code changes
  dt$county <- replace(dt$county, dt$county=="02158", "02270") # 02270 changed code to 02158 (July 1, 2015
  dt$county <- replace(dt$county, dt$county=="46102", "46113") # 46113 changed code to 46102 (May 1, 2015)
  dt$tract  <-  ifelse(dt$county %in% c("02270","46113"), paste0(dt$county, dt$tract_stub), dt$tract)

  # Census tracts renumbered in Pima County, AZ
  # Year  2010 GEOID  New GEOID
  # 2012	04019002701	04019002704	27.01 is now 27.04
  # 2012	04019002903	04019002906	29.03 is now 29.06
  # 2012	04019410501	04019004118	4105.01 is now 41.18
  # 2012	04019410502	04019004121	4105.02 is now 41.21
  # 2012	04019410503	04019004125	4105.03 is now 41.25
  # 2012	04019470400	04019005200	4704.00 is now 52.00
  # 2012	04019470500	04019005300	4705.00 is now 53.00
  dt$tract <- replace(dt$tract, dt$tract=="04019002704", "04019002701")
  dt$tract <- replace(dt$tract, dt$tract=="04019002906", "04019002903")
  dt$tract <- replace(dt$tract, dt$tract=="04019004118", "04019410501")
  dt$tract <- replace(dt$tract, dt$tract=="04019004121", "04019410502")
  dt$tract <- replace(dt$tract, dt$tract=="04019004125", "04019410503")
  dt$tract <- replace(dt$tract, dt$tract=="04019005200", "04019470400")
  dt$tract <- replace(dt$tract, dt$tract=="04019005300", "04019470500")

  # Geographic definition changed very slightly, resulting in new code
  # Year  2010 GEOID  New GEOID
  # 2011	36065940200	36065024900	Geographic definition changed
  dt$tract <- replace(dt$tract, dt$tract=="36065024900", "36065940200")

  # Census tracts renumbered in Madison County, NY
  # Year  2010 GEOID  New GEOID
  # 2011	36053940101	36053030101	9401.01 is now 0301.01
  # 2011	36053940102	36053030102	9401.02 is now 0301.02
  # 2011	36053940103	36053030103	9401.03 is now 0301.03
  # 2011	36053940200	36053030200	9402.00 is now 0302.00
  # 2011	36053940300	36053030300	9403.00 is now 0303.00
  # 2011	36053940401	36053030401	9404.01 is now 0304.01
  # 2011	36053940700	36053030402	9407.00 is now 0304.02
  # 2011	36053940403	36053030403	9404.03 is now 0304.03
  # 2011	36053940600	36053030600	9406.00 is now 0306.00
  dt$tract <- replace(dt$tract, dt$tract=="36053030101", "36053940101")
  dt$tract <- replace(dt$tract, dt$tract=="36053030102", "36053940102")
  dt$tract <- replace(dt$tract, dt$tract=="36053030103", "36053940103")
  dt$tract <- replace(dt$tract, dt$tract=="36053030200", "36053940200")
  dt$tract <- replace(dt$tract, dt$tract=="36053030300", "36053940300")
  dt$tract <- replace(dt$tract, dt$tract=="36053030401", "36053940401")
  dt$tract <- replace(dt$tract, dt$tract=="36053030402", "36053940700")
  dt$tract <- replace(dt$tract, dt$tract=="36053030403", "36053940403")
  dt$tract <- replace(dt$tract, dt$tract=="36053030600", "36053940600")

  # Census tracts renumbered in Oneida County, NY
  # Year  2010 GEOID  New GEOID
  # 2011	36065940100	36065024700	9401.00 is now 0247.00
  # 2011	36065940000	36065024800	9400.00 is now 0248.00
  dt$tract <- replace(dt$tract, dt$tract=="36065024700", "36065940100")
  dt$tract <- replace(dt$tract, dt$tract=="36065024800", "36065940000")

  # Geographic definition changed very slightly, resulting in new code
  # Year  2010 GEOID  New GEOID
  # 2012	06037930401	06037137000	Geographic definition changed
  dt$tract <- replace(dt$tract, dt$tract=="06037137000", "06037930401")

  # County equivalent Bedford City merged into Bedford County
  # Year  2010 GEOID  New GEOID
  # 2014	51515050100	51019050100	County equivalent Bedford City merged into Bedford County
  dt$tract <- replace(dt$tract, dt$tract=="51019050100", "51515050100")

  # Clean up and return
  dt <- dt[, c("county","tract_stub") := NULL]
  setnames(dt, "tract","geoid_new")
  setnames(dt, "tract_copy", geoid_name)

  return(dt)

}

