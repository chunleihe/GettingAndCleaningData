# Getting and Cleaning Data Course Assignment

##Goal

Companies like *FitBit, Nike,* and *Jawbone Up* are racing to develop the most advanced algorithms to attract new users. The data linked are collected from the accelerometers from the Samsung Galaxy S smartphone. 

A full description is available at the site where the data was obtained:  

<http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>

The data is available at:

<https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>

The aim of the project is to clean and extract usable data from the above zip file. R script called run_analysis.R that does the following:
- Merges the training and the test sets to create one data set.
- Extracts only the measurements on the mean and standard deviation for each measurement. 
- Uses descriptive activity names to name the activities in the data set
- Appropriately labels the data set with descriptive variable names. 
- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

In this repository, you find:

- *run_analysis.R* : the R-code run on the data set

- *Tidy.txt* : the clean data extracted from the original data using *run_analysis.R*

- *CodeBook.md* : the CodeBook reference to the variables in *Tidy.txt*

- *README.md* : the analysis of the code in *run_analysis.R*


## Getting Started

### Assumption
The R code in *run_analysis.R* proceeds under the assumption that the zip file available at <https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip> is downloaded and extracted in a certain Directory.

###Libraries Used

The libraries used in this operation are `data.table`. We prefer `data.table` as it is efficient in handling large data as tables. 
```{r}
if (!require("data.table")) {
  install.packages("data.table")
}

require("data.table")
```
## Load library
```{r}
if (!require("data.table")) {
  install.packages("data.table")
}

require("data.table")

setwd("C:/home/hadoop/coursera/Homework/Course3/UCI HAR Dataset")
```

## Read all the data

### Read features and activitylabels
```{r}
featureNames <- read.table("features.txt")
activityLabels <- read.table("activity_labels.txt", header = FALSE)
```

### Read test set
```{r}
test.labels <- read.table("test/y_test.txt", col.names="label")
test.subjects <- read.table("test/subject_test.txt", col.names="subject")
test.data <- read.table("test/X_test.txt")
```

### Read training set
```{r}
training.labels <- read.table("train/y_train.txt", col.names="label")
training.subjects <- read.table("train/subject_train.txt", col.names="subject")
training.data <- read.table("train/X_train.txt")
```

##Part 1. Merges the training and the test sets to create one data set.
```{r}
total.labels <- rbind(training.labels, test.labels)
total.subjects <- rbind(training.subjects, test.subjects)
total.data <- rbind(training.data, test.data)
```

### Naming the columns
```{r}
colnames(total.data) <- t(featureNames[2])
colnames(total.labels) <- "Activity"
colnames(total.subjects) <- "Subject"

completeDataSet <- cbind(total.data,total.labels,total.subjects)
```

## Part2. Extracts only the measurements on the mean and standard deviation for each measurement.

### Find the columns on the mean and standard deviation including the last two added columns
```{r}
columnsWithMeanSTD <- grep(".*Mean.*|.*Std.*", names(completeDataSet), ignore.case=TRUE)
requiredColumns <- c(columnsWithMeanSTD, 562, 563)
dim(completeDataSet)
```

### Extract the columns required only to extractedDataSet
```{r}
extractedDataSet <- completeDataSet[,requiredColumns]
dim(extractedDataSet)
```
## Part 3. Uses descriptive activity names to name the activities in the data set
```{r}
extractedDataSet$Activity <- as.character(extractedDataSet$Activity)
for (i in 1:6){
  extractedDataSet$Activity[extractedDataSet$Activity == i] <- as.character(activityLabels[i,2])
}
extractedDataSet$Activity <- as.factor(extractedDataSet$Activity)
```

## Part 4.Appropriately labels the data set with descriptive variable names.

### List all the column names
```{r}
desColNames <- names(extractedDataSet)
```

### Remove every non-alphabetic character and converting to lowercase
```{r}
desColNames <- tolower(gsub("[^[:alpha:]]", "", desColNames))
```

### Use the list as column names for data
```{r}
colnames(extractedDataSet) <- desColNames
```
## Part 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

### Aggreate extractDataSet group by subject and activity
```{r}
extractedDataSet$subject <- as.factor(extractedDataSet$subject)
extractedDataSet <- data.table(extractedDataSet)
tidyDataSet <- aggregate(. ~subject + activity, extractedDataSet, mean)
```

### Create the Tidy.txt file with the tidyDataSet
```{r}
tidyDataSet <- tidyData[order(tidyDataSet$subject,tidyDataSet$activity),]
write.table(tidyDataSet, file = "./Tidy.txt", row.names = FALSE)
```