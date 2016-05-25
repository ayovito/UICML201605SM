#Author:  Sam Mourad
#Date:    1/9/2016
#Notes:
#   Script to contain utility functions including data load.

#Clear environment
rm(list=ls())

#Load Libraries
library(RODBC)


#Set Variables####

#Set environment variables
dbConnStr = paste0('driver={SQL Server Native Client 11.0};',
                   'server=.;',
                   'database=UIC;',
                   'trusted_connection=yes;')

targetVar = 'NextReport'

predThreshold = 0.9

trainPerc = 0.75

#Load and prep Data####

#Set up connection and load data object -- replace by a function
dbConn = odbcDriverConnect(connection=dbConnStr)
reportData = sqlQuery(dbConn, 'SELECT * FROM dbo.vw_DataFrame')
close(dbConn)


# #Get the data
# reportData = loadData()


#Number of data points in the training set
nTrain = ceiling(dim(reportData)[1] * trainPerc)

#Random data points for training set
idxTrain = sample(x=as.integer(rownames(reportData)), size=nTrain)

#Get Training and Validation sets
finalData = {}
finalData$Train = reportData[idxTrain,]
finalData$Valid = reportData[-idxTrain,]

#Remove index variable
#Get column index of index variable
idx = which(colnames(reportData)=="ReportID")

#Move index values to row names and delete index variable
rownames(finalData$Train) = finalData$Train[,"ReportID"]
finalData$Train = finalData$Train[, -idx]

rownames(finalData$Valid) = finalData$Valid[,"ReportID"]
finalData$Valid = finalData$Valid[, -idx]

#Get index of Target Variable
finalData$targetIdx = which(colnames(finalData$Train)==targetVar)

dObj= finalData
# #Shuffle/split data for cross-validation
# dObj = splitData(x=reportData, perc=0.8,
#                  targetVar=targetVar, indexVar='ReportID')


#Check labels of Target Variable
length(unique(dObj$Train[,dObj$targetIdx]))

tbt = as.data.frame(table(dObj$Train[,dObj$targetIdx]))
tbt = tbt[order(tbt$Freq, decreasing=T),]
View(tbt)

tbv = as.data.frame(table(dObj$Valid[,dObj$targetIdx]))
tbv = tbv[order(tbv$Freq, decreasing=T),]
View(tbv)

rm(list=c('tbt','tbv'))


#Model Training####

#Train randomForest
library(randomForest)

rfMod = randomForest(NextReport ~ .,
                     data=dObj$Train,
                     importance=T,
                     proximity=F,
                     #mtry=sqrt(dim(dObj$Train)[2]-1),
                     ntree=100)

# #Remove classes with low count
# tb = as.data.frame(table(reportData$NextReport))
# tb = tb[order(tb$Freq, decreasing=T),]
# tb$cumperc =
#   apply(as.data.frame(tb[,"Freq"]), 2, function(x) cumsum(x)/sum(x))
# tb = tb[which(tb$cumperc<=.99),]

# #Train extraTrees
# library(extraTrees)
# 
# tgtIdx = which(colnames(dObj$Train)==targetVar)
# etMod = extraTrees(x=dObj$Train[,-tgtIdx], 
#                    y=dObj$Train[,tgtIdx],
#                    ntree=100,
#                    mtry=6,
#                    numRandomCuts=1,
#                    numThreads=1)


#Model Evaluation####

#Variable importance
rfMod$importance

varImpPlot(x=rfMod, main="Variable Importance")

rfMod$ntree
rfMod$mtry

#Cross-Validation
predMat = predict(object=rfMod,
                  newdata=dObj$Valid[,-dObj$targetIdx],
                  type='prob')

View(predMat)

predMax = apply(X=predMat, MARGIN=1, FUN=max)
predCol = max.col(m=predMat, ties.method='first')
predLab = colnames(predMat)[predCol]

predObj = {}
predObj$Prob = predMax
predObj$Label = predLab
predObj$Pred = predObj$Label
predObj$Pred[predObj$Prob<0.9] = 'N/A'
predObj$Actual = as.character(dObj$Valid$NextReport)
predObj$predPerc = sum(predObj$Pred!='N/A')/length(predObj$Label)
predObj$errorRate = 
  sum(predObj$Pred!=predObj$Actual & predObj$Pred!='N/A')/
    sum(predObj$Pred!='N/A')

