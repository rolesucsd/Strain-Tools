################################################################################
# Author: Renee Oles
# Last modified: 3/24/2022
# Title: 16s.R
# Purpose: compile local blast results and create output file
################################################################################

# CREATE OUTPUT BLAST SUMMARY #
################################################################################
library(tidyverse)
blast_files <- list.files(path="files/", pattern = "\\.out$")
blast <- data.frame()
for(f in blast_files){
  f2 <- paste("files/",f,sep="")
  if(file.size(f2) == 0){
    new <- data.frame(c(f,"NA",0,0,0,0,0,0,0,0,0,0))
    new <- as.data.frame(t(new))
  }
  else{
    new <- read.table(f2, fill=TRUE)
  }
  blast <- rbind(blast, new)
} 
colnames(blast) <- c("qseqid", "sseqid", "pident", "length", "mismatch", "gapopen",
                     "qstart", "qend", "sstart", "send", "evalue", "bitscore")
taxonomy <- read.csv("ncbi/taxonomy.txt", sep="\t")
#colnames(taxonomy) <- c("sseqid","k","p","c","o","f","g","s")
colnames(taxonomy) <- c("sseqid", "taxonomy")
blast <- left_join(blast,taxonomy)
write_delim(blast, "blast_out.txt", delim="\t")
################################################################################
