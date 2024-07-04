###############################################################################################
#' @author brian devoe
#' @description for testing different functions
#'
#'
###############################################################################################

# load libraries and functions, set HOME
library(ddkdevtools)

HOME <- dirname(getwd())
# source(paste0(HOME, "/COMMON/startup_COMMON.R"))
###############################################################################################


# check tables in databaase
ddk <- SQL_tables(database="DDK")
acs <- SQL_tables(database="ACS")

# Load metrics (METRICS_10 table contains both outcomes and opportunity metrics) table and corresponding dictionary
metricsDictionary <- SQL_dict(table_id="METRICS_10_dict", database="DDK")


METRICS_10 <- SQL_load(table    = "METRICS_10",
                       database = "DDK",
                       columns  = c("geoid", "year", "coi30_met"),
                       filter   = c("geoid LIKE '01%'", "year = 2010"))

