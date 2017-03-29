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
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn import model_selection, preprocessing, ensemble
##loading and processing data
##logistic regression, random forest classifier, gaussianNB
def main_function():
	processed_data=pd.read_json("../data/processed_train.json")
	img=pd.read_csv("../data/image_stats-fixed2.csv",index_col=0)
	processed_data=processed_data.merge(img,how="left",on="listing_id")
	processed_data=processed_data.fillna(0)
	train_data=processed_data
	train_data["created"] = pd.to_datetime(train_data["created"])
	train_data["created_year"] = train_data["created"].dt.year
	train_data["created_month"] = train_data["created"].dt.month
	train_data["created_day"] = train_data["created"].dt.day
	train_data["created_hour"] = train_data["created"].dt.hour

	
	categorical = ["display_address", "manager_id", "building_id", "street_address"]
	for f in categorical:
		if train_data[f].dtype=='object':
			#print(f)
			lbl = preprocessing.LabelEncoder()
			lbl.fit(list(train_data[f].values))
			train_data[f] = lbl.transform(list(train_data[f].values))
		

	train=train_data.drop(['description','avg_imagesize_x','avg_brightness_x','img_quantity_x','avg_luminance_x','created','listing_id','photos','features'],axis=1)
	print train.columns

	print '-'*100
	print "-"*150+"\ndata created"

	
	ans=[['Features','Train','Test']]
	
	y_train=train.loc[:,'interest_level']
	x_train=train.drop('interest_level',axis=1)
	print "-"*150+"\ndata created"

	res=addnew(x_train,y_train)
	print res

	

def addnew(x_train,y_train):
	clf = [LogisticRegression(C=100),RandomForestClassifier(n_estimators=200),GaussianNB(),DecisionTreeClassifier(max_depth=4),GradientBoostingClassifier(n_estimators=200, learning_rate=0.1,max_depth=4),AdaBoostClassifier(n_estimators=200)]
	score=[]
	print "-"*50+"\nmodel created"
	for i in range(6):
		estimator=[('lr', clf[0]), ('rf', clf[1]), ('gnb', clf[2]),('dt',clf[3]),('gb',clf[4]),('gb2',clf[4]),('gb3',clf[4]),('gb4',clf[4]),('gb5',clf[4]),('gb6',clf[5]),('gb7',clf[4]),('gb8',clf[4]),('gb9',clf[4]),('ada2',clf[5])]
		estimator.append(('new',clf[i]))
		print "-"*150+"\nestimator created"
		# if i==0:
		# 	params = {'lr__C': [1, 100], 'rf__n_estimators': [20, 200],'new__C': [1, 100]}
		# elif i==1:
		# 	params = {'lr__C': [1, 100], 'rf__n_estimators': [20, 200],'new__n_estimators': [20, 200]}
		print "-"*150+"\nparams created"
		eclf = VotingClassifier(estimators=estimator, voting='soft')
		score.append(np.mean(cross_val_score(eclf, x_train, y_train,n_jobs=4)))
		print "-"*150+"\nscore created"
		print "Score for model ", i, "is ", score[-1]

	return score

main_function()
