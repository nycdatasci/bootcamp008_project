from flask import Flask
from flask import request
from gensim.parsing.preprocessing import preprocess_string
from gensim import corpora,models, similarities
import gensim
import urllib
import json
from textstat.textstat import textstat
from flask import jsonify
from clean_test import analyze_text 
from config import * 
import requests
import xgboost as xgb
from sklearn.externals import joblib
import numpy as np
import pandas as pd
from sklearn.metrics import log_loss
from sklearn.model_selection import cross_val_predict, cross_val_score, train_test_split
from scipy import sparse
from sklearn.feature_extraction.text import TfidfVectorizer, CountVectorizer

app = Flask(__name__)


def classify_text(text):
  # load dictionary 
  # load model
  text=urllib.unquote(urllib.unquote(text))
  text_names =['Pride and Prejudice',
  'Adventures of Huckleberry Finn',
  "Alice's Adventures in Wonderland",
  "Moby Dick", "A Tale of Two Cities",
  "Grimms' Fairy Tales"]
  corpus = gensim.corpora.MmCorpus('./NLP Project/gutenberg.mm')
  dictionary=gensim.corpora.Dictionary.load('./NLP Project/gutenberg.dict')
  lsi = models.LsiModel(corpus)
  print lsi.show_topics()
  lsi= gensim.models.LsiModel.load('./NLP Project/gutenberg.model')
  index = similarities.MatrixSimilarity(lsi[corpus])
  index.load("./NLP Project/gutenberg.index")
  vec_bow = dictionary.doc2bow(preprocess_string(text))
  vec_lsi = lsi[vec_bow] 
  sims = index[vec_lsi]
  sims=[str(x) for x in sims]
  return dict(sorted(zip(text_names,sims),key=lambda x: x[1],reverse=True))


def meaning_cloud_topics(text):
  url = "http://api.meaningcloud.com/topics-2.0"
  payload = "key={}&lang={}&txt={}&tt=a".format(API_KEY,"en",text,"json")
  headers = {'content-type': 'application/x-www-form-urlencoded'}
  response = requests.request("POST", url, data=payload, headers=headers)
  response=json.loads(response.text)
  # keys= [key for key in response.keys() if key != "status"]
  # values = [response[key] for key in keys]
  response.pop('status', None)
  return response

def meaning_cloud_classification(text):
  url = "http://api.meaningcloud.com/class-1.1"
  payload = "key={}&lang={}&txt={}&model=IPTC_en".format(API_KEY,"en",text,"json")
  headers = {'content-type': 'application/x-www-form-urlencoded'}
  response = requests.request("POST", url, data=payload, headers=headers)
  response=json.loads(response.text)
  response.pop('status', None)
  return response


def query(doc):
    vec_bow = dictionary.doc2bow(preprocess_string(doc))
    vec_lsi = lsi[vec_bow] 
    return vec_lsi

def xgb_model(x_train):
  bst = joblib.load('/Users/jakebialer/better_writer/Model notebook/xgboost_final_final.pkl')
  dtrain= xgb.DMatrix(data=x_train)
  xgb_pred = bst.predict(dtrain)
  preds = pd.DataFrame(xgb_pred)
  preds['scores'] = preds[[0,1,2,3,4,5,6]].idxmax(axis = 1)
  return preds 

def get_features_from_text(text,essay_id):
  
  # essay_id 
  essay_dict = {'essay_set':essay_id}
  essay = pd.DataFrame(essay_dict,index=[0])
  df = analyze_text(text)
  df= pd.concat([essay,df],axis=1)
  df['essay'] = text
  essay_id = 1
  text= "this is a test"
  def count_vec_df(df):
      pred_feats =  df.columns.values.tolist()
      pred_feats.remove("essay")
      c_vect = joblib.load('/Users/jakebialer/better_writer/Model notebook/cvect_final_final.pkl')
      c_vect_sparse_1 = c_vect.transform(df['essay'])
      c_vect_sparse1_cols = c_vect.get_feature_names()
      df.drop('essay',axis=1,inplace=True)
      df_cv1_sparse = sparse.hstack((df[pred_feats].astype(float), c_vect_sparse_1)).tocsr()
      x_train = df_cv1_sparse.toarray()
      return x_train
  
  train = count_vec_df(df)
  return train

@app.route("/api/",methods=['POST'])
def analyze():
     text = str(request.data)
     xg_features= get_features_from_text(text,1)
     xg_predicts = xgb_model(xg_features)
     xg_vals= xg_predicts.iloc[0].tolist()
     xg_vals = map(str,xg_vals )
     xg_columns= xg_predicts.columns
     xg_predicts=zip(xg_columns,xg_vals)
     data ={}
     text_funcs = [textstat.flesch_reading_ease,textstat.smog_index,
     textstat.flesch_kincaid_grade,textstat.flesch_kincaid_grade,textstat.flesch_kincaid_grade,
     textstat.coleman_liau_index,textstat.automated_readability_index,textstat.dale_chall_readability_score,
     textstat.difficult_words,textstat.linsear_write_formula,textstat.gunning_fog,textstat.text_standard,
     classify_text,meaning_cloud_topics,meaning_cloud_classification]
     for func in text_funcs:
      data[func.__name__] = func(text)
     data['xg_boost'] = xg_predicts
     return jsonify(data)


if __name__ == "__main__":
    app.run(debug=True)
