# Helper functions to manage Visual3D output
##################################################

# Load required libraries
library(tidyverse)

# Increase the connection buffer size
Sys.setenv("VROOM_CONNECTION_SIZE" = 10000000)


tsv_to_tidy <- function(data_directory, file_name) {
  # imports a tsv file exported from Visual3D that is in a VERY WIDE format
  # the data must be normalized with short filenames in the header. 
  # Filenames must be in the form: SUBJECTID_SIDE
   
  # Set up variables
  file_name_info <- file_name %>% str_remove(".tsv") %>% str_split_1("_")
  subject <- file_name_info[1]  # relies on naming convention
  stance_side <- file_name_info[2]  # relies on naming convention
  input_path <- file.path(data_directory, file_name)
  
  #browser()
  
  print(paste("Begin processing:",file_name))
  tic <- Sys.time()
  print("Stage 1: prepare metadata")
  
  print("Step 1: Read in header data")
  metadata <- read_tsv(input_path, n_max = 5, col_names = FALSE, show_col_types = FALSE)
  
  # view(metadata)
  print("Step 2: Transpose the metadata")
  metadata <- metadata %>%
    t() %>%
    as_tibble(.name_repair = "unique") %>%
    setNames(c("filename", "raw_variable", "type", "origin", "axis")) %>% 
    select(-type, -origin) # cannot see a use for these
  
  # view(metadata)
  
  print("Step 3: Track column order and clean up cruff (can't have sorted data up to this point)")
  metadata <- metadata %>%
    mutate(column_number = row_number()) %>% 
    slice(-1) # first column (now row) is just NA
  
  # view(metadata)
  
  print("Step 4: Clean up variable names to make side reflect IPSI or CONTRA in terms of stance side frame of reference.")
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
  
  # view(metadata)
  
  print("Step 5: Sort by combined header data and column number, then assign step count")
  metadata <- metadata %>%
    mutate(combined_header_data = paste0(filename, variable, axis, stance_side)) %>% 
    arrange(combined_header_data, column_number) %>%
    group_by(combined_header_data) %>%
    mutate(step = row_number()) %>%
    ungroup() %>% 
    select(-combined_header_data)
  
  # view(metadata)
  
  print("Step 6: unpack filename into meaningful columns")
  metadata <- metadata %>% 
    separate(col=filename, into = c("subject", "order", "condition", "start_stop"), sep = "_") %>%
    mutate(start_stop = str_replace(start_stop, ".c3d","")) 
  
  # view(metadata)
  
  print("Step 7: Map to Raw Data Column Names")
  metadata <- metadata %>%
    select(subject, order, condition, start_stop, stance_side, variable, axis, column_number, step) %>%
    mutate(column_id = paste0("X", column_number)) 
  
  # view(metadata)
  
  
  ########### Fold Raw Data into Long Metadata
  print("Stage 2: fold raw data into long metadata") 
  print("Step 1. Read the raw data")
  raw_data <- read_tsv(input_path, 
                       col_names = FALSE, 
                       skip = 5, 
                       show_col_types = FALSE,
                       col_types = cols(.default = col_double()))
  # view(raw_data)
  print("Step 2. Reshape the raw data")
  long_data <- raw_data %>%
    rename(normalized_time = X1) %>% 
    pivot_longer(cols = -normalized_time, names_to = "column_id", values_to = "value") 
  
  # view(long_data)
  
  print("Step 3. Join the metadata with the reshaped raw data.")
  combined_data <- long_data %>%
    left_join(metadata, by = "column_id")
  
  # view(combined_data)
  
  print("Step 4. Clean up and arrange the final dataset")
  tidy_data <- combined_data %>%
    select(subject, order, condition, start_stop, stance_side, variable,  axis, step, normalized_time, value) 
  
  toc <- Sys.time()
  
  print(paste("Import completed at", toc))
  
  elapsed_time = toc - tic
  print(paste("Total time to import:", elapsed_time))
  
  return(tidy_data) 
  
}


tidy_by_period <- function(tidy_data) {
  
  print("getting belt speed differences in each step")
  belt_speeds <- tidy_data %>% 
    ungroup() %>% 
    filter(str_detect(variable, "Belt")) %>% 
    filter(axis=="X") %>% 
    pivot_wider(names_from = variable, values_from = value) %>% 
    mutate(speed_difference = IPSI_BeltSpeed- CONTRA_BeltSpeed,
           abs_speed_difference = abs(speed_difference))
  
  print("determining max belt speed") 
  max_speed_diff <- belt_speeds %>% 
    group_by(subject, order,condition,start_stop, stance_side,axis, step) %>% 
    summarize(max_speed_diff = max(abs_speed_difference))

   
  # create helper function to identify change in belt speeds 
  find_change_point <- function(data, window_size = 5) {
    n <- nrow(data)
    max_diff <- 0 # this will get updated as 
    change_point <- NA
    
    for (i in (window_size + 1):(n - window_size)) {
      mean1 <- mean(data$max_speed_diff[(i-window_size):(i-1)])
      mean2 <- mean(data$max_speed_diff[i:(i+window_size-1)])
      diff <- abs(mean2 - mean1)
      if (diff > max_diff) {
        max_diff <- diff
        change_point <- data$step[i]
      }
    }
    
    return(change_point)
  }
 
  print("identifying where speed change occurs")
  # flag where speed change happens 
  speed_change_steps <- max_speed_diff %>%
    group_by(condition, start_stop) %>%
    summarize(change_point = find_change_point(cur_data())) %>% 
    ungroup()
  
  
  print("Assigning steps to appropriate period")
  # Assign steps to periods
  steps_to_include <- 5
  
  steps_by_period <- max_speed_diff %>%
    ungroup() %>% 
    select(-axis) %>%  
    left_join(speed_change_steps, by = c("condition", "start_stop")) %>% 
    group_by(subject, order, condition, start_stop, stance_side) %>% 
    mutate(last_step = max(step)) %>% 
    ungroup() %>% 
    mutate(period = case_when(
      
      start_stop == "start" & step >= 1 & step <= 5 ~ "start_first_five",
      start_stop == "start" & step >= last_step-5 & step <= last_step ~ "start_last_five",
      start_stop == "stop" & step >= 1 & step <= 5 ~ "stop_first_five",
      start_stop == "stop" & step >= last_step-5 & step <= last_step ~ "stop_last_five",
      start_stop == "start" & step >= (change_point - steps_to_include -1) & step < change_point-1 ~ "Late Baseline",
      start_stop == "start" & step > change_point & step < (change_point + steps_to_include +1 ) ~ "Early Adaptation",
      start_stop == "stop" & step >= (change_point - steps_to_include -1) & step < change_point-1 ~ "Late Adaptation",
      start_stop == "stop" & step > change_point & step < (change_point + steps_to_include +1) ~ "Early Post Adaptation",
      TRUE ~ NA_character_
    ),
    period = factor(period, levels = c("start_first_five", 
                                       "Late Baseline", 
                                       "Early Adaptation", 
                                       "start_last_five", 
                                       "stop_first_five", 
                                       "Late Adaptation", 
                                       "Early Post Adaptation", 
                                       "stop_last_five"))) 
  
  
  # fold in period to highly granular data and filter for only those with period assigned
  print("filtering data to only include observations assigned to a period")
  tidy_data_by_period <- tidy_data %>% 
    left_join(steps_by_period) %>% 
    filter(!is.na(period)) %>% 
    select(-max_speed_diff, -change_point)
   
  return(tidy_data_by_period)
   
}

