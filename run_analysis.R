#The script 'run_analysis.R' is used to clean the 'training' data set and the 'test' dat sets and merge them together. It is used to finish the following task:
#======================
# 1. Merges the training and the test sets into one data set

# use fast dtplyr package
library(dtplyr)
setwd(....mycomputer/data_incubator/uci_har_dataset)
# create new folder: train+test to save all combined data
if(!file.exists("./train+test")){dir.create("./train+test")}
# concatenate train dat and test data into one combined data
for (file in c("X", "y", "subject")) {
  trainfile = paste("./train/", file, "_train.txt", sep="")
  testfile =  paste("./test/",  file, "_test.txt",sep="")
  writefile = paste("./train+test/", file, ".txt", sep="")
  fwrite(bind_rows(fread(trainfile), fread(testfile)), file = writefile)
}
setwd("./train+test")



# 2.Extracts only the measurements on the mean and standard deviation for each measurement. 

  a <- fread("X.txt")  # open data file
  feature <- fread("../features.txt") # open column name file
  names(a) = feature$V2  # rename variable names
  meanstd = select(a, grep("std[(][)]|mean[(][)]", names(a)))  # select mean() and std()
  fwrite(meanstd, file="./X_mean_std.txt")   # save file into X_mean_std.txt
  rm(a, feature)

# 3.Uses descriptive activity names to name the activities in the data set
  
  # change name for activity
  y = fread("y.txt")
  activity = fread("../activity_labels.txt")
  fwrite(mutate(y, V1 = activity$V2[V1]), file="y_with_descriptive_name.txt")
  # combine all data into a single table: 'subjectid_activity_variables.txt'
  X = fread("./X_mean_std.txt"); y = fread("./y_with_descriptive_name.txt"); subject = fread("./subject.txt")
  all = bind_cols(subject, y, X)
  fwrite(all, "subjectid_activity_variables.txt")  
  
# 4. Appropriately labels the data set with descriptive variable names.

# Note: Variable names in the dataset have already been substituted 
# by descriptive names

  all = fread("subjectid_activity_variables.txt") 
  names(all)[1] = "subjectid" 
  fwrite(all, file="subjectid_activity_variables.txt")
  
  all = fread("subjectid_activity_variables.txt") 
  names(all)[2] = "activitytype" 
  fwrite(all, file="subjectid_activity_variables.txt")


# 5. From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.
  all = fread("subjectid_activity_variables.txt") 
  newtable <- all %>% gather(variable, value, -activitytype, -subjectid) %>% 
    group_by(variable, activitytype, subjectid) %>% 
    summarise(average = mean(value))
  fwrite(newtable, file="average_per_variable_per_activity_per_subject.txt")

  # 6. delete all unnecessary files
  file.remove("X.txt", "X_mean_std.txt", "y.txt", "subject.txt", "y_with_descriptive_name.txt")