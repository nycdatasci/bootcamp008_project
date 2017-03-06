
# Read in Libraries
import pandas as pd
import numpy as np
import pandas as pd
from sklearn import preprocessing
from sklearn.neighbors import NearestNeighbors

# Import Files
train_df = pd.read_json("data/train.json")
test_df = pd.read_json("data/test.json")

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
	data_input['manager_id'] = lbl.transform(list(data_input['manager_id'].values))





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


# Split training set
X = train_df.ix[:, df.columns != "interest_level"]
y = train_df["interest_level"]
X_train, X_eval, y_train, y_eval = train_test_split(X, y, test_size=0.33)

# Split managers by fractions of interest level
temp = pd.concat([X_train.manager_id,pd.get_dummies(y_train)], axis = 1).groupby('manager_id').mean()
temp.columns = ['high_frac','low_frac', 'medium_frac']
temp['count'] = X_train.groupby('manager_id').count().iloc[:,1]

# assign value for manager skill
temp['manager_skill'] = temp['high_frac']*2 + temp['medium_frac']

unranked_managers_ixes = temp['count']<20
ranked_managers_ixes = ~unranked_managers_ixes

mean_values = temp.loc[ranked_managers_ixes, ['high_frac','low_frac', 'medium_frac','manager_skill']].mean()
temp.loc[unranked_managers_ixes,['high_frac','low_frac', 'medium_frac','manager_skill']] = mean_values.values

# Merge results onto training and evaluation set
X_train = X_train.merge(temp.reset_index(),how='left', left_on='manager_id', right_on='manager_id')
X_eval = X_eval.merge(temp.reset_index(),how='left', left_on='manager_id', right_on='manager_id')
new_manager_ixes = X_eval['high_frac'].isnull()
X_eval.loc[new_manager_ixes,['high_frac','low_frac', 'medium_frac','manager_skill']] = mean_values.values


# Run same process for Building Feature
temp_build = pd.concat([X_train.building_id,pd.get_dummies(y_train)], axis = 1).groupby('building_id').mean()
temp_build.columns = ['high_build','low_build', 'medium_build']
temp_build['build_count'] = X_train.groupby('building_id').count().iloc[:,1]

# assign value for manager skill
temp_build['building_score'] = temp_build['high_build']*2 + temp_build['medium_build']

unranked_building_ixes = temp_build['build_count']<20
ranked_building_ixes = ~unranked_building_ixes

building_mean = temp_build.loc[ranked_building_ixes, ['high_build','low_build', 'medium_build','building_score']].mean()
temp_build.loc[unranked_building_ixes,['high_build','low_build', 'medium_build','building_score']] = building_mean.values

# Merge results onto training and evaluation set
X_train = X_train.merge(temp_build.reset_index(),how='left', left_on='building_id', right_on='building_id')
X_eval = X_eval.merge(temp_build.reset_index(),how='left', left_on='building_id', right_on='building_id')
new_building_ixes = X_eval['high_build'].isnull()
X_eval.loc[new_building_ixes,['high_build','low_build', 'medium_build','building_score']] = building_mean.values



# Group coordinate locations together using KNN on training

# Feature Selection

# Fit Algorithms

# Results