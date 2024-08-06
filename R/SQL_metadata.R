#' @name  SQL_metadata
#' @title Load table metadata only
#' @author Clemens Noelke
#'
#' @description
#' Wrapper function that loads the table metadata only
#'
#' @param table_id Name of table from SQL database to load into R environment.
#'                 See SQL_table function for list of tables.
#'
#' @param database Name of database to connect to, character vector of length 1. Default is "DDK".

SQL_metadata <- function(database= "DDK", table_id = NULL) {

  # check if table and database is provided
  if(is.null(table_id)){stop("table_id parameter is required")}
  if(is.null(database)){stop("database parameter is required")}

  # Connect to Brandeis office SQL database
  con <- RMariaDB::dbConnect(
    RMariaDB::MariaDB(),
    host="129.64.58.140",
    port="3306",
    user="DDK_read_only",
    password="spAce-cat-algebra-7890!$")

  # check if database exists and remove connection and throw error if it does not
  db_list <- RMariaDB::dbGetQuery(con, "SHOW DATABASES;")
  if(!database %in% db_list$Database){
    RMariaDB::dbDisconnect(con); rm(con) # disconnect and remove connection
    stop(paste0("database '",  database,"' does not exist"))
  }
  rm(db_list)

  # after checking if database exists, select it for use
  RMariaDB::dbExecute(con, paste0("USE ", database, ";"))

  # load tables list and convert to vector
  tables <- RMariaDB::dbGetQuery(con, "SHOW TABLES;")
  tables <- tables[, 1]

  # Vector with table_ids
  table_ids <- tables[grepl("_metadata", tables)]

  # check if table exists and remove connection and throw error if it does not
  if(!table_id %in% table_ids){
    RMariaDB::dbDisconnect(con); rm(con) # disconnect and remove connection
    stop(paste0("table '",  table_id,"' does not exist in database '", database, "'", " -- please use SQL_table_ids('", database, "') or SQL_tables('", database, "') to list available tables"))
  } else {
    cat("\n  Table ID: ", table_id, "\n\n")
  }

  # Check if metadata exist and if so print it
  cat("\n")
  if ( table_id %in% tables ) {
    metadata <- RMariaDB::dbGetQuery(con, paste0("SELECT * FROM ", table_id, ";"))
    print(metadata)
  } else {
    print(paste0("Metadata for ", table_id, " does not exist."))
  }
  cat("\n")

  # disconnect from server
  RMariaDB::dbDisconnect(con); rm(con)

  # return
  return(data.table::as.data.table(metadata))

}

