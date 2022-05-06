#!/bin/bash

source ~/opt/anaconda3/bin/activate
python blast.py
conda activate blast
makeblastdb -in ncbi/sequence.fasta -parse_seqids -blastdb_version 5 -title "sequence" -dbtype nucl
for f in files/*.fastq
do
	f2=$(basename -s .fastq $f)
	conda activate seqtk
	seqtk trimfq -l 700 $f > files/$f2.trim.fq
	seqtk seq -a files/$f2.trim.fq > files/$f2.fasta
	conda activate blast
	blastn -db ncbi/sequence.fasta -query files/$f2.fasta -qcov_hsp_perc 50 -perc_identity 50 -max_target_seqs 3 -out files/$f2.out -evalue 1e-6 -num_threads 4 -outfmt '6'
done
Rscript 16s.R
