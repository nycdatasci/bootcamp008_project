import numpy as np
import pandas as pd
from sklearn import preprocessing, model_selection
import string
from sklearn.feature_extraction.text import  CountVectorizer
from scipy.stats import boxcox
from scipy import sparse
from sklearn.feature_extraction.text import  TfidfTransformer
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.decomposition import LatentDirichletAllocation
import nltk
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
import re
import string
import nltk.corpus



def tfidf_topic(text):
	# TF-IDF
	n_features = 10000
	n_topics = 7
	n_top_words = 500

	# TF
	tf_desc_vectorizer = CountVectorizer(max_df=0.95, min_df=2, max_features=n_features, stop_words='english')
	tf_desc = tf_desc_vectorizer.fit_transform(text)

	# IDF
	tfidf_process = TfidfTransformer()
	tfidf_desc = tfidf_process.fit_transform(tf_desc)
	tfidf_colmn = pd.DataFrame(pd.DataFrame(tfidf_desc.toarray()).\
	                           apply(np.mean, axis=1))

	# Topic Modeling
	lda = LatentDirichletAllocation(n_topics=n_topics, max_iter=5,
	                                learning_method='online', learning_offset=50.,
	                                random_state=0)
	lda.fit(tf_desc)
	topics = pd.DataFrame(lda.transform(tf_desc),
	                     columns = ['topic0', 'topic1', 'topic2', 
	                                'topic3', 'topic4', 'topic5', 'topic6'])
	topics['tfidf'] = tfidf_colmn
	return topics


def get_dec_tokens():
    text = []
    data = open('./input/test_desc_raw.txt', 'r')
    file_object = open('test_desc_clean.txt', 'w')
    for line in data:
        line = line.lower()

        line = re.sub(r'\d+', '', line)
        line = unicode(line, errors = 'ignore')
        tokenizer = nltk.RegexpTokenizer(r'\w+')
        cleaned_data = tokenizer.tokenize(line)

        # cleaned_data is the data withought punctuation
        line = str(' '.join(cleaned_data))

        stop_words = set(stopwords.words('english'))
        word_tokens = word_tokenize(line)


        filtered_sentence = [w for w in word_tokens if not w in stop_words]
        filtered_sentence = []
        for w in word_tokens:
            if w not in stop_words and\
            len(w) > 1 and \
            w != 'br':
                filtered_sentence.append(w)
        print filtered_sentence
        file_object.writelines(str(' '.join(filtered_sentence)+'\n'))
    file_object.close()


def get_features_tokens():
    text = []
    data = open('./input/test_features_raw.txt', 'r')
    file_object = open('test_features_clean.txt', 'w')
    for line in data:
        line = line.lower()

        line = re.sub(r'\d+', '', line)
        line = unicode(line, errors = 'ignore')
        tokenizer = nltk.RegexpTokenizer(r'\w+')
        cleaned_data = tokenizer.tokenize(line)

        # cleaned_data is the data withought punctuation
        line = str(' '.join(cleaned_data))

        stop_words = set(stopwords.words('english'))
        word_tokens = word_tokenize(line)


        filtered_sentence = [w for w in word_tokens if not w in stop_words]
        filtered_sentence = []
        for w in word_tokens:
            if w not in stop_words and\
            len(w) > 1 and \
            w != 'br':
                filtered_sentence.append(w)
        print filtered_sentence
        file_object.writelines(str(' '.join(filtered_sentence)+'\n'))
    file_object.close()



def data_transform(data):
	data['desc'] = data['description']
	data['desc'] = data['desc'].apply(lambda x: x.replace('<p><a  website_redacted ', ''))
	data['desc'] = data['desc'].apply(lambda x: x.replace('!<br /><br />', ''))

	string.punctuation.__add__('!!')
	string.punctuation.__add__('(')
	string.punctuation.__add__(')')

	remove_punct_map = dict.fromkeys(map(ord, string.punctuation))
	data['desc'] = data['desc'].apply(lambda x: x.translate(remove_punct_map))

	data['features2'] = data['features']
	data['features2'] = data['features2'].apply(lambda x: ' '.join(x))


	data_txt = data.loc[:, ['listing_id', 'desc', 'features2']]
	# only replace the empty desc with 0; still need deal with empty features2
	# data_txt = data_txt.replace(r'^\s+', 0, regex=True)
	return data_txt



