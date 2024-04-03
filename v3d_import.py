"""
Having created a hacky script to import data and summarize it, I'm going to now attempt to wrap it up in some 
more stable functions that will make things easier to grok and maintain.
"""


#%%
import polars as pl
from pathlib import Path
from plotnine import ggplot, aes, geom_line, facet_wrap, themes, facet_grid

# RAW_OUTPUT_FOLDER = Path(r"C:\Users\Mac Prible\OneDrive - The University of Texas at Austin\research\PDSV\data\pilot\v3d_output\gait_cycle_data")
RAW_OUTPUT_FOLDER = Path(r"C:\Users\Mac Prible\OneDrive - The University of Texas at Austin\research\PDSV\data\PDVS_2024\v3d")


def import_long_data(subject: int, side:str,) -> pl.DataFrame:
    """
    Note that all data here is in the form of normalized stance phase
    """
    file_name = f"S{subject}_{side}_gait_cycle_data.tsv"
    data_path = Path(RAW_OUTPUT_FOLDER,file_name)

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

    # Create a counter for each gait cycle to be used for selecting relevent data
    sequenced_column_names = []
    gait_cycle_sequence = []
    concatenated_names = raw_data["concatenated"].to_list()

    for item in concatenated_names:
        gait_cycle_sequence.append(sequenced_column_names.count(item))
        sequenced_column_names.append(item)

    raw_data = raw_data.with_columns(pl.Series("GaitCycle", gait_cycle_sequence))
    raw_data = raw_data.select(["GaitCycle"] + raw_data.columns[:-1])

    # realizing I also need to be storing the order of the trials in each file name
    # extract data that can be extracted from file name
    file_names = raw_data["file"].to_list()
    participants = []
    conditions = []  #   
    start_stop = []  #  i.e. start/stop
    condition_orders = []
    for name in file_names:
        participant, condition_order, remainder = name.split(sep="_",maxsplit=2)
        remainder = remainder.replace(".c3d","")
        condition, start_stop_str = remainder.rsplit(sep="_",maxsplit=1)
    
        participants.append(participant)
        conditions.append(condition)
        condition_orders.append(condition_order)
        start_stop.append(start_stop_str)

    raw_data = raw_data.with_columns(
        [
        pl.Series("Participant", participants), 
        pl.Series("Condition", conditions),
        pl.Series("ConditionOrder", condition_order),
        pl.Series("StartStop",start_stop),
        pl.Series("Side", [side]*len(start_stop))
        ]
        )
    drop_columns = ["file", "concatenated"]
    raw_data = raw_data.drop(drop_columns)


    front_columns = ["Participant", "Side", "Condition", "ConditionOrder", "StartStop", "VariableAxis", "GaitCycle"]
    back_columns = [col for col in raw_data.columns if col not in front_columns]
    raw_data = raw_data.select(front_columns+back_columns)

    data_long = raw_data.melt(id_vars=front_columns, value_name="Value", variable_name="NormalizedTimeStep")

    data_long = data_long.with_columns(pl.col("Value").cast(pl.Float64))
    data_long = data_long.with_columns(pl.col("NormalizedTimeStep").cast(pl.Int16))
    data_long = data_long.with_columns(
                        pl.when(pl.col("VariableAxis").str.contains("BeltSpeed"))
                        .then(pl.col("Value") * 1000)
                        .otherwise(pl.col("Value"))
                        .alias("Value")
                        )
    

    return data_long

def get_max_belt_speed_diff(data_long:pl.DataFrame)->pl.DataFrame:
    """
    returns the maximum belt speed difference across stance phases
    """
    variables = ["RightBeltSpeed_X","LeftBeltSpeed_X"]

    sample_data = (data_long.lazy()
                .filter(pl.col("VariableAxis").is_in(variables))
                .collect())

    belt_speed_data = sample_data.pivot(
        index=["Participant", "Side", "Condition", "ConditionOrder", "StartStop", "GaitCycle", "NormalizedTimeStep"],
        columns = "VariableAxis",
        values="Value")

    belt_speed_data = (belt_speed_data.lazy()
                    # get difference between belt speeds at each instant of time
                    .with_columns(
                        ((pl.col("LeftBeltSpeed_X")-pl.col("RightBeltSpeed_X")).abs()).alias("SpeedDiff")
                    )
                    # get max belt speed difference across each gait cycle
                    .group_by(["Condition", "Side", "Participant", "StartStop", "GaitCycle"])
                    .agg(pl.col("SpeedDiff").max().alias("MaxSpeedDiff"))
                    .sort(pl.col("GaitCycle"))               
                    .collect()
                    )
    return belt_speed_data

