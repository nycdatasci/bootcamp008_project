import pandas as pd
import numpy as np
from statsmodels.tsa.ar_model import AR

roto = pd.read_csv('http://rotoguru1.com/cgi-bin/nba-dhd-2017.pl?&user=jasonjjchen&key=J8987209841',sep = ':')

roto1 = roto.iloc[:-1,:]
roto1.loc[:,'Date'] = pd.to_datetime(roto1.Date.astype(int),format='%Y%m%d')
# roto1 = roto1.iloc[2:,:] #remove na for unfinished games
rotocols = roto1.columns[[1,2,3,4,5,6,8,9,10,11,12,16,24,25,31]]
roto1 = roto1[rotocols] #clean columns
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
# temp.columns = ['PG', 'SG', 'SF', 'PF', 'C']
dkgamelog['DK pos'] = dkgamelog['DK pos'].astype(int).astype(str).str.join('@').str.split('@')
dkgamelog = pd.concat([dkgamelog[['PLAYER', 'GAME_DATE', 'DK Sal', 'DK Change', 'DKP', 'Start', 'DK pos']], temp], axis= 1)
dkgamelog.loc[dkgamelog['DK Change'].isnull(), 'DK Change'] = 0


TS = roto1[['First  Last', 'DK pos', 'Date']]
#Filter out all players causing exceptions and players with very little observations.
roto1 = roto1.dropna()
exception_player = []
AR_predictions = pd.DataFrame([])
for name,group in roto1.groupby('First  Last'):
    print 'Processing: ', name
    TS = group.iloc[::-1]
    rng = pd.date_range('1/1/2000', periods = len(TS), freq = 'D')
    TS['Date_New'] = rng
    TS = TS.set_index('Date_New')
    TS = TS['DKP']
    #build the regression model
    try:
        model = AR(TS)
        model_fit = model.fit()
        predicted_value = model_fit.predict(start = len(TS) - 1, end = len(TS) - 1, dynamic = False)
    except Exception as e:
        print e.args
        exception_player.append(name)
    if len(group) <= 20 and name not in exception_player:
        exception_player.append(name)
    if len(group['DK pos'].unique()) == 1 and group['DK pos'].unique()[0] == 0 and name not in exception_player:
        exception_player.append(name)


from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
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


#Combine the fitlering 
exception_player_p1 = [x for x in exception_player if x not in injurylist.PLAYER.tolist()]
exception_player_p2 = [x for x in injurylist.PLAYER.tolist() if x not in exception_player]
unique_exception_player = exception_player_p1 + exception_player_p2
print len(unique_exception_player)
#unique_exception_player


#Regression loops
roto1 = roto1.dropna()
#exception_player = []
AR_predictions = pd.DataFrame([])
last_game_dates = []
for name,group in roto1.groupby('First  Last'):
    if name not in unique_exception_player:
        print 'Processing: ', name
        TS = group.iloc[::-1]
        rng = pd.date_range('1/1/2000', periods = len(TS), freq = 'D')
        TS['Date_New'] = rng
        TS = TS.set_index('Date_New')
        TS = TS['DKP']
        #build the regression model
        try:
            model = AR(TS)
            model_fit = model.fit()
            predicted_value = model_fit.predict(start = len(TS) - 1, end = len(TS) - 1, dynamic = False)
        except Exception as e:
            print e.args
            TS = TS.fillna(method = 'ffill')
            model = AR(TS)
            model_fit = model.fit()
            predicted_value = model_fit.predict(start = len(TS) - 1, end = len(TS) - 1, dynamic = False)
        predicted = pd.DataFrame(predicted_value)
        predicted = predicted.reset_index()
        predicted.columns = ['Date', 'Predictions']
        del predicted['Date']
        predicted['Player'] = name
        AR_predictions = pd.concat([AR_predictions, predicted], axis = 0)


#Get actual DKP's
roto1 = roto1.dropna()
#exception_player = []
#AR_predictions = pd.DataFrame([])
actual_DK_pos = []
for name,group in roto1.groupby('First  Last'):
    if name not in unique_exception_player:
        print 'Processing: ', name
        TS = group.iloc[::-1]
        rng = pd.date_range('1/1/2000', periods = len(TS), freq = 'D')
        TS['Date_New'] = rng
        TS = TS.set_index('Date_New')
        TS = TS['DKP']
        #build the regression model
        actual_DK_pos.append(TS[-1])


AR_predictions['Actual'] = actual_DK_pos

diff = AR_predictions['Predictions'] - AR_predictions['Actual']
diff_sqr = [x**2 for x in diff]
diff_sqr_sum = np.sum(diff_sqr)
MSE = diff_sqr_sum / len(AR_predictions)
np.sqrt(MSE)


#Regression loops
roto1 = roto1.dropna()
#exception_player = []
EWMA_predictions = pd.DataFrame([])
for name,group in roto1.groupby('First  Last'):
    if name not in unique_exception_player:
        print 'Processing: ', name
        TS = group.iloc[::-1]
        rng = pd.date_range('1/1/2000', periods = len(TS), freq = 'D')
        TS['Date_New'] = rng
        TS = TS.set_index('Date_New')
        TS = TS['DKP']
        TS = pd.ewma(TS.values, alpha = 0.97)
        #build the regression model
        try:
            model = AR(TS)
            model_fit = model.fit()
            predicted_value = model_fit.predict(start = len(TS) - 1, end = len(TS) - 1, dynamic = False)
        except Exception as e:
            print e.args
            TS = TS.fillna(method = 'ffill')
            model = AR(TS)
            model_fit = model.fit()
            predicted_value = model_fit.predict(start = len(TS) - 1, end = len(TS) - 1, dynamic = False)
        predicted = pd.DataFrame(predicted_value)
        predicted = predicted.reset_index()
        predicted.columns = ['Date', 'Predictions']
        del predicted['Date']
        predicted['Player'] = name
        EWMA_predictions = pd.concat([EWMA_predictions, predicted], axis = 0)


combined = pd.concat([AR_predictions, EWMA_predictions], axis = 1)
combined.columns = ('AR Predictions', 'Player1', 'Actual', 'EWMA Predictions', 'Player')
del combined['Player1']

#Get the last game dates for all players for whom we made predictions
last_game_dates = []
for name,group in roto1.groupby('First  Last'):
    if name not in unique_exception_player:
        print 'Processing: ', name
        TSA = group.iloc[::-1]
        last_game_date = TSA.Date.values[0]
        last_game_dates.append(last_game_date)

combined.to_csv('GamePredictions.csv')