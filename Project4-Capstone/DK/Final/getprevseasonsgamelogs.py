import nba_py
import nba_py.player
import nba_py.game
import nba_py.league
import nba_py.shotchart
import nba_py.team
import pandas as pd
import numpy as np

#need to get list of players in current season first
#create list of teams
a = nba_py.team.TeamList().info()
teamList = {}
teamRoster = {}
n = 0
for i in a.ABBREVIATION:
    if n == 30:
        break
    teamList[i] = [a.TEAM_ID[n]]
    teamRoster[i] = []
    n += 1

#change seas for other seasons
seas = '2015-16'
b = nba_py.player.PlayerList(season = seas,only_current=0).info()
playerList = {}
n = 0
for i in b.DISPLAY_FIRST_LAST:
    playerList[i] = [b.PERSON_ID[n], b.TEAM_ABBREVIATION[n], b.TEAM_ID[n]]
    try:
        teamRoster[b.TEAM_ABBREVIATION[n]].append(i)
    except:
        i = i
    n += 1


#create a df to merge opponent's gamelogs to the team gamelog 
OppGameLogs = pd.DataFrame({})
for i in teamList.keys():
    OppGameLogs = pd.concat([OppGameLogs, nba_py.team.TeamGameLogs(teamList[i][0], season= seas).info()], ignore_index= True)
OppGameLogs.columns = 'Opp_' + OppGameLogs.columns
OppGameLogs = OppGameLogs.drop(['Opp_GAME_DATE', 'Opp_MATCHUP', 'Opp_WL'], axis = 1)
OppGameLogs = OppGameLogs.rename(columns = {'Opp_Game_ID': 'Game_ID'})


#create team gamelogs and team averages and standard deviation tables
teamGameLogs = {}
teamAvgs = pd.DataFrame({})
# teamStds = pd.DataFrame({})
for i in teamList.keys():
    temp = nba_py.team.TeamGameLogs(teamList[i][0], season= seas).info()
    temp = pd.merge(temp, OppGameLogs.loc[OppGameLogs.Opp_Team_ID != teamList[i][0],: ], on = 'Game_ID')
    temp.GAME_DATE = pd.to_datetime(temp.GAME_DATE)
    d = temp.GAME_DATE
    temp['DaysSinceLastGame'] = d - d[1:].append(d[-1:]).reset_index().GAME_DATE
    temp['HA'] = temp.MATCHUP.apply(lambda x: 'H' if 'vs.' in x else 'A')
    temp['TEAM'] = temp.MATCHUP.apply(lambda x: x[:3])
    temp['OPP_TEAM'] = temp.MATCHUP.apply(lambda x: x[-3:])
    temp = temp.drop(['Team_ID', 'Game_ID', 'Opp_Team_ID', 'MATCHUP'], axis = 1)
    teamGameLogs[i] = temp
#     teamGameLogs[i].to_csv( i + 'gamelogs.csv')
    tempAVG = pd.DataFrame(temp.mean()).transpose().drop(['W', 'L', 'Opp_W', 'Opp_L'], axis = 1)
    tempAVG['TEAM'] = i
    # tempSTD = pd.DataFrame(temp.std()).transpose().drop(['W', 'L', 'Opp_W', 'Opp_L'], axis = 1)
    # tempSTD['TEAM'] = i
    teamAvgs = pd.concat([teamAvgs,tempAVG], ignore_index= True)
    # teamStds = pd.concat([teamStds,tempSTD], ignore_index= True)
teamAvgs.columns = 'AVG_' + teamAvgs.columns
teamAvgs = teamAvgs.rename(columns = {'AVG_TEAM': 'TEAM'})
# teamStds.columns = 'STD_' + teamStds.columns
# teamStds = teamStds.rename(columns = {'STD_TEAM': 'TEAM'})


#function to merge team vs opponent stats to player gamelogs
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

gamelogs2017 = pd.read_csv('allPlayersGameLogsModified.csv')

gamelogs2017 = gamelogs2017[['PLAYER', 'POSITION:1', 'POSITION:2', 'POSITION:3', 'POSITION:4', 'POSITION:5']]

playerpositions = gamelogs2017.groupby('PLAYER').mean().round().reset_index()

posit = []
for i in range(playerpositions.shape[0]):    
    positions = ''
    for j in ['POSITION:1', 'POSITION:2', 'POSITION:3', 'POSITION:4', 'POSITION:5']:
        if list(playerpositions[j])[i] ==1.0:
            positions += j[-1:]
    posit.append(positions)
playerpositions['DK pos'] = posit
playerpositions['DK pos'] = playerpositions['DK pos'].str.join('@').str.split('@')