def get_gait_cycle_periods(belt_speed_data:pl.DataFrame, steady_state_diff = 0.3,adaptation_diff=0.8, stance_count = 5)->pl.DataFrame:
    """
    returns a dataframe of stance phases that will represent:
        [late baseline, early adaptation, late adaptation, early post adaptation]
    
    steady_state_diff: maximum difference in belt speeds across stance phase for it to be included
                       in either baseline or post_adaptation periods
        
    adaptation_diff: minimum difference in belt speeds across stance phase for it to be included in
                     early_adaptation or late_adaptation 
    """

    steady_state_gait_cycles = (belt_speed_data.lazy()
                                .filter(pl.col("MaxSpeedDiff")<steady_state_diff)
                                .collect()
                                )
    
    baseline_cycles = (steady_state_gait_cycles.lazy()
                            .filter(pl.col("StartStop")=="start")
                            .sort(by="GaitCycle", descending=True)
                            .group_by(["Condition", "Side"])
                            .head(stance_count+1)
                            .group_by(["Condition", "Side"])
                            .tail(stance_count)
                            .with_columns(pl.lit("Baseline").alias("Period"))
                            .collect())

    post_adaptation_cycles = (steady_state_gait_cycles.lazy()
                            .filter(pl.col("StartStop")=="stop")
                            .sort(by="GaitCycle")
                            .group_by(["Condition", "Side"])
                            .head(stance_count+1)
                            .group_by(["Condition", "Side"])
                            .tail(stance_count)
                            .with_columns(pl.lit("PostAdapt").alias("Period"))
                            .collect())

    perturbed_gait_cycles = (belt_speed_data.lazy()
                            .filter(pl.col("MaxSpeedDiff")>adaptation_diff)
                            .collect())

    early_adaptation_cycles = (perturbed_gait_cycles.lazy()
                            .filter(pl.col("StartStop")=="start")
                            .sort(by="GaitCycle", descending=True)
                            .group_by(["Condition", "Side"])
                            .tail(stance_count+1)
                            .group_by(["Condition", "Side"])
                            .head(stance_count)
                            .with_columns(pl.lit("Early Adapt").alias("Period"))
                            .collect())

    late_adaptation_cycles = (perturbed_gait_cycles.lazy()
                            .filter(pl.col("StartStop")=="stop")
                            .sort(by="GaitCycle")
                            .group_by(["Condition", "Side"])
                            .tail(stance_count+1)
                            .group_by(["Condition", "Side"])
                            .head(stance_count)
                            .with_columns(pl.lit("Late Adapt").alias("Period"))
                            .collect())

    measured_gait_cycles = pl.concat([baseline_cycles,
                                      early_adaptation_cycles, 
                                      late_adaptation_cycles,
                                      post_adaptation_cycles])
        
    return measured_gait_cycles    

#%%
if __name__ == "__main__":

    #%%    
    subject = 1

    left_data_long = import_long_data(subject, "left")
    right_data_long = import_long_data(subject, "right")
    data_long = pl.concat([left_data_long,right_data_long])

    belt_speed_data = get_max_belt_speed_diff(data_long)
    #%%
    measured_gait_cycles = get_gait_cycle_periods(belt_speed_data)

    #%%
    join_columns = ["Condition", "Side", "Participant", "GaitCycle", "StartStop"]
    measured_data_long = measured_gait_cycles.join(data_long,on=join_columns)
    
    measured_data_long.write_csv(Path(RAW_OUTPUT_FOLDER, f"S{subject}_measured_data_long.csv"))

    #%%