

SQL_test <- function(user = NULL, password = NULL){

  # connect to SQL server
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),host='129.64.58.140',port=3306,user=user,password=password)

  # select database to write to
  RMariaDB::dbGetQuery(con, paste0("USE ACS;"))

  tables <- RMariaDB::dbGetQuery(con, "SHOW TABLES;")

  return(tables)

}
