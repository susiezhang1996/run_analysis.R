# 1.Merges the training and the test sets to create one data set
# Read file
library(reshape2)
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

# Unzip dataSet to /data directory
unzip(zipfile="./data/Dataset.zip",exdir="./data")
# Read tables
subject <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
xtrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
ytrain <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
train <- cbind(subject,ytrain,xtrain)
subjecttest <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
xtest <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
ytest <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
test <- cbind(subjecttest,ytest,xtest)
features <- read.table("./data/UCI HAR Dataset/features.txt")
colnames(xtrain) <- features[,2] 
colnames(ytrain) <-"activityId"
colnames(subject) <- "subjectId"

colnames(xtest) <- features[,2] 
colnames(ytest) <- "activityId"
colnames(subjecttest) <- "subjectId"
# merge two data set together
mergeddata <- rbind(train, test)


# 2.Extracts only the measurements on the mean and standard deviation for each measurement
Names <- colnames(mergeddata)
mean_std <- grep("mean\\(\\)|std\\(\\)", Names, value = TRUE)
mean_stddate <- subset(mergeddata, select = mean_std)
data1 <- subset(mergeddata, select = c("subjectId","activityId"))
mean_stddata <- cbind(mean_stddate,data1)
str(mean_stddata)

# 3.Uses descriptive activity names to name the activities in the data set
Labels <- read.table('./data/UCI HAR Dataset/activity_labels.txt')
colnames(Labels) <- c('activityId','activityType')
ActivityNames <- merge(mean_stddata, Labels, by.x = "activityId",by.y = "activityId", all = TRUE)
str(ActivityNames)

# 4.Appropriately labels the data set with descriptive variable names.
names(mergeddata)<-gsub("^t", "time", names(mergeddata))
names(mergeddata)<-gsub("^f", "frequency", names(mergeddata))
names(mergeddata)<-gsub("Acc", "Accelerometer", names(mergeddata))
names(mergeddata)<-gsub("Gyro", "Gyroscope", names(mergeddata))
names(mergeddata)<-gsub("Mag", "Magnitude", names(mergeddata))
names(mergeddata)<-gsub("BodyBody", "Body", names(mergeddata))

# 5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(plyr);
finalData<-aggregate(. ~subjectId + activityId, mergeddata, mean)
finalData<-finalData[order(finalData$subjectId,finalData$activityId),]
write.table(finalData, file = "tdata.txt",row.name=FALSE)
