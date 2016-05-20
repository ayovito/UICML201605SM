#Clear env
rm(list=ls())

#data types
vector()
list()
matrix()
array()
factor()
data.frame()


#Create iris promise object
data("iris")

#Create training object
trainIdx = sample(as.integer(rownames(iris)), 
                  floor(length(rownames(iris)) * .75))
validIdx = as.integer(rownames(iris))[-trainIdx]
trainData = iris[trainIdx, ]
validData = iris[validIdx, ]

#Validate
trainNvalid = union(trainIdx, validIdx)
setdiff(trainNvalid, as.integer(rownames(iris)))

#clean up environment
rm(trainNvalid)

#Train LDA ####
library(MASS)
#ldaFrmla = formula(paste0("trainData$", targetVar, "~."))
ldaMod = lda(formula = trainData$Species~., data = trainData)
ldaPred = predict(object = ldaMod, newdata = validData)
#str(ldaPred)
#nrow(ldaPred$posterior)
#ncol(ldaPred$posterior)
#View(ldaPred)

validData$ldaPredClass = ldaPred$class
validData$ldaPredProb = apply(ldaPred$posterior, 1, max)
#View(validData)

#Performance measures
ldaCntAll = length(validData$Species)
ldaCntIncorrect = length(which(validData$Species != validData$ldaPredClass))
ldaCntCorrect = length(which(validData$Species == validData$ldaPredClass))
ldaErrRate = ldaCntIncorrect / ldaCntAll
ldaPredRate = (ldaCntCorrect + ldaCntIncorrect) / ldaCntAll

#Display lda results
sprintf("LDA results: Prediction Rate: %s%% , Error Rate: %s%%",
        format(ldaPredRate * 100, digits = 4),
        format(ldaErrRate * 100, digits = 4))


#Train QDA ####
qdaMod = qda(formula = trainData$Species~., data = trainData)
qdaPred = predict(object = qdaMod, newdata = validData)
#str(qdaPred)
#nrow(qdaPred$posterior)
#ncol(qdaPred$posterior)
#View(qdaPred)

validData$qdaPredClass = qdaPred$class
validData$qdaPredProb = apply(qdaPred$posterior, 1, max)
#View(validData)

#Performance measures
qdaCntAll = length(validData$Species)
qdaCntIncorrect = length(which(validData$Species != validData$qdaPredClass))
qdaCntCorrect = length(which(validData$Species == validData$qdaPredClass))
qdaErrRate = qdaCntIncorrect / qdaCntAll
qdaPredRate = (qdaCntCorrect + qdaCntIncorrect) / qdaCntAll

#Display qda results
sprintf("QDA results: Prediction Rate: %s%% , Error Rate: %s%%",
        format(qdaPredRate * 100, digits = 4),
        format(qdaErrRate * 100, digits = 4))

#Train Random Forest ####
library(randomForest)
rfMod = randomForest(trainData$Species~., data = trainData)
rfPred = predict(object = qdaMod, newdata = validData)
#str(rfMod)
#str(rfPred)
#nrow(rfPred$posterior)
#ncol(rfPred$posterior)
#View(rfPred)

validData$rfPredClass = rfPred$class
validData$rfPredProb = apply(rfPred$posterior, 1, max)
#View(validData)

#Performance measures
rfCntAll = length(validData$Species)
rfCntIncorrect = length(which(validData$Species != validData$qdaPredClass))
rfCntCorrect = length(which(validData$Species == validData$rfPredClass))
rfErrRate = rfCntIncorrect / rfCntAll
rfPredRate = (rfCntCorrect + rfCntIncorrect) / rfCntAll

#Display qda results
sprintf("QDA results: Prediction Rate: %s%% , Error Rate: %s%%",
        format(qdaPredRate * 100, digits = 4),
        format(qdaErrRate * 100, digits = 4))

#For loop to iterate thru and compare average performance
n = 10
perfMat = matrix(data = NA, nrow = n, ncol = )

#Graphs ####
plot(iris[,1], iris[,2])
plot(iris[,1], iris[,2], type = 'p')
plot(iris[,1], iris[,2], type = 'b')
#Add a title
plot(iris[,1], iris[,2], main = 'Iris')
#Add axis titles
plot(iris[,1], iris[,2], main = 'Iris', xlab = names(iris)[1],
     ylab = names(iris)[2])
#Color points based on Species
plot(iris[,1], iris[,2], main = 'Iris', xlab = names(iris)[1],
     ylab = names(iris)[2], col = iris[,5])



# Load report.csv
report = read.csv("Report.csv")
# report$DateTime = 
#   strptime(report$InsertTimeStamp, format = "%Y-%m-%d %H:%M:%OS")

report$Year = substr(report$InsertTimeStamp, 1, 4)
report$Month = as.integer( substr(report$InsertTimeStamp, 6, 7))

