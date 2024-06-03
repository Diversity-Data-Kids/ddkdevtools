####################################################################################################
#' @name SQL_write_bulk
#' @title SQL_write_bulk
#' @author brian devoe
#'
#' @description
#' write table from given directory to COI SQL database using bulk/batch method
#' WARNING: This function will not work unless you have database administrator credentials
#' WARNING: will throw and error if local infile is not enabled as root user use 'SET GLOBAL local_infile = 1;' to enable
#'
#' @param infile path to file to write to SQL database. DO NOT INCLUDE ".csv" in infile string
#' @param table_id name of table to write to in SQL database
#' @param database name of database to write to in SQL database -- default is 'DDK'

# DONE: add overwrite option
# DONE: check if dictionary exists
# TODO: add creditionals requirement
# TODO: add check for database exists
# DONE: add check for table exists -- otherwise overwrite will fail if table does not exist while overwrite = TRUE
# TODO: add warning for infile parameter to NOT include ".csv" at end?
####################################################################################################



SQL_write_bulk <- function(infile = NULL, table_id = NULL, database = "DDK", HOME = NULL, overwrite = FALSE){

  # check if HOME exists
  if(!exists("HOME")){stop("HOME does not exist")}

  # create tmp directory if does not exist
  if (!dir.exists(paste0(HOME, "data/tmp"))){dir.create(paste0(HOME, "data/tmp"))}

  ##############################################################################

  # load dictionary to get column names and column types
  if(!file.exists(paste0(infile, "_dict.csv"))){return("Dictionary file does not exist!")}
  dict <- data.table::fread(paste0(infile, "_dict.csv"))

  # fix column names for sql query
  cols <- ""
  for(i in 1:nrow(dict)){
    if(i == nrow(dict)){cols <- paste0(cols, dict$column[i], " ", dict$typeSQL[i])}
    else {cols <- paste0(cols, dict$column[i], " ", dict$typeSQL[i], ", ")}
  }

  # load temporary data file
  tmp <- data.table::fread(paste0(infile, ".csv"), colClasses = dict$typeR)

  # replace missing values
  tmp[tmp==""]   <- NA
  tmp[tmp== Inf] <- NA # can we silence this warning?
  tmp[tmp==-Inf] <- NA # can we silence this warning?

  # write temporary data file
  tmp_path <- paste0(HOME, "data/tmp/", table_id, "_tmp.csv")
  data.table::fwrite(tmp, tmp_path, na = "\\N")

  ##############################################################################

  # connect to database
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),host='129.64.58.140',port=3306,user='dba1',password='Password123$')

  # select database
  RMariaDB::dbExecute(con, paste0("USE ", database, ";"))

  # check if table exists in database
  check <- RMariaDB::dbGetQuery(con, paste0("SELECT count(*) FROM information_schema.tables WHERE table_schema = '",database, "' AND table_name = '", table_id, "' LIMIT 1;"))

  # delete if overwrite == TRUE & check[[1]]
  if(overwrite == TRUE & check[[1]]==1){RMariaDB::dbExecute(con, paste0("DROP TABLE ", table_id, ";"))}

  # create table
  create_table <- paste0("CREATE TABLE ", table_id, " (", cols, ");")
  RMariaDB::dbExecute(con, create_table)

  # write table
  start <- Sys.time()
  query <- paste0("LOAD DATA LOCAL INFILE '", tmp_path, "' INTO TABLE ", table_id," FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;")
  RMariaDB::dbGetQuery(con, query)
  end   <- Sys.time()

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

  ##############################################################################

  # delete temporary file
  file.remove(tmp_path)

  # return time to write
  return(paste0("Time to write table: ", end-start))

}
