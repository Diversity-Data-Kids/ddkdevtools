####################################################################################################
#' @name SQL_write_bulk
#' @title SQL_write_bulk
#' @author brian devoe
#'
#' @description
#' write table from given directory to COI SQL database using bulk/batch method
#' WARNING: will throw and error if local infile is not enabled as root user use 'SET GLOBAL local_infile = 1;' to enable
#'
#' @param table data.table within R environment to write to SQL database
#' @param dict  dictionary of table
#' @param table_id name of table that will appear in SQL database
#' @param database name of database to write to in SQL database -- default is 'DDK'
#' @param overwrite logical to overwrite table if it exists -- default is FALSE
#' @param test logical to test function by checking if original data.frame is identical to data loaded
#'             into SQL server -- default is FALSE

# TODO: add credentials requirement and remove dba1 credentials from function
# TODO: add check for database exists
# TODO: check for table exists what if check > 1 ?
####################################################################################################



SQL_write_bulk <- function(database = "DDK", table_id = NULL, table = NULL, dict = NULL, user = NULL, password = NULL, overwrite = FALSE, test = FALSE){

  # Check if HOME vector exists
  if (!exists("HOME")) stop("HOME vector does not exist in global environment. Please set HOME to Git root directory.")

  # check if table exists
  if(is.null(table)){stop("table required")}

  # check if table_id exists
  if(is.null(table_id)){stop("table_id required")}

  # check if user name exists
  if(is.null(user)){stop("user required")}

  # check if password exists
  if(is.null(password)){stop("password required")}

  # check if dictionary exists
  if(is.null(dict)){stop("dictionary required")}

  # create tmp directory if does not exist
  if (!dir.exists(paste0(HOME, "/data/tmp"))){dir.create(paste0(HOME, "/data/tmp"), recursive=T)}

  ##############################################################################

  # replace missing values
  table[table==""]   <- NA
  table[table== Inf] <- NA # can we silence this warning?
  table[table==-Inf] <- NA # can we silence this warning?

  # write temporary data file
  tmp_path <- paste0(HOME, "/data/tmp/", table_id, "_tmp.csv")
  data.table::fwrite(table, tmp_path, na = "\\N", row.names = F, col.names = F)

  # Delete table from memory unless needed for testing
  if (test == TRUE) {
    rm(table)
    gc()
  }

  ##############################################################################

  # connect to database
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),host='129.64.58.140',port=3306,user='dba1',password='Password123$')

  # select database
  RMariaDB::dbExecute(con, paste0("USE ", database, ";"))

  # check if table exists in database
  check <- RMariaDB::dbGetQuery(con, paste0("SELECT count(*) FROM information_schema.tables WHERE table_schema = '",database, "' AND table_name = '", table_id, "' LIMIT 1;"))

  # delete if overwrite == TRUE & check[[1]]
  if(overwrite == TRUE & check[[1]]==1){RMariaDB::dbExecute(con, paste0("DROP TABLE ", table_id, ";"))}

  # fix column names for create table query
  cols <- ""
  for (i in 1:nrow(dict)) {
    if(i == nrow(dict)) {
      cols <- paste0(cols, dict$column[i], " ", dict$typeSQL[i])
    }
    else {
      cols <- paste0(cols, dict$column[i], " ", dict$typeSQL[i], ", ")
    }
  }

  # Enable loading local data
  RMariaDB::dbExecute(con, "SET GLOBAL local_infile=1;")

  # create table
  create_table <- paste0("CREATE TABLE ", table_id, " (", cols, ");")
  RMariaDB::dbExecute(con, create_table)

  # bulk insert query: if local infile is not enabled as root user use 'SET GLOBAL local_infile = 1;' to enable
  start <- Sys.time()
  query <- paste0("LOAD DATA LOCAL INFILE '", tmp_path, "' INTO TABLE ", table_id," FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\r\n';")
  RMariaDB::dbExecute(con, query)

  # time
  total_seconds <- as.numeric(difftime(Sys.time(), start, units = "secs"))
  minutes <- floor(total_seconds/60)
  seconds <- round(total_seconds%%60, 2)
  cat(sprintf("Time to write table to SQL: %d minutes and %.2f seconds\n", minutes, seconds))

  # test if data is identical to table inserted into SQL database
  if (test == TRUE) {
    # read table from database
    table_sql <- data.table::as.data.table(RMariaDB::dbGetQuery(con, paste0("SELECT * FROM ", table_id, ";")))
    # compare
    if(identical(table, table_sql)){print("PASSED: data inserted into SQL database is identical to original data")}
    else {print("FAILED: data inserted into SQL database is not identical to original data")}
  }

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

  ##############################################################################

  # delete temporary file
  file.remove(tmp_path)

  # return message
  return("SQL_write_bulk complete")

}
