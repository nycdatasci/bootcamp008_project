import nba_py
import nba_py.player
import nba_py.game
import nba_py.league
import nba_py.shotchart
import nba_py.team
import pandas as pd
import numpy as np
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
from scipy import stats
from scipy.stats import pearsonr
import math
import xgboost as xgb
from sklearn import preprocessing
from sklearn.cross_validation import train_test_split
from sklearn.linear_model import LinearRegression
import sklearn.cross_validation as cv
import sklearn.grid_search as gs
import sklearn.linear_model as lm
from scipy.stats import uniform as sp_rand
from sklearn.linear_model import Ridge
from sklearn.model_selection import RandomizedSearchCV
from keras.models import Sequential
from keras.layers import Dense, Dropout
from keras.callbacks import EarlyStopping
from sklearn.preprocessing import StandardScaler
from sklearn.utils import shuffle 
from sklearn.preprocessing import LabelEncoder
from bayes_opt import BayesianOptimization
from tqdm import tqdm
# from sklearn.cluster import KMeans
# from sklearn import metrics

#create list of teams
a = nba_py.team.TeamList().info()
teamList = {}
teamRoster = {}
n = 0
for i in a.ABBREVIATION:
    if n == 30:
        break
    teamList[i] = [a.TEAM_ID[n]]
    teamRoster[i] = {0:[], 1:[]}
    n += 1
#create list of players and insert them into rosters
b = nba_py.player.PlayerList().info()
playerList = {}
n = 0
for i in b.DISPLAY_FIRST_LAST:
    playerList[i] = [b.PERSON_ID[n], b.TEAM_ABBREVIATION[n], b.TEAM_ID[n]]
    n += 1

# create a df to merge opponent's gamelogs to the team gamelog 
OppGameLogs = pd.DataFrame({})
for i in teamList.keys():
    OppGameLogs = pd.concat([OppGameLogs, nba_py.team.TeamGameLogs(teamList[i][0]).info()], ignore_index= True)
OppGameLogs.columns = 'Opp_' + OppGameLogs.columns
OppGameLogs = OppGameLogs.drop(['Opp_GAME_DATE', 'Opp_MATCHUP', 'Opp_WL'], axis = 1)
OppGameLogs = OppGameLogs.rename(columns = {'Opp_Game_ID': 'Game_ID'})

#create team gamelogs and team averages and standard deviation tables
teamGameLogs = {}
teamAvgs = pd.DataFrame({})
for i in teamList.keys():
    temp = nba_py.team.TeamGameLogs(teamList[i][0]).info()
    temp = pd.merge(temp, OppGameLogs.loc[OppGameLogs.Opp_Team_ID != teamList[i][0],: ], on = 'Game_ID')
    temp.GAME_DATE = pd.to_datetime(temp.GAME_DATE)
    d = temp.GAME_DATE
    temp['DaysSinceLastGame'] = d - d[1:].append(d[-1:]).reset_index().GAME_DATE
    temp['HA'] = temp.MATCHUP.apply(lambda x: 'H' if 'vs.' in x else 'A')
    temp['TEAM'] = temp.MATCHUP.apply(lambda x: x[:3])
    temp['OPP_TEAM'] = temp.MATCHUP.apply(lambda x: x[-3:])
    temp = temp.drop(['Team_ID', 'Game_ID', 'Opp_Team_ID', 'MATCHUP'], axis = 1)
    teamGameLogs[i] = temp
    tempAVG = pd.DataFrame(temp.mean()).transpose().drop(['W', 'L', 'Opp_W', 'Opp_L'], axis = 1)
    tempAVG['TEAM'] = i
    teamAvgs = pd.concat([teamAvgs,tempAVG], ignore_index= True)
teamAvgs.columns = 'AVG_' + teamAvgs.columns
teamAvgs = teamAvgs.rename(columns = {'AVG_TEAM': 'TEAM'})


avgoppcols = [c for c in teamAvgs.columns if '_Opp_' in c]
avgteamcols = [c for c in teamAvgs.columns if (not ('_Opp_' in c) and ('AVG_'in c))]
def teamOppstats(team, opp):
    new_df = pd.DataFrame({})
    for i in range(len(team)):
        x = teamAvgs.loc[teamAvgs.TEAM == team[i], avgteamcols]
        x.columns = [c.replace('AVG_', '') for c in x.columns]
        y = teamAvgs.loc[teamAvgs.TEAM == opp[i], avgoppcols]
        y.columns = [c.replace('AVG_Opp_', '') for c in y.columns]
        z = x.reset_index(drop= True) - y.reset_index(drop = True)
        z.columns = 'TEAM_OPP_' + z.columns
        new_df = pd.concat([new_df, z], ignore_index=True)
    return new_df



#function to get rolling averages
def pastavg(days, col):
    new_col = []
    for i in range(len(col)):
        if i == len(col)-1:
            new_col.append(col.mean())
        else:
            new_col.append(col[i+1:i+days+1].mean())
    return new_col


roto = pd.read_csv('http://rotoguru1.com/cgi-bin/nba-dhd-2017.pl?&user=jasonjjchen&key=J8987209841',sep = ':')
roto1 = roto.iloc[:-1,:]
roto1.loc[:,'Date'] = pd.to_datetime(roto1.Date.astype(int),format='%Y%m%d')
rotocols = roto1.columns[[1,2,3,4,5,6,8,9,10,11,12,16,24,25,31]]
roto1 = roto1[rotocols] #clean columns

