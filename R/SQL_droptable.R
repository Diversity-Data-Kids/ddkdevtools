#' @name SQL_droptable
#' @title SQL_droptable
#' @author brian devoe
#'
#' @description
#' drops table from a give database
#'
#' @param database name of database to write to in SQL database
#' @param table_id name the table that will appear in SQL database
#' @param user username for SQL database, this function will only work with administrator credintials
#' @param password password for SQL database administrator

# SQL_droptable <- function(database = NULL, table_id = NULL, user = NULL, password = NULL){
SQL_droptable <- function(database = NULL, table_id = NULL, user = Sys.getenv("SQL_dba1"), password = Sys.getenv("SQL_dba1_pass")){


  # connect to SQL server
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),host='129.64.58.140',port=3306,user=user,password=password)

  # drop table  # select database to write to
  RMariaDB::dbExecute(con, paste0("USE ", database, ";"))
  RMariaDB::dbExecute(con, paste0("DROP TABLE ", table_id, ";"))

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

}