sprintf('Rate of Prediction: %f, Error rate: %f',
        predObj$predPerc, predObj$errorRate)

View(predObj)

rm(list= c('predMax', 'predCol', 'predLab'))

#Graph Error Rate and Rate of Prediction against Prediction Threshold
threshmat = matrix(NaN, nrow=11, ncol=3)
colnames(threshmat) = c('Thresh', 'Error', 'Pred')
threshstep = 1/(dim(threshmat)[1] - 1)

for (i in 1:dim(threshmat)[1]){
  threshmat[i, 1] = (i-1) * threshstep
  ntot = length(predObj$Label)
  npred = sum(predObj$Prob >= threshmat[i,1])
  ncorrect = sum(predObj$Prob>=threshmat[i,1] & predObj$Label!=predObj$Actual)
  threshmat[i,2] = ncorrect / npred
  threshmat[i,3] = npred / ntot
}


#p = recordPlot()
par(mar=c(5,4,4,6) + 0.1)
plot(x=threshmat[,1], y=threshmat[,2], type='b',
     main='Prediction Threshold',
     col='#FF4500', axes=FALSE, xlab="Threshold", ylab="", pch=1)
axis(side=1, at=threshmat[,1][
  seq(1, length(threshmat[,1]), (length(threshmat[,1]) - 1)/10)])
axis(side=2, ylim=c(0,max(threshmat[,2])), col=c('#FF4500','#FF4500'),
     col.axis='#FF4500')
mtext(side=2, text='Error Rate', col='#FF4500', line=2.5)
par(new=TRUE)
plot(x=threshmat[,1], y=threshmat[,3], type='b',
     col='#008000', axes=FALSE, xlab="", ylab="", pch=2)
axis(side=4, ylim=c(0,max(threshmat,3)), col=c('#008000','#008000'),
     col.axis='#008000')
mtext(side=4, text='Prediction Rate', col='#008000', line=2.5)
legend("topright", legend=c('Error Rate','Prediction Rate'),
       text.col=c('#FF4500','#008000'), lty = 1, #pch=c(1,2),
       col=c('#FF4500','#008000'))
box()
plot(p)

#Model Tuning####
mtryVar = c(6, 12)
ntreeVar = c(50, 100)

tuninggrid = merge(x=mtryVar, y=ntreeVar, all=TRUE)
colnames(tuninggrid) = c('mtry','ntree')
tuninggrid$error = rep(NaN, length(tuninggrid$mtry))
tuninggrid$perc = rep(NaN, length(tuninggrid$mtry))

for (i in 1:dim(tuninggrid)[1]){
  rfMod = randomForest(NextReport ~ .,
                       data=dObj$Train,
                       importance=T,
                       proximity=F,
                       mtry=tuninggrid$mtry[i],
                       ntree=tuninggrid$ntree[i])
  
  predMat = predict(object=rfMod,
                    newdata=dObj$Valid[,-dObj$targetIdx],
                    type='prob')
  
  predMax = apply(X=predMat, MARGIN=1, FUN=max)
  predCol = max.col(m=predMat, ties.method='first')
  predLab = colnames(predMat)[predCol]
  
  predObj = {}
  predObj$Prob = predMax
  predObj$Label = predLab
  predObj$Pred = predObj$Label
  predObj$Pred[predObj$Prob<predThreshold] = 'N/A'
  predObj$Actual = as.character(dObj$Valid[, targetVar])
  predObj$predPerc = sum(predObj$Pred!='N/A')/length(predObj$Label)
  predObj$errorRate = 
    sum(predObj$Pred!=predObj$Actual & predObj$Pred!='N/A')/
    sum(predObj$Pred!='N/A')
  
  tuninggrid$error[i] = predObj$errorRate
  tuninggrid$perc[i] = predObj$predPerc
}


#Generate predictions file####
write.csv(x=predObj,
          file='C:/temp/Predictions.txt',
          row.names=T)



#EDA####
#jpeg("C:/temp/testPlot.jpg")
#par(mar = par("mar") - c(4, 0, 2, 0))
layout(mat = c(1, 2, 3), heights = c(2, 3, 3))
boxplot(dObj$Train$ReportCodeID, horizontal = T)
hist(dObj$Train$ReportCodeID, freq = F)
d = density(dObj$Train$ReportCodeID)
lines(x = d, col = 'red')
box()
grid()
#par(mar = par("mar") + c(3, 0, 2, 0))
plot(dObj$Train$ReportCodeID)





