#functions to standardize names 
namechange = lambda x: x.replace('Derrick Jones', 'Derrick Jones, Jr.').replace('James Ennis', \
            'James Ennis III').replace('Guillermo Hernangomez', 'Willy Hernangomez').replace('Joseph Young', \
            'Joe Young').replace('Timothe Luwawu', 'Timothe Luwawu-Cabarrot').replace('Walter Tavares', \
            'Edy Tavares').replace('John Lucas', 'John Lucas III').replace('T.J. Warren', \
            'TJ Warren').replace('DeAndre Bembry', 'DeAndre\' Bembry').replace('P.J. Tucker', \
            'PJ Tucker').replace('Larry Nance', 'Larry Nance Jr.').replace('C.J. Wilcox', \
            'CJ Wilcox').replace('C.J. McCollum', 'CJ McCollum').replace('Wes Matthews', \
            'Wesley Matthews').replace('J.J. Redick', 'JJ Redick').replace('K.J. McDaniels', \
            'KJ McDaniels').replace('A.J. Hammons', 'AJ Hammons').replace('Louis Williams', \
            'Lou Williams').replace('Wade Baldwin', 'Wade Baldwin IV').replace('Kelly Oubre', \
            'Kelly Oubre Jr.').replace('Johnny O\'Bryant', 'Johnny O\'Bryant III').replace('J.R. Smith', \
            'JR Smith').replace('C.J. Miles', 'CJ Miles').replace('R.J. Hunter', 'RJ Hunter').replace('Otto Porter', \
            'Otto Porter Jr.').replace('Jose Barea', 'J.J. Barea').replace('Ishmael Smith', \
            'Ish Smith').replace('Nene Hilario', 'Nene').replace('Maurice N\'dour', 'Maurice Ndour')
#function to standardize team abbreviations
teamAbbrchange = lambda x: x.replace('atl', u'ATL').replace('bkn', u'BKN').replace('bos', u'BOS').replace('cha', \
            u'CHA').replace('chi', u'CHI').replace('cle', u'CLE').replace('dal', u'DAL').replace('den', \
            u'DEN').replace('det', u'DET').replace('gsw', u'GSW').replace('hou', u'HOU').replace('ind',\
            u'IND').replace('lac', u'LAC').replace('lal', u'LAL').replace('mem', u'MEM').replace('mia', \
            u'MIA').replace('mil', u'MIL').replace('min', u'MIN').replace('nor', u'NOP').replace('nyk', \
            u'NYK').replace('okc', u'OKC').replace('orl', u'ORL').replace('phi', u'PHI').replace('pho', \
            u'PHX').replace('por', u'POR').replace('sac', u'SAC').replace('sas', u'SAS').replace('tor', \
            u'TOR').replace('uta', u'UTA').replace('was', u'WAS')


roto1['First  Last'] = roto1['First  Last'].apply(namechange)

#clean up draft kings data
dkgamelog = roto1[-roto1['DK pos'].isnull()]
dkgamelog = dkgamelog[-dkgamelog['Start'].isnull()]
dkgamelog = dkgamelog.rename(columns = {'First  Last': 'PLAYER', 'Date': 'GAME_DATE'})
dkgamelog['Start'] = dkgamelog['Start'].astype(int)
temp = dkgamelog['DK pos'].astype(int).astype(str).str.join('@').str.get_dummies('@')
temp.columns = 'POSITION:' + temp.columns
dkgamelog['DK pos'] = dkgamelog['DK pos'].astype(int).astype(str).str.join('@').str.split('@')
dkgamelog = pd.concat([dkgamelog[['PLAYER', 'GAME_DATE', 'DK Sal', 'DK Change', 'DKP', 'Start', 'DK pos']], temp], axis= 1)
dkgamelog.loc[dkgamelog['DK Change'].isnull(), 'DK Change'] = 0

#modifying player gamelogs
stats_cols = ['MIN', 'FGM', 'FGA', 'FG_PCT', 'FG3M', 'FG3A', 'FG3_PCT', 'FTM', 'FTA', 'FT_PCT', 'OREB', 'DREB', \
              'REB', 'AST', 'STL', 'BLK', 'TOV', 'PF', 'PTS', 'PLUS_MINUS', 'DKP', 'DD', 'TD']
playerGameLogs = {}
allPlayersGameLogs = pd.DataFrame({})
playerAvgs = pd.DataFrame({})
for i in playerList.keys():
    temp = nba_py.player.PlayerGameLogs(playerList[i][0]).info()
    if temp.shape[0] > 5: #limit to players who play more than 5 games
        temp.GAME_DATE = pd.to_datetime(temp.GAME_DATE)
        temp['PLAYER'] = i
        d = temp.GAME_DATE
        temp['DaysSinceLastGame'] = d - d[1:].append(d[-1:]).reset_index().GAME_DATE
        temp.loc[:, 'DaysSinceLastGame'] = (temp.loc[:, 'DaysSinceLastGame']/np.timedelta64(1, 'D')).astype(int)
        temp['HA'] = temp.MATCHUP.apply(lambda x: 'H' if 'vs.' in x else 'A')
        temp['TEAM'] = temp.MATCHUP.apply(lambda x: x[:3])
        temp['OPP_TEAM'] = temp.MATCHUP.apply(lambda x: x[-3:])
        temp['DOUBLES'] = (temp['PTS']>=10).astype(int) + (temp['REB']>=10).astype(int) + (temp['AST']>=10).astype(int) \
                        + (temp['STL']>=10).astype(int) + (temp['BLK']>=10).astype(int)
        temp['DD'] = (temp['DOUBLES'] >= 2).astype(int)
        temp['TD'] = (temp['DOUBLES'] >= 3).astype(int)
        temp = pd.merge(temp, dkgamelog, how = 'left', on = ['PLAYER', 'GAME_DATE'])
        nulls = temp.Start.isnull()
        if nulls.sum()>0:
            for j in ['Start', 'POSITION:1', 'POSITION:2', 'POSITION:3', 'POSITION:4', 'POSITION:5']:
                temp.loc[nulls, j] = round(temp[j].mean())
            for j in ['DK Sal', 'DK Change']:
                temp.loc[nulls, j] = round(temp[j].mean(), -2)
            temp.loc[nulls, 'DKP'] = temp.loc[nulls, 'PTS'] + 0.5*temp.loc[nulls, 'FG3M'] + 1.25*temp.loc[nulls, 'REB'] + \
                                    1.5*temp.loc[nulls, 'AST'] + 2*temp.loc[nulls, 'STL'] - 0.5*temp.loc[nulls, 'TOV'] + \
                                    2*temp.loc[nulls, 'BLK'] + 1.5*temp.loc[nulls, 'DD'] + 3*temp.loc[nulls, 'TD']
            posit = []
            for j in range(nulls.sum()):
                positions = ''
                for k in ['POSITION:1', 'POSITION:2', 'POSITION:3', 'POSITION:4', 'POSITION:5']:
                    if list(temp[nulls][k])[j] ==1.0:
                        positions += k[-1:]
                posit.append(positions)
            temp.loc[nulls, 'DK pos'] = posit
            temp.loc[nulls, 'DK pos'] = temp.loc[nulls, 'DK pos'].str.join('@').str.split('@')
        for j in stats_cols:
            temp['Past3_' + j] = pastavg(3, temp[j])
            temp['Past6_' + j] = pastavg(6, temp[j])
            temp['Avg_' + j] = pastavg(temp.shape[0], temp[j]) 
        temp2 = temp[stats_cols] 
        tempAVG = pd.DataFrame(temp2.mean()).transpose()
        tempAVG['PLAYER'] = i
        playerAvgs = pd.concat([playerAvgs,tempAVG], ignore_index= True)
        temp = pd.concat([temp, teamOppstats(temp.TEAM, temp.OPP_TEAM)], axis = 1)
        allPlayersGameLogs = pd.concat([allPlayersGameLogs, temp], ignore_index= True)
        playerGameLogs[i] = temp
