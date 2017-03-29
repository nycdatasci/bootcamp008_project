import numpy as np
import pandas as pd
from scipy import stats
import random
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn import model_selection
from sklearn.model_selection import cross_val_score
from sklearn.ensemble import AdaBoostClassifier
from sklearn.ensemble import GradientBoostingClassifier
import xgboost as xgb
from sklearn import model_selection
from sklearn.ensemble import RandomForestClassifier

def GB(x_train,y_train,x_test):
	GB=GradientBoostingClassifier(n_estimators=200, learning_rate=0.1,max_depth=4)
	GB.fit(x_train,y_train)
	return GB.predict(x_test)

def XG(x_train,y_train,x_test,y_test):
	xg_train=xgb.DMatrix(x_train,label=y_train)
	xg_test=xgb.DMatrix(x_test,label=y_test)
	param={}
	param['objective'] = 'multi:softmax'
# scale weight of positive examples
	param['eta'] = 0.1
	param['max_depth'] = 6
	param['silent'] = 1
	param['nthread'] = 12
	param['num_class'] = 3
	watchlist = [ (xg_train,'train'), (xg_test, 'test') ]
	num_round = 10
	print "train xgboosting next"
	bst = xgb.train(param, xg_train, num_round, watchlist )
	return bst.predict(xg_test)

def stackmodel(x_train,y_train,x_test,y_test,test,y_train_copy,y_test_copy):
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
	    M1=pd.Series(GB(x_sub_train,y_sub_train,x_sub_test),index=x_sub_test.index)
	    M2=pd.Series(XG(x_sub_train,y_sub_train,x_sub_test,y_sub_test),index=x_sub_test.index)
	    app={'M1':M1,'M2':M2}
	    train_meta=train_meta.append(pd.DataFrame(app))
	#4th:Fit each base model to the full training dataset 
	#and make predictions on the test dataset. Store these predictions inside test_meta
	M1=pd.Series(GB(x_train,y_train,x_test),index=x_test.index)
	M2=pd.Series(XG(x_train,y_train,x_test,y_test),index=x_test.index)
	
	test['M1']=M1
	test['M2']=M2
	

	#5th: Fit a new model, S (i.e the stacking model) to train_meta, using M1 and M2 as features.
	#Optionally, include other features from the original training dataset or engineered features
	##==> transfer to dummy variables
	train_meta_dummy=pd.get_dummies(train_meta)
	test_meta=test.loc[:,['M1','M2']]
	test_meta_dummy=pd.get_dummies(test_meta)

	#random forest with meta only
	clf=RandomForestClassifier(n_estimators=200)
	clf.fit(train_meta_dummy,y_train_copy)
	trainacc1=accuracy_score(clf.predict(train_meta_dummy),y_train_copy)
	testacc1= accuracy_score(clf.predict(test_meta_dummy),y_test_copy)

	x_last_train=pd.concat([train_meta_dummy,x_train],axis=1)
	x_last_test=pd.concat([test_meta_dummy,x_test],axis=1)

	#random forest with combined
	clf.fit(x_last_train,y_train_copy)
	trainacc2=accuracy_score(clf.predict(x_last_train),y_train_copy)
	testacc2= accuracy_score(clf.predict(x_last_test),y_test_copy)

	out=[trainacc1,testacc1,trainacc2,testacc2]
	return out


def main_function():
	importance=['price','avg_imagesize_x','word_count','avg_luminance_x','avg_brightness_x','manager count','description_sentiment','img_quantity_x','unique_count','bedrooms','bathrooms','No Fee',\
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
	y_train=train.loc[:,'interest_level']
	x_train=train.drop('interest_level',axis=1).loc[:,importance[:16]]
	y_test=test.loc[:,'interest_level']
	x_test=test.drop('interest_level',axis=1).loc[:,importance[:16]]
	y_train_copy=y_train.copy()
	y_test_copy=y_test.copy()
	diction={'low':0,'medium':1,'high':2}
	y_train1=map(lambda x: diction[x],y_train)
	y_test1=map(lambda x: diction[x],y_test)
	y_train=pd.Series(y_train1,index=y_train.index)
	y_test=pd.Series(y_test1,index=y_test.index)
	res=stackmodel(x_train,y_train,x_test,y_test,test,y_train_copy,y_test_copy)
	print "This model is for all features"
	print "train accuracy on meta data is ",res[0]
	print "test accuracy on meta data is ", res[1]
	print "train accuracy on combined data is ",res[2]
	print "test accuracy on combined data is ", res[3]
	
#return and print 
main_function()

