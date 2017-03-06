#Log Loss Function
MultiLogLoss <- function(act, pred){
  eps <- 1e-15
  pred <- pmin(pmax(pred, eps), 1 - eps)
  right<-matrix(nrow=length(act), ncol=ncol(pred))
  for (j in 1:ncol(pred)){
    right[,j]<-act==colnames(pred)[j]
  }
  return(-1 * sum(rowSums(right * log(pred)))/nrow(pred))
}

#Join stuff
#features<-read.csv("~/NYCDSA/Project 3/NYC_DS_Project_3/features_extract.csv", row.names=1)
features<-read.csv("~/NYCDSA/Project 3/test.json/features_test.csv", row.names=1)
full_list<-listings3

full_list<-cbind(listings3, features)
full_list[, 1:12]<-sapply(full_list[,1:12], unlist)
full_list[,14:62]<-sapply(full_list[,14:62], as.factor)
dummy.full<-model.matrix(interest_level ~., data=full_list[,13:62])[,-1]
#features$interest_level<-"low"
#dummy.full<-model.matrix(interest_level ~., data=features)[,-1]

#Trying a Bernouilli Naive Bayes
library(e1071)
bnb.feat<-naiveBayes(y=full_list$interest_level[train], x=dummy.full[train,])
bnb.pred<-predict(bnb.feat, dummy.full[-train,], type="raw")
MultiLogLoss(full_list$interest_level[-train], bnb.pred)
#Logloss 2.618795--quite bad.

#Training
train<-sample(1:nrow(full_list), .7*nrow(full_list))
train.feat<-dummy.full[train,]
test.feat<-dummy.full[-train,]

library(randomForest)

#The followed section turned out to be useless.
#oob<-rep(0, 23)
#for (i in 3:25){
#  tree.train<-randomForest(full_list$interest_level[train] ~ ., data=train.feat, importance=T, mtry=i, ntree=350)
#  oob[i]<-tree.train$err.rate[350]
#  print(paste("Finished RF with mtry=", i))
#}
#Best model is mtry=8
# +150 on average Gini impurity on best model:
#Dog1 + Dishwasher1 + Subway1 + Marble1 + Cat1 + FeeNo + Doorman1 + Hardwood1 + Gym1 + EatIn1 + Stainless1 + Renovate1 + Prewar1 + Dining1 + Granite1 +
#HighCeiling1 + Elevator1 + OutdoorNone + LaundryUnit + Deck1 + WalkInClos1 + Light1 + LaundryNone + Super1 + OutdoorPrivate + OutdoorNone + Storage1

#Saturated Feature Model
tree.train<-randomForest(full_list$interest_level[train] ~ ., data=train.feat, importance=T, mtry=9)
#2.24 logloss--outperforms BNB

# Determine ideal number of mtry for RF test models
logl<-rep(0, 13)
for (i in 4:15){
  tree.pruned.train<-randomForest(full_list$interest_level[train] ~ Dog1 + Dishwasher1 + Subway1 + Marble1 + Cat1 + FeeNo + Doorman1 + Hardwood1 + Gym1 + EatIn1 + Stainless1 + Renovate1 + Prewar1 + Dining1 + Granite1 +HighCeiling1 + Elevator1 + LaundryUnit + LaundryNone + Deck1 + WalkInClos1 , data=train.feat, importance=T, mtry=i)
  logl[i-2]<-MultiLogLoss(full_list$interest_level[train], tree.pruned.train$votes)
  print(paste("Finished mtry=", i))
}
#mtry=9 best on logloss with 21 features--use mtry=i/2 for future test models

#Pare down number of features, using importance table from saturated model to determine preliminary order
#Measure logloss 
tree.train.rows<-rownames(tree.train$importance[order(tree.train$importance[,5], decreasing=T),])
train.feat<-train.feat[,tree.train.rows]
logl2<-rep(0, ncol(dummy.full))
for (i in 2:ncol(dummy.full)){
  tree.number.train<-randomForest(full_list$interest_level[train] ~ ., data=train.feat[,1:i], importance=T, mtry=round(i/2))
  logl2[i]<-MultiLogLoss(full_list$interest_level[train], tree.number.train$votes)
  print(paste("Finished model with", i, "features"))
}
#Log loss stops uniformly decreasing with 40 features.

#Try with order of features from misclassification rate instead
tree.train.rows2<-rownames(tree.train$importance[order(tree.train$importance[,4], decreasing=T),])
train.feat<-train.feat[,tree.train.rows]
logl3<-rep(0, ncol(dummy.full))
for (i in 2:ncol(dummy.full)){
  tree.number.train2<-randomForest(full_list$interest_level[train] ~ ., data=train.feat[,1:i], importance=T, mtry=round(i/2))
  logl3[i]<-MultiLogLoss(full_list$interest_level[train], tree.number.train2$votes)
  print(paste("Finished model with", i, "features"))
}
#Models produce no significant difference in logloss; using Gini importance as working model

#Try 39-feature model w/price added, prepare to further trim
dummy.price<-cbind(as.numeric(full_list$price), dummy.full)
colnames(dummy.price)[1]<-"price"
logl4<-rep(0, ncol(dummy.price))
logtest<-rep(0, ncol(dummy.price))
for (i in 2:40){
  tree.price2<-randomForest(full_list$interest_level[train] ~ ., data=dummy.price[train, 1:i], importance=T, mtry=round(i/2))
  #logl4[i-1]<-MultiLogLoss(full_list$interest_level[train], tree.price2$votes)
  logtest[i-1]<-MultiLogLoss(full_list$interest_level[-train], predict(tree.price2,dummy.price[-train,], type="prob"))
  print(paste("Finished model with", i, "features"))
}

#Inspect log-loss to see where significant drops 
logl4
logltest

c(logl4, .001)/c(1, logl4)
c(logltest, .001)/c(1, logltest)

#Logloss does not significantly drop after 25 features.
#Hunt and peck for a while to compare models and determine ideal features to prune.
best.1<-dummy.price[, c(1:3, 5:7, 9:12, 14:15, 21, 25)]
best.tree<-randomForest(full_list$interest_level[train] ~ ., data=best.1[train,], importance=T, mtry=7)
#1:3, 5:7, 9:12, 25 gets you 1.84, 1.535
#Add 14:15 to get down to 1.49 and 1.23, plus 21 to get down to 1.3 & 1.1



write.csv(best.2[,-2], "best_features.csv")
#Convert features to PCA
library(psych)
fa.parallel(dummy.full, fa="pc", n.iter=100)
feature.pca<-principal(dummy.full, nfactors=30, rotate="none")
pca.features<-cbind(full_list$listing_id, feature.pca$scores)
colnames(pca.features)[1]<-"listing_id"
#write.csv(pca.features, "pca_30_features.csv")
write.csv(pca.features, "pca_30_features_test.csv")

pca.forest<-randomForest(full_list[train,]$interest_level ~ . , data=full_list[train,c(11,14:43)], importance=T, mtry=15)
MultiLogLoss(full_list$interest_level[-train], predict(pca.forest, full_list[-train, c(11,14:43)], type="prob"))

names(logl4)<-1:40
log.df<-data.frame(1:55,logl4)
colnames(log.df)<-c("Variables", "Log.Loss")
library(ggplot2)
l<-ggplot(log.df[1:40,], aes(x=Variables, y=Log.Loss))
l + geom_line(lwd=2, aes(color="blue")) + labs(title="Pruning Random Forest Features", x="# of Features (plus Price)", y="Log-Loss") + theme(plot.title = element_text(hjust = 0.5)) + guides(color=F)

