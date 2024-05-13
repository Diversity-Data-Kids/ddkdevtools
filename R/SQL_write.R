#' @name SQL_write
#' @title SQL_write
#' @author brian devoe
#'
#' @description
#' write table from given directory to COI SQL database
#'
#' @param table data table in R environment to write to SQL database
#' @param table_name name the table that will appear in SQL database
#' @param database name of database to write to in SQL database

SQL_write <- function(table = NULL, table_name = NULL, database = NULL){

  # start time
  start <- Sys.time()

  # # column names
  # names <- colnames(table)
  # for(i in 1:length(names)){
  #   if(names[i] == "group"){names[i] <- "`group`"}
  #   class <- class(table[[i]])
  #   if(class == "character"){
  #     names[i] <- paste0(names[i], " text(30)")
  #   } else if(class == "integer"){
  #     names[i] <- paste0(names[i], " int(30)")
  #   } else if(class == "numeric"){
  #     names[i] <- paste0(names[i], " double(30,30)")
  #   }
  # }
  # # fix column names for sql query
  # names_str <- ""
  # for(i in 1:length(names)){
  #   if(i == length(names)){names_str <- paste0(names_str, names[i])}
  #   else {names_str <- paste0(names_str, names[i], ", ")}
  # }; rm(i,names,class)


  # connect to SQL server
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),host='129.64.58.140', port=3306,user='dba1', password='Password123$')

  # select database to write to
  RMariaDB::dbGetQuery(con, paste0("USE ", database, ";"))

  # write table
  dbWriteTable(con, table_name, table)

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

  # return time to write
  end <- Sys.time()
  return(paste0("Time to write table: ", end-start))

}
