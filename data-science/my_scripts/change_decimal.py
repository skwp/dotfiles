#!/usr/bin/env python

# usage: python change_decimal.py my_file.csv

import sys
import pandas as pd


file_name = sys.argv[1]
print(file_name)

parts = file_name.split(".")
new_file_name = "".join([parts[:-1], "parsed", parts[-1]])
print(new_file_name)

pd.read_csv(file_name, sep=";", decimal=",").to_csv(new_file_name, index=False)

