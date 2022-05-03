from Bio import SeqIO
import os

path = "files/"
ab1 = [f for f in os.listdir(path) if f.endswith('.ab1')]
for a in ab1:
	parse = SeqIO.parse("files/"+a, "abi")
	count = SeqIO.write(parse, "files/"+a[:-4]+".fastq", "fastq")
