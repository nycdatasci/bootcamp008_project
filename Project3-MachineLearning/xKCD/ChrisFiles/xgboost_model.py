
# Read in Libraries
import os
import sys
import operator
import pandas as pd
import numpy as np
from scipy import sparse
from sklearn import preprocessing, ensemble
from sklearn.preprocessing import MinMaxScaler
from sklearn.neighbors import NearestNeighbors
from sklearn.feature_selection import SelectKBest, f_classif
from sklearn.cross_validation import train_test_split, KFold
import xgboost as xgb
from sklearn import cross_validation
from sklearn.metrics import log_loss
from sklearn.grid_search import GridSearchCV

# Import Files
train_df = pd.read_json("/Users/arianiherrera/Desktop/NYCDataScience/Kaggle_Project/data/train.json")
test_df = pd.read_json("/Users/arianiherrera/Desktop/NYCDataScience/Kaggle_Project/data/test.json")
train_df.reset_index(inplace = True)
test_df.reset_index(inplace = True)
# Pre-processing
def preProcessing(data_input):

	# Numerical Features: Bathrooms, Bedrooms, Long, Lat, Price

	# Given no linearity for bath and beds interest, limit max number and convert to categorical
     data_input['bathrooms'].ix[data_input['bathrooms']>3] = 3
     data_input['bedrooms'].ix[data_input['bedrooms']>4] = 4


	# Outliers exist in the Price Feature, so we want to use a robust scaler method suited towards outliers
	# removes median then scales data based on inter-quartile range
     data_input['total_rooms'] = data_input['bedrooms'] + data_input['bathrooms']
     data_input['total_rooms'].ix[data_input['total_rooms']==0] = 1
     data_input['p_per_room'] = data_input['price']/data_input['total_rooms']
     robust_scaler = MinMaxScaler()
     robust_scaler.fit_transform(data_input['price'])


	# Categorical Features: Date, Manager ID,

	# Date Feature
     data_input["created"] = pd.to_datetime(data_input["created"])

	# Transform categorical features
     categorical = ['display_address', 'manager_id', 'building_id', 'street_address']
     for i in categorical:
         if data_input[i].dtype == 'object':
             lbl = preprocessing.LabelEncoder()
             lbl.fit(list(data_input[i].values))
             data_input[i] = lbl.transform(list(data_input[i].values))

     return data_input





# Feature Engineering
def featEngineering(data_input):

	# Create Feature which records the number of photos associated with listing
	data_input["num_photos"] = data_input["photos"].apply(len)
	data_input["num_photos"] = np.where(data_input['num_photos'] > 12 , 12, data_input['num_photos'])

	# Create Feature which records the number of features
	data_input["num_features"] = data_input["features"].apply(len)
	data_input["num_features"] = np.where(data_input['num_features'] > 17 , 17, data_input['num_features'])

	# Create year, month and day features
	data_input["created_year"] = data_input["created"].dt.year
	data_input["created_month"] = data_input["created"].dt.month
	data_input["created_day"] = data_input["created"].dt.day

	# Create feature with number of description words
	data_input["num_description_words"] = data_input["description"].apply(lambda x: len(x.split(" ")))

	return data_input

# Apply pre-processing and feature engineering
preProcessing(train_df)
preProcessing(test_df)

featEngineering(train_df)
featEngineering(test_df)

#train_df.reset_index(inplace = True)
#test_df.reset_index(inplace = True)

# Split training set
X = train_df.ix[:, train_df.columns != "interest_level"]
y = train_df["interest_level"]

# Split managers by fractions of interest level
temp = pd.concat([X.manager_id,pd.get_dummies(y)], axis = 1).groupby('manager_id').mean()
temp.columns = ['high_frac','low_frac', 'medium_frac']
temp['count'] = X.groupby('manager_id').count().iloc[:,1]

# assign value for manager skill
temp['manager_skill'] = temp['high_frac']*2 + temp['medium_frac']

unranked_managers_ixes = temp['count']<20
ranked_managers_ixes = ~unranked_managers_ixes

