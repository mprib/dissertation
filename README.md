# Introduction

This work space is the primary location for data processing scripts associated with my dissertation.
This README is intended to document the steps of data processing that take jjplace to serve as a reminder for future me.

# Stage 1: Vicon Output

Vicon data for each subject is stored within `research/PDSV/dissertation/raw_vicon/S#`.

# Stage 2: Creation of `.cmz` files

Individual calibration and trial data is aggregated into cmz files within `dissertation/cmz`.
The basic steps for the creation of the `.cmz` for each participant is as follows

1.  Load all motion trials
2.  Models --\> create from static calibration file --\> select static.c3d
3.  Add model file : `lower_extremity.mdh`
4.  Click "Skeleton Sword" button to calibrate functional knee and hip

At this point, there is a substantial amount of manual processing through the GUI, including tweaks to the underlying `mdh` file to accomodate issues peculiar to an individual data collection (such as a marker falling off the foot).

This is data that has been fully cleaned with one file each for the start and stop of all adaptation trials.
Additionally, there are going to be a couple of calibration files (S#\_static and S#\_dynamic).

# Stage 3: Run Pipelines 

These are stored in `dissertation\v3d\pipelines`:

1.  Filter Signals and Detect Events 
2.  Get Subject Mass *[update mass in model tab]*
3.  Compute Model Based Data 
4.  Clean up BeltSpeed data 
5.  Export normalized calculations 

The final pipeline will create `S#_left_gait_cycle_data.tsv` and `S#_right_gait_cycle_data.tsv` within the `dissertation\v3d\raw_v3d_output` subfolder.
These two files are the inputs of the next stage

# Stage 3: Convert to tidy format

see: `dissertation\pdvs_R\data_processing`

The raw pipeline output is in an exceptionally wide format.
Data for each subject is processed separately within the workbook `generate_single_subject_variables.Rmd`.
This workbook generates individual subject reports in `dissertation\pdvs_R\subject_reports` which can be visually inspected for reasonability of the Visual3D pipeline output and the resulting mean stance data that is determined for later stage processing.
That mean data (normalized parameter across stance phase, averaged across 5 steps) is the primary building block for later characterizations of torque and impulse. The step length data is determined based on the time normalized stance data at t=0.

Tidy data for each participant is stored in `pdsv_R\tidy_output`.

The script `batch_process.R` runs the workbook against all the subject data.

# Stage 4: Final Rollup and Analysis

Final processing of results occurs in PDSV_Results.qmd.
This will roll up the individual `S#_measured_data_long.csv` into a single dataframe for processing.

