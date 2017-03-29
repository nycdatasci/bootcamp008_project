# Domain Score 1 
import pandas as pd
from clean_test import analyze_text
import urllib
from multiprocessing import Pool

#p = multiprocessing.dummy.Pool(3)

data = pd.DataFrame.from_csv('training_set_rel3.tsv', sep='\t',encoding='ISO-8859-1')

texts= [text for text in data['essay'].tolist()]

p=Pool(5)
df = pd.DataFrame()

text_stats = p.map(analyze_text, texts)
for text_stat in text_stats:
  df2 = pd.DataFrame(text_stat)
  df=pd.concat([df, df2])

i = 0 

df.index=data.index
df.to_csv("essay_features1.csv")
