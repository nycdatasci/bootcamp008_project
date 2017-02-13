import pandas as pd
import datetime

wdir = r'E:\Projects\02 Web Scraping Project'
env = 'data/clean'
wdirF = wdir + '/' + env + '/'

songs = pd.read_csv(wdirF + 'swr3-songs-2016-v3.csv')
#songs = songs.loc[0:1000]

# Grouping and aggregating
songsPerMonth = songs.groupby(by='month').agg({'count'})['ts']
songsPerSong = songs.groupby(by=['artist', 'title']).agg({'count'})['ts']
songsPerSongRushHour = songs[songs['isRushHour']].groupby(by=['artist', 'title']).agg({'count'})['ts']
songsPerYear = songs.count()


#print(songsPerSongRushHour.sort_values(by='count', ascending=False).head(n=10))