playerAvgs.columns = 'AVG_' + playerAvgs.columns
playerAvgs = playerAvgs.rename(columns = {'AVG_PLAYER': 'PLAYER'})


#create team defense by position tables
#dictionary keys are positions
#dictionary 1 is similar to http://www.rotowire.com/daily/nba/defense-vspos.php?site=DraftKings&statview=season&pos=SG
#dictionary 2 is similar to http://www.dfsgold.com/nba/defense-vs-position
#need to add the information back to player gamelogs
teamDefbyPOS = {}
teamDefbyPOS2 = {}
for i in range(1,6):
    temp = allPlayersGameLogs.loc[allPlayersGameLogs['POSITION:' + str(i)] == 1, :]
    temp.loc[temp.MIN == 0, 'MIN'] = 1
    temp2 = temp[['OPP_TEAM', 'HA', 'DKP']]
    temp2.loc[:, 'DKP'] = temp2.loc[:, 'DKP'].div(temp.MIN, axis = 'index')
    x = temp2.groupby('OPP_TEAM')[['DKP']].mean()
    x['League_Comparison'] = (x['DKP']/x.mean()[0]-1)*100
    x = x.reset_index()
    y = temp2[temp2.HA == 'H'].groupby('OPP_TEAM')[['DKP']].mean()
    y['League_Comparison'] = (y['DKP']/y.mean()[0]-1)*100
    y.columns = 'HOME_' + y.columns 
    y = y.reset_index()
    z = temp2[temp2.HA == 'A'].groupby('OPP_TEAM')[['DKP']].mean()
    z['League_Comparison'] = (z['DKP']/z.mean()[0]-1)*100
    z.columns = 'AWAY_' + z.columns
    z = z.reset_index()
    temp2 = reduce(lambda left,right: pd.merge(left,right,on='OPP_TEAM'), [x,y,z])
    temp2.columns = 'BY_POS_' + temp2.columns 
    temp2 = temp2.rename(columns={'BY_POS_OPP_TEAM': 'OPP_TEAM'})
    teamDefbyPOS2[str(i)] = temp2
    temp.loc[:, stats_cols] = temp.loc[:, stats_cols].div(temp.MIN, axis='index')*36
    temp = temp.groupby('OPP_TEAM')[stats_cols].mean()
    temp['FG_PCT'] = temp['FGM']/temp['FGA']
    temp['FG3_PCT'] = temp['FG3M']/temp['FG3A']
    temp['FT_PCT'] = temp['FTM']/temp['FTA']
    temp.columns = 'DEF_BY_POS_' + temp.columns
    teamDefbyPOS[str(i)] = temp.ix[:,1:].reset_index()

#get injury list
driver = webdriver.Chrome()
driver.get('http://www.cbssports.com/nba/injuries/daily')
time.sleep(2)
plyr = driver.find_elements_by_xpath('//*[@id="DailyTableData"]/tr')
injurylist = {'DATE': [], 'POS': [], 'PLAYER': [], 'TEAM': [], 'INJURY': [], 'EXPECTED_RETURN': []}
for ply in plyr:
    injurylist['DATE'].append(ply.find_element_by_xpath('.//td[1]/div').text)
    injurylist['POS'].append(ply.find_element_by_xpath('.//td[2]/div').text)
    injurylist['PLAYER'].append(ply.find_element_by_xpath('.//td[3]/div').text)
    injurylist['TEAM'].append(ply.find_element_by_xpath('.//td[4]/div').text)
    injurylist['INJURY'].append(ply.find_element_by_xpath('.//td[5]/div').text)
    injurylist['EXPECTED_RETURN'].append(ply.find_element_by_xpath('.//td[6]/div').text)
injurylist = pd.DataFrame(injurylist)
injurylist['PLAYER'] = injurylist['PLAYER'].apply(namechange)
driver.close()

def pastavgfortday(players, days, col):
    return [playerGameLogs[i][col][:days].mean() for i in players]