#modifying player gamelogs
stats_cols = ['MIN', 'FGM', 'FGA', 'FG_PCT', 'FG3M', 'FG3A', 'FG3_PCT', 'FTM', 'FTA', 'FT_PCT', 'OREB', 'DREB', \
              'REB', 'AST', 'STL', 'BLK', 'TOV', 'PF', 'PTS', 'PLUS_MINUS', 'DKP', 'DD', 'TD']
playerGameLogs = {}
allPlayersGameLogs = pd.DataFrame({})
playerAvgs = pd.DataFrame({})
# playerStds = pd.DataFrame({})
for i in playerList.keys():
    if not i in list(playerpositions.PLAYER):
        continue
    temp = nba_py.player.PlayerGameLogs(playerList[i][0], season= seas).info()
    if temp.shape[0] > 5: #limit to players who play more than 5 games
#     try:
#         temp = nba_py.player.PlayerGameLogs(playerList[i][0]).info()
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
#         temp = temp.drop(['SEASON_ID', 'Player_ID', 'Game_ID', 'VIDEO_AVAILABLE', 'MATCHUP', 'DOUBLES'], axis = 1)
#         temp['DKPoints'] = temp['PTS'] + 0.5*temp['FG3M'] + 1.25*temp['REB'] + 1.5*temp['AST'] + 2*temp['STL'] - \
#                             0.5*temp['TOV'] + 2*temp['BLK'] + 1.5*temp['DD'] + 3*temp['TD']
#         temp = pd.merge(temp, dkgamelog, how = 'left', on = ['PLAYER', 'GAME_DATE'])
#         nulls = temp.Start.isnull()
#         if nulls.sum()>0:
#             for j in ['Start', 'POSITION:1', 'POSITION:2', 'POSITION:3', 'POSITION:4', 'POSITION:5']:
#                 temp.loc[nulls, j] = round(temp[j].mean())
#             for j in ['DK Sal', 'DK Change']:
#                 temp.loc[nulls, j] = round(temp[j].mean(), -2)
        temp['DKP'] = temp['PTS'] + 0.5*temp['FG3M'] + 1.25*temp['REB'] + 1.5*temp['AST'] + 2*temp['STL'] - \
                        0.5*temp['TOV'] + 2*temp['BLK'] + 1.5*temp['DD'] + 3*temp['TD']
        temp = pd.merge(temp, playerpositions, on= 'PLAYER', how= 'left')
#             posit = []
#             for j in range(nulls.sum()):
#                 positions = ''
#                 for k in ['POSITION:1', 'POSITION:2', 'POSITION:3', 'POSITION:4', 'POSITION:5']:
#                     if list(temp[nulls][k])[j] ==1.0:
#                         positions += k[-1:]
#                 posit.append(positions)
#             temp.loc[nulls, 'DK pos'] = posit
#             temp.loc[nulls, 'DK pos'] = temp.loc[nulls, 'DK pos'].str.join('@').str.split('@')
        for j in stats_cols:
            temp['Past3_' + j] = pastavg(3, temp[j])
            temp['Past6_' + j] = pastavg(6, temp[j])
            temp['Avg_' + j] = pastavg(temp.shape[0], temp[j]) 
        temp2 = temp[stats_cols] 
        tempAVG = pd.DataFrame(temp2.mean()).transpose()
        tempAVG['PLAYER'] = i
        # tempSTD = pd.DataFrame(temp2.std()).transpose()
        # tempSTD['PLAYER'] = i
        playerAvgs = pd.concat([playerAvgs,tempAVG], ignore_index= True)
        # playerStds = pd.concat([playerStds,tempSTD], ignore_index= True)
        temp = pd.concat([temp, teamOppstats(temp.TEAM, temp.OPP_TEAM)], axis = 1)
        allPlayersGameLogs = pd.concat([allPlayersGameLogs, temp], ignore_index= True)
        playerGameLogs[i] = temp
#         playerGameLogs[i].to_csv( i.replace(' ', '') + 'gamelogs.csv')
#     except:
#         i = i
playerAvgs.columns = 'AVG_' + playerAvgs.columns
playerAvgs = playerAvgs.rename(columns = {'AVG_PLAYER': 'PLAYER'})
# playerStds.columns = 'STD_' + playerStds.columns
# playerStds = playerStds.rename(columns = {'STD_PLAYER': 'PLAYER'})
playerAvgs.to_csv('playerAvgs' + seas + '.csv', index= False)


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
#         temp_df['OPP_TEAM'] = opp[i]
        new_df = pd.concat([new_df, temp_df], ignore_index= True)
    return new_df

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
    temp = temp.drop(['BY_POS_AWAY_DKP', 'BY_POS_AWAY_League_Comparison'], axis = 1)
    temp = temp[colstokeep]
    playerGameLogsModified[i] = temp
    allPlayersGameLogsModified = pd.concat([allPlayersGameLogsModified, temp], ignore_index= True)
    

allPlayersGameLogsModified.to_csv('allPlayersGameLogsModified' + seas + '.csv', index= False)
    
