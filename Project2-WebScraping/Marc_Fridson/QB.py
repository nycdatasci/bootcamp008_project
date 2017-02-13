from urllib import urlopen
import csv
from bs4 import BeautifulSoup
import re

with open ('QBcollegeStats.csv','wb') as csvfile:
    wrtr = csv.writer(csvfile, delimiter=',', quotechar='"')

    for year in range(1980, 2017):
        html = urlopen("http://www.sports-reference.com/cfb/years/"+str(year)+"-passing.html")
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
                Completions = col[4].string
                Pass_Attempts = col[5].string
                Pass_Yards = col[6].string
                Yards_per_Attempt = col[7].string
                Avg_YPA = col[8].string
                Passing_TDs = col[9].string
                Interceptions = col[10].string
                Rating = col[11].string
                Rush_Attempts = col[12].string
                Rush_Yards = col[13].string
                Avg_Rush_Yards = col[14].string
                Rushing_TDs = col[15].string
                Year = year
                record = (Year, Rank,Player, School, Conference, Games, Completions, Pass_Attempts, Yards_per_Attempt,Avg_YPA,Passing_TDs, Interceptions, Rating, Rush_Attempts, Rush_Yards, Avg_Rush_Yards, Rushing_TDs)
                wrtr.writerow(record)
                csvfile.flush()
            except:
                pass