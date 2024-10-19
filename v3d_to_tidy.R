# Load required libraries
library(tidyverse)

# Increase the connection buffer size
Sys.setenv("VROOM_CONNECTION_SIZE" = 500000)

# Set up variables
data_directory <- "C:\\Users\\Mac Prible\\OneDrive - The University of Texas at Austin\\research\\PDSV\\data\\PDVS_2024\\v3d"
stance_side <- "left"
file_name <- "left_v3d_in_R_gait_cycle_data.tsv"
output_name <- "processed_gait_cycle_data.csv"

tsv_to_tidy <- function(data_directory, file_name, output_name) {
  # Construct the full path
  input_path <- file.path(data_directory, file_name)
  output_path <- file.path(data_directory, output_name)
  
  tic <- Sys.time()
  print(paste("Import started at", tic))
  
  # Read the raw data
  raw_data <- read_tsv(input_path, col_names = FALSE, skip = 5, show_col_types = FALSE)
  
  
  print("Metadata and raw data read in")
  ############# Stage 1: Organize Metadata Header and get step count
  # Step 1: Read the metadata
  metadata <- read_tsv(input_path, n_max = 5, col_names = FALSE, show_col_types = FALSE)
  
  # Step 2: Transpose the metadata
  metadata <- metadata %>%
    t() %>%
    # as_tibble(.name_repair = "unique") %>%
    as_tibble() %>%
    setNames(c("filename", "raw_variable", "type", "origin", "axis")) %>% 
    select(-type, -origin) # cannot see a use for these
  
  # Step 3: Track column order and clean up cruff (can't have sorted data up to this point)
  metadata <- metadata %>%
    mutate(column_number = row_number()) %>% 
    slice(-1) # first column (now row) is just NA

  # Step 4: Clean up variable names to 
  metadata <- metadata %>% 
    mutate(stance_side = stance_side) %>% 
    mutate(variable = case_when(
           raw_variable == "RHEEL" ~ "R_HEEL",
           raw_variable == "LHEEL" ~ "L_HEEL",
           raw_variable == "FP1" ~ "Left_GRF",
           raw_variable == "FP2" ~ "Right_GRF",
           TRUE ~ raw_variable  # This keeps all other values unchanged
         ))  %>% 
    mutate(variable = case_when(
      stance_side == "left" & grepl("^(L_|Left)", variable) ~ sub("^(L_|Left_|Left)", "IPSI_", variable),
      stance_side == "right" & grepl("^(R_|Right)", variable) ~ sub("^(R_|Right_|Right)", "IPSI_", variable),
      stance_side == "right" & grepl("^(L_|Left)", variable) ~ sub("^(L_|Left_|Left)", "CONTRA_", variable),
      stance_side == "left" & grepl("^(R_|Right)", variable) ~ sub("^(R_|Right_|Right)", "CONTRA_", variable),
      TRUE ~ variable # Keeps all other values unchanged
    ))  
 
  # Step 4: Sort by combined header data and column number, then assign step count
  metadata <- metadata %>%
    mutate(combined_header_data = paste0(filename, variable, axis)) %>% 
    arrange(combined_header_data, column_number) %>%
    group_by(combined_header_data) %>%
    mutate(step = row_number()) %>%
    ungroup() %>% 
    select(-combined_header_data)
  
  # Step 1: unpack filename into meaningful columns
  metadata <- metadata %>% 
    separate(col=filename, into = c("subject", "order", "condition", "start_stop"), sep = "_") %>%
    mutate(start_stop = str_replace(start_stop, ".c3d","")) 
  
  print("Metadata organized for join")  
  ################ Stage 2: Join tidy metadata with value data ###################### 
  # 1. Prepare the metadata
  metadata <- metadata %>%
    select(subject, order, condition, start_stop, stance_side, variable, axis, column_number, step) %>%
    mutate(column_id = paste0("X", column_number)) 
  
  # 2. Reshape the raw data
  long_data <- raw_data %>%
    rename(normalized_time = X1) %>% 
    pivot_longer(cols = -normalized_time, names_to = "column_id", values_to = "value") 
  
  # 3. Join the metadata with the reshaped raw data
  combined_data <- long_data %>%
    left_join(metadata, by = "column_id")
  
  # 4. Clean up and arrange the final dataset
  final_data <- combined_data %>%
    select(subject, order, condition, start_stop, stance_side, variable,  axis, step, value) 
  
  
  toc <- Sys.time()
  
  print(paste("Import completed at", toc))
  
  elapsed_time = toc - tic
  print(paste("Total time to import:", elapsed_time))
  
  return(final_data)
  
  }