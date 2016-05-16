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
rm(x, y, trainNvalid)

#Train LDA
library(MASS)
#ldaFrmla = formula(paste0("trainData$", targetVar, "~."))
ldaMod = lda(formula = trainData$Species~., data = trainData)
pred = predict(object = ldaMod, newdata = validData)
View(pred)
