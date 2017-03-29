import re
import requests
from sys import version_info
from bs4 import BeautifulSoup
from tswift import Song
from tswift import Artist
import billboard
import os

def clean_song(title, artist):
	'''the twsift lyric api (which grabs the song lrycs from metrolyrics
	depends on having cleaned/sanitized inputs for both the title and artist.
	title and artist must contain no special characters, spaces are replaces with '-'
	anything in () is removed, and only the main artist is listed, so all featured artists are omitted
	otherwise the twsift api ewont return the correct lyrics, if it returns any!

	I wrote this function to:
	strip out non alplphanumeric characters from both the title and artist
	replace spaces with "-"
	split the title/artist on a (, or the words ' with', ' feat' (which indicates a secondary "featuring" artist or other extraneous detial
	'''	
	title = title.replace("'", "")
	title = title.replace('"', '')
	title = title.replace('!', '')
	title = title.replace('.', '')
	title = title.replace('.', '')
	title = title.replace(',', '')
	title = title.replace('&', '')
	title = title.replace('#', '')
	title = title.replace('?', '')
	title = title.replace('$', '')
	title = title.strip()
	title = title.replace(' ', '-')
	title = title.split( ' (')[0]

	c_title = title.lower().strip()

	artist = artist.replace('"', '')
	artist = artist.replace("'", '')
	artist = artist.split(' &')[0]
	artist = artist.split(' / ')[0]
	artist = artist.split(' x')[0]
	artist = artist.replace('.', '')
	artist = artist.split(' feat')[0]
	artist = artist.split(' with')[0]
	
	if artist.find(', ') > 0:
		artist = artist.split(',')[0]		
		
	artist = artist.replace('/','')
	artist = artist.replace(' ','-')
	artist = artist.replace(',','')
	c_artist = artist.lower().strip()

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
				r_line = line + '|'
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
					writename = 'lyrics/' + str(r_chartyear) + '|' + c_artist + '|' + c_title + '.txt' #sets lyric directory & filename structure for lyric files
			
					dir = os.path.dirname(writename)
					if not os.path.exists(dir):
						os.makedirs(dir)

					try:
						Song(title = c_title, artist = c_artist,).lyrics  #testing inputs with tswift api
					except Exception, e:
						print "Exception occurred for " + c_artist + ' - ' + c_title
						print e
						continue
					try:
						songlyrics = Song(title = c_title, artist = c_artist,).lyrics.format().replace('\n'," ") #testing .format() func from tswift, and placing content in variable
					except Exception, e:
						print "Exception occurred with the format function!"
						print e
						continue
			except Exception, e:
				print "track skipped!"
				continue
			print c_title + " " + c_artist
			try:
				target = open(writename, 'w')
				target.write(r_line.encode('utf-8'))
				target.write(songlyrics.encode('utf-8'))
				target.close()
				print c_artist + ' - ' + c_title + " Success!"
			except Exception, e:
				print "track skipped! - write error!"
				continue
	print "Scraping Lyrics Complete"
	
main()