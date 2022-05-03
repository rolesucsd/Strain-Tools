'''============================================================================================
Renee Oles      3 May 2022
============================================================================================'''

import sys
import argparse
import pandas as pd

def rename_column_names(df_to_rename, df_with_names, output):
    for count in range(0,len(df_to_rename.columns)-2):
        column = count % 12
        row = count // 12
        new_name = df_with_names.values[row,column]
        df_to_rename = df_to_rename.rename({df_to_rename.columns[count+2] : new_name}, axis=1)
    df_to_rename = df_to_rename.drop('T° 600', 1)
    df_to_rename.to_csv(output, index=0)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Rename_plate')
    parser.add_argument("--input", help="the input plate file")
    parser.add_argument("--key", help="the key plate names")
    parser.add_argument("--output", help="the output file name")
    args = parser.parse_args()

# example input 
# output = "plate_new.txt"
# file_to_rename="plate.txt"
# file_with_names="plate_map.csv"
    output = args.output
    file_to_rename=args.input
    file_with_names=args.key
    rename_column_names(pd.read_csv(file_to_rename, sep='\t'),pd.read_csv(file_with_names, index_col=0),output)