def getdefbypos(pos, opp):
    new_df = pd.DataFrame({})
    for i in range(len(opp)):
        temp_df = pd.DataFrame({})
        for j in pos[i]:
            x = teamDefbyPOS[j].loc[teamDefbyPOS[j].OPP_TEAM == opp[i],:]
            y = teamDefbyPOS2[j].loc[teamDefbyPOS2[j].OPP_TEAM == opp[i],:]
            z = pd.merge(x,y, on= 'OPP_TEAM')
            temp_df = pd.concat([temp_df,z], ignore_index= True)
        temp_df = pd.DataFrame(temp_df.mean()).transpose()
        new_df = pd.concat([new_df, temp_df], ignore_index= True)
    return new_df
#function to get the data for todays players 
def gettodaysplayers():
    date = pd.to_datetime('Today') #change date to 'today'
    x = roto1[roto1.Date == date][['First  Last', 'Team', 'Opp', 'H/A', 'DK Sal', \
                                                      'DK Change', 'DK pos', 'Date']]
    x = x[-x['DK Sal'].isnull()]
    x.columns = ['PLAYER', 'TEAM', 'OPP_TEAM', 'HA', 'DK Sal', 'DK Change', 'DK pos', 'GAME_DATE']
    x.PLAYER = x.PLAYER.apply(namechange)
    x.TEAM = x.TEAM.apply(teamAbbrchange)
    x.OPP_TEAM = x.OPP_TEAM.apply(teamAbbrchange)
    players = []
    for i in x.PLAYER:
        if (not i in list(injurylist.PLAYER)): 
            if (i in playerGameLogs.keys()):
                players.append(i)
    x = x[[(i in players) for i in x.PLAYER]]
    x['DK pos'] = x['DK pos'].astype(int).astype(str).str.join('@').str.split('@')
    temp = x['DK pos'].str.join('@').str.get_dummies('@')
    temp.columns = 'POSITION:' + temp.columns
    x = pd.concat([x, temp], axis= 1)
    x['DaysSinceLastGame'] = [(date - playerGameLogs[i]['GAME_DATE'][0]) for i in x.PLAYER]
    x.loc[:, 'DaysSinceLastGame'] = (x.loc[:, 'DaysSinceLastGame']/np.timedelta64(1, 'D')).astype(int)
    x = pd.concat([x.reset_index(drop=True), teamOppstats(list(x.TEAM), list(x.OPP_TEAM)).reset_index(drop=True)], axis = 1)
    for i in stats_cols:
        x['Past3_' + i] = pastavgfortday(x.PLAYER, 3, i)
        x['Past6_' + i] = pastavgfortday(x.PLAYER, 6, i)
        x['Avg_' + i] = pastavgfortday(x.PLAYER, 82, i) 
    x = pd.concat([x, getdefbypos(x['DK pos'], x.OPP_TEAM)], axis = 1)
    x.loc[x.HA == 'A', 'BY_POS_HOME_DKP'] = x.loc[x.HA == 'A', 'BY_POS_AWAY_DKP']
    x.loc[x.HA == 'A', 'BY_POS_HOME_League_Comparison'] = x.loc[x.HA == 'A', 'BY_POS_AWAY_League_Comparison']
    x = x.rename(columns = {'BY_POS_HOME_DKP': 'BY_POS_ARENA_DKP', 'BY_POS_HOME_League_Comparison': 'BY_POS_ARENA_League_Comparison'})
    x = x.drop(['BY_POS_AWAY_DKP', 'BY_POS_AWAY_League_Comparison'], axis = 1)
    return x


colstokeep = ['PLAYER', u'GAME_DATE', 'DaysSinceLastGame', 'HA', 'TEAM', 'OPP_TEAM', \
              'POSITION:1', 'POSITION:2', 'POSITION:3', 'POSITION:4', 'POSITION:5', 'Past3_MIN', 'Past6_MIN', 'Avg_MIN', \
              'Past3_FGM', 'Past6_FGM', 'Avg_FGM', 'Past3_FGA', 'Past6_FGA', 'Avg_FGA', 'Past3_FG_PCT', 'Past6_FG_PCT', \
              'Avg_FG_PCT', 'Past3_FG3M', 'Past6_FG3M', 'Avg_FG3M', 'Past3_FG3A', 'Past6_FG3A', 'Avg_FG3A', \
              'Past3_FG3_PCT', 'Past6_FG3_PCT', 'Avg_FG3_PCT', 'Past3_FTM', 'Past6_FTM', 'Avg_FTM', 'Past3_FTA', \
              'Past6_FTA', 'Avg_FTA', 'Past3_FT_PCT', 'Past6_FT_PCT', 'Avg_FT_PCT', 'Past3_OREB', 'Past6_OREB', 'Avg_OREB', \
              'Past3_DREB', 'Past6_DREB', 'Avg_DREB', 'Past3_REB', 'Past6_REB', 'Avg_REB', 'Past3_AST', 'Past6_AST', 'Avg_AST', \
              'Past3_STL', 'Past6_STL', 'Avg_STL', 'Past3_BLK', 'Past6_BLK', 'Avg_BLK', 'Past3_TOV', 'Past6_TOV', \
              'Avg_TOV', 'Past3_PF', 'Past6_PF', 'Avg_PF', 'Past3_PTS', 'Past6_PTS', 'Avg_PTS', 'Past3_PLUS_MINUS', \
              'Past6_PLUS_MINUS', 'Avg_PLUS_MINUS', 'Past3_DKP', 'Past6_DKP', 'Avg_DKP', 'Past3_DD', 'Past6_DD', 'Avg_DD', \
              'Past3_TD', 'Past6_TD', 'Avg_TD', u'TEAM_OPP_W_PCT', u'TEAM_OPP_MIN', u'TEAM_OPP_FGM', u'TEAM_OPP_FGA', \
              u'TEAM_OPP_FG_PCT', u'TEAM_OPP_FG3M', u'TEAM_OPP_FG3A', u'TEAM_OPP_FG3_PCT', u'TEAM_OPP_FTM', \
              u'TEAM_OPP_FTA', u'TEAM_OPP_FT_PCT', u'TEAM_OPP_OREB', u'TEAM_OPP_DREB', u'TEAM_OPP_REB', u'TEAM_OPP_AST', \
              u'TEAM_OPP_STL', u'TEAM_OPP_BLK', u'TEAM_OPP_TOV', u'TEAM_OPP_PF', u'TEAM_OPP_PTS', 'DEF_BY_POS_FGM', \
              'DEF_BY_POS_FGA', 'DEF_BY_POS_FG_PCT', 'DEF_BY_POS_FG3M', 'DEF_BY_POS_FG3A', 'DEF_BY_POS_FG3_PCT', \
              'DEF_BY_POS_FTM', 'DEF_BY_POS_FTA', 'DEF_BY_POS_FT_PCT', 'DEF_BY_POS_OREB', 'DEF_BY_POS_DREB', \
              'DEF_BY_POS_REB', 'DEF_BY_POS_AST', 'DEF_BY_POS_STL', 'DEF_BY_POS_BLK', 'DEF_BY_POS_TOV', 'DEF_BY_POS_PF', \
              'DEF_BY_POS_PTS', 'DEF_BY_POS_PLUS_MINUS', 'DEF_BY_POS_DKP', 'DEF_BY_POS_DD', 'DEF_BY_POS_TD', \
              'BY_POS_DKP', 'BY_POS_League_Comparison', 'BY_POS_ARENA_DKP', 'BY_POS_ARENA_League_Comparison', 'DKP']



