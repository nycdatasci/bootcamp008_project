###this file is aimed to calculate the accuracy based on the voting classifier
import numpy as np
import pandas as pd
from scipy import stats
import random
from sklearn.model_selection import cross_val_score
from sklearn.linear_model import LogisticRegression
from sklearn.naive_bayes import GaussianNB
from sklearn.ensemble import RandomForestClassifier
from sklearn.ensemble import VotingClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import GridSearchCV
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.model_selection import cross_val_score
from sklearn.ensemble import AdaBoostClassifier
from sklearn.metrics import log_loss
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn import model_selection, preprocessing, ensemble

#from sklearn.model_selection import KFold
##loading and processing data
##logistic regression, random forest classifier, gaussianNB
def main_function():
	importance=['avg_imagesize_y','price','word_count','manager count','description_sentiment','avg_B','avg_imgheight','avg_G','avg_R','unique_count','bedrooms',
	'dist_count','No Fee','bathrooms','avg_metadata','Doorman','Elevator']
	processed_data=pd.read_json("../data/processed_train.json")
	processed_test=pd.read_json('../data/processed_test.json')
	img=pd.read_csv("../data/image_stats-fixed2.csv",index_col=0)
	processed_data=processed_data.merge(img,how="left",on="listing_id")
	processed_test=processed_test.merge(img,how="left",on="listing_id")
	processed_data=processed_data.fillna(0)
	processed_test=processed_test.fillna(0)
	train_data=processed_data
	test_data=processed_test
	train_data["created"] = pd.to_datetime(train_data["created"])
	test_data["created"] = pd.to_datetime(test_data["created"])
	train_data["created_year"] = train_data["created"].dt.year
	test_data["created_year"] = test_data["created"].dt.year
	train_data["created_month"] = train_data["created"].dt.month
	test_data["created_month"] = test_data["created"].dt.month
	train_data["created_day"] = train_data["created"].dt.day
	test_data["created_day"] = test_data["created"].dt.day
	train_data["created_hour"] = train_data["created"].dt.hour
	test_data["created_hour"] = test_data["created"].dt.hour


	categorical = ["display_address", "manager_id", "building_id", "street_address"]
	for f in categorical:
		if train_data[f].dtype=='object':
			#print(f)
			lbl = preprocessing.LabelEncoder()
			lbl.fit(list(train_data[f].values) + list(test_data[f].values))
			train_data[f] = lbl.transform(list(train_data[f].values))
			test_data[f] = lbl.transform(list(test_data[f].values))

	train=train_data.drop(['description','avg_imagesize_x','avg_brightness_x','img_quantity_x','avg_luminance_x','created','listing_id','photos','features'],axis=1)
	test=test_data.drop(['description','avg_imagesize_x','avg_brightness_x','img_quantity_x','avg_luminance_x','created','listing_id','photos','features'],axis=1)
	
	print train.columns

	print '-'*100
	print test.columns
	y_train=train.loc[:,'interest_level']
	x_train=train.drop('interest_level',axis=1)#.loc[:,importance]
	
	x_test=test#.loc[:,importance]

	
	print "-"*150+"\ndata created"

	res=addnew(x_train,y_train,x_test)
	res=pd.DataFrame(res,columns=['low','medium','high'],index=x_test.index)
	ans=pd.concat([processed_test,res],axis=1)
	ans=ans.loc[:,['listing_id','low','medium','high']]
	
	ans.to_csv("voteResult.csv")

	

def addnew(x_train,y_train,x_test):
	clf = [LogisticRegression(C=100,n_jobs=12),RandomForestClassifier(n_estimators=200,n_jobs=12),GaussianNB(),DecisionTreeClassifier(max_depth=6),GradientBoostingClassifier(n_estimators=200, learning_rate=0.1,max_depth=6),AdaBoostClassifier(n_estimators=200)]
	print "-"*50+"\nmodel created"
	estimator=[('lr', clf[0]), ('rf', clf[1]), ('gnb', clf[2]),('dt',clf[3]),('gb',clf[4]),('rf2',clf[1]),('rf3',clf[1]),('gb2',clf[4]),('gb3',clf[4]),('gb4',clf[4]),('gb5',clf[4])]
	print "-"*150+"\nestimator created"
	print "-"*150+"\nparams created"
	eclf = VotingClassifier(estimators=estimator, voting='soft')
	eclf.fit(x_train,y_train)
	pred=eclf.predict_proba(x_test)
	print "-"*150+"\nscore created"
	

	return pred

main_function()
