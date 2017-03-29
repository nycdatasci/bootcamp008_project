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
import numpy as np


def analyze_text(text):
    print "test"
    paragraph_regex = re.compile("\\n\\s*\\n")
    all_paragraphs=re.split(paragraph_regex, text)
    all_paragraphs=filter(lambda x: len(x)>0, all_paragraphs)
  
    def slice(n,words):
        n_gram = list(islice(words, n, 4))
        return " ".join(n_gram)
  
    def nsyl(word): 
        return [len(list(y for y in x if isdigit(y[-1]))) for x in d[word.lower()]] 
  
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
        #extract_paragraph_topics() Google News and Wikipedia 
       # distance from previous paragraph 
        #distance from previous N paragraph
        paragraph_lengths.append(len(paragraph))
        entropies.append(entropy.shannon_entropy(paragraph.encode('utf-8').strip()))
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
                      })
  
    for part_of_speech in parts_of_speech_counter.keys():
      df1[part_of_speech+"_prop"] = parts_of_speech_counter[part_of_speech]/float(total_parts_of_speech)
    total_words = 0 
    for key in word_counter:
      total_words+=word_counter[key]
    for stopword in STOPWORDS:
      df1[stopword+"_prop"] = word_counter[stopword]/float(total_words)
    return df1
    