playerGameLogsModified = {}
allPlayersGameLogsModified = pd.DataFrame({})
for i in playerGameLogs.keys():
    temp = playerGameLogs[i]
    temp = pd.concat([temp, getdefbypos(temp['DK pos'], temp['OPP_TEAM'])], axis = 1)
    temp.loc[temp.HA == 'A', 'BY_POS_HOME_DKP'] = temp.loc[temp.HA == 'A', 'BY_POS_AWAY_DKP']
    temp.loc[temp.HA == 'A', 'BY_POS_HOME_League_Comparison'] = temp.loc[temp.HA == 'A', 'BY_POS_AWAY_League_Comparison']
    temp = temp.rename(columns = {'BY_POS_HOME_DKP': 'BY_POS_ARENA_DKP', 'BY_POS_HOME_League_Comparison': 'BY_POS_ARENA_League_Comparison'})
    temp = temp[colstokeep]
    playerGameLogsModified[i] = temp
    allPlayersGameLogsModified = pd.concat([allPlayersGameLogsModified, temp], ignore_index= True)
    
# for adding player position to players from different seasons
# allPlayersGameLogsModified.to_csv('allPlayersGameLogsModified.csv', index= False)

gamelogs2016 = pd.read_csv('allPlayersGameLogsModified2015-16.csv')
gamelogs2016.PLAYER = gamelogs2016.PLAYER + ' 2016'
gamelogs2015 = pd.read_csv('allPlayersGameLogsModified2014-15.csv')
gamelogs2015.PLAYER = gamelogs2015.PLAYER + ' 2015'


allPlayersGameLogsFinal = pd.concat([allPlayersGameLogsModified[colstokeep], gamelogs2016[colstokeep], \
                                     gamelogs2015[colstokeep]], ignore_index= True)

#uncomment below to redo clusters; if clusters are redone, bayes must be rerun
# playerAvgs2016 = pd.read_csv('playerAvgs2015-16.csv')
# playerAvgs2016.PLAYER = playerAvgs2016.PLAYER + ' 2016'
# playerAvgs2015 = pd.read_csv('playerAvgs2014-15.csv')
# playerAvgs2015.PLAYER = playerAvgs2015.PLAYER + ' 2015'

# playerAvgsFinal = pd.concat([playerAvgs, playerAvgs2016, playerAvgs2015], ignore_index= True)
#clustering function
# from sklearn.cluster import KMeans
# from sklearn import metrics
# def cluster_players(n=10,df=playerAvgsFinal):
#     df = df[df.AVG_DKP.isnull() == False]
#     kmeans_model = KMeans(n_clusters=n, random_state=1)
#     kmeans_model.fit(df.drop(['PLAYER','AVG_DKP'],axis=1))
#     labels = kmeans_model.labels_+1
#     return pd.concat([df,pd.DataFrame(labels,columns=['cluster'])],axis=1).sort_values('cluster')
# player_clusters = cluster_players()[['PLAYER', 'cluster']]
# player_clusters.to_csv('playerclusters.csv', index= False)



#create clusters
#need to add clusters back to game logs
player_clusters = pd.read_csv('playerclusters.csv')
clusters = {}
for i in range(1,11):
    clusters[i] = player_clusters[player_clusters.cluster == i]['PLAYER'] 

clustereddfs = {}
injuryadjustment = {}
for i in clusters.keys():
    clustereddfs[i] = allPlayersGameLogsFinal[[(x in list(clusters[i])) for x in list(allPlayersGameLogsFinal.PLAYER)]]
    temp = clustereddfs[i][clustereddfs[i].DaysSinceLastGame>10]
    temp = temp[temp.Avg_DKP != 0]
    injuryadjustment[i] = 1 + ((temp['DKP'] - temp['Avg_DKP'])/temp['Avg_DKP']).mean()


numericalcolumns = list(allPlayersGameLogsFinal.select_dtypes(include=[np.number]))
droppedcols = [x for x in allPlayersGameLogsFinal.columns if (not x in numericalcolumns)]


def corrtable(df, numcols = numericalcolumns):
    a = []
    for i in numcols:
        b = pearsonr(df['DKP'], df[i])
        a.append([i, b[0], b[1]])
    a = pd.DataFrame(a)
    a.columns = ['columns', 'correlation', 'pvalue']
    a['abscorr'] = abs(a['correlation'])
    a = a[a['pvalue'] <0.05]
    a = a[a['abscorr'] != 1.0].sort_values(['abscorr'], ascending=[0])
    return a

