from datetime import datetime
import pandas as pd
import os


p = pd.read_csv('nbaplayerstats.csv')
t = pd.read_csv('nbateamstats.csv')

def change_Date(d):
    z = {"JAN": "01", "FEB": "02", "OCT": "10", "NOV": "11", "DEC": "12"}
    y = d[:3]
    d = d.replace(y, z[y]).replace(",", "").replace(" ", "-")
    d = datetime.strptime(d, "%m-%d-%Y")
    return d
#adding columns to  player gamelogs
for i in p['PLAYER']:
    i = i.replace(" ", "")
    a = pd.read_csv(i + "gamelog.csv")
    n = 0
    a["DATE"] = None
    a["OPPONENT"] = None
    a["ARENA"] = None
    for j in a["MATCHUP"]:
        a["DATE"][n] = change_Date(j[:12])
        a["OPPONENT"][n] = j[-3:]
        if "vs." in j:
            a["ARENA"][n] = "HOME"
        else: 
            a["ARENA"][n] = "AWAY"
        n = n + 1
    os.remove(i + "gamelog.csv")
    a.to_csv(i + "gamelog.csv")
#combine team stats and adding columns to gamelogs
for i in t['TEAM']:
    i = i.replace(" ", "")
    a = pd.read_csv(i + ".csv")
    b = pd.read_csv(i + "opp.csv")
    os.remove(i + ".csv")
    os.remove(i + "opp.csv")
    pd.merge(a, b, on = "BREAKDOWN").to_csv(i + ".csv")
    c = pd.read_csv(i + "gamelog.csv")
    os.remove(i + "gamelog.csv")
    n = 0
    c["DATE"] = None
    c["OPPONENT"] = None
    c["ARENA"] = None
    for j in c["MATCHUP"]:
        c["DATE"][n] = change_Date(j[:12])
        c["OPPONENT"][n] = j[-3:]
        if "vs." in j:
            c["ARENA"][n] = "HOME"
        else: 
            c["ARENA"][n] = "AWAY"
        n = n + 1
    os.remove(i + "gamelog.csv")
    c.to_csv(i + "gamelog.csv")

