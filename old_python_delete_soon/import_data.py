#%%
import polars as pl
from pathlib import Path
from plotnine import ggplot, aes, geom_line, facet_wrap, themes

output_folder = Path(r"C:\Users\Mac Prible\OneDrive - The University of Texas at Austin\research\PDSV\data\pilot\v3d_output\gait_cycle_data")

subject = 1
side = "right"
side = "left"

file_name = f"s{subject}_{side}_gait_cycle_data.tsv"
data_path = Path(output_folder,file_name)

# Read the data without headers
raw_data = pl.read_csv(data_path, separator='\t', has_header=False)

raw_data = raw_data.transpose()
raw_data[0,0] = "file"
raw_data[0,1] = "variable"
raw_data[0,4] = "axis"

# Drop the file folder columns which are extraneous
columns_to_drop = raw_data.columns[2:4]  # Adjust the indices to match the columns you want to drop
raw_data = raw_data.drop(columns_to_drop)

# Step 1: Extract the first row to get the new column names
new_column_names = raw_data.head(1).to_dict(as_series=False)
# Convert the dictionary values to a list of new column names
new_column_names = [value[0] for value in new_column_names.values()]

# Step 2: Remove the first row from the DataFrame
raw_data = raw_data.tail(-1)

# Step 3: Set the new column names
raw_data.columns = new_column_names

#%%
# Concatenate "file", "variable", and "axis" columns into a new column named "concatenated"
raw_data = raw_data.with_columns(
    pl.concat_str(
       [raw_data["variable"], raw_data["axis"]],
       separator="_"
    ).alias("VariableAxis"))

raw_data = raw_data.with_columns(
    pl.concat_str(
        [raw_data["file"], raw_data["VariableAxis"]], 
        separator="_"  # You can adjust the separator as needed
    ).alias("concatenated")
)

raw_data = raw_data.drop(["variable", "axis"])
# To insert 'concatenated' at column 0 position, we use `select` with column names reordered
front_columns = ["VariableAxis", "concatenated"]
back_columns = [col for col in raw_data.columns if col not in front_columns]
raw_data = raw_data.select(front_columns+back_columns)

#%%
# Create a counter for each gait cycle to be used for selecting relevent data
sequenced_column_names = []
gait_cycle_sequence = []
concatenated_names = raw_data["concatenated"].to_list()

for item in concatenated_names:
    gait_cycle_sequence.append(sequenced_column_names.count(item))
    sequenced_column_names.append(item)

raw_data = raw_data.with_columns(pl.Series("GaitCycle", gait_cycle_sequence))
raw_data = raw_data.select(["GaitCycle"] + raw_data.columns[:-1])

# %%
# realizing I also need to be storing the order of the trials in each file name
# extract data that can be extracted from file name
file_names = raw_data["file"].to_list()
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

raw_data = raw_data.with_columns(
    [
    pl.Series("Participant", participants), 
    pl.Series("Condition", conditions),
    pl.Series("Period",periods),
    pl.Series("Side", [side]*len(periods))
    ]
    )

# %%
drop_columns = ["file", "concatenated"]
raw_data = raw_data.drop(drop_columns)


front_columns = ["Participant", "Side", "Condition", "Period", "VariableAxis", "GaitCycle"]
back_columns = [col for col in raw_data.columns if col not in front_columns]
raw_data = raw_data.select(front_columns+back_columns)

# %%
data_long = raw_data.melt(id_vars=front_columns, value_name="Value", variable_name="NormalizedTimeStep")

# %%
data_long = data_long.with_columns(pl.col("Value").cast(pl.Float64))
data_long = data_long.with_columns(pl.col("NormalizedTimeStep").cast(pl.Int16))
data_long = data_long.with_columns(pl.col("Value")*-1)
# %%

# Now the hard part...figuring out when the perturbation begins...
conditions = data_long["Condition"].unique().to_list()
all_variables = data_long["VariableAxis"].unique().to_list()
# %%

variables = ["RightBeltSpeed_X","LeftBeltSpeed_X"]

#%%
sample_data = (data_long.lazy()
               .filter(pl.col("VariableAxis").is_in(variables))
               .collect())

