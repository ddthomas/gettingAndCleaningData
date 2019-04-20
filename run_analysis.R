# The submitted data set is tidy.
# The Github repo contains the required scripts.
# GitHub contains a code book that modifies and updates the available codebooks with the data to indicate all the variables and summaries calculated, along with units, and any other relevant information.
# The README that explains the analysis files is clear and understandable.
# The work submitted for this project is the work of the student who submitted it.


# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only then mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.

# Load Packages
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)

# Set WD
setwd("/cloud/project/2-R-Programming/Clean")

# Read activity labels and features
activityLabels <- read.delim("UCI HAR Dataset/activity_labels.txt", sep = ' ', header = FALSE,
                   col.names = c("classLabels", "activityName"))

features <- read.delim("UCI HAR Dataset/features.txt", sep = ' ', header = FALSE,
                       col.names = c("index", "featureName"))

# Extract only the data on mean and standard deviation
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
# Change to camelCase for consitency
featuresWanted.names <- gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names <- gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)


# Load the TRAIN dataset
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("UCI HAR Dataset/train/y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

# Load the TEST dataset
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI HAR Dataset/test/y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Merge datasets
combined <- rbind(train, test)

# Label columns
colnames(combined) <- c("subject", "activity", featuresWanted.names)

# Change classLabels(int) to activityName(chr) -> factor
combined$activity <- factor(combined$activity, levels = activityLabels[,1], labels = activityLabels[,2])

# Change subject from int to factor
combined$subject <- as.factor(combined$subject)

# 
combined <- reshape2::melt(data = combined, id = c("subject", "activity"))
combined <- reshape2::dcast(data = combined, subject + activity ~ variable, fun.aggregate = mean)

write.table(combined, "tidyData.txt", row.names = FALSE, quote = FALSE)
