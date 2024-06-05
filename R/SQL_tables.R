#' @name SQL_tables
#' @title Returns as data.table a summary table of all tables in a database
#' @author brian devoe
#'
#' @description
#' Returns a data.table with tables in a database. Each row contains the table's id and metadata for that table.
#'
#' @param database Name of database to connect to, character vector of length 1. Default is "DDK".

SQL_tables <- function(database = "DDK"){

  # Connect to Brandeis office SQL database
  con <- RMariaDB::dbConnect(
    RMariaDB::MariaDB(),
    host='129.64.58.140',
    port=3306,
    user='dba1',
    password='Password123$')

  # Check if database exists and remove connection and throw error if it does not
  db_list <- RMariaDB::dbGetQuery(con, "SHOW DATABASES;")
  if(!database %in% db_list$Database){
    RMariaDB::dbDisconnect(con);rm(con) # disconnect and remove connection
    stop(paste0("database '",  database,"' does not exist"))
  }
  rm(db_list)

  # Connect to specific database
  if(is.null(database)){
    RMariaDB::dbExecute(con, "USE DDK;")}
  if(!is.null(database)){
    RMariaDB::dbExecute(con, paste0("USE ", database, ";"))}

  # load tables list and convert to vector
  tables <- RMariaDB::dbGetQuery(con, "SHOW TABLES;")
  tables <- tables[, 1]

  # Vector with table_ids
  table_ids <- tables[!grepl("_dict", tables)]
  table_ids <- table_ids[!grepl("_metadata", table_ids)]

  # Check that metadata and dictionary exist
  for (tbl in 1:length(table_ids)){
    if ( (paste0(table_ids[tbl], "_metadata") %in% tables)==F ) print(paste0("metadata table for ", table_ids[tbl], " does not exist"))
    if ( (paste0(table_ids[tbl], "_dict") %in% tables)==F )     print(paste0("metadata table for ", table_ids[tbl], " does not exist"))
  }

  # for loop to get all tables metadata
  tbl_list <- vector("list", length(table_ids))
  for(tbl in 1:length(table_ids)) {

    # load metadata
    dt <- RMariaDB::dbGetQuery(con, paste0("SELECT * FROM ", paste0(table_ids[tbl], "_metadata"), ";"))

    # Pivot wide
    dt <- tidyr::pivot_wider(dt, names_from = field, values_from = value)

    # column for TRUE/FALSE if dictionary exists
    dt$has_dict <- paste0(table_ids[tbl], "_dict") %in% tables

    # column count
    col_count <- RMariaDB::dbGetQuery(con, paste0("SELECT COUNT(*) FROM information_schema.columns WHERE table_name = '", table_ids[tbl], "';"))
    dt$col_count <- col_count[1, 1]; rm(col_count)

    # row count
    row_count <- RMariaDB::dbGetQuery(con, paste0("SELECT COUNT(*) FROM ", table_ids[tbl], ";"))
    dt$row_count <- row_count[1, 1]; rm(row_count)

    # Collect results
    tbl_list[[tbl]] <- data.table::as.data.table(dt); rm(dt)

  }
  rm(tbl)

  # Stack
  dt <- data.table::rbindlist(tbl_list, fill=T); rm(tbl_list)

  # disconnect from server
  RMariaDB::dbDisconnect(con); rm(con)

  # save table
  # save(list_tables, file = paste0("data/", database, ".rda"))

  # return
  return(dt)

}
