#' @name   SQL_table_id_list
#' @title  List/return table IDs
#' @author brian devoe
#'
#' @description
#' List available tables in COI SQL database, excluding dictionary and metadata tables. Returns tables as character vector.
#'
#' @param database Name of database to connect to, character vector of length 1. Default is "DDK".


# function list tables
SQL_table_id_list <- function(database = "DDK"){

 # Connect to Brandeis office SQL database
  con <- RMariaDB::dbConnect(
    RMariaDB::MariaDB(),
    host='129.64.58.140',
    port=3306,
    user='dba1',
    password='Password123$')

  # Connect to database
  RMariaDB::dbExecute(con, paste0("USE ", database, ";")) # Clemens: changed this to dbExecute

  # load tables list and convert to vector
  tables <- RMariaDB::dbGetQuery(con, "SHOW TABLES;")
  tables <- tables[, 1]

  # Remove dictionary and metadata tables
  tables <- tables[!grepl("_dict", tables)]
  tables <- tables[!grepl("_metadata", tables)]

  # disconnect from server
  RMariaDB::dbDisconnect(con); rm(con)

  # return
  cat("\n")
  cat(paste0("Tables in ", database, " database:\n\n"))
  cat(paste0("  ", tables), sep="\n")
  cat("\n")

  return(as.character(tables))

}
