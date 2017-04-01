from urllib import urlopen
import csv
from bs4 import BeautifulSoup
import re

with open ('KStats.csv','wb') as csvfile:
    wrtr = csv.writer(csvfile, delimiter=',', quotechar='"')

    for year in range(1980, 2017):
        html = urlopen("http://www.sports-reference.com/cfb/years/"+str(year)+"-kicking.html")
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
                XPM= col[4].string
                XPA= col[5].string
                XP_Per= col[6].string
                FGM= col[7].string
                FGA= col[8].string
                FG_Per= col[9].string
                Points= col[10].string
                Year = year
                record = (Year, Rank,Player, School, Conference,Games,XPM,XPA,XP_Per,FGM,FGA,FG_Per,Points)
                wrtr.writerow(record)
                csvfile.flush()
            except:
                pass