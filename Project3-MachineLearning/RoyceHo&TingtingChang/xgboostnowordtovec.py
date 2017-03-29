import numpy as np
import pandas as pd
import xgboost as xgb
from sklearn import preprocessing, model_selection
import string
from sklearn.feature_extraction.text import  CountVectorizer
from scipy.stats import boxcox
from scipy import sparse

train = pd.read_json('train_useful.json')
test = pd.read_json('test_useful.json')

y_map = {'low': 2, 'medium': 1, 'high': 0}
train['interest_level'] = train['interest_level'].apply(lambda x: y_map[x])
y_train = train.interest_level.values


x_train = train.drop(['interest_level'], axis = 1)
x_test = test

cols = [c for c in x_train.columns if not (('desc:' in c) or ('feats:' in c))]
x_train = x_train[cols]
x_test = x_test[cols]

x_train = sparse.csr_matrix(x_train)
x_test = sparse.csr_matrix(x_test)


SEED = 777
NFOLDS = 5

params = {
    'eta':.01,
    'colsample_bytree':.8,
    'subsample':.8,
    'seed':0,
    'nthread':16,
    'objective':'multi:softprob',
    'eval_metric':'mlogloss',
    'num_class':3,
    'silent':0
}

dtrain = xgb.DMatrix(data=x_train, label=y_train)
dtest = xgb.DMatrix(data=x_test)


bst = xgb.cv(params, dtrain, 10000, NFOLDS, early_stopping_rounds=50, verbose_eval=25)
best_rounds = np.argmin(bst['test-mlogloss-mean'])
bst = xgb.train(params, dtrain, best_rounds)

bst.save_model('xgboostnowordtovec.model')
preds = bst.predict(dtest)
preds = pd.DataFrame(preds)
cols = ['high', 'medium', 'low']
preds.columns = cols
preds['listing_id'] = test.listing_id.values

preds.to_csv('xgboostnowordtovec.csv', index=None)