mean_values = temp.loc[ranked_managers_ixes, ['high_frac','low_frac', 'medium_frac','manager_skill']].mean()
temp.loc[unranked_managers_ixes,['high_frac','low_frac', 'medium_frac','manager_skill']] = mean_values.values

# Merge results onto training and evaluation set
X = X.merge(temp.reset_index(),how='left', left_on='manager_id', right_on='manager_id')

# Run same process for Building Feature
temp_build = pd.concat([X.building_id,pd.get_dummies(y)], axis = 1).groupby('building_id').mean()
temp_build.columns = ['high_build','low_build', 'medium_build']
temp_build['build_count'] = X.groupby('building_id').count().iloc[:,1]

# assign value for manager skill
temp_build['building_score'] = temp_build['high_build']*2 + temp_build['medium_build']

unranked_building_ixes = temp_build['build_count']<20
ranked_building_ixes = ~unranked_building_ixes

building_mean = temp_build.loc[ranked_building_ixes, ['high_build','low_build', 'medium_build','building_score']].mean()
temp_build.loc[unranked_building_ixes,['high_build','low_build', 'medium_build','building_score']] = building_mean.values

# Merge results onto training and evaluation set
X = X.merge(temp_build.reset_index(),how='left', left_on='building_id', right_on='building_id')

# Transform Test data and bind train and eval data
train_df = X
#y_combine = y_eval.append(y)
#y_combine.sort_index(inplace = True)
#train_df['count'] = train_df.groupby(['manager_id'])['listing_id'].transform('count')
#train_df['build_count'] = train_df.groupby(['building_id'])['listing_id'].transform('count')
train_df['interest_level'] = y



test_df = test_df.merge(temp.reset_index(),how='left', left_on='manager_id', right_on='manager_id')
new_manager_ixes = test_df['high_frac'].isnull()
test_df.loc[new_manager_ixes,['high_frac','low_frac', 'medium_frac','manager_skill']] = mean_values.values

test_df = test_df.merge(temp_build.reset_index(),how='left', left_on='building_id', right_on='building_id')
new_building_ixes = test_df['high_build'].isnull()
test_df.loc[new_building_ixes,['high_build','low_build', 'medium_build','building_score']] = building_mean.values

train_df['manager_count'] = train_df.groupby(['manager_id'])['listing_id'].transform('count')
train_df['building_count'] = train_df.groupby(['building_id'])['listing_id'].transform('count')

test_df['manager_count'] = test_df.groupby(['manager_id'])['listing_id'].transform('count')
test_df['building_count'] = test_df.groupby(['building_id'])['listing_id'].transform('count')
print test_df["listing_id"].head()
#test_df['count'] = test_df.groupby(['manager_id'])['listing_id'].transform('count')
#test_df['build_count'] = test_df.groupby(['building_id'])['listing_id'].transform('count')

# Group coordinate locations together using KNN on training

# Feature Selection
cols = test_df.columns.values
predictors = [i.encode('ascii', 'ignore') for i in cols]
predictors.remove('description')
predictors.remove('features')
predictors.remove('photos')
predictors.remove('listing_id')
predictors.remove('created')
predictors.remove('created_year')
predictors.remove('high_frac')
predictors.remove('medium_frac')
predictors.remove('low_frac')
predictors.remove('high_build')
predictors.remove('medium_build')
predictors.remove('low_build')
predictors.remove('build_count')
predictors.remove('count')
predictors.remove('created_month')
predictors.remove('index')

#print predictors
#print y_combine.size
#print train_df['interest_level'].size
#print y.tail(100)
#print train_df['manager_skill'].describe()
#print train_df.shape
#print test_df.tail(20)


# Perform feature selection
selector = SelectKBest(f_classif, k=10)
selector.fit(train_df[predictors], train_df["interest_level"])
# Get the raw p-values for each feature, and transform from p-values into scores
scores = -np.log10(selector.pvalues_)
# pair scores with names
scores_list_total = zip(predictors, scores)

score_index = selector.get_support()
score_names = [i for (i, v) in zip(predictors, score_index) if v]
print scores_list_total


# Change interest lvl to numeric
target_map = {'high': 0, 'medium': 1, 'low': 2}
train_X = train_df[predictors]
train_y = np.array(train_df['interest_level'].apply(lambda x: target_map[x]))