# %%
belt_speed_data = sample_data.pivot(
    index=["Participant", "Side", "Condition", "Period", "GaitCycle", "NormalizedTimeStep"],
    columns = "VariableAxis",
    values="Value")

belt_speed_data = (belt_speed_data.lazy()
                   # get difference between belt speeds at each instant of time
                   .with_columns(
                       ((pl.col("LeftBeltSpeed_X")-pl.col("RightBeltSpeed_X")).abs()*1000).alias("SpeedDiff")
                   )
                   # get max belt speed difference across each gait cycle
                   .group_by(["Condition", "Side", "Participant", "Period", "GaitCycle"])
                   .agg(pl.col("SpeedDiff").max().alias("MaxSpeedDiff"))
                   .sort(pl.col("GaitCycle"))               
                   .collect()
                   )


#%%
# Plot using plotnine
plot = (ggplot(belt_speed_data, aes(x='GaitCycle', y='MaxSpeedDiff', color='Condition')) +
        geom_line() +
        facet_wrap("~Period")+
        themes.theme_minimal())

# %%
plot.show()

# %%
# grab gait cycles to measure by filtering belt_speed_data on speed difFerence and getting max gait cycle
steady_state_gait_cycles = (belt_speed_data.lazy()
                            .filter(pl.col("MaxSpeedDiff")<0.3)
                            .collect()
                            )
# %%
last_steady_state_Pre = (steady_state_gait_cycles.lazy()
                         .filter(pl.col("Period")=="start")
                         .sort(by="GaitCycle", descending=True)
                         .group_by(["Condition"]).head(6)
                         .collect()
)
#%%
first_steady_state_Post = (steady_state_gait_cycles.lazy()
                           .filter(pl.col("Period")=="stop")
                           .sort(by="GaitCycle")
                           .group_by(["Condition"]).head(6)
                           .collect()
)

# %%
# For "Start" Period, sort by GaitCycle descending and get the first (latest) of each group
# Combine the results back into a single DataFrame
measured_gait_cycles = pl.concat([last_steady_state_Pre, first_steady_state_Post])
measured_gait_cycles

# %%
join_columns = ["Condition", "Side", "Participant", "GaitCycle", "Period"]
measured_data_long = measured_gait_cycles.join(data_long,on=join_columns)
# %%
# measured data here is the Visual3D data associated with the last 6 steps of PreAdaptation and
# the first 6 steps of post adaptation. I would like to potentially filter out the "intermediate"
# steps as well (# 6 or #1 as the case may be) but this is my draft approach
index_columns = ["Condition", "Side", "Participant", "GaitCycle", "Period", "NormalizedTimeStep"]
measured_data = measured_data_long.pivot(index = index_columns,
                                         values="Value",
                                         columns="VariableAxis")
# %%
group_columns = ["Condition", "Side", "Participant", "Period", "NormalizedTimeStep"]

result = (measured_data
          .group_by(group_columns)
          .agg([
                 pl.col("L_ANKLE_MOMENT_X").mean().alias("avg_L_ANKLE_MOMENT_X"),
                 pl.col("R_ANKLE_MOMENT_X").mean().alias("avg_R_ANKLE_MOMENT_X"),
                 pl.col("R_ANKLE_MOMENT_Y").mean().alias("avg_R_ANKLE_MOMENT_Y"),
                 pl.col("R_ANKLE_MOMENT_Z").mean().alias("avg_R_ANKLE_MOMENT_Z"),
                 pl.col("LeftBeltSpeed_X").mean().alias("avg_LeftBeltSpeed_X"),
                 pl.col("RightBeltSpeed_X").mean().alias("avg_RightBeltSpeed_X"),
                 pl.col("HEEL_DISTANCE_X").mean().alias("avg_HEEL_DISTANCE_X") 
          ])
)
# %%

plot = (ggplot(result, aes(x='NormalizedTimeStep', y='avg_L_ANKLE_MOMENT_X', color='Condition')) +
        geom_line() +
        facet_wrap("~Period")+
        themes.theme_minimal())

plot.show()
# %%
plot = (ggplot(result, aes(x='NormalizedTimeStep', y='avg_R_ANKLE_MOMENT_X', color='Condition')) +
        geom_line() +
        facet_wrap("~Period")+
        themes.theme_minimal())

plot.show()

# %%