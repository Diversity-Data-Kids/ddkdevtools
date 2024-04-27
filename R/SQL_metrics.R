#' @name SQL_metrics
#' @title SQL_metrics
#' @author brian devoe
#'
#' @description
#' write metrics tables (large data) to SQL database


# load data -----------------------------------------------------------------------------------

start <- Sys.time()
infile <- "C:/Users/bdevoe/Dropbox/COI30/Production/SQL/TRACT/metrics-20.csv"
table <- data.table::fread(infile)
end <- Sys.time()
print(end-start)

# generate col types for SQL query ------------------------------------------------------------

# table[,1] <- as.character(table[,1])
#FIXME: geo column is messing up
table$geoid20 <- NULL

# column names
names <- colnames(table)
for(i in 1:length(names)){
  if(names[i] == "group"){names[i] <- "`group`"}
    class <- class(table[[i]])
  if(class == "character"){
    N <- max(nchar(table[[i]]))
    # N <- as.character(30)
    names[i] <- paste0(names[i], " varchar(", N, ")")
  } else if(class == "integer"){
    names[i] <- paste0(names[i], " int(4)")
  } else if(class == "numeric"){
    names[i] <- paste0(names[i], " double(10,10)")
  }
}

# fix column names for sql query
names_str <- ""
for(i in 1:length(names)){
  if(i == length(names)){names_str <- paste0(names_str, names[i])}
  else {names_str <- paste0(names_str, names[i], ", ")}
}
rm(N,class,i,names,table)

# connect to database and query ---------------------------------------------------------------

# connection
con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),host='129.64.58.140',port=3306,user='dba1',password='Password123$')

# select database to query to
RMariaDB::dbGetQuery(con, paste0("USE ", "coi_test", ";"))

# create table
create_table <- paste0("CREATE TABLE ", "test_table1", " (", names_str, ");")
RMariaDB::dbExecute(con, create_table)
rm(create_table)

# write table
query <- paste0("LOAD DATA LOCAL INFILE '", infile, "' INTO TABLE ", "test_table1"," FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n';")
RMariaDB::dbGetQuery(con, query)

# remove first row (contains redundant column names)
RMariaDB::dbGetQuery(con, paste0("DELETE FROM ", "test_table1", " LIMIT 1;"))

# load table for testing
start <- Sys.time()
testtable1 <- RMariaDB::dbGetQuery(con, paste0("SELECT * ", "FROM test_table1;"))
end <- Sys.time()
print(end-start)


# disconnect from server
RMariaDB::dbDisconnect(con);rm(con)

