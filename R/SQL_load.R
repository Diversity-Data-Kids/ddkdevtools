#' @name SQL_load
#' @title SQL_load
#' @author brian devoe
#'
#' @description
#' load table from SQL database
#'
#' @param table_id Name of table from SQL database to load into R environment.
#'                 See SQL_table function for list of tables.
#' @param database Name of database to connect to. Default is 'coi'.
#' @param columns  Columns to load from table. Default is all columns. Input format is a vector, i.e.
#'                 columns = c("col1", "col2", "col3", ...)
#' @param filter   Filter to apply to table. Default is no filter. Input format is a string (DO NOT USE)
#'
#' @param noisily  Print out dictionary and metadata of table. Default is FALSE.

# TODO: add example function call to documentation
# TODO: add noisily option to print out dictionary and metadata of table

# function: load_db
SQL_load <- function(table_id = NULL, database = NULL, columns = NULL, filter = NULL, noisily = FALSE){

  # start timer
  start <- Sys.time()

  # check if table and database is provided
  if(is.null(table_id)){   stop("table_id parameter is required")}
  if(is.null(database)){stop("database parameter is required")}

  # recode the columns parameter to a string for SQL query
  if(!is.null(columns)){columns <- paste(columns, collapse=", ")}

  # Connect to Brandeis office SQL database
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),host='129.64.58.140', port=3306,user='dba1',password='Password123$')

  # check if database exists and remove connection and throw error if it does not
  db_list <- RMariaDB::dbGetQuery(con, "SHOW DATABASES;")
  if(!database %in% db_list$Database){
    RMariaDB::dbDisconnect(con);rm(con) # disconnect and remove connection
    stop(paste0("database '",  database,"' does not exist"))
  }

  # after checking if database exists, select it for use
  RMariaDB::dbGetQuery(con, paste0("USE ", database, ";"))

  # check if table exists and remove connection and throw error if it does not
  table_id_list <- RMariaDB::dbGetQuery(con, "SHOW TABLES;")
  if(!table_id %in% table_id_list$Tables_in_ACS){
    RMariaDB::dbDisconnect(con);rm(con) # disconnect and remove connection
    stop(paste0("table '",  table_id,"' does not exist in database '", database, "'", " -- please use SQL_table_ids('",database,"') to list available tables"))
  }

  # load table
  if( is.null(columns)){dt <- RMariaDB::dbGetQuery(con, paste0("SELECT * FROM ", table_id, ";"))}
  if(!is.null(columns)){dt <- RMariaDB::dbGetQuery(con, paste0("SELECT ", columns, " FROM ", table_id, ";"))}
  # TODO: if(!is.null(columns) & !is.null(filter)){dt <- RMariaDB::dbGetQuery(con, )}

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

  # end timer
  end <- Sys.time()
  print(paste("Time to load table:", end-start))

  # return
  return(dt)

}

