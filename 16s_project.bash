#!/bin/bash
# Project - sanger sequencing to fastq and ncbi blast # 

# Input - file containing .seq and .ab1 files 
# Step 1 - convert ab1 files to fastq files (could use SEQIO in python or another package?)
# Step 2 - trim fastq files 
#	want to match to around 95% identity, coverage of over 90%, and limit the number of top matches returned
# Step 3 - run fastq files against ncbi custom database (should be a 16s database) using blast locally
# Step 4 - convert output files to one tabular output file with all samples matched to top ncbi hit 


# TODO: install anaconda3 and use the following command to activate it
source ~/opt/anaconda3/bin/activate

# Ideas 
# For steps 2-3 use anaconda to create enviornments to use blastn and seqtk 
# For anaconda enviornment setup the command to run on the terminal is: 
#	conda create -n blast -c bioconda blast
# In the bash file, activate the enviornment by:
#	conda activate blast

# For step 4, you could use your favorite data-wrangling language (I like R)
# All these steps could be compiled into one bash script 