adjustedclusterdfs = {}
clusteredcolumns = {}
for i in clustereddfs.keys():
    x = list(corrtable(clustereddfs[i])['columns'])
    x = list(set(droppedcols + x + ['POSITION:1', 'POSITION:2', 'POSITION:3', 'POSITION:4', 'POSITION:5', 'DKP']))
    clusteredcolumns[i] = [a for a in x if a != 'DKP']
    adjustedclusterdfs[i] = clustereddfs[i][x]


gettoday = gettodaysplayers()
todaysplayers = pd.merge(gettoday[colstokeep[:-1]], player_clusters, on='PLAYER')

todaysclusters = {}
for i in clusters.keys():
    todaysclusters[i] = todaysplayers[todaysplayers.cluster == i][clusteredcolumns[i]]

adjustplayersDKP = {}
for i in todaysclusters.keys():
    try:
        temp = todaysclusters[i]
        temp = temp[temp.DaysSinceLastGame > 10]
        for j in temp.PLAYER:
            adjustplayersDKP[j] = injuryadjustment[i]
    except:
        i = i

allPlayersGameLogs['Back'] = ((allPlayersGameLogs['POSITION:1'] + allPlayersGameLogs['POSITION:2']) > 0).astype(int)
z = allPlayersGameLogs[['TEAM', 'Back', 'MIN']].groupby(['TEAM', 'Back']).sum().reset_index()
z1 = allPlayersGameLogs[['TEAM', 'MIN']].groupby(['TEAM']).sum().reset_index()
z1.columns = ['TEAM', 'TOT_MIN']
z2 = pd.merge(z, z1, on='TEAM')
z2['TOT_MIN_PER_GAME'] = z2.MIN/z2.TOT_MIN*240


playerstoignore = []
playerstoignorefinal = []
for i in injurylist.PLAYER:
    try:
        if ((pd.to_datetime('Today') - playerGameLogs[i].GAME_DATE[0])/np.timedelta64(1, 'D')).astype(int) <= 10:
            playerstoignore.append(i)
            playerstoignorefinal.append(i)
    except:
        playerstoignore.append(i)
        playerstoignorefinal.append(i)

players = {}
for i in playerGameLogs.keys():
    team = playerGameLogs[i].TEAM[0]
    pos = int(round(allPlayersGameLogs[allPlayersGameLogs.PLAYER == i]['Back'].mean()))
    past3mins = playerGameLogs[i].Avg_MIN[0]
    players[i] = [team, past3mins, pos]
    teamRoster[team][pos].append(i)
    try:
        if ((pd.to_datetime('Today') - playerGameLogs[i].GAME_DATE[0])/np.timedelta64(1, 'D')).astype(int) > 5:
            playerstoignorefinal.append(i)
    except:
        playerstoignorefinal.append(i)
        
teamstoupdate = []
for i in playerstoignore:
    try:
        temp = [players[i][0], players[i][2]]
        if temp not in teamstoupdate:
            teamstoupdate.append(temp)
    except:
        i = i

teamstoupdate = [x for x in teamstoupdate if x[0] in list(set(gettoday.TEAM))]

adjustplayersmins = {}
for i in teamstoupdate:
    roster = set(teamRoster[i[0]][i[1]])
    mins = z2[(z2.TEAM == i[0]) & (z2.Back == i[1])].reset_index().TOT_MIN_PER_GAME[0]
    playr = []
    plyrmins = 0
    roster = [x for x in roster if ((x not in playerstoignorefinal) and x not in list(injurylist.PLAYER))]
    for j in roster:
        if players[j][1] > 25:
            mins -= players[j][1]
        else:
            playr.append(j)
            plyrmins += players[j][1]
    for j in playr:
        if (mins/plyrmins) < 0:
            adjustplayersmins[j] = 0
        elif (mins/plyrmins) > 1.5:
            adjustplayersmins[j] = 1.5
        else:
            adjustplayersmins[j] = (mins/plyrmins)

#linearreg and NN do not give results better than using avg_dkp so to save time, don't run
#can be used to            
# #linearreg
# param_grid = {'alpha': sp_rand()}
# #linear regression
# linregpreds = pd.DataFrame()
# # linregresults ={}
# for i in range(1,11):
#     temp = adjustedclusterdfs[i]
#     x = temp[list(temp.select_dtypes(include=[np.number]))].drop(['DKP'], axis = 1)
#     y = temp.DKP
#     model = Ridge()
#     rsearch = RandomizedSearchCV(estimator=model, param_distributions=param_grid, scoring= 'neg_mean_squared_error', n_iter=100)
#     rsearch.fit(x, y)
#     best = rsearch.best_estimator_
# #     para_search = gs.GridSearchCV(ols, para_grid, scoring='neg_mean_squared_error', cv =5).fit(x, y)
# #     best = para_search.best_estimator_
# #     best.fit(x,y)
# #     colnames = x.columns
# #     result = pd.DataFrame(ols.coef_).transpose()
# #     result.columns = colnames.tolist()
# #     result['intercept'] = ols.intercept_ 
# #     result = result.transpose()
# #     result.columns = ['coefficient']
# #     linregresults[i] =result 
#     temp2 = temp[['PLAYER', 'DKP']]
#     temp2['PREDS'] = best.predict(x)
#     linregpreds = linregpreds.append(temp2)


