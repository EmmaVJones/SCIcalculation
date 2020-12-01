# R110 rarification tool rebuild QA

library(tidyverse)
library(pool)
library(readxl)

### Production Environment
pool <- dbPool(
  drv = odbc::odbc(),
  Driver = "SQL Server Native Client 11.0", 
  Server= "DEQ-SQLODS-PROD,50000",
  dbname = "ODS",
  trusted_connection = "yes"
)

# pull raw benthics data
stationBenthics <- pool %>% tbl("Edas_Benthic_View") %>%
  as_tibble() %>%
  rename( "StationID" = "STA_ID",
          "BenSampID"  = "WBS_SAMP_ID",
          "RepNum" = "WBS_REP_NUM",
          "FinalID" = "WBMT_FINAL_ID",
          "Individuals" = "WBE_INDIVIDUALS",
          "ID Comments" = "WBE_COMMENT",
          "Entered By" = "WBE_INSERTED_BY", # not in EDAS table but good info
          "Taxonomist" = "TAXONOMIST_NAME",  # not in EDAS table but good info
          "Entered Date" = "WBE_INSERTED_DATE") %>%
  mutate(`Excluded Taxa` = ifelse(WBE_EXCLUDED_TAXA_YN == "Y", -1, 0)) %>%
  dplyr::select(StationID, BenSampID, RepNum, FinalID, Individuals, `Excluded Taxa`, `ID Comments`, Taxonomist, `Entered By`, `Entered Date`)


# Bring in new R110 samples
newR110 <- read_excel('ODSdataComparison/R110QA/NewR110s.xlsx')%>%
  mutate(OriginalBenSampID = gsub('R110','',WBS_SAMP_ID))


# filter to just rarified samples
stationBenthicsMatch <- filter(stationBenthics, BenSampID %in% unique(newR110$OriginalBenSampID)) %>%
  full_join(newR110, by = c('BenSampID' = 'OriginalBenSampID', 'FinalID' ='WBMT_FINAL_ID')) %>%
  mutate(`Rarified > Original` = ifelse(WBE_INDIVIDUALS > Individuals, T, F))

nrow(filter(stationBenthicsMatch, `Rarified > Original` == T))

write.csv(stationBenthicsMatch, 'ODSdataComparison/R110QA/stationBenthicsMatch_revised.csv')

# Bring in new R110 samples
originalR110 <- read_excel('ODSdataComparison/R110QA/OriginalR110s.xlsx')

# filter to just rarified samples
stationBenthicsMatchOriginal <- filter(stationBenthics, BenSampID %in% unique(originalR110$WBS_SAMP_ID)) %>%
  full_join(originalR110, by = c('BenSampID' = 'WBS_SAMP_ID', 'FinalID' ='WBMT_FINAL_ID')) %>%
  mutate(`Rarified > Original` = ifelse(WBE_INDIVIDUALS > Individuals, T, F))

