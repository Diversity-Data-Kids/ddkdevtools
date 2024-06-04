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
#' @param overwrite logical to overwrite table if it exists -- default is FALSE
#'
#' @param user username for SQL database, this function will only work with administrator credintials
#' @param password password for SQL database administrator

SQL_write <- function(table = NULL, table_id = NULL, database = NULL, user = NULL, password = NULL, overwrite=F){

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
  end <- Sys.time()
  return(paste0("Time to write table: ", end-start))

}
