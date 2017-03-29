import pylab
import calendar
import numpy as np
import pandas as pd
from scipy import stats
from datetime import datetime
import matplotlib.pyplot as plt
import random
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn import model_selection
from sklearn.ensemble import BaggingClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn import svm
from sklearn.naive_bayes import GaussianNB
from sklearn.model_selection import cross_val_score
from sklearn.ensemble import AdaBoostClassifier
	#base model 1: multinomial logistic regression
	#base model 2: bagged decision trees
	#base model 3: Random Forest trees
	#base model 4: SVM
	#base model 5: bayes classifier
	#base model 6: Ada Boosting
#base model 1: multinomial logistic regression
def mlog(x_train,y_train,x_test):
	lr = LogisticRegression().fit(x_train, y_train)
	return lr.predict(x_test)
#base model 2: bagged decision trees
def bagDT(x_train,y_train,x_test,y_test):
	kfold = model_selection.KFold(n_splits=10)
	cart = DecisionTreeClassifier()
	num_trees = 100
	model = BaggingClassifier(base_estimator=cart, n_estimators=num_trees)
	model.fit(x_train,y_train)
	predict = model_selection.cross_val_predict(model, x_test, y_test, cv=kfold)
	return predict
 #base model 3: Random Forest trees
	
def rfClassifier(x_train,y_train,x_test,y_test):
	num_trees = 100
	max_features = 3
	kfold = model_selection.KFold(n_splits=10, random_state=seed)
	model = RandomForestClassifier(n_estimators=num_trees, max_features=max_features)
	model.fit(x_train,y_train)
	predicted = model_selection.cross_val_predict(model, x_test, y_test, cv=kfold)
	return predicted
#base model 4: SVM	
def svmm(x_train,y_train,x_test):
	clf = svm.SVC(decision_function_shape='ovr')
	clf.fit(x_train, y_train) 
	return clf.predict(x_test)
#base model 5: Naive Bayes Classifier
def gnb(x_train,y_train,x_test):
	gnb=GaussianNB()
	y_pred = gnb.fit(x_train, y_train).predict(x_test)
	return y_pred

#base model 6: Ada boosting classifier
def adaBC(x_train,y_train,x_test):
	clf = AdaBoostClassifier(n_estimators=100)
    clf.fit(x_train,y_train)
    return clf.predict(x_test)
