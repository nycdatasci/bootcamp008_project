# Get data from SWR3 playlists for missing entries

import datetime
import bs4
import requests
import csv
import os
import time
import pandas as pd

os.chdir(r'E:\Projects\02 Web Scraping Project')
wdir = os.getcwd()

def getSWR3Playlist(plURL):
    res = requests.get(plURL)
    soup = bs4.BeautifulSoup(res.text, 'html.parser')
    res.close()
        
    plEntries = list()
    i = 1
    while(i == 1 or len(elDate) > 0):
        # Get playlist entry elements
        elDate   = soup.select('#playlist > li:nth-of-type(' + str(i) + ') > time > span:nth-of-type(1)')
        elTime   = soup.select('#playlist > li:nth-of-type(' + str(i) + ') > time > span:nth-of-type(2)')
        elArtist = soup.select('#playlist > li:nth-of-type(' + str(i) + ') > div > div.detail-body > span > h5')
        elTitle  = soup.select('#playlist > li:nth-of-type(' + str(i) + ') > div > div > h4')  #.detail-body > h4')
        
        if elArtist == []:
            elArtist = soup.select('#playlist > li:nth-of-type(' + str(i) + ') > div > div > span')

        # Only if entries left
        if((len(elDate) > 0) & (len(elTime) > 0) & (len(elArtist) > 0) & (len(elTitle) > 0)):
            element = {'date': elDate[0].text.strip(), 'time': elTime[0].text.strip(),
                       'artist': elArtist[0].text.strip(), 'title': elTitle[0].text.strip()}
            plEntries.append(element)
            print(element)

        i += 1

    return plEntries
        
# SWR3 Playlist URL
swr3URL = 'http://www.swr3.de/musik/playlisten/-/id=47424/cf=42/did=65794/93avs/index.html?'
swr3Songs = list()

reload = pd.read_csv(wdir + '/data/dirty/reload/reload.csv', sep=';')
print(reload.head())
# Get playlists from beginDate to endDate
for index, row in reload.iterrows():
    print(time.strftime("%Y-%m-%d %H:%M:%S"), '-', 'Getting data:', 'day =', row['date'], 'hour =', row['hour'])
    swr3Songs += getSWR3Playlist(swr3URL + 'hour=' + str(row['hour']) + '&date=' + row['date'])

i = 0
with open(wdir + '/data/dirty/reload/missing.csv', 'w', encoding='utf-8') as tgtFile:
    wr = csv.DictWriter(tgtFile, swr3Songs[0].keys(), quoting=csv.QUOTE_ALL)
    wr.writeheader()
    for i in range(len(swr3Songs)):
        wr.writerow(swr3Songs[i])
