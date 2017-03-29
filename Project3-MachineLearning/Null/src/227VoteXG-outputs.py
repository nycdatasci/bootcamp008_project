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
##loading and processing data
##logistic regression, random forest classifier, gaussianNB
def main_function():
	print "\n\n\n"+'='*120 + '\n' +"Beginning Model...\n" + '='*120
	print "Defining Features\n" + '*'*120
	importance=['price','avg_imagesize_x','word_count','avg_luminance_x','avg_brightness_x','manager count','description_sentiment','img_quantity_x','unique_count','bedrooms','bathrooms','No Fee',\
	'dist_count','Doorman','Laundry In Building','Elevator','Fitness Center','Reduced Fee','Exclusive','Cats Allowed','Dogs Allowed','Furnished',\
	'Common Outdoor Space','Laundry In Unit','Private Outdoor Space','Parking Space','Short Term Allowed','By Owner','Sublet / Lease-Break',\
	'Storage Facility']
	print "\n\nReading in Training Data...\n" + '*'*120
	processed_data=pd.read_json("../data/processed_train.json")
	print "\n\nReading in Image stats...\n" + '*'*120
	img=pd.read_csv("../data/image_stats-fixed.csv",index_col=0)
	print "\n\nProcessing Data...\n"
	processed_data=processed_data.merge(img,how="left",on="listing_id")
	print "Addressing NA values...\n" 
	processed_data=processed_data.fillna(0)
	print "Data processed\n"+ '*'*120 

	train_data=processed_data.sample(n=processed_data.shape[0]*8/10)
	test_data=processed_data.drop(train_data.index)
	print "Splitting data into train & test sets\n"+ '-'*120 + '\n' + '-'*120 

	train=train_data.drop(['building_id','created','description','display_address','manager_id','longitude','latitude','listing_id','photos','street_address','features'],axis=1)
	test=test_data.drop(['building_id','created','description','display_address','manager_id','longitude','latitude','listing_id','photos','street_address','features'],axis=1)
	ans=[['Features','Train','Test']]
	print "Training Features:" +"\n"*5
	for i in range(5,len(importance)+1):
		y_train=train.loc[:,'interest_level']
		x_train=train.drop('interest_level',axis=1).loc[:,importance[0:i]]
		y_test=test.loc[:,'interest_level']
		x_test=test.drop('interest_level',axis=1).loc[:,importance[0:i]]
		print '-'*120 + '\n' 
		print "Features : " + str(i)
		print '-'*120

		res=voting(x_train,y_train,x_test,y_test)
		print "This model is for top ", i, " features"
		print "train accuracy is ",res[0]
		print "test accuracy is ", res[1]
		ans.append([i,res[0],res[1]])
	df = pd.DataFrame(ans[1:],columns=ans[0]).set_index('Features')
	print "writing output to voting.csv"
	df.to_csv("voting.csv")
	print "*"*200 + '\nModel Complete\n' + '*'*120
	

def voting(x_train,y_train,x_test,y_test):
	clf1 = LogisticRegression(random_state=1)
	print "		Set Logistic Regression\n" + '-'*120
	clf2 = RandomForestClassifier(random_state=1)
	print "		Set Random Forest\n" + '-'*120
	clf3 = GaussianNB()
	print "		Set Naive Bayes\n" + '-'*120
	clf4 = DecisionTreeClassifier(max_depth=4)
	print "		Set Decision Tree\n" + '-'*120
	eclf = VotingClassifier(estimators=[('lr', clf1), ('rf', clf2), ('gnb', clf3),('dt',clf4)], voting='soft')
	print "		Set Voting Classifier\n" + '-'*120
	params = {'lr__C': [1, 100], 'rf__n_estimators': [20, 200],}
	grid = GridSearchCV(estimator=eclf, param_grid=params, cv=5)
	print "		Set Grid Search\n" + '-'*120
	print "		Starting grid fit... (this may take a while)"
	grid.fit(x_train, y_train)
	print "		Grid fit complete\n" + '-'*120
	trainacc=sum(grid.predict(x_train)==y_train)*1.0/y_train.shape[0]
	testacc=sum(grid.predict(x_test)==y_test)*1.0/y_test.shape[0]
	print "Calculating test accuracy\n" + '-'*120
	res=[trainacc,testacc]
	return [trainacc,testacc]

main_function()
