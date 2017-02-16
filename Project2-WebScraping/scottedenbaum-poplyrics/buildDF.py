import re
import requests
import nltk
from bs4 import BeautifulSoup
from tswift import Song
from tswift import Artist
import billboard
import os
import glob
import numpy as np
import pandas as pd


def get_stopwords():
	with open('stopwords.txt', 'rb') as f:
		words = f.read().splitlines()
	return set(words)

def remove_nonalphanum(text):
    # Names should contain only lowercase alphanumeric characters and spaces.
    text = text.replace('-', ' ').lower()
    text = (re.sub(r'[^\w\- ]+', '', text))
    text = text.replace(' ', '-')
    return text

def unique_words(lyrics):
#	words = lyrics.replace("'",'').replace('"','').replace('?','').replace('!','').replace('(').replace(')').replace('.','').replace(',','').replace('-','').split(' ')
	words = remove_nonalphanum(lyrics)
	return set(words)

lyric_list = []
set(os.listdir('lyrics/')) & set(os.listdir('track-data/')) #re run part of code that builds track name to build year.artist.track

# print len(set(os.listdir('lyrics/')) & set(os.listdir('track-data/')))
for key in (set(os.listdir('lyrics/')) & set(os.listdir('track-data/'))):
	lyric_dict = {}
	lyric_dict['file'] = key
	if key.find('.txt') > 0:
		with open(os.path.join('lyrics/', key)) as lyric_f:
			lyric_dict['lyric'] = lyric_f.readlines()
	
		with open(os.path.join('track-data/', key)) as track_f:
			ChartYear, Artist, Title, _ = track_f.readline().split('|', 3)
			lyric_dict['ChartYear'] = ChartYear
			lyric_dict['Artist'] = Artist
			lyric_dict['Title'] = Title
	
		lyric_list.append(lyric_dict)
#print lyric_dict	
df_lyric = pd.DataFrame(lyric_list)
#print df_lyric
print df_lyric.columns
print df_lyric.index
print df_lyric[df_lyric['Artist']== 'ub-40']

