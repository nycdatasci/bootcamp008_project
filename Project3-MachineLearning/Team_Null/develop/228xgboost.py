import numpy as np
import pandas as pd
from scipy import stats
import random

def main_function():
	importance=['price','avg_imagesize_x','word_count','avg_luminance_x','avg_brightness_x','manager count','description_sentiment','img_quantity_x','unique_count','bedrooms','bathrooms','No Fee',\
	'dist_count','Doorman','Laundry In Building','Elevator','Fitness Center','Reduced Fee','Exclusive','Cats Allowed','Dogs Allowed','Furnished',\
	'Common Outdoor Space','Laundry In Unit','Private Outdoor Space','Parking Space','Short Term Allowed','By Owner','Sublet / Lease-Break',\
	'Storage Facility']
	processed_data=pd.read_json("../data/processed_train.json")
	img=pd.read_csv("../data/image_stats-fixed.csv",index_col=0)
	processed_data=processed_data.merge(img,how="left",on="listing_id")
	processed_data=processed_data.fillna(0)
	train_data=processed_data.sample(n=processed_data.shape[0]*8/10)
	test_data=processed_data.drop(train_data.index)
	train=train_data.drop(['building_id','created','description','display_address','longitude','latitude','manager_id','listing_id','photos','street_address','features'],axis=1)
	test=test_data.drop(['building_id','created','description','display_address','longitude','latitude','manager_id','listing_id','photos','street_address','features'],axis=1)
	ans=[['Features','Train Acc','Test Acc']]
	for i in range(5,train.shape[1]+1):
		y_train=train.loc[:,'interest_level']
		x_train=train.drop('interest_level',axis=1).loc[:,importance[0:i]]
		y_test=test.loc[:,'interest_level']
		x_test=test.drop('interest_level',axis=1).loc[:,importance[0:i]]
		xg_train=xgb.DMatrix(x_train,label=y_train)
		xg_test=xgb.DMatrix(x_test,label=y_test)
		param['objective'] = 'multi:softmax'
# scale weight of positive examples
		param['eta'] = 0.1
		param['max_depth'] = 6
		param['silent'] = 1
		param['nthread'] = 4
		param['num_class'] = 6
		watchlist = [ (xg_train,'train'), (xg_test, 'test') ]
		num_round = 5
		print "all initial completed"
		bst = xgb.train(param, xg_train, num_round, watchlist );
# get prediction
		print "train"
		trainacc=accuracy_score(bst.predict(xg_train),y_train)
		testacc=accuracy_score(bst.predict(xg_test),y_test)
		
		print "This model is for top ", i, " features"
		print "train accuracy on train data is ",trainacc
		print "test accuracy on test data is ", testacc
		
		ans.append([i,trainacc,testacc])
	df = pd.DataFrame(ans[1:],columns=ans[0]).set_index('Features')
	df.to_csv("xgboost.csv")
main_function()