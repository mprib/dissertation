# Introduction

This work space is the primary location for data processing scripts associated with my dissertation. This README is intended to document the steps of data processing that take place to serve as a reminder for future me.

# Stage 1: Vicon Output

Vicon data for each subject is stored within research/PDSV/data/PDVS_2024/S#.
This is data that has been fully cleaned with one file each for the start and stop of all adaptation trials.
Additionally, there are going to be a couple of calibration files (S#\_static and S#\_dynamic).

# Stage 2: Visual 3D pipeline output

1.  Load all motion trials (ignoring static and dynamic calibration trials)
2.  Models --\> create from static calibration file --\> select S#\_static.c3d
3.  Add `.mdh` file from PDVS_2024: `lower_extremity.mdh`
4.  Click "Skeleton Sword" button to calibrate functional knee and hip
5.  Run Pipelines
    0.  Filter Signals and Detect Events
    1.  Get Subject Mass (Update mass in model tab)
    2.  Compute Model Based Data (i.e. joint torques)
    3.  Export data

Pipeline `3` will create `left_gait_cycle_data.tsv` and `right_gait_cycle_data.tsv` within the `v3d` subfolder.
These must be manually renamed to `S#_left_gait_cycle_data.tsv` and `S#_right_gait_cycle.tsv`.
These two files are the inputs of the next stage

# Stage 3: Rolling up with Python

The objective here is to convert the `.tsv` files into a tidy tabular format that can subsequently be processed within python.
Because these final 2 stages of processing are code heavy, they are stored in the git repo `pdvs_v3d`. 
Open `tsv_to_tidy.py`, update the subject number, and run the script.
It should create a `S#_measured_data_long.csv` which is a tidy table that can be loaded into R.


# Stage 4: Final Stats and Rollup

Final processing of results occurs in PDSV_Results.qmd.
This will roll up the individual `S#_measured_data_long.csv` into a single dataframe for processing.
There are some additional transformations that tidy up the Visual3D output.

