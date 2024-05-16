#' @name SQL_table_id_list
#' @title SQL_table_id_list
#' @author brian devoe
#'
#' @description
#' Call function to list available tables in COI SQL database
#'
#' @param database Name of database to connect to. Default is 'coi'.


# function list tables
SQL_table_id_list <- function(database = NULL){

 # Connect to Brandeis office SQL database
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),host='129.64.58.140', port=3306,user='dba1',password='Password123$')

  # connect to coi database
  RMariaDB::dbGetQuery(con, paste0("USE ", database, ";"))

  # load tables list
  tables <- RMariaDB::dbGetQuery(con, "SHOW TABLES;")

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

  # return
  return(tables)
}
