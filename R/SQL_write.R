#' @name SQL_write
#' @title SQL_write
#' @author brian devoe
#'
#' @description
#' write table from R environment into SQL database
#' WARNING: This function will not work unless you have database administrator credentials
#'
#' @param database name of database to write to in SQL database
#' @param table_id name the table that will appear in SQL database
#' @param table data table in R environment to write to SQL database
#' @param user username for SQL database, this function will only work with administrator credintials
#' @param password password for SQL database administrator
#' @param overwrite logical to overwrite table if it exists -- default is FALSE


# SQL_write <- function(database = NULL, table_id = NULL, table = NULL, user = NULL, password = NULL, overwrite=F){
SQL_write <- function(database = NULL,table_id = NULL,table = NULL,user = Sys.getenv("SQL_dba1"),password = Sys.getenv("SQL_dba1_pass"),overwrite=F){

  # start time
  start <- Sys.time()

  # connect to SQL server
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),host='129.64.58.140',port=3306,user=user,password=password)

  # select database to write to
  RMariaDB::dbExecute(con, paste0("USE ", database, ";"))

  # check if table exists in database
  check <- RMariaDB::dbGetQuery(con, paste0("SELECT count(*) FROM information_schema.tables WHERE table_schema = '",database, "' AND table_name = '", table_id, "' LIMIT 1;"))

  # delete if overwrite == TRUE & check[[1]]
  if(overwrite == TRUE & check[[1]]==1){RMariaDB::dbExecute(con, paste0("DROP TABLE ", table_id, ";"))}

  # write table
  dbWriteTable(con, table_id, table)

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

  # return time to write
  total_seconds <- as.numeric(difftime(Sys.time(), start, units = "secs"))
  minutes <- floor(total_seconds/60)
  seconds <- round(total_seconds%%60, 2)
  return(cat(sprintf("Time to write table to SQL: %d minutes and %.2f seconds\n", minutes, seconds)))


}
