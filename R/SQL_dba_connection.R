#' @author brian devoe
#' @description
#' This script is used to activate a connection to the SQL server as the database administrator.

# # load database administrator credentials
# source(paste0(dirname(getwd()), "/Credentials/SQL_dba_creds.R"))
#
# # connect to SQL server
# con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),host=host, port=port,user=user, password=password)
#
# # remove credentials
# rm(host, port, user, password, dir)

# SQL query
dbGetQuery(con, "SHOW databases;")
dbGetQuery(con, "SHOW tables in ACS;")
dbGetQuery(con, "SHOW tables in DDK;")

# SQL disconnect
dbDisconnect(con); rm(con)

