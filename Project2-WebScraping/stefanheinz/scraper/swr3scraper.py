# Get data from SWR3 playlists from begDate to endDate

import datetime
import bs4
import requests
import csv
import os
import time

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

begDate = datetime.date(2016, 2, 15)
endDate = datetime.date(2016, 2, 15)
begHour = 23
endHour = 24
thisDate = begDate + datetime.timedelta(days = -1)

# Get playlists from beginDate to endDate
while(thisDate < endDate):
    thisDate += datetime.timedelta(days = 1)

    # For each hour of the day
    for hour in range(begHour, endHour):
        print(time.strftime("%Y-%m-%d %H:%M:%S"), '-', 'Getting data:', 'day =', thisDate, 'hour =', hour)
        swr3Songs += getSWR3Playlist(swr3URL + 'hour=' + str(hour) + '&date=' + thisDate.strftime('%Y-%m-%d'))

i = 0
with open(wdir + '/data/dirty/reload/swr3-songs-' + endDate.strftime('%y%m%d') + '-' + begDate.strftime('%y%m%d') + '.csv', 'w', encoding='utf-8') as tgtFile:
    wr = csv.DictWriter(tgtFile, swr3Songs[0].keys(), quoting=csv.QUOTE_ALL)
    wr.writeheader()
    for i in range(len(swr3Songs)):
        wr.writerow(swr3Songs[i])
