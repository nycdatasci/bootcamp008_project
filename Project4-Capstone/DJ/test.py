from collections import deque,defaultdict
from collections import Counter
import re
import pandas as pd
from itertools import islice
from gensim.parsing.preprocessing import *
from nltk.tokenize import word_tokenize,sent_tokenize
from nltk import pos_tag
import entropy
from nltk.corpus import cmudict
from curses.ascii import isdigit 
import syllables
# PunktSentenceTokenizer
# PunktWordTokenizer

from gutenberg.cleanup import strip_headers
import requests
# http://nbviewer.jupyter.org/github/rare-technologies/gensim/blob/develop/docs/notebooks/atmodel_tutorial.ipynb
# https://nicschrading.com/project/Intro-to-NLP-with-spaCy/
# http://www.nltk.org/book/ch07.html
# http://www.nltk.org/book/ch07.html
def load_etext(num):
  url ='http://www.gutenberg.org/files/{0}/{0}-0.txt'.format(num)
  data= requests.get(url)
  return data.text

texts =[]
text_nums=[1342,76,11,2701,98,2591]
text_names =['Pride and Prejudice','Adventures of Huckleberry Finn',"Alice’s Adventures in Wonderland",
            "Moby Dick", "A Tale of Two Cities","Grimms’ Fairy Tales"]
for text_num in text_nums:
    text = strip_headers(load_etext(text_num))
    texts.append(text)

paragraph_regex = re.compile("\\n\\s*\\n")
all_paragraphs=re.split(paragraph_regex, texts[0])
all_paragraphs=filter(lambda x: len(x)>0, all_paragraphs)
# paragraph_lengths=map(lambda x: len(x), all_paragraphs)
# print reduce(lambda x, y: x + y, paragraph_lengths) / len(paragraph_lengths)

# 
# https://github.com/Kapiche/caterpillar/blob/master/caterpillar/processing/analysis/tokenize.py

# DEFAULT_FILTERS = [lambda x: x.lower(), strip_tags, strip_multiple_whitespaces]
# text=preprocess_string(texts[0],filters=DEFAULT_FILTERS)
# http://nlpforhackers.io/training-pos-tagger/



# for word in words:
#   parts_of_speech[pos_tag(word)]+=1
#   word_counter[word]+=1
#   last_four_words.append(word)
#   # N grams 
#   if len(last_four_words)>4:
#     last_four_words.popleft()
#     four_gram_counter[slice(0,last_four_words)] +=1 
#   if len(last_four_words)>=2:
#     two_gram_counter[slice(2,last_four_words)] +=1
#   if len(last_four_words)>=3:
#     three_gram_counter[slice(1,last_four_words)] +=1


import time
t1=time.time()



# def analyze_text(all_paragraphs):

def slice(n,words):
  n_gram = list(islice(words, n, 4))
  return " ".join(n_gram)

def nsyl(word): 
 return [len(list(y for y in x if isdigit(y[-1]))) for x in d[word.lower()]] 

# words = word_tokenize(text)
last_four_words =deque([])


paragraph_lengths=[]
sentence_lengths=[]
avg_sentence_length_per_para=[]
num_sentences_per_para=[]
entropies=[]
syllables_counter = defaultdict(int)



parts_of_speech_counter= defaultdict(int)
word_counter = defaultdict(int)
two_gram_counter = defaultdict(int)
three_gram_counter = defaultdict(int)
four_gram_counter = defaultdict(int)


for paragraph in all_paragraphs: 
  # extract_paragraph_topics() Google News and Wikipedia 
  # distance from previous paragraph 
  # distance from previous N paragraph
  paragraph_lengths.append(len(paragraph))
  entropies.append(entropy.shannon_entropy(paragraph.encode("utf-8")))
  num_sentences =0
  for sentence in sent_tokenize(paragraph):
    num_sentences +=1
    paragraph_sent_lengths =[]
    paragraph_sent_lengths.append(len(sentence))
    avg_sentence_length_per_para.append( sum(paragraph_sent_lengths) / float(len(paragraph_sent_lengths)))
    sentence_lengths.append(len(sentence))
    num_sentences_per_para.append(num_sentences)
    words = word_tokenize(paragraph)
    pos = pos_tag(words)
    for word,p in pos:
        syllables_counter[str(syllables.count(word))]+=1
        word_counter[word]+=1
        if word is not None:
          last_four_words.append(word)
        parts_of_speech_counter[p]+=1
        if len(last_four_words)>4:
          last_four_words.popleft()
          four_gram_counter[slice(0,last_four_words)] +=1 
        if len(last_four_words)>=2:
          two_gram_counter[slice(2,last_four_words)] +=1
        if len(last_four_words)>=3:
          three_gram_counter[slice(1,last_four_words)] +=1
        # N grams 
        # Stop Words
        # Syllable words 



features = pd.DataFrame()
#analyze_text(all_paragraphs)

# paragraph_lengths
# sentence_lengths
# avg_sentence_length_per_para
# num_sentences_per_para
# entropies
# syllables_counter
# parts_of_speech_counter
# word_counter
# two_gram_counter
# three_gram_counter 
# four_gram_counter 

all_syllables = []
for key in syllables_counter.keys():
  all_syllables.extend([float(key)]*syllables_counter[key])

total_parts_of_speech = 0
for key in parts_of_speech_counter:
  total_parts_of_speech+=parts_of_speech_counter[key]



df1 = pd.DataFrame({'average_paragraph_length':[np.mean(paragraph_lengths)],
                    'average_sentence_lengths':[np.mean(sentence_lengths)],
                    'avg_entropies':[np.mean(entropies)],
                    'avg_syllables':[np.mean(all_syllables)]
                    # proportion of parts of speech -> parts of speech/ total parts of speech
                    # proportion of stop words / total words 
                    # proportion of bigram stop words 

                    })

for part_of_speech in parts_of_speech_counter.keys():
  df1[part_of_speech+"_prop"] = parts_of_speech_counter[part_of_speech]/float(total_parts_of_speech)

total_words = 0 
for key in word_counter:
  total_words+=word_counter[key]


for stopword in STOPWORDS:
  df1[stopword+"_prop"] = word_counter[stopword]/float(total_words)

from sklearn.ensemble import RandomForestClassifier


# clf=RandomForestClassifier()


t2= time.time()
print(t2-t1)

# process_text 
  # process_text_group 
    # process_text_group('paragraph') -> save_statistics -> calculate agg_stats
    # process_text_group('sentence') -> save_statistics -> calculate agg_stats
    # process_text_group('word') -> save_statistics -> calculate agg_stats

  # paragraph length
  # similarity to previous paragraphs
  # num words 


Counter(word_counter).most_common()[0:10]
Counter(four_gram_counter).most_common()[0:10]
Counter(three_gram_counter).most_common()[0:10]
Counter(two_gram_counter).most_common()[0:10]
Counter(parts_of_speech_counter).most_common()[0:10]
Counter(syllables_counter).most_common()[0:10]



