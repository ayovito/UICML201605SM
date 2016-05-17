#Clear env
rm(list=ls())

#Create iris promise object
data("iris")

#Create training object
trainIdx = sample(as.integer(rownames(iris)), length(rownames(iris)) * .75)
validIdx = as.integer(rownames(iris))[-trainIdx]
trainData = iris[trainIdx, ]
validData = iris[validIdx, ]

#Validate
trainNvalid = union(trainIdx, validIdx)
setdiff(trainNvalid, as.integer(rownames(iris)))

#clean up environment
rm(trainNvalid)

#Train LDA####
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


#Train QDA####
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












