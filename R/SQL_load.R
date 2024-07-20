###############################################################################################
#' @name  SQL_load
#' @title Load table from SQL database
#' @author brian devoe
#'
#' @description
#' Wrapper function for SQL SELECT queries from the SQL database.
#' By default, it saves table as Rdata file in the HOME/data/source_data/sql/ folder. If the
#' table already exists, it will load the table from the Rdata file, unless
#' overwrite is set to TRUE (FALSE by default). If overwrite is set to TRUE, the function
#' will load the table from the SQL database and overwrite the existing Rdata file. The
#' function needs the HOME vector to exist in the global environment and point to the
#' Git root directory.
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
#' @param show_metadata_only   Default is FALSE. If TRUE, function call only prints out dictionary and metadata.
#'
#' @param overwrite    Default is TRUE. If FALSE and table exists in /data/source_data/sql/ folder, function
#'                     will load table from csv file using a dictionary (i.e., with correct types). If TRUE, function will download table from SQL database and
#'                     overwrite the existing csv file.

###############################################################################################

# function: load_db
SQL_load <- function(database  = "DDK",
                     table_id   = NULL,
                     columns    = NULL,
                     filter     = NULL,
                     noisily    = TRUE,
                     show_metadata_only = FALSE,
                     overwrite  = TRUE) {

  ### Initial checks

  # start timer
  start <- Sys.time()

  # check if table and database is provided
  if(is.null(table_id)){stop("table_id parameter is required")}
  if(is.null(database)){stop("database parameter is required")}

  # recode the columns parameter to a string for SQL query
  if(!is.null(columns)){columns <- paste(columns, collapse=", ")}

  # recode the filter parameter to a string for SQL query
  if(!is.null(filter)){filter <- paste(filter, collapse=" AND ")}

  # Check if HOME vector exists
  if (!exists("HOME")) stop("HOME vector does not exist in global environment. Please set HOME to Git root directory.")

  ##############################################################################

  ### Save to folder and check if table exists
  # Set up save-to folder if it doesn't already exists
  SAVE_TO <- paste0(HOME, "/data/source_data/sql/", database)
  if (dir.exists(SAVE_TO)==F) dir.create(SAVE_TO, recursive = T)

  # file and dictionary
  file_name <- paste0(SAVE_TO, "/", table_id, ".csv")
  dict_name <- paste0(SAVE_TO, "/", table_id, "_dict.csv")

  ##############################################################################

  # Check if table exists

  # If yes, load it and skip the rest of the code, but only if overwrite is FALSE and
  # show_metadata_only is FALSE, too. If either is TRUE, then don't load the table from disk
  # because either only the metadata has been requested or the table should be overwritten.
  if ( file.exists(file_name)==T & overwrite==F & show_metadata_only==F) {

    print(paste("Loading table from disk:", file_name))

    if (file.exists(dict_name)==F) stop(paste0("Dictionary does not exist: ", dict_name, ". Manually delete the table (", file_name, ") and try again."))

    # Load dictionary
    dict <- fread(dict_name, colClasses = "character")

    # Load data
    dt <- dict$data_type; names(dt) <- dict$column_name
    dt <- fread(file_name, select=dt)

    # End timer and return data.table
    total_seconds <- as.numeric(difftime(Sys.time(), start, units = "secs"))
    minutes <- floor(total_seconds / 60); seconds <- round(total_seconds %% 60, 2)
    cat(sprintf("Time to load table from disk: %d minutes and %.2f seconds\n", minutes, seconds))

    return(dt)

  } else {

    print(paste("Connecting to SQL database"))

    # Connect to Brandeis office SQL database
    # con <- RMariaDB::dbConnect(
    #   RMariaDB::MariaDB(),
    #   host='129.64.58.140',
    #   port=3306,
    #   user='dba1',
    #   password='Password123$')

    con <- dbConnect(MariaDB(), host = "129.64.58.140", port = 3306, user = "DDK_read_only", password = "spAce-cat-algebra-7890!$")

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

    if (show_metadata_only==F) {

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
      total_seconds <- as.numeric(difftime(Sys.time(), start, units = "secs"))
      minutes <- floor(total_seconds / 60); seconds <- round(total_seconds %% 60, 2)
      cat(sprintf("Time to download table from SQL: %d minutes and %.2f seconds\n", minutes, seconds))

    }

    # disconnect from server
    RMariaDB::dbDisconnect(con); rm(con)

  }

  ##############################################################################

  # return
  if (show_metadata_only==F) {

    # save to disk
    dt <- data.table::as.data.table(dt)
    data.table::fwrite(dt, file_name)

    # Create dictionary for dt, save to disk
    dict <- data.table::data.table(column_name = names(dt), data_type = sapply(dt, class))
    data.table::fwrite(dict, dict_name)

    # Return data table
    return(dt)
  } else {
    print("No table loaded (show_metadata_only==T).")
  }

}

