
# coding: utf-8

# # Predicting Gender in 2017_2014_CP_WBS_SALES_Expanded_2

# ### Notebook automatically generated from your model

# Model SVM, trained on 2017-03-27 17:07:58.

# #### Generated on 2017-03-28 13:29:05.170417

# prediction
# This notebook will reproduce the steps for a BINARY_CLASSIFICATION on  2017_2014_CP_WBS_SALES_Expanded_2.
# The main objective is to predict the variable Gender

# Let's start with importing the required libs :

# In[ ]:

import dataiku
import numpy as np
import pandas as pd
import sklearn as sk
import dataiku.core.pandasutils as pdu
from dataiku.doctor.preprocessing import PCA
from collections import defaultdict, Counter


# And tune pandas display options:

# In[ ]:

pd.set_option('display.width', 3000)
pd.set_option('display.max_rows', 200)
pd.set_option('display.max_columns', 200)


# #### Importing base data

# The first step is to get our machine learning dataset:

# In[ ]:

# We apply the preparation that you defined. You should not modify this.
preparation_steps = []
preparation_output_schema = {u'userModified': False, u'columns': [{u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Date ID', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'bigint', u'name': u'Purchase ID', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'downcastedToStringFromMeaning': u'LongMeaning', u'type': u'string', u'name': u'Shipping Postal Code', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Shipping State', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Shipping Region', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Shipping Last Name', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Shipping First Name', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'bigint', u'name': u'Repeat Purchaser', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Billing Email', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'email domain', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Billing City', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Billing Last Name', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Billing First Name', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'downcastedToStringFromMeaning': u'LongMeaning', u'type': u'string', u'name': u'Billing Postal Code', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Billing State', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Gender', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Billiing Region', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'bigint', u'name': u'Web Visits for Day', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'bigint', u'name': u'Web Hits for Day', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Purchase Date', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Weekday', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Month', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'bigint', u'name': u'Day', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'bigint', u'name': u'Year', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'double', u'name': u'Purchase Total', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'bigint', u'name': u'Total Order Qty', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Conversion Rate to Visits', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Conv Rate to Web Hits', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'bigint', u'name': u'Total Quantity', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Product Name 1', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'bigint', u'name': u'Quantity 1', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Product Name 2', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'bigint', u'name': u'Quantity 2', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Product Name 3', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'bigint', u'name': u'Quantity 3', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Product Name 4', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'bigint', u'name': u'Quantity4', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'string', u'name': u'Product Name 5', u'maxLength': -1}, {u'timestampNoTzAsDate': False, u'type': u'bigint', u'name': u'Quantity 5', u'maxLength': -1}]}

ml_dataset_handle = dataiku.Dataset('2017_2014_CP_WBS_SALES_Expanded_2')
ml_dataset_handle.set_preparation_steps(preparation_steps, preparation_output_schema)
get_ipython().magic(u'time ml_dataset = ml_dataset_handle.get_dataframe(limit = 100000)')

print 'Base data has %i rows and %i columns' % (ml_dataset.shape[0], ml_dataset.shape[1])
# Five first records",
ml_dataset.head(5)


# #### Initial data management

# The preprocessing aims at making the dataset compatible with modeling.
# At the end of this step, we will have a matrix of float numbers, with no missing values.
# We'll use the features and the preprocessing steps defined in Models.
# 
# Let's only keep selected features

# In[ ]:

ml_dataset = ml_dataset[[u'Purchase Date', u'Billing Postal Code', u'Billiing Region', u'Billing Last Name', u'Product Name 1', u'Product Name 2', u'Product Name 3', u'email domain', u'Total Quantity', u'Shipping State', u'Shipping Region', u'Web Visits for Day', u'Conversion Rate to Visits', u'Day', u'Billing State', u'Gender', u'Year', u'Quantity4', u'Quantity 1', u'Purchase Total', u'Quantity 2', u'Billing City', u'Conv Rate to Web Hits', u'Shipping Last Name', u'Month', u'Total Order Qty', u'Web Hits for Day', u'Repeat Purchaser', u'Billing Email', u'Shipping Postal Code', u'Weekday']]


# Let's first coerce categorical columns into unicode, numerical features into floats.

# In[ ]:

# astype('unicode') does not work as expected
def coerce_to_unicode(x):
    if isinstance(x, str):
        return unicode(x,'utf-8')
    else:
        return unicode(x)

categorical_features = [u'Purchase Date', u'Billing Postal Code', u'Billiing Region', u'Billing Last Name', u'Product Name 1', u'Product Name 2', u'Product Name 3', u'email domain', u'Shipping State', u'Shipping Region', u'Conversion Rate to Visits', u'Billing State', u'Billing City', u'Conv Rate to Web Hits', u'Shipping Last Name', u'Month', u'Billing Email', u'Shipping Postal Code', u'Weekday']
numerical_features = [u'Total Quantity', u'Web Visits for Day', u'Day', u'Year', u'Quantity4', u'Quantity 1', u'Purchase Total', u'Quantity 2', u'Total Order Qty', u'Web Hits for Day', u'Repeat Purchaser']
text_features = []
from dataiku.doctor.utils import datetime_to_epoch
for feature in categorical_features:
    ml_dataset[feature] = ml_dataset[feature].apply(coerce_to_unicode)
for feature in text_features:
    ml_dataset[feature] = ml_dataset[feature].apply(coerce_to_unicode)
for feature in numerical_features:
    if ml_dataset[feature].dtype == np.dtype('M8[ns]'):
        ml_dataset[feature] = datetime_to_epoch(ml_dataset[feature])
    else:
        ml_dataset[feature] = ml_dataset[feature].astype('double')


# We are now going to handle the target variable and store it in a new variable:

# In[ ]:

target_map = {u'Male': 1, u'Female': 0}
ml_dataset['__target__'] = ml_dataset['Gender'].map(str).map(target_map)
del ml_dataset['Gender']


# Remove rows for which the target is unknown.
ml_dataset = ml_dataset[~ml_dataset['__target__'].isnull()]


# #### Cross-validation strategy

# The dataset needs to be split into 2 new sets, one that will be used for training the model (train set)
# and another that will be used to test its generalization capability (test set)

# This is a simple cross-validation strategy.

# In[ ]:

train, test = pdu.split_train_valid(ml_dataset, prop=0.8)
print 'Train data has %i rows and %i columns' % (train.shape[0], train.shape[1])
print 'Test data has %i rows and %i columns' % (test.shape[0], test.shape[1])


# #### Features preprocessing

# The first thing to do at the features level is to handle the missing values.
# Let's reuse the settings defined in the model

# In[ ]:

drop_rows_when_missing = []
impute_when_missing = [{'impute_with': u'MEAN', 'feature': u'Total Quantity'}, {'impute_with': u'MEAN', 'feature': u'Web Visits for Day'}, {'impute_with': u'MEAN', 'feature': u'Day'}, {'impute_with': u'MEAN', 'feature': u'Year'}, {'impute_with': u'CONSTANT', 'feature': u'Quantity4', 'value': 0.0}, {'impute_with': u'MEAN', 'feature': u'Quantity 1'}, {'impute_with': u'MEAN', 'feature': u'Purchase Total'}, {'impute_with': u'MEAN', 'feature': u'Quantity 2'}, {'impute_with': u'MEAN', 'feature': u'Total Order Qty'}, {'impute_with': u'MEAN', 'feature': u'Web Hits for Day'}, {'impute_with': u'MEAN', 'feature': u'Repeat Purchaser'}]

# Features for which we drop rows with missing values"
for feature in drop_rows_when_missing:
    train = train[train[feature].notnull()]
    test = test[test[feature].notnull()]
    print 'Dropped missing records in %s' % feature

# Features for which we impute missing values"
for feature in impute_when_missing:
    if feature['impute_with'] == 'MEAN':
        v = train[feature['feature']].mean()
    elif feature['impute_with'] == 'MEDIAN':
        v = train[feature['feature']].median()
    elif feature['impute_with'] == 'CREATE_CATEGORY':
        v = 'NULL_CATEGORY'
    elif feature['impute_with'] == 'MODE':
        v = train[feature['feature']].value_counts().index[0]
    elif feature['impute_with'] == 'CONSTANT':
        v = feature['value']
    train[feature['feature']] = train[feature['feature']].fillna(v)
    test[feature['feature']] = test[feature['feature']].fillna(v)
    print 'Imputed missing values in feature %s with value %s' % (feature['feature'], unicode(str(v), 'utf8'))


# We can now handle the categorical features (still using the settings defined in Models):

# Let's dummy-encode the following features.
# A binary column is created for each of the 100 most frequent values.

# In[ ]:

LIMIT_DUMMIES = 100

categorical_to_dummy_encode = [u'Purchase Date', u'Billing Postal Code', u'Billiing Region', u'Billing Last Name', u'Product Name 1', u'Product Name 2', u'Product Name 3', u'email domain', u'Shipping State', u'Shipping Region', u'Conversion Rate to Visits', u'Billing State', u'Billing City', u'Conv Rate to Web Hits', u'Shipping Last Name', u'Month', u'Billing Email', u'Shipping Postal Code', u'Weekday']

# Only keep the top 100 values
def select_dummy_values(train, features):
    dummy_values = {}
    for feature in categorical_to_dummy_encode:
        values = [
            value
            for (value, _) in Counter(train[feature]).most_common(LIMIT_DUMMIES)
        ]
        dummy_values[feature] = values
    return dummy_values

DUMMY_VALUES = select_dummy_values(train, categorical_to_dummy_encode)

def dummy_encode_dataframe(df):
    for (feature, dummy_values) in DUMMY_VALUES.items():
        for dummy_value in dummy_values:
            dummy_name = u'%s_value_%s' % (feature, unicode(dummy_value))
            df[dummy_name] = (df[feature] == dummy_value).astype(float)
        del df[feature]
        print 'Dummy-encoded feature %s' % feature

dummy_encode_dataframe(train)

dummy_encode_dataframe(test)


# Let's rescale numerical features

# In[ ]:

rescale_features = {u'Total Quantity': u'AVGSTD', u'Quantity 2': u'AVGSTD', u'Web Visits for Day': u'AVGSTD', u'Total Order Qty': u'AVGSTD', u'Quantity 1': u'AVGSTD', u'Purchase Total': u'AVGSTD', u'Year': u'AVGSTD', u'Repeat Purchaser': u'AVGSTD', u'Web Hits for Day': u'AVGSTD', u'Day': u'AVGSTD'}
for (feature_name, rescale_method) in rescale_features.items():
    if rescale_method == 'MINMAX':
        _min = train[feature_name].min()
        _max = train[feature_name].max()
        scale = _max - _min
        shift = _min
    else:
        shift = train[feature_name].mean()
        scale = train[feature_name].std()
    if scale == 0.:
        del train[feature_name]
        del test[feature_name]
        print 'Feature %s was dropped because it has no variance' % feature_name
    else:
        print 'Rescaled %s' % feature_name
        train[feature_name] = (train[feature_name] - shift).astype(np.float64) / scale
        test[feature_name] = (test[feature_name] - shift).astype(np.float64) / scale


# #### Modeling

# Before actually creating our model, we need to split the datasets into their features and labels parts:

# In[ ]:

train_X = train.drop('__target__', axis=1)
test_X = test.drop('__target__', axis=1)

train_Y = np.array(train['__target__'])
test_Y = np.array(test['__target__'])


# Now we can finally create our model !

# In[ ]:

from sklearn.svm import SVC
clf = SVC(C=1.0,
          kernel='poly',
          gamma=2.0,
          coef0=0.0,
          tol=0.001,
          probability=True,
          max_iter=-1)


# ... And train it

# In[ ]:

get_ipython().magic(u'time clf.fit(train_X, train_Y)')


# Build up our result dataset

# The model is now being trained, we can apply it to our test set:

# In[ ]:

get_ipython().magic(u'time _predictions = clf.predict(test_X)')
get_ipython().magic(u'time _probas = clf.predict_proba(test_X)')
predictions = pd.Series(data=_predictions, index=test_X.index, name='predicted_value')
cols = [
    u'probability_of_value_%s' % label
    for (_, label) in sorted([(int(label_id), label) for (label, label_id) in target_map.iteritems()])
]
probabilities = pd.DataFrame(data=_probas, index=test_X.index, columns=cols)

# Build scored dataset
results_test = test_X.join(predictions, how='left')
results_test = results_test.join(probabilities, how='left')
results_test = results_test.join(test['__target__'], how='left')
results_test = results_test.rename(columns= {'__target__': 'Gender'})


# #### Results

# You can measure the model's accuracy:

# In[ ]:

from dataiku.doctor.utils.metrics import mroc_auc_score
test_Y_ser = pd.Series(test_Y)
print 'AUC value:', mroc_auc_score(test_Y_ser, _probas)


# We can also view the predictions directly.
# Since scikit-learn only predicts numericals, the labels have been mapped to 0,1,2 ...
# We need to 'reverse' the mapping to display the initial labels.

# In[ ]:

inv_map = { label_id : label for (label, label_id) in target_map.iteritems()}
predictions.map(inv_map)


# That's it. It's now up to you to tune your preprocessing, your algo, and your analysis !
# 
