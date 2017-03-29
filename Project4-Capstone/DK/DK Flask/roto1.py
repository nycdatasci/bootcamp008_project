#draft kings data
import pandas as pd
roto = pd.read_csv('http://rotoguru1.com/cgi-bin/nba-dhd-2017.pl?&user=jasonjjchen&key=J8987209841',sep = ':')

roto1 = roto.iloc[:-1,:]
roto1.loc[:,'Date'] = pd.to_datetime(roto1.Date.astype(int),format='%Y%m%d')
# roto1 = roto1.iloc[2:,:] #remove na for unfinished games
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

today = roto1[roto1.Date == pd.to_datetime('2017-03-29')][['First  Last','GTime(ET)']]
# print 'fromroto', sorted(today['GTime(ET)'].unique())