import numpy as np # linear algebra
import pandas as pd # data processing, CSV file I/O (e.g. pd.read_csv)


# from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.grid_search import GridSearchCV
# from sklearn.externals import joblib



# train = pd.read_csv('./royce/train_dummies.csv')
# test = pd.read_csv('./royce/test_dummies.csv')
train = pd.read_csv('train_lg.csv')
test = pd.read_csv('test_lg.csv')

# y_map = {'low': 2, 'medium': 1, 'high': 0}
# train['interest_level'] = train['interest_level'].apply(lambda x: y_map[x])
# y_train = train.interest_level.values
# X_train = train.drop(['interest_level'], axis = 1)

# X_test = test


y_map = {'low': 2, 'medium': 1, 'high': 0}
train['interest_level'] = train['interest_level'].apply(lambda x: y_map[x])
y_train = train.interest_level.values
X_train = train.drop(['interest_level'], axis = 1)

X_test = test

#joblib memmap the data
# joblib.dump(X_train, '/tmp/Xmwe.mmap')
# loading for memmapped usage
# X_train = joblib.load('/tmp/Xmwe.mmap', mmap_mode='r+')

## ElasticNet

param_grid = [{'C': [0.001, 0.01, 0.1, 1, 10, 100, 1000],
								'penalty': ('l1', 'l2')}]
grid = GridSearchCV(LogisticRegression(), param_grid, scoring = 'accuracy', cv=5, n_jobs=3)
grid.fit(X_train, y_train)

print('Best parameters: %s' % grid.best_params_)
print('Accuracy: %.2f' % grid.best_score_)
print ('Best estimator: %s' % grid.best_estimator_)

preba = grid.best_estimator_.predict_proba(X_test)
preba = pd.DataFrame(preba)
cols = ['high', 'medium', 'low']
preba.columns = cols
preba['listing_id'] = test.listing_id.values

preba.to_csv('./input/submission_regression.csv', index=False)


# Best parameters: {'penalty': 'l1', 'C': 100}
# Accuracy: 0.70
# Best estimator: LogisticRegression(C=100, class_weight=None, dual=False, fit_intercept=True,
#           intercept_scaling=1, max_iter=100, multi_class='ovr', n_jobs=1,
#           penalty='l1', random_state=None, solver='liblinear', tol=0.0001,
#           verbose=0, warm_start=False)




















