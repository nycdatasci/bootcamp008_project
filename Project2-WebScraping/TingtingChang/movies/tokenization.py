# -*- coding: utf-8 -*-

import nltk
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
# import string
# import pandas as pd
# import numpy as np
import csv
import json

review = {}
data = []
with open('./movies/data/zootopia_2016.csv', 'r') as infile:
    reader = csv.reader(infile)
    for rows in reader:
        review['source_name'] = rows[0]
        review['comment_date'] = rows[1]
        review['critic_name'] = rows[2]
        review['comment_content'] = rows[3]
        data.append(review)
    print data

# with open('./movies/data2/zootopia_json.txt', 'w') as outfile:
#         json.dump(reviews, outfile)


# tokenizer = nltk.RegexpTokenizer(r'\w+')

# for i in range(0, len(reviews)):
#     cleaned_cmt = tokenizer.tokenize(reviews[i]['comment_content'])
#     reviews[i]['comment_content'] = str(' '.join(cleaned_cmt))
#     stop_words = set(stopwords.words('english'))
#     word_tokens = word_tokenize(reviews[i]['comment_content'])
#     print word_tokens
    #filtered_sentence = [w for w in word_tokens if not w in stop_words]
        
#     filtered_sentence = []
#     for w in word_tokens:
#         if w not in stop_words:
#             filtered_sentence.append(w)
#     print filtered_sentence
    
    
    
