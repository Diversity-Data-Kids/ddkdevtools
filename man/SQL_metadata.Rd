% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/SQL_metadata.R
\name{SQL_metadata}
\alias{SQL_metadata}
\title{Load table metadata only}
\usage{
SQL_metadata(table_id = NULL, database = "DDK")
}
\arguments{
\item{table_id}{Name of table from SQL database to load into R environment.
See SQL_table function for list of tables.}

\item{database}{Name of database to connect to, character vector of length 1. Default is "DDK".}
}
\description{
Wrapper function that loads the table metadata only
}
\author{
Clemens Noelke
}
