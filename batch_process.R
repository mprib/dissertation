
library(rmarkdown)
library(purrr)
library(glue)

# Define the output directory - modify this path as needed
output_dir <- "C:\\Users\\Mac Prible\\OneDrive - The University of Texas at Austin\\research\\PDSV\\data\\PDVS_2024\\v3d\\subject_reports"

# Define list of subjects with deliberate case
subjects <- c(
  "s1", 
  "S2",
  "S3",
  "S4",
  "S5"
) 

# Function to render for a single subject
render_subject_report <- function(subject) {
  message(glue("\nStarting to process {subject}"))
  message(glue("Current working directory: {getwd()}"))
  
  # Create output filename
  output_filename <- glue("{subject}_report.html")
  message(glue("Output filename will be: {output_filename}"))
  
  # Full output path
  output_file <- file.path(output_dir, output_filename)
  message(glue("Full output path: {output_file}"))
  
  # Render the R Markdown document with parameters
  tryCatch({
    message(glue("Attempting to render with params$subject = {subject}"))
    render(
      input = "process_single_subject.Rmd",
      output_file = output_file,
      params = list(subject = subject),
      quiet = FALSE  # Changed to FALSE to see more detail
    )
    message(glue("Successfully processed subject {subject}"))
  }, error = function(e) {
    message(glue("Full error message for {subject}: {e$message}"))
    message("Stack trace:")
    print(e)
  })
}

# Create output directory if it doesn't exist
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Process subjects one at a time
for(subject in subjects) {
  render_subject_report(subject)
}

message("Processing complete!")