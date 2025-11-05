Automated Data Fetcher
An R-based automated data collection system that fetches data from web sources at regular intervals, saves it locally, and performs basic analysis.
Features

🔄 Automatic Data Collection: Fetches data every 1 minute (configurable)
💾 Timestamped Storage: Saves each fetch with unique timestamp
📊 Automated Analysis: Generates summary statistics and reports
🔔 Notifications: Console alerts for successful/failed fetches
📁 Organized Output: Separate folders for data and analysis results

Prerequisites

R (version 4.0.0 or higher)
RStudio (recommended)

Installation

Clone this repository:

bashgit clone https://github.com/yourusername/automated-data-fetcher.git
cd automated-data-fetcher

Install required R packages:

rinstall.packages(c("httr", "readr", "dplyr", "lubridate"))

(Optional) For background scheduling:

r# Windows
install.packages("taskscheduleR")

# Linux/Mac
install.packages("cronR")
Usage
Basic Usage (Continuous Running)

Open data_fetcher.R in RStudio
Configure your data source URL (line 30)
Run the script - it will fetch data every 1 minute

rsource("data_fetcher.R")
To stop: Press ESC or Ctrl+C
Change Fetch Interval
Edit line in the script:
rSys.sleep(60)  # 60 seconds = 1 minute
Common intervals:

5 minutes: 300
10 minutes: 600
30 minutes: 1800
1 hour: 3600

Background Scheduling (Windows)
For unattended operation without keeping RStudio open:
rlibrary(taskscheduleR)
taskscheduler_create(
  taskname = "data_fetch_10min",
  rscript = "path/to/data_fetcher.R",
  schedule = "MINUTE",
  modifier = 10
)
Data Sources
The script is pre-configured with USGS Earthquake data, but you can use any CSV/TXT URL:
Suggested Sources:

Earthquakes: https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.csv
Weather Buoys: https://www.ndbc.noaa.gov/data/latest_obs/latest_obs.txt
COVID Data: https://covid.ourworldindata.org/data/owid-covid-data.csv

Simply change the URL variable in the script.
Project Structure
automated-data-fetcher/
├── data_fetcher.R          # Main script
├── README.md               # This file
├── .gitignore             # Git ignore rules
├── data_files/            # Downloaded data (timestamped)
└── analysis_results/      # Analysis reports (timestamped)
Output Files
Data Files
Located in data_files/, named as:
data_20241105_143022.csv
data_20241105_144022.csv
Analysis Reports
Located in analysis_results/, named as:
analysis_20241105_143022.txt
analysis_20241105_144022.txt
Configuration
Edit these variables at the top of data_fetcher.R:
rURL <- "your-data-source-url"
OUTPUT_DIR <- file.path(getwd(), "data_files")
ANALYSIS_DIR <- file.path(getwd(), "analysis_results")
Notifications
Currently supports:

✅ Console notifications (default)
📧 Email notifications (commented out - requires configuration)
🔔 System notifications (commented out - requires notifier package)

Troubleshooting
Script won't run

Ensure all packages are installed
Check that the URL is accessible
Verify you have write permissions in the directory

Data not saving

Check the console for error messages
Verify the URL returns valid CSV/TXT data
Ensure data_files folder exists

Can't stop the script

Press ESC in RStudio
Press Ctrl+C in R console
Close RStudio (last resort)

Contributing
Contributions are welcome! Please feel free to submit a Pull Request.
License
MIT License - feel free to use this project for any purpose.
Author
Your Name
Acknowledgments

USGS for providing earthquake data API
R community for excellent packages
