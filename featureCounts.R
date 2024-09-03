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

write_csv(countsTidy, "geneCounts.csv")