## get data
train_file = './input/train.json'
test_file = './input/test.json'


train_data = pd.read_json(train_file)
test_data = pd.read_json(test_file)
listing_id = test_data.listing_id.values


# train = train_data.iloc[0:100, ]
# test = test_data.iloc[0:100, ]
train_txt = data_transform(train_data)
test_txt = data_transform(test_data)

# get description
trian_desc = train_txt.desc
test_desc = test_txt.desc

# get features
train_features = train_txt.features2
test_features = test_txt.features2


# call tfidf & topic 
train_tfidf_topic = tfidf_topic(text_trian)
test_tfidf_topic = tfidf_topic(text_test)


# save it to the new file
train_tfidf_topic.to_json('train_topic_tfidf.json')
test_tfidf_topic.to_json('test_topic_tfidf.json')


# word2vec

# save training description and features as txt file
train_features_text = train_txt['features']
with open("train_features.txt", "w") as text_file:
    for i in train_features_text:
        text_file.write((i+'\n').encode('utf8'))
#         text_file.write(str(i) + '\n', )


train_desc_text = train_txt['desc']
with open("train_desc.txt", "w") as text_file:
    for i in train_desc_text:
        text_file.write((i+'\n').encode('utf8'))
#         text_file.write(str(i) + '\n', )

# save test description and features as txt file
test_features_text = test_txt['features']
with open("test_features_raw.txt", "w") as text_file:
    for i in test_features_text:
        text_file.write((i+'\n').encode('utf8'))
#         text_file.write(str(i) + '\n', )


test_desc_text = test_txt['desc']
with open("test_desc_raw.txt", "w") as text_file:
    for i in test_desc_text:
        text_file.write((i+'\n').encode('utf8'))
#         text_file.write(str(i) + '\n', )

# tokenize data
get_dec_tokens()
get_features_tokens()


## training data features
# use word2vec mac to transfer clean txt to vectors
train_features_vect = pd.read_csv('./input/train_features_vectors.json',
                        delimiter=' ',
                        names=map(str, range(101)), 
                        skiprows=[0,1]).drop(['100'], axis=1)


# map every line of desc to vector library to vectors
train_vecs_feature = list()
with open('./input/train_features_clean_tokens.txt', 'rb') as f:
    for line in f:
        tokens = line.split()
        line_vecs_feature = train_features_vect.ix[set(tokens)].dropna(axis=0, how='all').mean(axis=0, skipna=True)
#         print line_vecs_feature
        train_vecs_feature.append(line_vecs_feature)

train_features_vec_df = pd.DataFrame(train_vecs_feature)
train_features_vec_df = train_features_vec_df.fillna(0)
train_features_vec_df.to_csv('train_features_vec.csv', index=False)

## training data description
# use word2vec mac to transfer clean txt to vectors
train_desc_vect = pd.read_csv('./input/train_desc_vectors.json',
                        delimiter=' ',
                        names=map(str, range(101)), 
                        skiprows=[0,1]).drop(['100'], axis=1)


# map every line of cleaned desc to vector library to vectors
train_vecs_desc = list()
with open('./input/train_desc_clean_tokens.txt', 'rb') as f:
    for line in f:
        tokens = line.split()
        line_vecs_desc = train_desc_vect.ix[set(tokens)].dropna(axis=0, how='all').mean(axis=0, skipna=True)
#         print line_vecs_feature
        train_vecs_desc.append(line_vecs_desc)

train_desc_vec_df = pd.DataFrame(train_vecs_desc)
train_desc_vec_df = train_desc_vec_df.fillna(0)
train_desc_vec_df.to_csv('train_desc_vec.csv', index=False)



## testing data features
# use word2vec mac to transfer clean txt to vectors
test_features_vect = pd.read_csv('./input/test_features_vectors.json',
                        delimiter=' ',
                        names=map(str, range(101)), 
                        skiprows=[0,1]).drop(['100'], axis=1)


