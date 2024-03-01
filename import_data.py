#%%
import polars as pl
from pathlib import Path

output_folder = Path(r"C:\Users\Mac Prible\OneDrive - The University of Texas at Austin\research\PDSV\data\pilot\v3d_output")

file_name = "S1_LON_LOFF_BeltSpeed_HeelDistance.tsv"
data_path = output_folder / file_name

# Read the data without headers
data = pl.read_csv(data_path, separator='\t', has_header=False)

# Extract the first 4 rows to create unique column names
header_rows = data.head(5)

# Create unique column names by concatenating non-empty values across the first 4 rows
unique_column_names = ['_'.join(filter(None, row.to_list())) for row in header_rows]

# from here, need to start making some sequential labels...
