#clean up the workspace
rm(list = ls())

#set working directory
setwd("~/Desktop/JHU/getting and cleaning data/UCI HAR Dataset")

#read training data
features       = read.table('./features.txt',header=FALSE)
activityLabels = read.table('./activity_labels.txt',header=FALSE)
subjectTrain   = read.table('./train/subject_train.txt',header=FALSE)
xTrain         = read.table('./train/x_train.txt',header=FALSE)
yTrain         = read.table('./train/y_train.txt',header=FALSE)

#add column names
colnames(activityLabels)  = c('activityId','activityLabel');
colnames(subjectTrain)  = "subjectId";
colnames(xTrain)        = features[,2]; 
colnames(yTrain)        = "activityId";

#create training set
trainingSet = cbind(subjectTrain,xTrain,yTrain)

#read the test data
subjectTest = read.table('./test/subject_test.txt',header=FALSE);
xTest       = read.table('./test/x_test.txt',header=FALSE); 
yTest       = read.table('./test/y_test.txt',header=FALSE); 

#add column names
colnames(subjectTest) = "subjectId";
colnames(xTest)       = features[,2]; 
colnames(yTest)       = "activityId";

#create test set
testSet = cbind(subjectTest,xTest,yTest)

#combine the training and test set
finalSet = rbind(trainingSet,testSet)

#get column names
colNames = colnames(finalSet)

#choose "mean" and "std" measures
nameWanted = (grepl("activity..",colNames) | grepl("subject..",colNames) | grepl("-mean..",colNames) & !grepl("-meanFreq..",colNames) & !grepl("mean..-",colNames) | grepl("-std..",colNames) & !grepl("-std()..-",colNames));
finalSet = finalSet[nameWanted==T]
finalSet = merge(finalSet,activityLabels,by='activityId',all.x=T)
colNames  = colnames(finalSet) 

#add descriptive names to each column
for (i in 1:length(colNames)) 
{
  colNames[i] = gsub("\\()","",colNames[i])
  colNames[i] = gsub("-std$","StdDev",colNames[i])
  colNames[i] = gsub("-mean","Mean",colNames[i])
  colNames[i] = gsub("^(t)","Time",colNames[i])
  colNames[i] = gsub("^(f)","Freq",colNames[i])
  colNames[i] = gsub("([Gg]ravity)","Gravity",colNames[i])
  colNames[i] = gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body",colNames[i])
  colNames[i] = gsub("[Gg]yro","Gyro",colNames[i])
  colNames[i] = gsub("AccMag","AccMagnitude",colNames[i])
  colNames[i] = gsub("([Bb]odyaccjerkmag)","BodyAccJerkMagnitude",colNames[i])
  colNames[i] = gsub("JerkMag","JerkMagnitude",colNames[i])
  colNames[i] = gsub("GyroMag","GyroMagnitude",colNames[i])
}
colnames(finalSet) = colNames;

#gather the mean values of the dataset
finalSetNoActivityLabel = finalSet[,names(finalSet) != 'activityLabel'];
tidySet = aggregate(finalSetNoActivityLabel[,names(finalSetNoActivityLabel) != c('activityId','subjectId')],by=list(activityId=finalSetNoActivityLabel$activityId,subjectId = finalSetNoActivityLabel$subjectId),mean)
tidySet = merge(tidySet,activityLabels,by='activityId',all.x=T)

#export the result
write.table(tidySet, './tidySet.txt',row.names=F,sep='\t')
