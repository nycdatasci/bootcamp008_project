
# Read in Libraries
import pandas as pd
import numpy as np
import pandas as pd
from sklearn import preprocessing
from sklearn.preprocessing import RobustScaler
from sklearn.neighbors import NearestNeighbors
from sklearn.feature_selection import SelectKBest, f_classif
from sklearn.cross_validation import train_test_split
from sklearn import cross_validation
from sklearn.metrics import log_loss
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.model_selection import GridSearchCV

# Import Files
train_df = pd.read_json(open("data/train.json", "r"))
test_df = pd.read_json(open("data/test.json", "r"))

# Pre-processing
def preProcessing(data_input):

	# Numerical Features: Bathrooms, Bedrooms, Long, Lat, Price

	# Given no linearity for bath and beds interest, limit max number and convert to categorical
	data_input['bathrooms'] = np.where(data_input['bathrooms'] > 4 , 4, data_input['bathrooms'])
	data_input['bedrooms'] = np.where(data_input['bedrooms'] > 5 , 5, data_input['bedrooms'])

	bath_dummies = pd.get_dummies(data_input['bathrooms'], prefix='bathrooms')
	bed_dummies = pd.get_dummies(data_input['bedrooms'], prefix='bedrooms')
	data_input[bath_dummies.columns] = bath_dummies
	data_input[bed_dummies.columns] = bed_dummies

	# Outliers exist in the Price Feature, so we want to use a robust scaler method suited towards outliers
	# removes median then scales data based on inter-quartile range
	robust_scaler = RobustScaler()
	data_input['price'] = robust_scaler.fit_transform(data_input['price'])


	# Categorical Features: Date, Manager ID,

	# Date Feature
	data_input["created"] = pd.to_datetime(data_input["created"])

	# Transform manager ID 
	label = preprocessing.LabelEncoder()
	label.fit(list(data_input['manager_id'].values))
	data_input['manager_id'] = label.transform(list(data_input['manager_id'].values))

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

train_df.reset_index(inplace = True)
test_df.reset_index(inplace = True)

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

#test_df['count'] = test_df.groupby(['manager_id'])['listing_id'].transform('count')
#test_df['build_count'] = test_df.groupby(['building_id'])['listing_id'].transform('count')

# Group coordinate locations together using KNN on training

# Feature Selection
cols = test_df.columns.values
predictors = [i.encode('ascii', 'ignore') for i in cols]
predictors.remove('street_address')
predictors.remove('building_id')
predictors.remove('description')
predictors.remove('display_address')
predictors.remove('features')
predictors.remove('manager_id')
predictors.remove('photos')
predictors.remove('listing_id')
predictors.remove('created')



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
#print scores_list_total

# Drop unwanted fields
predictors.remove('created_year')
predictors.remove('high_frac')
predictors.remove('medium_frac')
predictors.remove('low_frac')
predictors.remove('high_build')
predictors.remove('medium_build')
predictors.remove('low_build')
predictors.remove('build_count')
predictors.remove('count')

# Fit Algorithms
algorithms = [
    [GradientBoostingClassifier(random_state=1, n_estimators=500, max_depth=5), predictors],
    [RandomForestClassifier(random_state=1, n_estimators=500, min_samples_split=10, min_samples_leaf=5), predictors]#,
#    [SVC(random_state=1,kernel = 'rbf',C = 1.0,probability = True), predictors]
]


full_predictions = []
avg_score = []
stratify_divide = cross_validation.StratifiedKFold(train_df["interest_level"], 5, random_state=1)

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
gbc_params = {
	'learning_rate': xrange(.05, .25, .05), 'max_depth': xrange(5,16,2), 'min_samples_split': xrange(200,1001,200),
	'min_samples_leaf':range(30,71,10), 'max_features': 'sqrt', 'random_state': 1, 'n_jobs': 4, 'cv': stratify_divide, 
	'subsample':[0.6,0.7,0.75,0.8,0.85,0.9], 'n_estimators': xrange(400, 2001, 200), 'warm_start': True
}
rfc_params = {
	'max_depth': xrange(5,16,2), 'min_samples_split': xrange(200,1001,200), 'min_samples_leaf':range(30,71,10), 'max_features': 'sqrt', 
	'random_state': 1, 'n_jobs': 4, 'n_estimators': xrange(400, 2001, 200), 'class_weight': 'balanced_subsample', 'warm_start': True
}

# Fit Grids
gbc = GradientBoostingClassifier()
rfc = RandomForestClassifier()

gbc_clf = GridSearchCV(gbc, gbc_params)
rfc_clf = GridSearchCV(rfc, rfc_params)

gbc_clf.fit(train_df[predictors], train_df["interest_level"])
rfc_clf.fit(train_df[predictors], train_df["interest_level"])

# Get best estimations for grids
gbc_predictions = gbc_clf.predict_proba(test_df[predictors].astype(float))
rfc_predictions = rfc_clf.predict_proba(test_df[predictors].astype(float))



# Results

submission = pd.DataFrame({
        "listing_id": test_df["listing_id"],
        "high": predictions[:,0],
        "medium": predictions[:,2],
        "low": predictions[:,1]
})

submission.to_csv("/Users/arianiherrera/Desktop/NYCDataScience/Kaggle_Project/submission.csv", index=False)

















