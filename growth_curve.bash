#!/bin/bash

# Batch file to run growth curve program and reformat plate read-out

python rename_columns_with_matrix_key.py --input "plate_map.csv"
 --key "plate.txt" --output "plate_new.txt"

Rscript growthcurve.R -f plate_new.txt -o growth_curve