def stackmodel(x_train,y_train,x_test,y_train):
	#1st: partition the train set into 5 test sets
	x_train_cpy=x_train.copy()
	k=x_train.shape[0]/5
	x_sp=[[],[],[],[],[]]
	for i in range(4):
	    sample=random.sample(x_train.index,k)
	    x_sp[i]=x_train.ix[sample]
	    x_train=x_train.drop(sample)
	x_sp[4]=x_train

	#2nd: create train_meta and test_meta
	train_meta=pd.DataFrame()
	#3rd: for each fold in 1st, use other 5 folds as training set to predict the result for that fold.
	#and save them in train_meta
	x_train=x_train_cpy
	for i in range(5):
	    x_sub_test=x_sp[i]
	    x_sub_train=x_train.drop(x_sub_test.index)
	    y_sub_test=y_train[x_sub_test.index]
	    y_sub_train=y_train[x_sub_train.index]
	    M1=pd.Series(mlog(x_sub_train,y_sub_train,x_sub_test),index=x_sub_test.index)
	    M2=pd.Series(bagDT(x_sub_train,y_sub_train,x_sub_test,y_sub_test),index=x_sub_test.index)
	    M3=pd.Series(rfClassifier(x_sub_train,y_sub_train,x_sub_test,y_sub_test),index=x_sub_test.index)
	    M4=pd.Series(svmm(x_sub_train,y_sub_train,x_sub_test),index=x_sub_test.index)
	    M5=pd.Series(gnb(x_sub_train,y_sub_train,x_sub_test),index=x_sub_test.index)
	    M6=pd.Series(adaBC(x_sub_train,y_sub_train,x_sub_test),index=x_sub_test.index)
	    app={'M1':M1,'M2':M2,'M3':M3, 'M4':M4, 'M5':M5,'M6':M6}
	    train_meta=train_meta.append(pd.DataFrame(app))
	#4th:Fit each base model to the full training dataset 
	#and make predictions on the test dataset. Store these predictions inside test_meta
	M1=pd.Series(mlog(x_train,y_train,x_test),index=x_test.index)
	M2=pd.Series(bagDT(x_train,y_train,x_test,y_test),index=x_test.index)
	M3=pd.Series(rfClassifier(x_train,y_train,x_test,y_test),index=x_test.index)
	M4=pd.Series(svmm(x_train,y_train,x_test),index=x_test.index)
	M5=pd.Series(gnb(x_train,y_train,x_test),index=x_test.index)
	M6=pd.Series(adaBC(x_train,y_train,x_test),index=x_test.index)
	test['M1']=M1
	test['M2']=M2
	test['M3']=M3
	test['M4']=M4
	test['M5']=M5
	test['M6']=M6

	#5th: Fit a new model, S (i.e the stacking model) to train_meta, using M1 and M2 as features.
	#Optionally, include other features from the original training dataset or engineered features
	##==> transfer to dummy variables
	train_meta_dummy=pd.get_dummies(train_meta)
	test_meta=test.loc[:,['M1','M2','M3','M4','M5','M6']]
	test_meta_dummy=pd.get_dummies(test_meta)

	#random forest with meta only
	res=rfClassifier(train_meta_dummy,y_train,test_meta_dummy,y_test)
	trainacc1=accuracy_score(rfClassifier(train_meta_dummy,y_train,train_meta_dummy,y_train),y_train)
	testacc1= accuracy_score(res,y_test)

	x_last_train=pd.concat([train_meta_dummy,x_train],axis=1)
	x_last_test=pd.concat([test_meta_dummy,x_test],axis=1)

	#random forest with combined
	res=rfClassifier(x_last_train,y_train,x_last_test,y_test)
	trainacc2=accuracy_score(rfClassifier(x_last_train,y_train,x_last_train,y_train),y_train)
	testacc2= accuracy_score(res,y_test)

    out=[trainacc1,testacc1,trainacc2,testacc2]
    return out


def main_function():
	importance=['price','avg_imagesize','word_count','avg_luminance','avg_brightness','manager count','description_sentiment','img_quantity','unique_count','bedrooms','bathrooms','No Fee',\
	'dist_count','Doorman','Laundry In Building','Elevator','Fitness Center','Reduced Fee','Exclusive','Cats Allowed','Dogs Allowed','Furnished',\
	'Common Outdoor Space','Laundry In Unit','Private Outdoor Space','Parking Space','Short Term Allowed','By Owner','Sublet / Lease-Break',\
	'Storage Facility']
	processed_data=pd.read_json("../data/processed_train.json")
	img=pd.read_csv("../data/image_stats-fixed.csv",index_col=0)
	processed_data=processed_data.merge(img,how="left",on="listing_id")
	processed_data=processed_data.fillna(0)
	train_data=processed_data.sample(n=processed_data.shape[0]*7/10)
	test_data=processed_data.drop(train_data.index)
	train=train_data.drop(['building_id','created','description','display_address','longitude','latitude','manager_id','listing_id','photos','street_address','features'],axis=1)
	test=test_data.drop(['building_id','created','description','display_address','longitude','latitude','manager_id','listing_id','photos','street_address','features'],axis=1)
	ans=[['Features','Train on meta','Test on meta','Train with all','Test with all']]
	for i in range(5,train.shape[1]+1):
		y_train=train.loc[:,'interest_level']
		x_train=train.drop('interest_level',axis=1).loc[:,importance[0:i]]
		y_test=test.loc[:,'interest_level']
		x_test=test.drop('interest_level',axis=1).loc[:,importance[0:i]]
		

		res=stackmodel(x_train,y_train,x_test,y_test)
		print "This model is for top ", i, " features"
		print "train accuracy on meta data is ",res[0]
		print "test accuracy on meta data is ", res[1]
		print "train accuracy on combined data is ",res[2]
		print "test accuracy on combined data is ", res[3]
		ans.append([i,res[0],res[1],res[2],res[3]])
	df = pd.DataFrame(ans[1:],columns=ans[0]).set_index('Features')
	df.to_csv("stackingmodel.csv")
	
#return and print 
main_function()

