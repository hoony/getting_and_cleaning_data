filename <- "datasets.zip"
outputname <- "output.txt"
foldername <- "UCI HAR Dataset"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
  unzip(filename)
}

# Set Activity Labels
activityLabels <- read.table(paste(foldername, "/activity_labels.txt", sep=""))
activityLabels[,2] <- as.character(activityLabels[,2])

# Set features and features that need to extract
allFeatures <- read.table(paste(foldername, "/features.txt", sep=""))[,2]
allFeatures <- as.character(allFeatures)
features <- grep(".*mean.*|.*std.*", allFeatures)
featureColNames <- allFeatures[features]

# Load the datasets
train <- read.table(paste(foldername, "/train/X_train.txt", sep=""))[features]
trainActivities <- read.table(paste(foldername, "/train/Y_train.txt", sep=""))
trainSubjects <- read.table(paste(foldername, "/train/subject_train.txt", sep=""))
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table(paste(foldername, "/test/X_test.txt", sep=""))[features]
testActivities <- read.table(paste(foldername, "/test/Y_test.txt", sep=""))
testSubjects <- read.table(paste(foldername, "/test/subject_test.txt", sep=""))
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featureColNames)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, outputname, row.names = FALSE, quote = FALSE)