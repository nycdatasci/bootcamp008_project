import os
import sys
import operator
import numpy as np
import pandas as pd
from scipy import sparse
from sklearn import model_selection, preprocessing, ensemble
from sklearn.metrics import log_loss
from sklearn.feature_extraction.text import TfidfVectorizer
from scipy.stats import zscore

from sklearn.cross_validation import KFold
#from sklearn.model_selection import KFold
from keras.models import Sequential
from keras.layers import Dense, Dropout, Activation
from keras.layers.normalization import BatchNormalization
from keras.layers.advanced_activations import PReLU
from keras.callbacks import EarlyStopping, ModelCheckpoint

from keras.utils.np_utils import to_categorical


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


y_train=train.loc[:,'interest_level']
x_train=train.drop('interest_level',axis=1)
x_test=test
y_train_copy=y_train.copy()
diction={'low':0,'medium':1,'high':2}
y_train1=map(lambda x: diction[x],y_train)
y_train=pd.Series(y_train1,index=y_train.index)

train_X = x_train.as_matrix()
test_X = x_test.as_matrix()
print "before scalar train size",train_X.shape
print "before scalar test size",test_X.shape

traintest = np.vstack((train_X, test_X))

traintest = preprocessing.StandardScaler().fit_transform(traintest)

train_X = traintest[range(train_X.shape[0])]
test_X = traintest[range(train_X.shape[0], traintest.shape[0])]
print "after scalar train size",train_X.shape
print "after scalar test size", test_X.shape
## neural net
def nn_model():
	model = Sequential()
    
	model.add(Dense(300, input_dim = train_X.shape[1], init = 'he_normal', activation='sigmoid'))
	model.add(BatchNormalization())
	model.add(Dropout(0.35))
	model.add(PReLU())
    
	model.add(Dense(50, init = 'he_normal', activation='sigmoid'))
	model.add(BatchNormalization())    
	model.add(Dropout(0.35))
	model.add(PReLU())
	
	model.add(Dense(3, init = 'he_normal', activation='softmax'))
	model.compile(loss = 'categorical_crossentropy', optimizer = 'adam')#, metrics=['accuracy'])
	return(model)

train_y = y_train

train_y = to_categorical(train_y,nb_classes=3)
print "this is train Y",train_y
print '-'*50
do_all = True
## cv-folds
nfolds = 10
if do_all:
	if nfolds>1:
		folds = KFold(int(len(train_y)), n_folds = nfolds, shuffle = True, random_state = 111)
	pred_oob = np.zeros((len(train_y), 3))
	testset = test_X
else:
	folds = KFold(int(len(train_y)*0.8), n_folds = nfolds, shuffle = True, random_state = 111)
	pred_oob = np.zeros((int(len(train_y)*0.8), 3))
	testset = train_X[range(int(len(train_y)*0.8), len(train_y))]
	ytestset = train_y[int(len(train_y)*0.8):(len(train_y))]

print "-"*100
print "KFold passed"
print "-"*100

## train models
nbags = 1

from time import time
import datetime

pred_test = np.zeros((testset.shape[0], 3))
begintime = time()
count = 0
filepath="weights.best.hdf5"
print "-"*100
print "Start train"
print "-"*100
if nfolds>1:
	for (inTr, inTe) in folds:
		count += 1
		print "INTR&INTE read"
		xtr = train_X[inTr]
		ytr = train_y[inTr]
		xte = train_X[inTe]
		yte = train_y[inTe]
		pred = np.zeros((xte.shape[0], 3))
		print(0)
		print "Model created"
		model = nn_model()
		early_stop = EarlyStopping(monitor='val_loss', patience=75, verbose=0)
		checkpoint = ModelCheckpoint(filepath, monitor='val_loss', verbose=0, save_best_only=True)
		print "model fit"
		model.fit(xtr, ytr, nb_epoch = 1200, batch_size=1000, verbose = 0, validation_data=[xte, yte])

		pred += model.predict_proba(x=xte, verbose=0)
	        
		pred_test += model.predict_proba(x=testset, verbose=0)
	        
		print(log_loss(yte,pred/(1)))
		if  not do_all:
			print(log_loss(ytestset,pred_test/(1+count*nbags)))
		print(str(datetime.timedelta(seconds=time()-begintime)))
	pred /= nbags
	pred_oob[inTe] = pred
	score = log_loss(yte,pred)
	print('Fold ', count, '- logloss:', score)
	if not do_all:
		print(log_loss(ytestset, pred_test/(nbags * count)))
else:
	for j in range(nbags):
		print(j)
		model = nn_model()
		model.fit(train_X, train_y, nb_epoch = 1200, batch_size=1000, verbose = 0)
		pred_test += model.predict_proba(x=testset, verbose=0)
		print(str(datetime.timedelta(seconds=time()-begintime)))

if nfolds>1:
	if do_all:
		print('Total - logloss:', log_loss(train_y, pred_oob))
	else:
		print('Total - logloss:', log_loss(train_y[0:int(len(train_y)*0.8)], pred_oob))


if do_all:
	## train predictions
	if nfolds>1:
		out_df = pd.DataFrame(pred_oob)
		out_df.columns = ["low", "medium", "high"]
		out_df["listing_id"] = train_data.listing_id.values
		out_df.to_csv("keras_starter_train.csv", index=False)

	## test predictions
	pred_test /= (nfolds*nbags)
	out_df = pd.DataFrame(pred_test)
	out_df.columns = ["low", "medium", "high"]
	out_df["listing_id"] = test_data.listing_id.values
	out_df.to_csv("keras__test_full.csv", index=False)
