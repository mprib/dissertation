#%%
import polars as pl
from pathlib import Path

output_folder = Path(r"C:\Users\Mac Prible\OneDrive - The University of Texas at Austin\research\PDSV\data\pilot\v3d_output\gait_cycle_data")

subject = 2
side = "left"

file_name = f"s{subject}_{side}_gait_cycle_data.tsv"
data_path = Path(output_folder,file_name)

# Read the data without headers
data = pl.read_csv(data_path, separator='\t', has_header=False)

data = data.transpose()
data[0,0] = "file"
data[0,1] = "variable"
data[0,4] = "axis"


# Drop the file folder columns which are extraneous
columns_to_drop = data.columns[2:4]  # Adjust the indices to match the columns you want to drop
data = data.drop(columns_to_drop)

# Step 1: Extract the first row to get the new column names
new_column_names = data.head(1).to_dict(as_series=False)
# Convert the dictionary values to a list of new column names
new_column_names = [value[0] for value in new_column_names.values()]

# Step 2: Remove the first row from the DataFrame
data = data.tail(-1)

# Step 3: Set the new column names
data.columns = new_column_names

#%%
# Concatenate "file", "variable", and "axis" columns into a new column named "concatenated"
data = data.with_columns(
    pl.concat_str(
       [data["variable"], data["axis"]],
       separator="_"
    ).alias("VariableAxis"))

data = data.with_columns(
    pl.concat_str(
        [data["file"], data["VariableAxis"]], 
        separator="_"  # You can adjust the separator as needed
    ).alias("concatenated")
)

data = data.drop(["variable", "axis"])
# To insert 'concatenated' at column 0 position, we use `select` with column names reordered
front_columns = ["VariableAxis", "concatenated"]
back_columns = [col for col in data.columns if col not in front_columns]
data = data.select(front_columns+back_columns)

#%%
# Create a counter for each gait cycle to be used for selecting relevent data
sequenced_column_names = []
gait_cycle_sequence = []
concatenated_names = data["concatenated"].to_list()

for item in concatenated_names:
    gait_cycle_sequence.append(sequenced_column_names.count(item))
    sequenced_column_names.append(item)

data = data.with_columns(pl.Series("GaitCycle", gait_cycle_sequence))
data = data.select(["GaitCycle"] + data.columns[:-1])

# %%
# realizing I also need to be storing the order of the trials in each file name
# extract data that can be extracted from file name
file_names = data["file"].to_list()
participants = []
conditions = []  #   
periods = []  #  i.e. start/stop
for name in file_names:
    participant, remainder = name.split(sep="_",maxsplit=1)
    remainder = remainder.replace(".c3d","")
    condition, period = remainder.rsplit(sep="_",maxsplit=1)
    
    participants.append(participant)
    conditions.append(condition)
    periods.append(period)

data = data.with_columns(
    [
    pl.Series("Participant", participants), 
    pl.Series("Condition", conditions),
    pl.Series("Period",periods),
    pl.Series("Side", [side]*len(periods))
    ]
    )

# %%
drop_columns = ["file", "concatenated"]
data = data.drop(drop_columns)


front_columns = ["Participant", "Side", "Condition", "Period", "VariableAxis", "GaitCycle"]
back_columns = [col for col in data.columns if col not in front_columns]
data = data.select(front_columns+back_columns)

# %%
data_long = data.melt(id_vars=front_columns, value_name="Value", variable_name="NormalizedTimeStep")


# %%
data_long = data_long.with_columns(pl.col("Value").cast(pl.Float64))
data_long = data_long.with_columns(pl.col("NormalizedTimeStep").cast(pl.Int16))
# %%

# Now the hard part...figuring out when the perturbation begins...


conditions = data_long["Condition"].unique().to_list()
all_variables = data_long["VariableAxis"].unique().to_list()
# %%

condition = "uni_sbt"
variables = ["RightBeltSpeed_X","LeftBeltSpeed_X"]

#%%
sample_data = (data_long.lazy()
               .filter(pl.col("Condition")==condition)
               .filter(pl.col("Period")=="start")
               .filter(pl.col("VariableAxis").is_in(variables))
               .collect())
# %%
sample_data_wide = sample_data.pivot(
    index=["Participant", "Side", "Condition", "Period", "GaitCycle", "NormalizedTimeStep"],
    columns = "VariableAxis",
    values="Value")
# %%
