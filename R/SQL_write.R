#' @name SQL_write
#' @title SQL_write
#' @author brian devoe
#'
#' @description
#' write table from given directory to COI SQL database
#'
#' @param table data table in R environment to write to SQL database
#' @param table_name name the table that will appear in SQL database
#' @param database name of database to write to in SQL database

SQL_write <- function(table = NULL, table_name = NULL, database = NULL){

  # start time
  start <- Sys.time()

  # connect to SQL server
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),host='129.64.58.140', port=3306,user='dba1', password='Password123$')

  # select database to write to
  RMariaDB::dbGetQuery(con, paste0("USE ", database, ";"))

  # write table
  dbWriteTable(con, table_name, table)

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

  # return time to write
  end <- Sys.time()
  return(paste0("Time to write table: ", end-start))
  
}
