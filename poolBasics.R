library(shiny)
library(tidyverse)
library(pool)

# establish db connection locally
pool <- dbPool(
  drv = odbc::odbc(),#"SQL Server",  # note the space between SQL and Server ( how MS named driver)
  Driver = "SQL Server",  # note the space between SQL and Server ( how MS named driver)
  Server= "WSQ04151,50000",
  dbname = "ODS_test"
)
onStop(function() {
  poolClose(pool)
})

pool <- dbPool(
  drv = odbc::odbc(),#"SQL Server",  # note the space between SQL and Server ( how MS named driver)
  Driver = "SQL Server",  # note the space between SQL and Server ( how MS named driver)
  Server= "DEQ-SQLODS-PROD,50000",
  dbname = "ODS"
)

con <- dbConnect(odbc::odbc(),
                 .connection_string = 'driver={SQL Server};server={DEQ-SQLODS-PROD,50000};database={ODS};trusted_connection=true')


#args <- list(
#  drv = odbc::odbc(),
#  Driver = "SQL Server",  # note the space between SQL and Server ( how MS named driver)
#  Server= "WSQ04151,50000",
#  Database = "ODS_test"
#)

#con <- do.call(DBI::dbConnect, args)
#on.exit(DBI::dbDisconnect(con))




# establish db connection on server. Need to enter credentials safely on server after upload
#pool <- dbPool(
#  drv = odbc::odbc(),
#  Driver = "SQLServer",   # note the LACK OF space between SQL and Server ( how RStudio named driver)
#  Server= "WSQ04151,50000",
#  Database = "ODS_test",
#  username = Sys.getenv("userid"),
#  password = Sys.getenv("pwd") )


ui <-