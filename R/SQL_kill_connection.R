#' @name SQL_kill_connection
#' @title SQL_kill_connection
#' @author brian devoe
#'
#' @description
#' kills processes from a database
#'
#' @param user username for SQL database, this function will only work with administrator credintials
#' @param password password for SQL database administrator


# SQL_kill_connection <- function(user = NULL, password = NULL){
SQL_kill_connection <- function(user = Sys.getenv("SQL_dba1"), password = Sys.getenv("SQL_dba1_pass")){

  # connect to SQL server
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),host='129.64.58.140',port=3306,user=user,password=password)

  # show process list
  processList <- dbGetQuery(con, "SHOW PROCESSLIST;")

  # subset process list to connections that are in "Sleep" state
  processList <- processList[processList$Command == "Sleep",]

  # loop through process list
  for(id in processList$Id){

    # kill all processes that are in "Sleep" state
    RMariaDB::dbExecute(con, paste0("KILL ", id, ";"))

  }

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

}
