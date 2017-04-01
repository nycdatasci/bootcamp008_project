from bs4 import BeautifulSoup
import urllib
import re
import csv
import time

start_urls = []

with open('IMDB_Links.csv', 'rb') as f:
    start_urls = [url.strip() for url in f.readlines()]

link_dictionary = {}

for url in start_urls:
	time.sleep(1)
	url = url[1:-2]
	print url
	if url != None or url != '':
		page = urllib.urlopen(url)
		soup = BeautifulSoup(page, 'html.parser')
		name = soup.select(".title_wrapper > h1:nth-of-type(1)")
		stripped_name =	name[0].text.strip()
		rating = soup.select(".ratingValue > strong:nth-of-type(1) > span:nth-of-type(1)")
		stripped_rating = rating[0].text.strip()
	
		Poster_image = soup.select(".poster > a:nth-of-type(1) > img:nth-of-type(1)")
		image_link = re.search('(?<=src=")[A-Za-z0-9\.\-\_@\:\/\,]*', str(Poster_image[0]))
		image_link = image_link.group(0)
		link_dictionary[stripped_name] = [stripped_rating, image_link]

		urllib.urlretrieve(image_link, stripped_name + "_Poster.jpg")

#print link_dictionary 

f = open('scrapped_data.csv', 'wb')
w = csv.DictWriter(f, sorted(link_dictionary.keys()))
w.writeheader()
w.writerow({k.encode('utf8'):v.encode('utf8') for k, v in link_dictionary.items()})
f.close()
		

