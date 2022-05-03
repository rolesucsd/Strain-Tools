################################################################################
# Author: Renee Oles
# Date Modified: 05/03/2021
# Purpose: Create growth curve fit
# Input: Table with time and OD at each time where each sample is a column
################################################################################

## Set up 
library("optparse")
library("tidyverse")

option_list = list(
  make_option(c("-f", "--input_file"), type="character", default=NULL, 
              help="file name", metavar="character"),
  make_option(c("-o", "--output"), type="character", default="out", 
              help="output file name, no extension [default= %default]", metavar="character"),
  make_option(c("-t", "--correct_time"), type="logical", default=TRUE, 
              help="change time from hours to minutes [default= %default]", metavar="character"),
  make_option(c("-n", "--normalize_background"), type="logical", default=TRUE, 
              help="normalize background [default= %default]", metavar="character")
); 

## Read input from user
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);
## Define variables
# name of input file - first column is time, following columns are samples with 
# OD at each time
file_name <- opt$input_file
# name of output file - don't include extension in file name
output_file_name <-opt$output
# if the time is in hours, keep this as true, if in minutes, switch to FALSE
correct_time <- opt$correct_time
# if the background OD has already been subtracted
normalize_background <- opt$normalize_background

# Run growthcurveR
library(growthcurver)
f <- read.csv(file_name, header=TRUE)
if(correct_time){
  colnames(f)[1] <- "time"
  time <- separate(f,time,c("hours","minutes","seconds"), sep=":",remove = TRUE)
  minutes <- function(x, output){
    A <- as.numeric(x[1])
    B <- as.numeric(x[2])
    C <- as.numeric(x[3])
    return(A*60+B+C/60)
  }
f$time <- apply(time,1,minutes)  
}
if(normalize_background){
  norm<-"blank"
}else {norm<-"none"}
# get rid of all columns that are empty
f <- f[,-grep("Empty", colnames(f))]
# average out the control values
f$blank <- rowSums(f[,grep("Control", colnames(f))])/3
f <- f[,-grep("Control", colnames(f))]

gc_fit <- SummarizeGrowthByPlate(f, bg_correct=norm)
# Run a for loop to summarize replicates into avg column
gc_fit_sum <- data.frame()
rep <- colnames(f)[2:ncol(f)]
rep <- unique(unlist(lapply(rep, function(x){strsplit(x,"[.]")[[1]][1]})))
for (i in rep){
  reps <- gc_fit[grepl(i,gc_fit[,1]),]
  avg <- colMeans(reps[,c(2:9)])
  gc_fit_sum <- rbind(gc_fit_sum,avg)
  rownames(gc_fit_sum)[nrow(gc_fit_sum)] <- i
}
colnames(gc_fit_sum) <- colnames(gc_fit)[2:9]

gc_fit <- gc_fit %>% arrange(desc(k))
gc_fit <- gc_fit[-nrow(gc_fit),]
write.table(gc_fit, file = paste(output_file_name,".txt",sep=""), quote = FALSE, 
            sep = "\t", row.names = FALSE)
gc_fit_sum <- gc_fit_sum %>% arrange(desc(k))
write.table(gc_fit_sum, file = paste(output_file_name,"_sum.txt",sep=""), quote = FALSE, 
            sep = "\t", row.names = TRUE)


# Print each of the growth curves 
num_analyses <- length(names(f)) - 1
d_gc <- data.frame(sample = character(num_analyses),
                   k = numeric(num_analyses),
                   n0  = numeric(num_analyses),
                   r = numeric(num_analyses),
                   t_mid = numeric(num_analyses),
                   t_gen = numeric(num_analyses),
                   auc_l = numeric(num_analyses),
                   auc_e = numeric(num_analyses),
                   sigma = numeric(num_analyses),
                   stringsAsFactors = FALSE)
jpeg(file="growth_curve.jpeg", width=3000,height=3000, res=300)
par(mfcol = c(8,12))
par(mar = c(0.25,0.25,0.25,0.25))
n <- 1    # keeps track of the current row in the output data frame
for (i in 2:ncol(f)) {
    f_temp <- f[,i] - f$blank
    gc_fit <- SummarizeGrowth(data_t = f$time, data_n = f_temp,
                              bg_correct = "none")
    # Now, add the metrics from this column to the next row (n) in the 
    # output data frame, and increment the row counter (n)
    d_gc$sample[n] <- colnames(f)[i]
    d_gc[n, 2:9] <- c(gc_fit$vals$k,
                      gc_fit$vals$n0,
                      gc_fit$vals$r,
                      gc_fit$vals$t_mid,
                      gc_fit$vals$t_gen,
                      gc_fit$vals$auc_l,
                      gc_fit$vals$auc_e,
                      gc_fit$vals$sigma)
    n <- n + 1
    n_obs <- length(gc_fit$data$t)
    idx_to_plot <- 1:20 / 20 * n_obs
    plot(gc_fit$data$t[idx_to_plot], gc_fit$data$N[idx_to_plot], 
         pch = 20, 
         xlim = c(0, max(f$time)), 
         ylim = c(0, max(f[,2:ncol(f)])),
         cex = 0.6, xaxt = "n", yaxt = "n")
    text(x = max(f$time)/4, y = max(f[,2:ncol(f)]), labels = colnames(f)[i], pos = 1)
    lines(gc_fit$data$t, predict(gc_fit$model), col = "red")
}
dev.off()