# Create function to run XGBoost model
def runXGB(train_X, train_y, test_X, params, test_y=None, predictors=None, seed_val = 0, num_rounds=1000):
    
    plst = list(params.items())
    xg_train = xgb.DMatrix(train_X, label=train_y)
    if test_y is not None:
        xg_test = xgb.DMatrix(test_X, label=test_y)
        watch_list = [(xg_train, 'train'), (xg_test, 'test')]
        model = xgb.train(plst, xg_train, num_rounds, watch_list, early_stopping_rounds=20)
    else:
        xg_test = xgb.DMatrix(test_X)
        model = xgb.train(plst, xg_train, num_rounds)
    
        pred_test_y = model.predict(xg_test)
        return pred_test_y, model


# Run Cross Validation
kf = cross_validation.KFold(n=train_X.shape[0], n_folds=5, shuffle = True, random_state=1)
cv_scores = []

xg_best_params = {
	'objective': 'multi:softprob', 'max_depth': 6, 'eta': 0.1,
	'silent':1, 'num_class': 3, 'eval_metric': 'mlogloss', 'seed': 0,
	'min_child_weight':1, 'subsample': 0.7, 'colsample_bytree': 0.7
}

for dev_index, val_index in kf:
    dev_X, val_X = train_X.loc[dev_index,:], train_X.loc[val_index,:]
    dev_y, val_y = train_y[dev_index], train_y[val_index]
    predictions, model = runXGB(dev_X, dev_y, val_X, xg_best_params, val_y)
    cv_scores.append(log_loss(val_y,predictions))
    print(cv_scores)
    break
print params
# for alg, predictors in algorithms:
#     # Fit the algorithm using the full training data.   
#     alg.fit(train_df[predictors], train_df["interest_level"])
#     # Predict using the test dataset.  We have to convert all the columns to floats to avoid an error.
#     predictions = alg.predict_proba(test_df[predictors].astype(float))
#     full_predictions.append(predictions)
#     scores = cross_validation.cross_val_score(alg, train_df[predictors], train_df["interest_level"], cv=stratify_divide)
#     avg_score.append(scores.mean())
# print avg_score
# print sum(avg_score)/len(avg_score)

# Set up parameters for Algos


# change search parameters, run model then set best parameter as constant and repeat process (also look at feature importance!)
#gbc_search = {'max_leaf_nodes': [6],'subsample':[0.55], 'learning_rate': [.05, .01, .001], 'n_estimators': [3000], 'min_samples_leaf':[50], 'min_samples_split': [200], 'max_depth': [4], 'max_features': ['sqrt'], 'random_state': [1], 'warm_start': [True]}
#
## Fit Grids
#gbc = GradientBoostingClassifier()
#
#
#gbc_clf = GridSearchCV(gbc, gbc_search, verbose=3, n_jobs= 3, scoring = 'log_loss',cv=stratify_divide)
#
#gbc_clf.fit(train_df[predictors], train_df["interest_level"])
#
## get params and log loss: GBC best = 0.58769686897544415, RFC best = 0.675859134382
#gbc_score = [gbc_clf.best_score_, gbc_clf.best_params_]
#
#print gbc_score
#
## get feature importance and visualize
#GB_importance = gbc_clf.best_estimator_.feature_importances_
#
#
#pd.Series(index = predictors, data = gbc_clf.best_estimator_.feature_importances_).sort_values().plot(kind = 'bar')
#
#
#
## Get best estimations for grids
#gbc_predictions = gbc_clf.best_estimator_.predict_proba(test_df[predictors].astype(float))

#print gbc_clf.best_estimator_
#print predictors

# Results
predictions, model = runXGB(train_X, train_y, test_df[predictors], params=xg_best_params, num_rounds=400)
submission = pd.DataFrame(predictions)
submission.columns = ["high", "medium", "low"]
submission["listing_id"] = test_df.listing_id.values

submission.to_csv("/Users/arianiherrera/Desktop/NYCDataScience/Kaggle_Project/xgb_submission.csv", index=False)
print submission
















