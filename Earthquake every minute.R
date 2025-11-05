# Hourly Data Fetcher and Analyzer
# Install required packages if needed:
# install.packages(c("httr", "readr", "dplyr", "lubridate", "cronR", "notifier"))

library(httr)
library(readr)
library(dplyr)
library(lubridate)

# Set working directory to the location of this script
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  # If running in RStudio, use the script's location
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  if (script_path != "") {
    setwd(script_path)
  }
} else {
  # If running from command line, use the script's location
  script_path <- dirname(sys.frame(1)$ofile)
  if (!is.null(script_path) && script_path != "") {
    setwd(script_path)
  }
}

cat("Working directory:", getwd(), "\n\n")

# Configuration
# Example URLs to try:
# Earthquakes (updates every minute): "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.csv"
# Weather stations: "https://www.ndbc.noaa.gov/data/latest_obs/latest_obs.txt"
# COVID data: "https://covid.ourworldindata.org/data/owid-covid-data.csv"

URL <- "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.csv"
OUTPUT_DIR <- file.path(getwd(), "data_files")
ANALYSIS_DIR <- file.path(getwd(), "analysis_results")

# Create directories if they don't exist
dir.create(OUTPUT_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(ANALYSIS_DIR, showWarnings = FALSE, recursive = TRUE)

# Function to fetch and save data
fetch_and_save <- function(url, output_dir) {
  
  # Generate timestamp for filename
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  filename <- file.path(output_dir, paste0("data_", timestamp, ".csv"))
  
  tryCatch({
    # Fetch data
    cat("Fetching data from:", url, "\n")
    response <- GET(url)
    
    # Check if request was successful
    if (status_code(response) == 200) {
      
      # Save raw content
      writeBin(content(response, "raw"), filename)
      cat("Data saved to:", filename, "\n")
      
      # Read the data for analysis
      data <- read_csv(filename, show_col_types = FALSE)
      
      return(list(success = TRUE, filename = filename, data = data))
      
    } else {
      cat("Error: HTTP status code", status_code(response), "\n")
      return(list(success = FALSE, error = paste("HTTP", status_code(response))))
    }
    
  }, error = function(e) {
    cat("Error fetching data:", e$message, "\n")
    return(list(success = FALSE, error = e$message))
  })
}

# Function to send notification
send_notification <- function(message, title = "Data Fetcher Alert") {
  
  # Option 1: Console notification
  cat("\n", rep("=", 50), "\n")
  cat(title, "\n")
  cat(message, "\n")
  cat(rep("=", 50), "\n\n")
  
  # Option 2: System notification (Windows/Mac/Linux)
  # Uncomment if you want system notifications:
  # if (requireNamespace("notifier", quietly = TRUE)) {
  #   notifier::notify(title = title, msg = message)
  # }
  
  # Option 3: Email notification using mailR
  # Uncomment and configure if you want email alerts:
  # library(mailR)
  # send.mail(from = "your@email.com",
  #           to = "your@email.com",
  #           subject = title,
  #           body = message,
  #           smtp = list(host.name = "smtp.gmail.com", 
  #                      port = 465,
  #                      user.name = "your@email.com",
  #                      passwd = "your_password",
  #                      ssl = TRUE),
  #           authenticate = TRUE,
  #           send = TRUE)
}

# Function to analyze data
analyze_data <- function(data, filename) {
  
  tryCatch({
    cat("\n--- Analysis Report ---\n")
    
    # Basic statistics
    cat("Number of rows:", nrow(data), "\n")
    cat("Number of columns:", ncol(data), "\n")
    cat("Column names:", paste(names(data), collapse = ", "), "\n\n")
    
    # Summary statistics
    cat("Summary:\n")
    print(summary(data))
    
    # Save analysis report
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
    report_file <- file.path(ANALYSIS_DIR, paste0("analysis_", timestamp, ".txt"))
    
    sink(report_file)
    cat("Analysis Report\n")
    cat("Generated:", Sys.time(), "\n")
    cat("Source file:", filename, "\n\n")
    cat("Dimensions:", nrow(data), "rows x", ncol(data), "columns\n\n")
    cat("Summary Statistics:\n")
    print(summary(data))
    sink()
    
    cat("\nAnalysis saved to:", report_file, "\n")
    
    return(list(success = TRUE, report_file = report_file))
    
  }, error = function(e) {
    cat("Error analyzing data:", e$message, "\n")
    return(list(success = FALSE, error = e$message))
  })
}

# Main function to run the complete workflow
run_hourly_fetch <- function() {
  
  cat("\n")
  cat("========================================\n")
  cat("Starting hourly data fetch\n")
  cat("Time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
  cat("========================================\n\n")
  
  # Step 1: Fetch and save data
  result <- fetch_and_save(URL, OUTPUT_DIR)
  
  if (result$success) {
    
    # Step 2: Send success notification
    send_notification(
      message = paste("Data successfully fetched and saved to:", result$filename),
      title = "Data Fetch Successful"
    )
    
    # Step 3: Analyze data
    analysis <- analyze_data(result$data, result$filename)
    
    if (analysis$success) {
      send_notification(
        message = paste("Analysis completed. Report saved to:", analysis$report_file),
        title = "Analysis Complete"
      )
    }
    
  } else {
    # Send error notification
    send_notification(
      message = paste("Failed to fetch data. Error:", result$error),
      title = "Data Fetch Failed"
    )
  }
}

# Run once immediately
run_hourly_fetch()

# Continuous loop - fetches data every 10 minutes
cat("\n")
cat("========================================\n")
cat("Starting continuous monitoring\n")
cat("Fetching data every 10 minutes\n")
cat("Press ESC or Ctrl+C to stop\n")
cat("========================================\n\n")

while(TRUE) {
  Sys.sleep(60)  # Sleep for 10 minutes (600 seconds)
  run_hourly_fetch()
}

# ============================================
# Alternative scheduling methods:
# ============================================

# Method 1: Use taskscheduleR (Windows - better for long-term scheduling)
# install.packages("taskscheduleR")
# library(taskscheduleR)
# taskscheduler_create(
#   taskname = "data_fetch_10min",
#   rscript = rstudioapi::getSourceEditorContext()$path,
#   schedule = "MINUTE",
#   modifier = 10
# )

# Method 2: Use cronR (Linux/Mac)
# install.packages("cronR")
# library(cronR)
# cmd <- cron_rscript(rscript = rstudioapi::getSourceEditorContext()$path)
# cron_add(command = cmd, frequency = "*/10 * * * *", id = "data_fetch_10min")

# Method 3: Custom interval (change 600 to desired seconds)
# 600 = 10 minutes
# 3600 = 1 hour
# 1800 = 30 minutes
# 300 = 5 minutes