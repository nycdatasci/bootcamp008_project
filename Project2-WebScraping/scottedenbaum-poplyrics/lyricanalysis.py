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


lyricpath = 'lyrics/*.txt'
songlist = 'songlist.txt'

lyrics={}
trackinfo = {}
info = []
count = 1

with open(songlist, 'r') as f:
	for line in f.readlines():
		print line
		print count
		count = count + 1
		track = line[:-4].replace('.','')
		print track
		
		try:
			with open('lyrics/' + line.strip(), 'r') as g:
				words = g.readlines()
			lyrics[track] = words
		except Exception, e:
			print "Exception with lyrics for track: " + track
			continue
			
		try:
			with open('track-data/' + line.strip(), 'r') as h:
				info_ = h.readline()

				ChartYear,Artist,Title,Pos.This.Week,Pos.Last.Week,Peak.Pos.This.Week,Total.Weeks,Entry.Date,Pos.Entry,Overall.Peak.Pos,Overall.Total.Weeks = info_.strip().split('|')

				info.append((ChartYear,Artist,Title,Pos.This.Week,Pos.Last.Week,Peak.Pos.This.Week,Total.Weeks,Entry.Date,Pos.Entry,Overall.Peak.Pos,Overall.Total.Weeks))
			trackinfo[track] = info_
		except Exception, e:
			print "Exception with artist/title/chart info for track: " + track
			continue
print lyrics
print trackinfo
print info

df = pd.DataFrame()
df['Track'] = lyrics.keys()
df['Lyrics'] = lyrics.values()
