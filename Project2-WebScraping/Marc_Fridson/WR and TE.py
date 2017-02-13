from urllib import urlopen
import csv
from bs4 import BeautifulSoup
import re

with open ('WRTEStats.csv','wb') as csvfile:
    wrtr = csv.writer(csvfile, delimiter=',', quotechar='"')

    for year in range(1980, 2017):
        html = urlopen("http://www.sports-reference.com/cfb/years/"+str(year)+"-receiving.html")
        soup = BeautifulSoup(html.read());
        for row in soup.findAll('tr'):
            try:
                col1=row.findAll('th')
                Rank=col1[0].string
                col=row.findAll('td')
                Player = col[0].get_text()
                Player= re.sub('\*', '', Player)
                School = col[1].string
                Conference = col[2].string
                Games = col[3].string
                Receptions = col[4].string
                Receiving_Yards = col[5].string
                Avg_Receiving_Yards = col[6].string
                Receiving_TDs = col[7].string
                Rush_Attempts = col[8].string
                Rush_Yards = col[9].string
                Avg_Rush_Yards = col[10].string
                Rushing_TDs = col[11].string
                Scrim_Plays= col[12].string
                Scrim_Yards= col[13].string
                Avg_Scrim_Yards= col[14].string
                Scrim_TDs= col[15].string
                Year = year
                record = (Year, Rank,Player, School, Conference, Games, Receptions, Receiving_Yards, Avg_Receiving_Yards, Receiving_TDs,Rush_Attempts, Rush_Yards, Avg_Rush_Yards,Rushing_TDs, Scrim_Plays, Scrim_Yards, Avg_Scrim_Yards,Scrim_TDs)
                wrtr.writerow(record)
                csvfile.flush()
            except:
                pass