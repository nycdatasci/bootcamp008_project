import numpy as np
import pandas as pd
from sklearn import preprocessing

import nltk
from nltk.tokenize import word_tokenize

with open("../data/processed_train.json") as f:
    data = pd.read_json(f)

d = data.description
d_sum = d.apply(lambda x: reduce(logical_or, x), axis=1)

d_null = d.apply(lambda x: len(x) > 0) # ~3%

d_words = d.apply(word_tokenize)
d_words_count = d_words.apply(len)

d_length = d.apply(len)                 # probably useless
d_word_length_ratio = d_words/d_length  # .



percent_null = sum(~d_null) / float(sum(d_null))

dist = data.features.apply(
    lambda x: pd.Series(map(lambda z: 1 if (z in x) else 0, distinct_features) +
                        [list(np.setdiff1d(x, distinct_features))]))

