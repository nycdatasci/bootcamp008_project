import numpy as np
import pandas as pd
from scipy import stats
import random
import xgboost as xgb
import numpy as np
import pandas as pd
from scipy import stats
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn import model_selection
from sklearn.ensemble import AdaBoostClassifier
from sklearn.ensemble import GradientBoostingClassifier
from sklearn import model_selection
from sklearn.ensemble import RandomForestClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.linear_model import LogisticRegression
def GB(x_train,y_train,x_test):
	GB=GradientBoostingClassifier(n_estimators=200, learning_rate=0.1,max_depth=6)
	GB.fit(x_train,y_train)
	return GB.predict_proba(x_test)

def KNN(x_train,y_train,x_test):
	KNN=KNeighborsClassifier(n_estimators=5,n_jobs=12)
	KNN.fit(x_train,y_train)
	return KNN.predict_proba(x_test)

def lr(x_train,y_train,x_test):
	lr=LogisticRegression(solver='lbfgs',multi_class='multinomial',n_jobs=12)
	lr.fit(x_train,y_train)
	return lr.predict_proba(x_test)

def rf(x_train,y_train,x_test):
	rf=RandomForestClassifier(n_estimators=200,n_jobs=12)
	rf.fit(x_train,y_train)
	return rf.predict_proba(x_test)
def ada(x_train,y_train,x_test):
	ada=AdaBoostClassifier(n_estimators=50,learning_rate=0.1)
	ada.fit(x_train,y_train)
	return ada.predict_proba(x_test)


def XG(x_train,y_train,x_test,y_test):
	xg_train=xgb.DMatrix(x_train,label=y_train)
	xg_test=xgb.DMatrix(x_test,label=y_test)
	param={}
	param['objective'] = 'multi:softmax'
# scale weight of positive examples
	param['eta'] = 0.1
	param['max_depth'] = 6
	param['silent'] = 1
	param['nthread'] = 4
	param['num_class'] = 3
	watchlist = [ (xg_train,'train'), (xg_test, 'test') ]
	num_round = 20
	print "train xgboosting next"
	bst = xgb.train(param, xg_train, num_round, watchlist )
	res= {'train':bst.predict(xg_train),'test':bst.predict(xg_test)}
	return res



def stackmodel(x_train,y_train,x_test,y_test):
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
		print 'this is the ',i,'th round of stacking'
		x_sub_test=x_sp[i]
		x_sub_train=x_train.drop(x_sub_test.index)
		y_sub_test=y_train[x_sub_test.index]
		y_sub_train=y_train[x_sub_train.index]
		M1=pd.DataFrame(GB(x_sub_train,y_sub_train,x_sub_test),columns=['GB_low','GB_medium','GB_high'],index=x_sub_test.index)
		print "Gradient Boosting"
		M2=pd.DataFrame(lr(x_sub_train,y_sub_train,x_sub_test),columns=['lr_low','lr_medium','lr_high'],index=x_sub_test.index)
		print "Logistic"
		M3=pd.DataFrame(KNN(x_sub_train,y_sub_train,x_sub_test),columns=['knn_low','knn_medium','knn_high'],index=x_sub_test.index)
		print "KNN"
		M4=pd.DataFrame(rf(x_sub_train,y_sub_train,x_sub_test),columns=['rf_low','rf_medium','rf_high'],index=x_sub_test.index)
		print "Random Forest"
		M5=pd.DataFrame(ada(x_sub_train,y_sub_train,x_sub_test),columns=['ada_low','ada_medium','ada_high'],index=x_sub_test.index)
		print "Adaboost"
		train_meta=train_meta.append(pd.concat([M1,M2,M3,M4,M5],axis=1))
	print "train_meta size is" ,train_meta.shape[0]

	#4th:Fit each base model to the full training dataset 
	#and make predictions on the test dataset. Store these predictions inside test_meta
	print "For the all train and test set"
	x_train=x_train_cpy
	M1=pd.DataFrame(GB(x_train,y_train,x_test),columns=['GB_low','GB_medium','GB_high'],index=x_test.index)
	print "GB"
	M2=pd.DataFrame(lr(x_train,y_train,x_test),columns=['lr_low','lr_medium','lr_high'],index=x_test.index)
	print "LR"
	M3=pd.DataFrame(KNN(x_train,y_train,x_test),columns=['knn_low','knn_medium','knn_high'],index=x_test.index)
	print "KNN"
	M4=pd.DataFrame(rf(x_train,y_train,x_test),columns=['rf_low','rf_medium','rf_high'],index=x_test.index)
	print "RF"
	M5=pd.DataFrame(ada(x_train,y_train,x_test),columns=['ada_low','ada_medium','ada_high'],index=x_test.index)
	print "ADA"
	test_meta=pd.concat([M1,M2,M3,M4,M5],axis=1)
	print "test_meta size is ", test_meta.shape[0]
	#5th: Fit a new model, S (i.e the stacking model) to train_meta, using M1 and M2 as features.
	#Optionally, include other features from the original training dataset or engineered features
	##==> transfer to dummy variables
	
	pred=XG(train_meta,y_train,test_meta,y_test)
	#random forest with meta only
	

	print "accuracy of train is ", accuracy_score(pred['train'],y_train)
	print "accuracy of test is ", accuracy_score(pred['test'],y_test)



def main_function():
	importance=['price','avg_imagesize_x','word_count','avg_luminance_x','avg_brightness_x','manager count','description_sentiment','img_quantity_x','unique_count','bedrooms','bathrooms','No Fee',\
	'dist_count','Doorman','Laundry In Building','Elevator','Fitness Center','Reduced Fee','Exclusive','Cats Allowed','Dogs Allowed','Furnished',\
	'Common Outdoor Space','Laundry In Unit','Private Outdoor Space','Parking Space','Short Term Allowed','By Owner','Sublet / Lease-Break',\
	'Storage Facility']
	processed_data=pd.read_json("../data/processed_train.json")
	processed_test=pd.read_json('../data/processed_test.json')
	img=pd.read_csv("../data/image_stats-fixed.csv",index_col=0)
	processed_data=processed_data.merge(img,how="left",on="listing_id")
	processed_test=processed_test.merge(img,how="left",on="listing_id")
	processed_data=processed_data.fillna(0)
	processed_test=processed_test.fillna(0)
	train_data=processed_data.sample(n=processed_data.shape[0]*7/10)
	test_data=processed_data.drop(train_data.index)
	train=train_data.drop(['building_id','created','description','display_address','longitude','latitude','manager_id','listing_id','photos','street_address','features'],axis=1)
	test=test_data.drop(['building_id','created','description','display_address','longitude','latitude','manager_id','listing_id','photos','street_address','features'],axis=1)
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
    print "y_train size is", y_train.shape[0]
    print 'y_test size is ', y_test.shape[0]
	res=stackmodel(x_train,y_train,x_test,y_test)
	
#return and print 
main_function()


