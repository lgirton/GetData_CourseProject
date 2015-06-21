#Tidy Dataset CodeBook

This codebook describes the source datasets, cleaning and transformations into the resultant "tidy" dataset.  The original dataset can be found at:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The archive extracts to a directory called 'UCI HAR Dataset' with the following are the files from that archive that were used in generating the tidy dataset for this assignment.

|File|Description|
|----|-----------|
|activity_labels.txt|A file containing the descriptive names for the activity labels|
|features.txt|A file containing the column names for the training and testing datasets|
|test/subject_test.txt|The subjects for the test dataset, there is a row for every row in the test dataset|
|test/X_test.txt|A dataset containing the sensor measurements and their statistics for the test dataset.  There was currently 561 attributes|
|test/y_test.txt|The labels (activity) for the test dataset, there is a row for every row in the test dataset|
|train/subject_train.txt|The subjects for the train dataset, there is a row for every row in the train dataset|
|train/X_train.txt|A dataset containing the sensor measurements and their statistics for the train dataset.  There was currently 561 attributes|
|train/y_train.txt|The labels (activity) for the train dataset, there is a row for every row in the train dataset|

## Preparing the dataset

In the first part of the run_analysis.R script, I load the 'features.txt', which contains the descriptive column names for the X_test.txt and X_train.txt datasets.  There are 561 rows in this dataset

```{r}
# Load column names of the train and test dataset
features <- read.table("./UCI HAR Dataset/features.txt", header = F,
                  col.names = c("idx","feature"), stringsAsFactors = F)
```

Next, the names are sanitized by replacing the parenthesis and converting the minus signs with the underscore character:

```{r}
# Strip parenthesis and covert '-' to '_'
features <- gsub("\\(|\\)", "", features$feature)
features <- gsub("-", "_", features)
```

Lastly, I use a regular expression to grep for the feature names that contain mean or std, per the course project instructions and store the indices in a vector called features_idx, which I use the subset the test and train columns.  This is results in 66 columns from the 561.

```{r}
features_idx <- grep("_(mean|std)(_|$)", features)

```

Next, I load the activity.txt file which contains the descriptive activity names for the labels in the y_test.txt and y_train.txt file.  This will be used later to transform the dataset with descriptive label names.

```{r}
activities <- read.table("./UCI HAR Dataset/activity_labels.txt", 
                         header = F, col.names = c("idx", "activity"))
```

The next step I perform is to combine the subject, data and labels into one file.  Because this operation is generally the same for both the test and train datasets, I've create a function that will do the following:

1. Read in the main dataset
2. Subset the columns to those that contain mean or std
3. Read in the subjects and labels
4. Replace labels with descriptive activity names
5. Combine the subject, main dataset and activity into a single data frame.

Below is the source code of the function.

```{r}
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
```

I use the function to create the consolidated train and testing datasets

```{r}
# Load train dataset with combined labels and subjects
train <- getdata("./UCI HAR Dataset/train/X_train.txt", 
                 "./UCI HAR Dataset/train/subject_train.txt", 
                 "./UCI HAR Dataset/train/y_train.txt")

# Load test dataset with combined labels and subjects
test <- getdata("./UCI HAR Dataset/test/X_test.txt", 
                "./UCI HAR Dataset/test/subject_test.txt", 
                "./UCI HAR Dataset/test/y_test.txt")

```

## Final Dataset

I use the dplyr package to create the final dataset:

1. Combine the test and train datasets
2. Transform from a wide dataset to the long form (Gather)
3. Calculate mean value of each of the measurements by subject and activity
4. Tranform the dataset back into the wide form (Spread)

```{r}

# Combine train and test dataset, gather (long) the measurement columns,
# summarise mean value by subject, activity and measurement and 
# then spread (wide) the data for a more condensed output.
data <- train %>%
  bind_rows(test) %>%
  gather(measurement, value, -subject, -activity) %>%
  group_by(subject, activity, measurement) %>%
  summarise(mean=mean(value)) %>%
  spread(measurement, mean)

```

This results in a dataset with 68 columns, which includes the subject for the observation, the descriptive activity, as well as the mean of the sensor data for the activity and subject

Below is a list of the column names in the dataset:

subject, activity, tBodyAcc_mean_X, tBodyAcc_mean_Y, tBodyAcc_mean_Z, tBodyAcc_std_X, tBodyAcc_std_Y, tBodyAcc_std_Z, tGravityAcc_mean_X, tGravityAcc_mean_Y, tGravityAcc_mean_Z, tGravityAcc_std_X, tGravityAcc_std_Y, tGravityAcc_std_Z, tBodyAccJerk_mean_X, tBodyAccJerk_mean_Y, tBodyAccJerk_mean_Z, tBodyAccJerk_std_X, tBodyAccJerk_std_Y, tBodyAccJerk_std_Z, tBodyGyro_mean_X, tBodyGyro_mean_Y, tBodyGyro_mean_Z, tBodyGyro_std_X, tBodyGyro_std_Y, tBodyGyro_std_Z, tBodyGyroJerk_mean_X, tBodyGyroJerk_mean_Y, tBodyGyroJerk_mean_Z, tBodyGyroJerk_std_X, tBodyGyroJerk_std_Y, tBodyGyroJerk_std_Z, tBodyAccMag_mean, tBodyAccMag_std, tGravityAccMag_mean, tGravityAccMag_std, tBodyAccJerkMag_mean, tBodyAccJerkMag_std, tBodyGyroMag_mean, tBodyGyroMag_std, tBodyGyroJerkMag_mean, tBodyGyroJerkMag_std, fBodyAcc_mean_X, fBodyAcc_mean_Y, fBodyAcc_mean_Z, fBodyAcc_std_X, fBodyAcc_std_Y, fBodyAcc_std_Z, fBodyAccJerk_mean_X, fBodyAccJerk_mean_Y, fBodyAccJerk_mean_Z, fBodyAccJerk_std_X, fBodyAccJerk_std_Y, fBodyAccJerk_std_Z, fBodyGyro_mean_X, fBodyGyro_mean_Y, fBodyGyro_mean_Z, fBodyGyro_std_X, fBodyGyro_std_Y, fBodyGyro_std_Z, fBodyAccMag_mean, fBodyAccMag_std, fBodyBodyAccJerkMag_mean, fBodyBodyAccJerkMag_std, fBodyBodyGyroMag_mean, fBodyBodyGyroMag_std, fBodyBodyGyroJerkMag_mean, fBodyBodyGyroJerkMag_std

