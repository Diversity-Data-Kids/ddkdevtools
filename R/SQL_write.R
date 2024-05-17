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
#'
#' @param user username for SQL database, this function will only work with administrator credintials
#' @param password password for SQL database administrator

SQL_write <- function(table = NULL, table_id = NULL, database = NULL, user = NULL, password = NULL){

  # start time
  start <- Sys.time()

  # connect to SQL server
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),host='129.64.58.140',port=3306,user=user,password=password)

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
