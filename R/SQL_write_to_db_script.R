#' @name SQL_write_to_db_script
#' @title SQL_write_to_db_script
#' @author brian devoe
#'
#' @description
#' uses the SQL_write function to write all csv files in a directory to the COI database




# path <- "C:/Users/bdevoe/Desktop/SQL/"
# files2 <- c("METROS", "NATION", "NATION-METROS", "STATE", "OPP_GAP", "ZIP", "TRACT")
# for(file2 in files2){
#   files <- list.files(paste0(path, file2, "/"))
#   for(file in files){
#     print(file)
#     file_name <- gsub("-", "_", file)
#     infile <- paste0(path, file2, "/", file, "/", file, ".csv")
#     SQL_write(infile = infile, table_name = file_name, database = "coi_test")
#   }
# }
# rm(path,file,files,file2,files2,file_name,infile)


