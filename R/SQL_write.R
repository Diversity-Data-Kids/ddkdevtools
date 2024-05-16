#' @name SQL_write
#' @title SQL_write
#' @author brian devoe
#'
#' @description
#' write table from R environment into SQL database
#' WARNING: This function will not work unless you have database administrator credentials
#'
#' @param table data table in R environment to write to SQL database
#' @param table_id name the table that will appear in SQL database
#' @param database name of database to write to in SQL database

SQL_write <- function(table = NULL, table_id = NULL, database = NULL){

  # start time
  start <- Sys.time()

  # # load database administrator credentials
  # source(paste0(dirname(getwd()), "/Credentials/SQL_dba_creds.R"))
  #
  # # connect to SQL server
  # con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),host=host, port=port,user=user, password=password)
  #
  # # remove credentials
  # rm(host, port, user, password, dir)

  # select database to write to
  RMariaDB::dbGetQuery(con, paste0("USE ", database, ";"))

  # write table
  dbWriteTable(con, table_id, table)

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

  # return time to write
  end <- Sys.time()
  return(paste0("Time to write table: ", end-start))

}
