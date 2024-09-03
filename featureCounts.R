## Packages 
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("Rsubread") #Contains featureCounts
BiocManager::install("org.Hs.eg.db") #For obtaining symbols
BiocManager::install("annotate")

library(Rsubread)
library(tidyverse)
library(annotate)
library(org.Hs.eg.db)
library(gt)
library(plotly)
library(DT)
## featureCounts
fC <- featureCounts(files = c("alignment.sam"),
                    annot.inbuilt = "hg38",
                    useMetaFeatures = TRUE,
                    isPairedEnd = F,
                    nthreads = 8)

#save counts 
fC_counts <- as.data.frame(fC$counts) 

head(fC_counts)
fC$stat
head(fC$annotation)
row_names <- dimnames(fC_counts)[[1]]
print(row_names)

#as tibble with column of GeneIDs
countsTidy <- as_tibble(fC_counts) %>%
  mutate(GeneID = row_names, .before = 1)

#Get symbols and set as column in tibble
require('org.Hs.eg.db')
Symbols <- getSYMBOL(countsTidy$GeneID, data = 'org.Hs.eg.db')

countsTidy <- 
  countsTidy %>%
  mutate(Symbol = Symbols, .before=1)

countsTidy$Symbol[countsTidy$Symbol == 0] <- NA

countsTidy <- na.exclude(countsTidy) 

colnames(countsTidy)[3] <- "Raw counts"

#Excel readable file
write_csv(countsTidy, "geneCounts.csv")

#Static table - Not relevant without filtering
countsTidy %>%
  gt() %>%
  tab_header(
    title = "Raw Mapped Reads for OTM_CTRL_24T_2024"
  ) %>%
  tab_footnote(
    footnote = "Reads mapped with minimap2 v2.26"
  )

#Interactive table
datatable(countsTidy,
          extensions = c("KeyTable", "FixedHeader"),
          filter = "top",
          options = list(keys = TRUE,
                         searchHighlight = TRUE,
                         pageLength = 10, 
                         lengthMenu = c("10", "25", "50", "100")),
          caption = "Raw Mapped Reads for OTM_CTRL_24T_2024"
          )

?datatable

write_csv(fC$stat, "alignmentStats.csv")
