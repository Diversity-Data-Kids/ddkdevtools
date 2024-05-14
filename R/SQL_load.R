#' @name SQL_load
#' @title SQL_load
#' @author brian devoe
#'
#' @description
#' load table from SQL database
#'
#' @param table    Name of table from SQL database to load into R environment.
#'                 See SQL_table function for list of tables.
#' @param database Name of database to connect to. Default is 'coi'.
#' @param columns  Columns to load from table. Default is all columns. Input format is a vector, i.e.
#'                 columns = c("col1", "col2", "col3", ...)

# function: load_db
SQL_load <- function(table = NULL, database = NULL, columns = NULL){

  # start timer
  start <- Sys.time()

  # check if table and database is provided
  if(is.null(table)){   stop("table parameter is required")}
  if(is.null(database)){stop("database parameter is required")}

  # recode the columns parameter to a string for SQL query
  if(!is.null(columns)){columns <- paste(columns, collapse=", ")}

  # Connect to Brandeis office SQL database
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),host='129.64.58.140', port=3306,user='dba1',password='Password123$')

  # select database
  RMariaDB::dbGetQuery(con, paste0("USE ", database, ";"))

  # load table
  if( is.null(columns)){dt <- RMariaDB::dbGetQuery(con, paste0("SELECT * FROM ", table, ";"))}
  if(!is.null(columns)){dt <- RMariaDB::dbGetQuery(con, paste0("SELECT ", columns, " FROM ", table, ";"))}

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

  # end timer
  end <- Sys.time()
  print(paste("Time to load table:", end-start))

  # return
  return(dt)
}

