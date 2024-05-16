#' @name SQL_tables
#' @title SQL_tables
#' @author brian devoe
#'
#' @description
#' Returns a table that lists all the given tables in a database. Each row contains the table name
#' and metadata for that table.
#'
#' @param database Name of database to connect to. Default is 'coi'.

SQL_tables <- function(database = NULL){

  # Connect to Brandeis office SQL database
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),
                   host='129.64.58.140', port=3306,
                   user='dba1', password='Password123$')

  # connect to coi database
  if(is.null(database)){
    RMariaDB::dbGetQuery(con, "USE coi;")}
  if(!is.null(database)){
    RMariaDB::dbGetQuery(con, paste0("USE ", database, ";"))}

  # load tables list
  tables <- RMariaDB::dbGetQuery(con, "SHOW TABLES;")

  # filter to only metadata
  tables <- tables[grepl("_metadata", tables$Tables_in_coi),]

  # for loop to get all tables metadata
  list_tables <- data.table()
  for(table in tables){

    # table name for the actual data table (not metadata or dictionary)
    table2 <- gsub("_metadata", "", table)

    # load metadata
    dt <- RMariaDB::dbGetQuery(con, paste0("SELECT * FROM ", table, ";"))
    dt$type <- NULL
    dt <- tidyr::pivot_wider(dt, names_from = name, values_from = value)

    # column for TRUE/FALSE if dictionary exists
    dict_exists <- paste0(table2, "_dictionary") %in% tables

    # column count
    col_count <- RMariaDB::dbGetQuery(con, paste0("SELECT COUNT(*) FROM information_schema.columns WHERE table_name = '", table2, "';"))

    # row count
    row_count <- RMariaDB::dbGetQuery(con, paste0("SELECT COUNT(*) FROM ", table2, ";"))

    # row and column bind data
    dt <- cbind(table_id = table2, dict_exists = dict_exists, dt, row_count = row_count$`COUNT(*)`, col_count = col_count$`COUNT(*)`)
    list_tables <- rbind(list_tables, dt)
  }

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

  # save table
  # save(list_tables, file = paste0("data/", database, ".rda"))

  # return
  return(list_tables)
}
