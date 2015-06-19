library(dplyr)
library(tidyr)

zipurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

#Download and zip dataset if the 'UCI HAR Dataset' directory doesn't exist
if (!file.exists("UCI HAR Dataset")) {
  zipfile <- "UCI HAR Dataset.zip"
  download.file(zipurl, destfile = zipfile, method = "curl")
  unzip(zipfile)
}

# Load column names of the train and test dataset
features <- read.table("./UCI HAR Dataset/features.txt", header = F,
                  col.names = c("idx","feature"), stringsAsFactors = F)

# Strip parenthesis and covert '-' to '_'
features <- gsub("\\(|\\)", "", features$feature)
features <- gsub("-", "_", features)

# We're only interested in the features that describe the mean or std
# Get a vector of indices for features that contain 'mean' or 'std' in
# them.
features_idx <- grep("_(mean|std)(_|$)", features)

# Read labels (activity names)
activities <- read.table("./UCI HAR Dataset/activity_labels.txt", 
                         header = F, col.names = c("idx", "activity"))

# Much of the data reading, combining and transformations on the train and test
# datasets are the same, so this is a utility function to consolidate the 
# functionality in one place
getdata <- function(datafile, subjfile, lablfile) {
  
  # Read the data file
  data <- read.table(datafile, header = F, colClasses = rep("numeric", length(features)))
  
  # Reduce columns to those with mean and std
  data <- data[features_idx]
  colnames(data) <- features[features_idx]
  
  # Read the subjects
  subj <- read.table(subjfile, header = F, col.names = "subject")
  
  # Read the labels
  labl <- read.table(lablfile, header = F, col.names = "activity")
  labl$activity <- factor(labl$activity, levels=activities$idx, 
                          labels=activities$activity)
  
  # Combine columns into one dataset
  data <- bind_cols(subj, data, labl)

  return(data)
}

# Load train dataset with combined labels and subjects
train <- getdata("./UCI HAR Dataset/train/X_train.txt", 
                 "./UCI HAR Dataset/train/subject_train.txt", 
                 "./UCI HAR Dataset/train/y_train.txt")

# Load test dataset with combined labels and subjects
test <- getdata("./UCI HAR Dataset/test/X_test.txt", 
                "./UCI HAR Dataset/test/subject_test.txt", 
                "./UCI HAR Dataset/test/y_test.txt")

# Combine train and test dataset, gather (long) the measurement columns,
# summarise mean value by subject, activity and measurement and 
# then spread (wide) the data for a more condensed output.
data <- train %>%
  bind_rows(test) %>%
  gather(measurement, value, -subject, -activity) %>%
  group_by(subject, activity, measurement) %>%
  summarise(mean=mean(value)) %>%
  spread(measurement, mean)

write.table(data, "tidydataset.txt", quote = F, row.names = F)
  
  