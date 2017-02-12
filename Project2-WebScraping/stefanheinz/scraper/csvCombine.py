# Combine all single month CSV files into one big CSV file

import pandas as pd
import os
import csv
import time


os.chdir('E:/Projects/02 Web Scraping Project')
wdir = os.getcwd()
env = 'clean'

songData = pd.DataFrame()
i = 0
for file in os.listdir(wdir + r'/data/' + env + ''):
    if file[len(file)-3:] == 'csv':
        print(time.strftime("%Y-%m-%d %H:%M:%S"), '-', wdir + r'/data/' + env + '/' + file)
        songData = songData.append(pd.read_csv(wdir + '/data/' + env + '/' + file))

songData.drop_duplicates(subset=['date', 'time', 'artist', 'title'], inplace=True)
songData.to_csv(wdir + '/data/' + env + '/swr3-songs-2016-v2.csv', quoting=csv.QUOTE_ALL, index=False)