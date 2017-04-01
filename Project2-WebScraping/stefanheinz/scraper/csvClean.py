# swr3Scraper collects data, but apparently stores it in different order
# for each CSV file. This code reorders each file.

import pandas as pd
import os
import csv


os.chdir('E:/Projects/02 Web Scraping Project')
wdir = os.getcwd()
env = 'dirty/reload'

for file in os.listdir(wdir + r'/data/' + env):
    if file[len(file)-3:] == 'csv':
        print(wdir + r'/data/' + env + '/' + file)
        #songData = songData.append(pd.read_csv(wdir + r'/data/' + file, encoding='cp273'))
        
        songData = pd.DataFrame(columns=range(0, 4))
        i = 0
        with open(wdir + r'/data/' + env + '/' + file, newline='', encoding='utf-8') as fr:
            reader = csv.reader(fr)
            for row in reader:
                #print(row)
                if i == 0:
                    cols = row
                else:
                    songData = songData.append([row])
                    
                i += 1
                
            songData.columns = cols
            
        songData = songData[['date', 'time', 'artist', 'title']]
            
        with open(wdir + r'/data/clean/' + file[:len(file)-4] + '-clean.csv', 'w') as fw:
            wr = csv.writer(fw, delimiter=',', quoting=csv.QUOTE_ALL)
            wr.writerow(songData.columns)
            for i in range(len(songData)):
                wr.writerow(songData.iloc[i])
            
#print(songData[['date', 'time', 'artist', 'title']])
#print(songData.head())