# map every line of desc to vector library to vectors
test_vecs_feature = list()
with open('./input/test_features_clean_tokens.txt', 'rb') as f:
    for line in f:
        tokens = line.split()
        line_vecs_feature = test_features_vect.ix[set(tokens)].dropna(axis=0, how='all').mean(axis=0, skipna=True)
#         print line_vecs_feature
        test_vecs_feature.append(line_vecs_feature)

test_vecs_feature_df = pd.DataFrame(test_vecs_feature)
test_vecs_feature_df = test_vecs_feature_df.fillna(0)
test_vecs_feature_df.to_csv('test_features_vec.csv', index=False)


## testing data description
# use word2vec mac to transfer clean txt to vectors
test_desc_vect = pd.read_csv('./input/test_desc_vectors.json',
                        delimiter=' ',
                        names=map(str, range(101)), 
                        skiprows=[0,1]).drop(['100'], axis=1)


# map every line of cleaned desc to vector library to vectors
test_vecs_desc = list()
with open('./input/test_desc_clean_tokens.txt', 'rb') as f:
    for line in f:
        tokens = line.split()
        line_vecs_desc = test_desc_vect.ix[set(tokens)].dropna(axis=0, how='all').mean(axis=0, skipna=True)
#         print line_vecs_feature
        test_vecs_desc.append(line_vecs_desc)

test_desc_vec_df = pd.DataFrame(test_vecs_desc)
test_desc_vec_df = test_desc_vec_df.fillna(0)
test_desc_vec_df.to_csv('test_desc_vec.csv', index=False)


test_desc_raw = './input/test_desc_raw.txt'
test_desc_clean = 'test_desc_clean.txt'
get_tokens(test_desc_raw, test_desc_clean)


test_features_raw = './input/test_features_raw.txt'
test_features_clean = 'test_features_clean.txt'
get_tokens(test_features_raw, test_features_clean)



def get_tokens(input_file, output_file):
    text = []
    data = open(input_file, 'r')
    file_object = open(output_file, 'w')
    for line in data:
        line = line.lower()

        line = re.sub(r'\d+', '', line)
        line = unicode(line, errors = 'ignore')
        tokenizer = nltk.RegexpTokenizer(r'\w+')
        cleaned_data = tokenizer.tokenize(line)

        # cleaned_data is the data withought punctuation
        line = str(' '.join(cleaned_data))

        stop_words = set(stopwords.words('english'))
        word_tokens = word_tokenize(line)


        filtered_sentence = [w for w in word_tokens if not w in stop_words]
        filtered_sentence = []
        for w in word_tokens:
            if w not in stop_words and\
            len(w) > 1 and \
            w != 'br':
                filtered_sentence.append(w)
        print filtered_sentence
        file_object.writelines(str(' '.join(filtered_sentence)+'\n'))
    file_object.close()


train_desc_clean = './input/train_desc_clean.txt'
train_desc_vec = 'train_desc_vec.csv'
word_vec_mean(train_desc_clean, train_desc_vec)

test_features_vectors = './input/test_features_vects_vocabulary.json'
test_features_vec = './input/test_features_vec.csv'
word_vec_mean(test_features_vectors, test_features_vec)

def word_vec_mean(input_file1,input_file2, output_file):
	# map every line of cleaned desc to vector library to vectors
	## testing data features
	# use word2vec mac to transfer clean txt to vectors
	input_vectors = pd.read_csv(input_file1,
	                        delimiter=' ',
	                        names=map(str, range(101)), 
	                        skiprows=[0,1]).drop(['100'], axis=1)

	vectors = list()
	with open(input_file2, 'rb') as f:
	    for line in f:
	        tokens = line.split()
	        line_vecs = input_vectors.ix[set(tokens)].dropna(axis=0, how='all').mean(axis=0, skipna=True)
	#         print line_vecs_feature
	        vectors.append(line_vecs)

	vectors_df = pd.DataFrame(vectors)
	vectors_df = vectors_df.fillna(0)
	vectors_df.to_csv(output_file, index=False)


test_features_vects = './input/test_desc_vects_vocabulary.json'
test_features_clean = './input/test_features_clean.txt'
test_features_vec_mean = './input/test_features_vec_mean.csv'
word_vec_mean(test_features_vects, test_features_clean, test_features_vec_mean)


	

