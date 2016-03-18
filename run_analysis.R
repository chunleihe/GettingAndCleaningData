## Load library
if (!require("data.table")) {
  install.packages("data.table")
}

require("data.table")

setwd("C:/home/hadoop/coursera/Homework/Course3/UCI HAR Dataset")

## Read all the data

### Read features and activitylabels
featureNames <- read.table("features.txt")
activityLabels <- read.table("activity_labels.txt", header = FALSE)


### Read test set
test.labels <- read.table("test/y_test.txt", col.names="label")
test.subjects <- read.table("test/subject_test.txt", col.names="subject")
test.data <- read.table("test/X_test.txt")


### Read training set
training.labels <- read.table("train/y_train.txt", col.names="label")
training.subjects <- read.table("train/subject_train.txt", col.names="subject")
training.data <- read.table("train/X_train.txt")

##Part 1. Merges the training and the test sets to create one data set.

total.labels <- rbind(training.labels, test.labels)
total.subjects <- rbind(training.subjects, test.subjects)
total.data <- rbind(training.data, test.data)

### Naming the columns
colnames(total.data) <- t(featureNames[2])
colnames(total.labels) <- "Activity"
colnames(total.subjects) <- "Subject"

completeDataSet <- cbind(total.data,total.labels,total.subjects)

## Part2. Extracts only the measurements on the mean and standard deviation for each measurement.

### Find the columns on the mean and standard deviation including the last two added columns
columnsWithMeanSTD <- grep(".*Mean.*|.*Std.*", names(completeDataSet), ignore.case=TRUE)
requiredColumns <- c(columnsWithMeanSTD, 562, 563)
dim(completeDataSet)

### Extract the columns required only to extractedDataSet
extractedDataSet <- completeDataSet[,requiredColumns]
dim(extractedDataSet)

## Part 3. Uses descriptive activity names to name the activities in the data set

extractedDataSet$Activity <- as.character(extractedDataSet$Activity)
for (i in 1:6){
  extractedDataSet$Activity[extractedDataSet$Activity == i] <- as.character(activityLabels[i,2])
}
extractedDataSet$Activity <- as.factor(extractedDataSet$Activity)

## Part 4.Appropriately labels the data set with descriptive variable names.

### List all the column names
desColNames <- names(extractedDataSet)
### Remove every non-alphabetic character and converting to lowercase
desColNames <- tolower(gsub("[^[:alpha:]]", "", desColNames))
### Use the list as column names for data
colnames(extractedDataSet) <- desColNames

## Part 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

### Aggreate extractDataSet group by subject and activity
extractedDataSet$subject <- as.factor(extractedDataSet$subject)
extractedDataSet <- data.table(extractedDataSet)
tidyDataSet <- aggregate(. ~subject + activity, extractedDataSet, mean)


### Create the Tidy.txt file with the tidyDataSet
tidyDataSet <- tidyData[order(tidyDataSet$subject,tidyDataSet$activity),]
write.table(tidyDataSet, file = "./Tidy.txt", row.names = FALSE)

