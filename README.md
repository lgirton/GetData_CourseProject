# Getting and Cleaning Data Course Project

The purpose of this project to retrieve, clean and transform the following dataset located at:

[UCI HAR Dataset](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) 

The *run_analysis.R* script has been provided to merge and clean the datasets within the archive above.  *run_analysis.R* will download the UCI HAR Dataset.zip and stage the contents to the working directory if the contents don't already exist.  See [CodeBook.md](./CodeBook.md) for additional information on the transforms executed on the original datasets, as well as the tidy dataset variable definitions.  

In addition to the base packages installed with R, *run_analysis.R* has a dependency on the following libraries:

* dplyr
* tidyr

These can be installed using the following commands:

```
install.packages("dplyr")
install.packages("tidyr")

```
The *run_analysis.R*, *README.md*, *CodeBook.md* are the only files necessary to satisfy the Course Project assignment, but I have also included a Rmarkdown file, [Prediction.Rmd](./Prediction.Rmd) and the corresponding generated Markdown file [Prediction.md](./Prediction.md) that goes a little further to make predictions on the using Random Forest decision tree classifier.  Additionally, I delve into using Principal Components Analysis (PCA) on the dataset to reduce some of the dimensions to aid in visualizing the dataset, as well as compare models built using a subset of the principal components to that of the original dataset.

(SPOILER ALERT: The model is able to achieve 97% accuracy in predicting the activity!).


