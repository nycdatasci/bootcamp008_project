# Song analytics

import pandas as pd
import datetime
import csv
import re
 
wdir = r'E:\Projects\02 Web Scraping Project'
env = 'data/clean'
wdirF = wdir + '/' + env + '/'

# Rush hour in Germany cf. https://de.wikipedia.org/wiki/Verkehrszeiten
# Die Hauptverkehrszeit geht üblicherweise von 6 bis 9 Uhr (Früh-HVZ) und von 16 bis 19 Uhr (Spät-HVZ).
rushHour = {
        'morning': {
            'from': 6,
            'to': 9-1   # until 08:59
        },

        'evening': {
            'from': 16,
            'to': 19-1  # until 18:59
        }
    }

# Seasons cf. https://de.wikipedia.org/wiki/Jahreszeit#Meteorologische_Jahreszeiten
season ={
        'winter15': {
            'from': datetime.date(2015, 12, 1),
            'to': datetime.date(2016, 2, 29)
        },

        'spring': {
            'from': datetime.date(2016, 3, 1),
            'to': datetime.date(2016, 5, 31)
        },

        'summer': {
            'from': datetime.date(2016, 6, 1),
            'to': datetime.date(2016, 8, 31)
        },

        'fall': {
            'from': datetime.date(2016, 9, 1),
            'to': datetime.date(2016, 11, 30)
        },

        'winter16': {
            'from': datetime.date(2016, 12, 1),
            'to': datetime.date(2017, 2, 28)
        }
    }

songs = pd.read_csv(wdirF + 'swr3-songs-2016-v2.csv')

# Create timestamp from 'date' and 'time' columns, then remove the latter two
songs['ts'] = songs.apply(lambda row: datetime.datetime.strptime(row['date'] + ' ' + row['time'], '%d.%m.%Y %H:%M'), axis=1)
songs.sort_values(by='ts', inplace=True)
songs.reset_index(drop=True, inplace=True)

# Clean artist name. Sometimes artists singing the same title have different spellings:
#  * Vega, Suzanne - Luka
#  * Vega,Suzanne - Luka
songs['artist'] = songs.apply(lambda row: re.sub(',(?=[A-Za-z0-9])', ', ', row['artist']), axis=1)

# Create more date and time variables
songs['day'] = songs.apply(lambda row: row['ts'].day, axis=1)
songs['month'] = songs.apply(lambda row: row['ts'].month, axis=1)
songs['year'] = songs.apply(lambda row: row['ts'].year, axis=1)

songs['wday'] = songs.apply(lambda row: row['ts'].isoweekday(), axis=1)
songs['wdayLbl'] = songs.apply(lambda row: datetime.datetime.strftime(row['ts'], '%a'), axis=1)
songs['week'] = songs.apply(lambda row: row['ts'].week, axis=1)
songs['quarter'] = songs.apply(lambda row: row['ts'].quarter, axis=1)

songs['hour'] = songs.apply(lambda row: row['ts'].hour, axis=1)
songs['minute'] = songs.apply(lambda row: row['ts'].minute, axis=1)

songs['rushHour'] = songs.apply(lambda row: max([x if row['hour'] >= rushHour[x]['from'] and row['hour'] <= rushHour[x]['to'] and row['wday'] < 6 else '' for x in rushHour]), axis=1)
songs['season'] = songs.apply(lambda row: max([x if row['ts'].date() >= season[x]['from'] and row['ts'].date() <= season[x]['to'] else '' for x in season]), axis=1)

songs.to_csv(wdirF + 'swr3-songs-2016-v3.csv', index=False, quoting=csv.QUOTE_ALL)