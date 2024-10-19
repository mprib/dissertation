# Load required libraries
library(tidyverse)

# Increase the connection buffer size
Sys.setenv("VROOM_CONNECTION_SIZE" = 500000)

# Set up variables
# data_directory <- "C:\\Users\\Mac Prible\\OneDrive - The University of Texas at Austin\\research\\PDSV\\data\\PDVS_2024\\v3d"
# file_name <- "left_v3d_in_R_gait_cycle_data.tsv"
# output_name <- "processed_gait_cycle_data.csv"

tsv_to_tidy <- function(data_directory, file_name, output_name) {
  # Construct the full path
  input_path <- file.path(data_directory, file_name)
  output_path <- file.path(data_directory, output_name)
  
  
  # Read the raw data
  raw_data <- read_tsv(input_path, col_names = FALSE, skip = 5)
  
  # Read the metadata
  metadata <- read_tsv(input_path, n_max = 5, col_names = FALSE)
  
  # Get the number of columns
  num_cols <- ncol(metadata)
  
  # Initialize an empty list to store our processed data
  processed_data <- list()
  
  # Initialize variables to keep track of the previous metadata values and step count
  prev_metadata <- c("", "", "", "")
  step_count <- 0
  
  for (i in 2:num_cols) {  # Start from 2 to skip the ITEM column
    # Extract the current column from raw_data
    col_data <- raw_data %>%
      select(1, i) %>%
      set_names(c("ITEM", "Value"))
    
    # Add metadata
    col_data$File <- metadata[[i]][1]
    col_data$Measurement <- metadata[[i]][2]
    col_data$Model <- metadata[[i]][3]
    col_data$Type <- metadata[[i]][4]
   
    # Check if all metadata variables are the same as the previous iteration
    current_metadata <- c(col_data$File[1], col_data$Measurement[1], col_data$Model[1], col_data$Type[1])
    if (all(current_metadata == prev_metadata)) {
      # If they're the same, it's a new step
      step_count <- step_count + 1
      col_data$Step <- step_count
    } else {
      # If they're different, start from scratch
      step_count <- 1
      col_data$Step <- step_count
    }
    
    # Update prev_metadata for the next iteration
    prev_metadata <- current_metadata
    
    # Add to our list
    processed_data[[i-1]] <- col_data
    
    # Print a status update
    if (step_count == 1) {
      cat("Step count reset to 1 at column", i, "of", num_cols, "\n")
    }
  }
  
  # Combine all processed data
  cat("Binding data together")
  tidy_data <- bind_rows(processed_data)
  
  # Save the tidy data to a CSV file
  write_csv(tidy_data, output_path)
  
  # Print a message to confirm the file has been saved
  cat("Data has been saved to:", output_path, "\n")
}