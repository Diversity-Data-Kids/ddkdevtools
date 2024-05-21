#' @name  SQL_load
#' @title Load table from SQL database
#' @author brian devoe
#'
#' @description
#' Wrapper function that helps execute SQL SELECT queries for clients and DDK data team.
#'
#' @param table_id Name of table from SQL database to load into R environment.
#'                 See SQL_table function for list of tables.
#'
#' @param database Name of database to connect to, character vector of length 1. Default is "DDK".
#'
#' @param columns  Columns to load from table. Default is all columns. Input format is a vector, i.e.
#'                 columns = c("col1", "col2", "col3", ...)
#'
#' @param filter   Filter to apply to table. Default is no filter. Input format is a string (DO NOT USE)
#'                 filter = c("col1 = 'value1', col2 = 'value2', col3 >= 'value3', ...)
#'
#' @param noisily  Print out dictionary and metadata of table. Default is TRUE
#'
#' @param load_table   Default is TRUE. If FALSE, function call only prints out dictionary and metadata.

# TODO: add example function call to documentation

# function: load_db
SQL_load <- function(table_id   = NULL,
                     database   = "DDK",
                     columns    = NULL,
                     filter     = NULL,
                     noisily    = TRUE,
                     load_table = TRUE) {

  # start timer
  start <- Sys.time()

  # check if table and database is provided
  if(is.null(table_id)){stop("table_id parameter is required")}
  if(is.null(database)){stop("database parameter is required")}

  # recode the columns parameter to a string for SQL query
  if(!is.null(columns)){columns <- paste(columns, collapse=", ")}

  # recode the filter parameter to a string for SQL query
  if(!is.null(filter)){filter <- paste(filter, collapse=" AND ")}

  # Connect to Brandeis office SQL database
  con <- RMariaDB::dbConnect(
    RMariaDB::MariaDB(),
    host='129.64.58.140',
    port=3306,
    user='dba1',
    password='Password123$')

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
  table_ids <- tables[!grepl("_dict", tables)]
  table_ids <- table_ids[!grepl("_metadata", table_ids)]

  # check if table exists and remove connection and throw error if it does not
  if(!table_id %in% table_ids){
    RMariaDB::dbDisconnect(con); rm(con) # disconnect and remove connection
    stop(paste0("table '",  table_id,"' does not exist in database '", database, "'", " -- please use SQL_table_ids('", database, "') or SQL_tables('", database, "') to list available tables"))
  } else {
    cat("\n  Table ID: ", table_id, "\n\n")
  }

  # Check if metadata exist and if so print it
  cat("\n")
  if ( paste0(table_id, "_metadata") %in% tables ) {
    if (noisily) print(RMariaDB::dbGetQuery(con, paste0("SELECT * FROM ", table_id, "_metadata;")))
  } else {
    print(paste0("metadata for ", table_id, " does not exist."))
  }
  cat("\n")

  # Check if dictionary exist and if so print it
  cat("\n")
  if ( paste0(table_id, "_dict") %in% tables ) {
    if (noisily) print(RMariaDB::dbGetQuery(con, paste0("SELECT * FROM ", table_id, "_dict;")))
  } else {
    print(paste0("dictionary for ", table_id, " does not exist."))
  }
  cat("\n")

  if (load_table==T) {

    # load full table
    if ( is.null(columns) ) {
      dt <- RMariaDB::dbGetQuery(con, paste0("SELECT * FROM ", table_id, ";"))
    }

    # load selected columns from table
    if ( !is.null(columns) ) {
      dt <- RMariaDB::dbGetQuery(con, paste0("SELECT ", columns, " FROM ", table_id, ";"))
    }

    # load selected columns and filtered rows from table
    if ( !is.null(columns) & !is.null(filter) ) {
      dt <- RMariaDB::dbGetQuery(con, paste0("SELECT ", columns, " FROM ", table_id, " WHERE ", filter, ";"))
    }

    # end timer
    end <- Sys.time()
    print(paste("Time to load table:", round(end-start, 2)))

  }

  # disconnect from server
  RMariaDB::dbDisconnect(con); rm(con)

  # return
  if (load_table==T) {
    return(data.table::as.data.table(dt))
  } else {
    print("No table loaded (load_table==F).")
  }

}

