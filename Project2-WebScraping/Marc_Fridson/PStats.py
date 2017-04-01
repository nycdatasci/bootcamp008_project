from urllib import urlopen
import csv
from bs4 import BeautifulSoup
import re

with open ('PStats.csv','wb') as csvfile:
    wrtr = csv.writer(csvfile, delimiter=',', quotechar='"')

    for year in range(1980, 2017):
        html = urlopen("http://www.sports-reference.com/cfb/years/"+str(year)+"-punting.html")
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
                Punts= col[4].string
                Punt_Yards= col[5].string
                Avg_Punt= col[6].string
                Year = year
                record = (Year, Rank,Player, School, Conference,Games,Punts,Punt_Yards,Avg_Punt)
                wrtr.writerow(record)
                csvfile.flush()
            except:
                pass