#' @name SQL_write_bulk
#' @title SQL_write_bulk
#' @author brian devoe
#'
#' @description
#' write table from given directory to COI SQL database using bulk/batch method
#' WARNING: This function will not work unless you have database administrator credentials
#'
#' @param infile path to file to write to SQL database
#' @param table_id name of table to write to in SQL database
#' @param database name of database to write to in SQL database -- default is 'DDK'

SQL_write_bulk <- function(infile = NULL, table_id = NULL, database = "DDK"){

  ##############################################################################

  # load table to get column names and column types
  table <- data.table::fread(infile, nrow = 1)
  table[,1] <- as.character(table[,1])

  # column names
  names <- colnames(table)
  for(i in 1:length(names)){
    if(names[i] == "group"){names[i] <- "`group`"}
     class <- class(table[[i]])
    if(class == "character"){
      names[i] <- paste0(names[i], " text(30)")
    } else if(class == "integer"){
      names[i] <- paste0(names[i], " int(30)")
    } else if(class == "numeric"){
      names[i] <- paste0(names[i], " double(30,30)")
    } else if(class == "logical"){
      names[i] <- paste0(names[i], " boolean")
    }
  }
  # fix column names for sql query
  names_str <- ""
  for(i in 1:length(names)){
    if(i == length(names)){names_str <- paste0(names_str, names[i])}
    else {names_str <- paste0(names_str, names[i], ", ")}
  }

  ##############################################################################

  # TODO: fix connection
  # connect to database
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),host='129.64.58.140',port=3306,user='dba1',password='Password123$')

  # select coi db
  RMariaDB::dbExecute(con, paste0("USE ", database, ";"))

  # MySQL syntax for creating a table
  # CREATE TABLE table_id (
  #     column1 datatype,
  #     column2 datatype,
  #     column3 datatype,
  #    ....
  # );

  # create table
  create_table <- paste0("CREATE TABLE ", table_id, " (", names_str, ");")
  RMariaDB::dbExecute(con, create_table)

  ##############################################################################

  # write table
  start <- Sys.time()
  query <- paste0("LOAD DATA LOCAL INFILE '", infile, "' INTO TABLE ", table_id," FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n';")
  RMariaDB::dbGetQuery(con, query)
  end   <- Sys.time()

  # need to remove first row from table
  RMariaDB::dbGetQuery(con, paste0("DELETE FROM ", table_id, " LIMIT 1;"))

  ##############################################################################

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

  # return time to write
  return(paste0("Time to write table: ", end-start))

}
