import re
import requests
import nltk
from sys import version_info
from bs4 import BeautifulSoup
from tswift import Song
from tswift import Artist
import billboard
import os

def clean_song(title, artist):
	if title.find("'") > 0:
		title = title.replace("'", "")
	elif title.find('"') > 0:
		title = title.replace('"', '')
	elif title.find('!') > 0:
		title = title.replace('!', '')
	elif title.find('#') > 0:
		title = title.replace('.', '')
	elif title.find('.') > 0:
		title = title.replace('.', '')
	elif title.find(',') > 0:
		title = title.replace(',', '')
	elif title.find('&') > 0:
		title = title.replace('&', '')
	elif title.find('?') > 0:
		title = title.replace('?', '')
	elif title.find('$') > 0:
		title = title.replace('$', '')
	elif title.find('('):
		title = title.split( ' (')[0]

	c_title = title.lower().strip().replace(' ', '-').replace('.', '').replace("'", "").replace('!', '').replace(',', '').replace('$', '').replace('?', '').replace('&', '').replace('#', '')

	if artist.find('"') > 0:
		artist = artist.replace('"', '')
	elif artist.find("'") > 0:
		artist = artist.replace("'", '')
	elif artist.find(' & ') > 0:
		artist = artist.split(' &')[0]
	elif artist.find(' / ') > 0:
		artist = artist.split(' / ')[0]
	elif artist.find(', ') > 0:
		artist = artist.split(',')[0]
	elif artist.find(' x ') > 0:
		artist = artist.split(' x')[0]
	elif artist.find('.') > 0:
		artist = artist.replace('.', '')
	elif artist.find(' feat') > 0:
		artist = artist.split(' feat')[0]
	elif artist.find(' with ') > 0:
		artist = artist.split(' with')[0]
		
	c_artist = artist.lower().strip().replace('/','').replace('.', '').replace(' ', '-').replace("'", '').replace('"', '').replace(',', '')

	return(c_title, c_artist)

def main():
	#file = 'billboard100-00s.csv'
	py3 = version_info[0] > 2 #creates boolean value for test that Python major version > 2

	if py3:
		file = input("Please enter billboard | separated .csv file: ")
	else:
		file = raw_input("Please enter billboard | separated .csv file: ")
	with open(file, 'r') as f:
		f.readline()
		for line  in f.readlines():
			try:
				x = True
				line = line.split("|")
				print line
				[a, b, c, q, title, artist, d, p, f, g, chartyear] = line
				for col in line:
					if title:
						r_title = title
						print r_title
					if artist:
						r_artist = artist
						print r_artist
					if chartyear:
						r_chartyear = chartyear[:4]
					c_title, c_artist = clean_song(r_title, r_artist)
					writename = 'track-data/' + str(r_chartyear) + '-' + c_artist + '-' + c_title + '.txt'
			
					dir = os.path.dirname(writename)
					if not os.path.exists(dir):
						os.makedirs(dir)

					#try:
					#	Song(title = c_title, artist = c_artist,).lyrics
					#except Exception, e:
					#	print "Exception occurred for " + c_artist + ' - ' + c_title
					#	print e
					#	continue
# 					try:
# 						Song(title = c_title, artist = c_artist,).lyrics.format().replace('\n'," ")
# 					except Exception, e:
# 						print "Exception occurred for " + c_artist + ' - ' + c_title + "!"
# 						print e
# 						x = False
# 						continue
			except Exception, e:
				print "track skipped!"
				x = False
				continue
			print c_title + " " + c_artist
			try:
				if x == True:
					trackdata = str(r_chartyear) + "|" + c_artist + "|" + c_title + "|"#  + a + "|" + b + "|" + c + "|" + q + "|" + d + "|" + p + "|" + f + "|" + g
					target = open(writename, 'w')
					target.write(trackdata.encode('utf-8'))
					target.close()
					print c_artist + ' - ' + c_title + " Success!"
			except Exception, e:
				print "track skipped! - write error!"
				continue
	print "Scraping Lyrics Complete"
	
main()