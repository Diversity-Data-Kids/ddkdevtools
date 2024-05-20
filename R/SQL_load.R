#' @name  SQL_load
#' @title SQL_load
#' @author brian devoe
#'
#' @description
#' Wrapper function that helps execute SQL SELECT queries for clients and DDK data team.
#'
#' @param table_id Name of table from SQL database to load into R environment.
#'                 See SQL_table function for list of tables.
#'
#' @param database Name of database to connect to. Default is 'coi'.
#'
#' @param columns  Columns to load from table. Default is all columns. Input format is a vector, i.e.
#'                 columns = c("col1", "col2", "col3", ...)
#'
#' @param filter   Filter to apply to table. Default is no filter. Input format is a string (DO NOT USE)
#'                 filter = c("col1 = 'value1', col2 = 'value2', col3 >= 'value3', ...)
#'
#' @param noisily  Print out dictionary and metadata of table. Default is FALSE.

#' @param newparam blank description


# # load full ADI_HIED table from ACS database
# ADI_HIED <- SQL_load(table = "ADI_HIED", database = "ACS")
# # load selected columns from METRICS_10 table from DDK database
# METRICS_10 <- SQL_load(table    = "METRICS_10",
#                        database = "DDK",
#                        columns  = c("geoid10", "year", "coi30_met"))
# # load selected columns and filtered rows from METRICS_10 table from DDK database
# METRICS_10 <- SQL_load(table    = "METRICS_10",
#                        database = "DDK",
#                        columns  = c("geoid10", "year", "coi30_met"),
#                        filter   = c("year = 2010"))
# adding testing line
# TODO: add example function call to documentation

# function: load_db
SQL_load <- function(table_id = NULL, database = NULL, columns = NULL, filter = NULL, noisily = TRUE){

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
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),host='129.64.58.140', port=3306,user='dba1',password='Password123$')

  # check if database exists and remove connection and throw error if it does not
  db_list <- RMariaDB::dbGetQuery(con, "SHOW DATABASES;")
  if(!database %in% db_list$Database){
    RMariaDB::dbDisconnect(con);rm(con) # disconnect and remove connection
    stop(paste0("database '",  database,"' does not exist"))
  }

  # after checking if database exists, select it for use
  RMariaDB::dbExecute(con, paste0("USE ", database, ";"))

  # check if table exists and remove connection and throw error if it does not
  table_id_list <- RMariaDB::dbGetQuery(con, "SHOW TABLES;")
  if(!table_id %in% table_id_list[[1]]){
    RMariaDB::dbDisconnect(con);rm(con) # disconnect and remove connection
    stop(paste0("table '",  table_id,"' does not exist in database '", database, "'", " -- please use SQL_table_ids('",database,"') to list available tables"))
  }

  # after checking if database exists, print out dictionary and metadata of table if noisily is TRUE
  if(noisily){
    # TODO: add check if condition that checks if dictionary and metadata tables exist
    print("Dictionary ")
    print(RMariaDB::dbGetQuery(con, paste0("SELECT * FROM ", table_id, "_dict;")))
    print("metadata ")
    print(RMariaDB::dbGetQuery(con, paste0("SELECT * FROM ", table_id, "_metadata;")))
  }

  # load full table
  if( is.null(columns)){dt <- RMariaDB::dbGetQuery(con, paste0("SELECT * FROM ", table_id, ";"))}

  # load selected columns from table
  if(!is.null(columns)){dt <- RMariaDB::dbGetQuery(con, paste0("SELECT ", columns, " FROM ", table_id, ";"))}

  # load selected columns and filtered rows from table
  #FIXME: not working? threw error when tried to load METRICS_10 table with filter year == 2010
  if(!is.null(columns) & !is.null(filter)){dt <- RMariaDB::dbGetQuery(con, paste0("SELECT ", columns, " FROM ", table_id, "WHERE ", filter, ";"))}

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

  # end timer
  end <- Sys.time()
  print(paste("Time to load table:", end-start))

  # return
  return(dt)

}