# #NN
# seed = 7
# numpy.random.seed(seed)
# dataset = allPlayersGameLogsFinal
# dataset.GAME_DATE = pd.to_datetime(dataset.GAME_DATE)
# numcols = list(dataset.select_dtypes(include=[np.number]))
# categorical = [x for x in dataset.columns if (not x in numcols) ]
# for f in categorical[2:]:
#     lbl = preprocessing.LabelEncoder()
#     lbl.fit(list(dataset[f].values))
#     dataset[f] = lbl.transform(list(dataset[f].values))
# dataset = shuffle(dataset)
# X = dataset.loc[:, list(dataset)[:-1]]
# Y = dataset.loc[:, 'DKP']
# a = pd.concat([X[['PLAYER', 'GAME_DATE']], Y], axis = 1)
# X = X.loc[:,X.columns[2:]].as_matrix()
# X = StandardScaler().fit(X).transform(X)
# Y = Y.as_matrix()/70
# # create model
# model = Sequential()
# model.add(Dense(200, input_dim=len(dataset.columns) - 3, init='uniform', activation='sigmoid'))
# model.add(Dropout(0.5))
# model.add(Dense(20, init='uniform', activation='sigmoid'))
# model.add(Dense(1, init='uniform', activation='sigmoid'))
# model.compile(loss='mean_squared_error', optimizer='adam', metrics=['mae'])
# history = model.fit(X, Y, nb_epoch=1000, batch_size=10, validation_split= 0.2, callbacks=[EarlyStopping(patience= 20, min_delta=1e-5)])
# predictions = model.predict(X)*70
# x = pd.concat([a.reset_index(drop=True), pd.DataFrame(predictions), ], axis = 1)



#bayes opt; need to rerun if clusters are redone
# def xgb_evaluate(min_child_weight,
#                  colsample_bytree,
#                  max_depth,
#                  subsample,
#                  gamma,
#                  lamb):
#     params['objective'] = 'reg:linear'
#     params['min_child_weight'] = int(min_child_weight)
#     params['cosample_bytree'] = max(min(colsample_bytree, 1), 0)
#     params['max_depth'] = int(max_depth)
#     params['subsample'] = max(min(subsample, 1), 0)
#     params['gamma'] = max(gamma, 0)
#     params['lambda'] = max(lamb, 0)


#     cv_result = xgb.cv(params, xgtrain, num_boost_round=num_rounds, nfold=5,
#              seed=random_state,
#              callbacks=[xgb.callback.early_stop(20)])

#     return -cv_result['test-rmse-mean'].values[-1]


# def prepare_data(i):
#     train = adjustedclusterdfs[i].drop(['GAME_DATE'], axis = 1)
#     categorical_columns = train.select_dtypes(include=['object']).columns

#     for column in tqdm(categorical_columns):
#         le = LabelEncoder()
#         train[column] = le.fit_transform(train[column])

#     y = train['DKP']

#     X = train.drop(['DKP', 'PLAYER'], 1)
#     xgtrain = xgb.DMatrix(X, label=y)

#     return xgtrain

# num_rounds = 3000
# random_state = 0
# num_iter = 25
# init_points = 5
# params = {
#     'eta': 0.01,
#     'silent': 1,
#     'eval_metric': 'rmse',
#     'verbose_eval': True,
#     'seed': random_state
# }

# bestparams = {}
# for i in range(1,11):
#     xgtrain = prepare_data(i)


#     xgbBO = BayesianOptimization(xgb_evaluate, {'min_child_weight': (1, 20),
#                                                 'colsample_bytree': (0.1, 1),
#                                                 'max_depth': (5, 15),
#                                                 'subsample': (0.5, 1),
#                                                 'gamma': (0, 10),
#                                                 'lamb': (0, 10),
#                                                 })

#     xgbBO.maximize(init_points=init_points, n_iter=num_iter)
#     bestparams[i] = xgbBO.res['max']['max_params']

# bestparams = pd.DataFrame(bestparams).reset_index()
# bestparams = bestparams.rename(columns = {'index': 'params'})
# bestparams.to_csv('xgboostbestparams.csv', index= False)

bestparams =pd.read_csv('xgboostbestparams.csv')

params = {}
for i in range(1,11):
    params[i] = {}
    n = 0
    for j in bestparams.params:
        params[i][j] = bestparams[str(i)][n]
        n += 1



def runXGB(colsample_bytree, gamma, lamb, max_depth, min_child_weight, subsample, \
           train_X, train_y, test_X, test_y=None, feature_names=None, seed_val=0, num_rounds=3000):
    param = {}
    param['objective'] = 'reg:linear'
    param['eta'] = 0.01
    param['max_depth'] = max_depth
    param['gamma'] = gamma
    param['silent'] = 1
    param['lambda'] = lamb
    param['eval_metric'] = "rmse"
    param['min_child_weight'] = min_child_weight
    param['subsample'] = subsample
    param['colsample_bytree'] = colsample_bytree
    param['seed'] = seed_val
    num_rounds = num_rounds

    plst = list(param.items())
    xgtrain = xgb.DMatrix(train_X, label=train_y)

    if test_y is not None:
        xgtest = xgb.DMatrix(test_X, label=test_y)
        watchlist = [ (xgtrain,'train'), (xgtest, 'test') ]
        model = xgb.train(plst, xgtrain, num_rounds, watchlist, early_stopping_rounds=50)
    else:
        xgtest = xgb.DMatrix(test_X)
        model = xgb.train(plst, xgtrain, num_rounds)

    pred_test_y = model.predict(xgtest)

    return pred_test_y, model


from sklearn import preprocessing

TRAIN = {}
TRAINTARGET = {}
TEST = {}

for i in adjustedclusterdfs.keys():
    
    categorical = ['HA']
    for f in categorical:
        lbl = preprocessing.LabelEncoder()
        lbl.fit(list(adjustedclusterdfs[i][f].values))
        adjustedclusterdfs[i][f] = lbl.transform(list(adjustedclusterdfs[i][f].values))
        todaysclusters[i][f] = lbl.transform(list(todaysclusters[i][f].values))
    
   
    TRAIN[i] =adjustedclusterdfs[i].drop(['DKP'], axis = 1)
    TRAINTARGET[i] = adjustedclusterdfs[i]['DKP']
    TEST[i] = todaysclusters[i]


