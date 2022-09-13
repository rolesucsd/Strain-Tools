#Author: Renee Oles
#Date: Sep 2022
#Purpose: Divide a species into phylogroups using MASH
#Source: Abrams 

In this tutorial, we will take a species and create a distance matrix using the tool MASH (citation). We will cluster the distance matrix and cut the dendrogram to produce phylogroups. This method is computationally inexpensive and robust. 

1. Running Mash
Mash can be downloaded through anaconda using the following command - 
```{bash}
conda create -n mash -c bioconda mash
```
source - https://anaconda.org/bioconda/mash 

To run MASH on all assemblies in a directory, you can use the following snakemake rule 
```{python}
rule mash_fasta:
    input:
        expand("../Assembly/Shovill/{file}/{file}.fna", file=filtered)
    params:
        out="../MGWAS/Mash/fasta",
        pref="../Assembly/Shovill/"
    output:
        "../MGWAS/Mash/fasta.tsv"
    shell:
        """
        mash sketch -s 10000 -o {params.out} {input}
        mash dist {params.out}.msh {params.out}.msh -t > {output}
        """
```


2. Use MASH output to create a distance matrix
```{r}
library(tidyverse)
library(factoextra)
library(useful)
library(MASS)
library(ggplot2)
library("dbscan")
library(ape)
library("Hmisc")
library(pheatmap)
library(RColorBrewer)

# FINAL CLUSTER METHOD BASED ON PAPER https://www.nature.com/articles/s42003-020-01626-5#MOESM3
mash <- read.csv("Pyseer/full/fasta.tsv", header=TRUE, row.names=1, sep="\t", check.names = FALSE)
dist<- as.dist(1-cor(t(mash)))

################################################################################

## PART 1: CREATE CLUSTERING FUNCTIONS ##
################################################################################

# Ward D2 (have to self-define height to cut by)
hc1 <- hclust(dist, method = "ward.D2" )
summary(hc1$height)
plot(hc1, hang=-5, sub="", xlab="", labels=F)
lineage <- as.data.frame(cutree(hc1, h=max(hc1$height*0.125)))
colnames(lineage) <- "lineage"
lineage$Sample <- rownames(lineage)
l1 <- lineage[lineage$lineage == 1,2]
l2 <- lineage[lineage$lineage == 2,2]

mash_l1 <- mash[c(l1),c(l1)]
mash_l2 <- mash[c(l2),c(l2)]

dist_l1<- as.dist(1-cor(t(mash_l1)))
dist_l2<- as.dist(1-cor(t(mash_l2)))

hc1_l1 <- hclust(dist_l1, method = "ward.D2" )
plot(hc1_l1, hang=-5, sub="", xlab="", labels=F)
summary(hc1_l1$height)
lineage_l1 <- as.data.frame(cutree(hc1_l1, h=max(hc1_l1$height*0.125)))
colnames(lineage_l1) <- "lineage"

hc1_l2 <- hclust(dist_l2, method = "ward.D2" )
plot(hc1_l2, hang=-5, sub="", xlab="", labels=F)
summary(hc1_l2$height)
lineage_l2 <- as.data.frame(cutree(hc1_l2, h=max(hc1_l2$height*0.125)))
colnames(lineage_l2) <- "lineage"

lineage_l2$lineage <- lineage_l2$lineage + length(unique(lineage_l1$lineage))
lineage_full <- rbind(lineage_l1,lineage_l2)
colnames(lineage_full)[1] <- "Phylogroup"
lineage_full$Phylogroup <- as.factor(lineage_full$Phylogroup)
lineage_full$Sample <- rownames(lineage_full)
write.table(lineage_full, "phylogroups.txt",quote=FALSE,row.names=FALSE,sep="\t")
################################################################################

## PART 2: PLOTTING ##
################################################################################
# Heatmap
library(randomcoloR)
library(dendsort)
colfunc <- colorRampPalette(rev(brewer.pal(n=11, name = "BrBG")))

coul <- as.data.frame(randomColor(count=length(unique(lineage_l2$lineage))))
coul$lineage <- min(lineage_l2$lineage)+seq(1:nrow(coul))-1
coul <- left_join(lineage_l2,coul)

tiff(filename="lineage2_mash.tiff", units="in", width=10, height=10, res=300)
heatmap(as.matrix(mash_l2), Rowv = as.dendrogram(hc1_l2),Colv = 'Rowv', 
        ColSideColors = coul[,2], labRow = FALSE, labCol = FALSE, 
        col = hcl.colors(50))
dev.off()
#pheatmap(mash_l2, annotation_col = lineage_full, annotation_colors = coul)

coul <- as.data.frame(randomColor(count=length(unique(lineage_l1$lineage))))
coul$lineage <- seq(1:nrow(coul))
coul <- left_join(lineage_l1,coul)
tiff(filename="lineage1_mash.tiff", units="in", width=10, height=10, res=300)
heatmap(as.matrix(mash_l1), Rowv = as.dendrogram(hc1_l1),Colv = 'Rowv', 
        ColSideColors = coul[,2], labRow = FALSE, labCol = FALSE, 
        col = hcl.colors(50))
dev.off()

#pheatmap(mash_l1, annotation_col = lineage_full, annotation_colors = coul)

lineage_temp <- as.data.frame(as.numeric(lineage_full[,1]))
colnames(lineage_temp)[1] <- "lineage"
tiff(filename="lineage_mash.tiff", units="in", width=10, height=10, res=300)
heatmap(as.matrix(mash), Rowv = as.dendrogram(hc1),Colv = 'Rowv', 
        labRow = FALSE, labCol = FALSE, 
        col = hcl.colors(50))
dev.off()

group_edit <- left_join(lineage,groups)
group_edit <- left_join(group_edit,lineage_full)
write.table(group_edit, "group_lineage.txt",quote=FALSE,row.names=FALSE,sep="\t")


```

