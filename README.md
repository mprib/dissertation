# Introduction

This work space is the primary location for data processing scripts associated with my dissertation.
This README is intended to document the steps of data processing that take jjplace to serve as a reminder for future me.

# Stage 1: Vicon Output

Vicon data for each subject is stored within research/PDSV/dissertation/raw_vicon/S#.
This is data that has been fully cleaned with one file each for the start and stop of all adaptation trials.
Additionally, there are going to be a couple of calibration files (S#\_static and S#\_dynamic).

# Stage 2: Visual 3D pipeline output

1.  Load all motion trials
2.  Models --\> create from static calibration file --\> select static.c3d
3.  Add model file : `lower_extremity.mdh`
4.  Click "Skeleton Sword" button to calibrate functional knee and hip
5.  Run Pipelines:
- Filter Signals and Detect Events
- Get Subject Mass (Update mass in model tab)
- Compute Model Based Data (i.e. joint torques)
- Clean up BeltSpeed data
- Export normalized calculations.

Pipeline `4` will create `S#_left_gait_cycle_data.tsv` and `S#_right_gait_cycle_data.tsv` within the `v3d\output` subfolder.
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
Just taking a moment to feel what it's like to type in Rstudio on linux.
Is this something that I can do a lot of?
Should I specifically do all my drafting in RStudio?
I'm thinking that I might.
Rather than trying to do something fancy within vscode where this kind of data analysis and processing is not really a first class citizen.
Yep, this is easy enough.
I'm fairly happy with how this is working.
So I shouldn't try to overcomplicate things.
Just keep everything here in RStudio for data analysis and manuscript drafting.
There should already be default tools for integrating with word and other tools.
I may need to do some stuff with pandoc on the other side for conversion back to markdown.

Ok.
I think I'm learning how this works in the source view.