todayspreds = pd.DataFrame()
for i in clustereddfs.keys():
        
    x_train = TRAIN[i].drop(['PLAYER','GAME_DATE','TEAM','OPP_TEAM'],axis=1)
    y_train = TRAINTARGET[i]
    x_test = TEST[i].drop(['PLAYER','GAME_DATE','TEAM','OPP_TEAM'],axis=1)
    
    print 'training cluster ',str(i)
    pred, model = runXGB(params[i]['colsample_bytree'], params[i]['gamma'], params[i]['lamb'],int(params[i]['max_depth']), \
                         params[i]['min_child_weight'], params[i]['subsample'], x_train, y_train, x_test)
    model.save_model('cluster'+str(i)+'.model')
    
    temp = pd.concat([pd.DataFrame(pred),TEST[i]\
                      .reset_index(drop=True)\
                      [['PLAYER','GAME_DATE','POSITION:1','POSITION:2','POSITION:3','POSITION:4','POSITION:5']]],axis=1)
    todayspreds = todayspreds.append(temp)


todayspreds = pd.merge(todayspreds, gettoday[['PLAYER', 'DK Sal']], on= 'PLAYER')
todayspreds['minmult'] = todayspreds.PLAYER.apply(lambda x: 1 if x not in adjustplayersmins.keys() else adjustplayersmins[x])
todayspreds['DKPmult'] = todayspreds.PLAYER.apply(lambda x: 1 if x not in adjustplayersDKP.keys() else adjustplayersDKP[x])
todayspreds['predadjust'] = todayspreds[0]*todayspreds.minmult*todayspreds.DKPmult

predsforskewdness = {}
for i in range(1,11):
    model = xgb.Booster()
    model.load_model('cluster'+str(i)+'.model') # load data
    x_test = xgb.DMatrix(TRAIN[i].drop(['PLAYER','GAME_DATE','TEAM','OPP_TEAM'],axis=1))
    pred = model.predict(x_test)
    temp = pd.concat([pd.DataFrame(pred),adjustedclusterdfs[i]\
                      .reset_index(drop=True)\
                      [['PLAYER','GAME_DATE','POSITION:1','POSITION:2','POSITION:3','POSITION:4','POSITION:5', 'DKP']]],axis=1)
    predsforskewdness[i] = temp


# skewness_dict = {}
# kurtosis_dict = {}
# for i in set(allPlayersGameLogsFinal.PLAYER):
#     #print name
#     temp = allPlayersGameLogsFinal[allPlayersGameLogsFinal.PLAYER == i]
#     skewness_dict[i] = stats.skew(temp.DKP)
#     kurtosis_dict[i] = stats.kurtosis(temp.DKP)
# skew_df1 = pd.DataFrame(kurtosis_dict, index = ['Kurtosis'])
# skew_df2 = pd.DataFrame(skewness_dict, index = ['Skewness'])
# skewness_df = pd.concat([skew_df1, skew_df2], axis = 0).T.reset_index().rename(columns= {'index': 'PLAYER'})
# skewness_df.to_csv('skewness.csv', index = False)

skewness_df = pd.read_csv('skewness.csv')
param_grid = {'alpha': np.logspace(-2, 5, 100)}

results ={}
# skewpreds = pd.DataFrame()
for i in range(1,11):
    temp = pd.merge(predsforskewdness[i][['PLAYER', 'DKP', 0]], skewness_df, on = 'PLAYER', how= 'left')
    temp = temp.rename(columns = {0:'PREDS'})
    temp.Kurtosis = temp.Kurtosis * temp['PREDS']
    temp.Skewness = temp.Skewness * temp['PREDS']
    x = temp[['PREDS', 'Kurtosis', 'Skewness']]
    y = temp.DKP
    model = Ridge()
    rsearch = gs.GridSearchCV(estimator=model, param_grid=param_grid, scoring= 'neg_mean_squared_error')
    rsearch.fit(x, y)
    best = rsearch.best_estimator_
#     temp2 = temp[['PLAYER', 'DKP']]
#     temp2['PREDS'] = best.predict(x)
#     skewpreds = skewpreds.append(temp2)
    colnames = x.columns
    result = pd.DataFrame(best.coef_).transpose()
    result.columns = colnames.tolist()
    result['intercept'] = best.intercept_ 
    result = result.transpose()
    result.columns = ['coefficient']
    results[i] =result 

todays = pd.merge(todayspreds, skewness_df, on = 'PLAYER', how= 'left')
todays = todays.rename(columns= {0:'PREDS'})
todays.Kurtosis = todays.Kurtosis * todays.PREDS
todays.Skewness = todays.Skewness * todays.PREDS

todays = pd.merge(todays, player_clusters, on= 'PLAYER', how= 'left')

todayskewness = pd.DataFrame()
for i in range(1,11):
    temp = todays[todays.cluster == i]
    temp['adjust'] = temp.PREDS* results[i]['coefficient'][0] + temp.Kurtosis * results[i]['coefficient'][1]  + \
                    temp.Skewness * results[i]['coefficient'][2] + results[i]['coefficient'][3]
    todayskewness = todayskewness.append(temp)

todayspreds = pd.merge(todayspreds, todayskewness[['PLAYER', 'adjust']], on= 'PLAYER', how= 'left')
todayspreds['finaladjust'] = todayspreds.adjust * todayspreds.minmult * todayspreds.DKPmult
timeseries = pd.read_csv('GamePredictions.csv')
timeseries = timeseries.rename(columns = {'Player': 'PLAYER'})
todayspreds = pd.merge(todayspreds, timeseries[['PLAYER', 'AR Predictions', 'EWMA Predictions']], on= 'PLAYER')

todayspreds = todayspreds.rename(columns= {0:'PREDS'})
todayspreds = pd.merge(todayspreds[['PLAYER', 'DK Sal', 'PREDS', 'predadjust', 'adjust', 'finaladjust', 'AR Predictions', 'EWMA Predictions']], 
         todaysplayers, on= 'PLAYER', how='left')

todayspreds.to_csv(str(pd.to_datetime('today'))[:10]+'preds.csv',index=False)