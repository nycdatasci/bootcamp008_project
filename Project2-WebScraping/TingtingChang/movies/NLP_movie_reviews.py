# put 100 movies into one big data frame
import pandas as pd
import csv
import json
import re
import nltk
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize


def put_data_together():
    import os
    import re
    data_dir = 'movies/data/'
    pwd = os.getcwd()
    
    file_names = os.listdir(os.path.join(pwd, data_dir))
    data = None
    for file_ in file_names:
        file_dir = os.path.join(pwd, data_dir, file_)
        df = pd.read_csv(file_dir)
        df['movie_name'] = re.sub('_', ' ', file_[:-8]).capitalize()
        data = pd.concat([df, data], axis=0)
#     for i in range(0, len(file_names)):
#         file_dir = pwd + data_dir + file_names[i]
#         df = pd.read_csv(file_dir)
#         df['movie_name'] = re.sub('_', ' ', file_names[i][:-8]).capitalize()
#         data = pd.concat([df, data], axis=0)
    print "test"
    print len(data)
#     print data.iloc[1500]
    data.to_csv('data.csv', index=False)

def get_tokens():
    file_object = open('./movies/data2/data_tk.txt', 'w')
    
    df = pd.read_csv('./movies/data.csv')

    tokenizer = nltk.RegexpTokenizer(r'\w+')
    reviews = []

    for i in range(len(df)):
        df.loc[i]['review_detail'] = df.loc[i]['review_detail'].lower().strip()
        df.iloc[i, 3] = re.sub('\[full review in spanish\]', '', df.iloc[i, 3])    
        
        cleaned_cmt = tokenizer.tokenize(df.loc[i]['review_detail'])
        df.loc[i]['review_detail'] = str(' '.join(cleaned_cmt))
        stop_words = set(stopwords.words('english'))
        word_tokens = word_tokenize(df.loc[i]['review_detail'])
# #         filtered_sentence = [w for w in word_tokens if not w in stop_words]

        filtered_sentence = []
        for w in word_tokens:
            if w not in stop_words:
                filtered_sentence.append(w)
        file_object.writelines(str(filtered_sentence))
        df.loc[i]['review_detail'] = str(' '.join(filtered_sentence))
        reviews.append([df.loc[i]['review_detail'],df.loc[i]['movie_name']])
    file_object.close()
    print df.iloc[0, 3]
    print reviews[1] 
    pd.DataFrame(reviews, columns=['review_detail', 'movie_name']).\
    to_csv("reviews_movie.csv", index=False)
#     reviews = list(reviews.values.tolist())
    
    return df
    

## Sentiment analysis for whole dataset
from nltk.sentiment.vader import SentimentIntensityAnalyzer
import pandas as pd
import math

data_df = get_tokens()

## Sentiment analysis for whole dataset; get sentiment mean score for every movie
from nltk.sentiment.vader import SentimentIntensityAnalyzer
import pandas as pd
import math

def get_sentiment_score():
    sid = SentimentIntensityAnalyzer()
    sentiment_review = []
    sentiment_mean = []
    for i in range(0, len(reviews)):
        sentence = reviews[i]
        ss = sid.polarity_scores(str(sentence))
    #     for k in sorted(ss):
    #         print '{0}: {1}, '.format(k, ss[k])
    #     sentiment_review.append(str(sentence))
        ss['review_detail'] = sentence[0]
        ss['movie_name'] = sentence[1]
        sentiment_review.append(ss)
    # print pd.DataFrame(sentiment_review)
    sentiment_review = pd.DataFrame(sentiment_review)
    sentiment_review.to_csv('sentiment_reviews.csv', index = False)
    for i in list(set(list(sentiment_review['movie_name']))):
        sentiment_mean.append([i, sentiment_review[\
                        sentiment_review['movie_name'] == i]['compound'].mean()])
    sentiment_mean = pd.DataFrame(sentiment_mean)
    sentiment_mean.columns = ['movie_name', 'sentiment_mean']
    sentiment_review.to_csv('sentiment_mean.csv', index = False)

    return sentiment_review, sentiment_mean

[sentiment_review, sentiment_mean] = get_sentiment_score()



data_df = get_tokens()

put_data_together()  