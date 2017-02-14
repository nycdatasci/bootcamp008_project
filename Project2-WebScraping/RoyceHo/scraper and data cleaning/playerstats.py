from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import collections
import time
import csv

driver = webdriver.Chrome()

driver.get('http://stats.nba.com/players/traditional/#!?sort=PTS&dir=-1')

csv_file = open('nbaplayerstats.csv', 'wb')
writer = csv.writer(csv_file)
writer.writerow(['PLAYER', 'TEAM', 'AGE', 'GP', 'W', 'L', 'MIN', 'PTS', 'FGM', 'FGA', 'FG%', '3PM', '3PA', '3P%', \
				 'FTM', 'FTA', 'FT%', 'OREB', 'DREB', 'REB', 'AST', 'TOV', 'STL', 'BLK', 'PF', 'DD2', 'TD3', '+/-'])
while True:
	try:
		button = driver.find_element_by_xpath('/html/body/main/div[2]/div/div[2]/div/div/nba-stat-table/div[2]/div/a')
		button.click()
		time.sleep(5)
	except:
		break
plyr = driver.find_elements_by_xpath('/html/body/main/div[2]/div/div[2]/div/div/nba-stat-table/div[1]/div[1]/table/tbody/tr')

links = []

for ply in plyr:
	plyr_dict = collections.OrderedDict()
	link = ply.find_element_by_xpath('.//td[2]/a').get_attribute('href') + 'traditional/'
	Player = ply.find_element_by_xpath('.//td[2]/a').text
 	Team = ply.find_element_by_xpath('.//td[3]').text
	Age = ply.find_element_by_xpath('.//td[4]').text
	GP = ply.find_element_by_xpath('.//td[5]').text
	W = ply.find_element_by_xpath('.//td[6]').text
	L = ply.find_element_by_xpath('.//td[7]').text
	Min = ply.find_element_by_xpath('.//td[8]').text
	Pts = ply.find_element_by_xpath('.//td[9]').text
	FGM = ply.find_element_by_xpath('.//td[10]').text
	FGA = ply.find_element_by_xpath('.//td[11]').text
	FGper = ply.find_element_by_xpath('.//td[12]').text
	threePM = ply.find_element_by_xpath('.//td[13]').text
	threePA = ply.find_element_by_xpath('.//td[14]').text
	threePper = ply.find_element_by_xpath('.//td[15]').text
	FTM = ply.find_element_by_xpath('.//td[16]').text
	FTA = ply.find_element_by_xpath('.//td[17]').text
	FTper = ply.find_element_by_xpath('.//td[18]').text
	OReb = ply.find_element_by_xpath('.//td[19]').text
	DReb = ply.find_element_by_xpath('.//td[20]').text
	Reb = ply.find_element_by_xpath('.//td[21]').text
	Ast = ply.find_element_by_xpath('.//td[22]').text
	TOv = ply.find_element_by_xpath('.//td[23]').text
	Stl = ply.find_element_by_xpath('.//td[24]').text
	Blk = ply.find_element_by_xpath('.//td[25]').text
	PF = ply.find_element_by_xpath('.//td[26]').text
	DD2 = ply.find_element_by_xpath('.//td[27]').text
	TD3 = ply.find_element_by_xpath('.//td[28]').text
	plusMinus = ply.find_element_by_xpath('.//td[29]').text
	links.append([link, Player.replace(' ','')])
	plyr_dict['Player'] = Player
	plyr_dict['Team'] = Team
	plyr_dict['Age'] = Age
	plyr_dict['GP'] = GP
	plyr_dict['W'] = W
	plyr_dict['L'] = L
	plyr_dict['Min'] = Min
	plyr_dict['Pts'] = Pts
	plyr_dict['FGM'] = FGM
	plyr_dict['FGA'] = FGA
	plyr_dict['FGper'] = FGper
	plyr_dict['threePM'] = threePM
	plyr_dict['threePA'] = threePA
	plyr_dict['threePper'] = threePper
	plyr_dict['FTM'] = FTM
	plyr_dict['FTA'] = FTA
	plyr_dict['FTper'] = FTper
	plyr_dict['OReb'] = OReb
	plyr_dict['DReb'] = DReb
	plyr_dict['Reb'] = Reb
	plyr_dict['Ast'] = Ast
	plyr_dict['TOv'] = TOv
	plyr_dict['Stl'] = Stl
	plyr_dict['Blk'] = Blk
	plyr_dict['PF'] = PF
	plyr_dict['DD2'] = DD2
	plyr_dict['TD3'] = TD3
	plyr_dict['plusMinus'] = plusMinus
	writer.writerow(plyr_dict.values())


csv_file.close()

def playerstats(tabs):
	for tab in tabs:
		tab_dict = collections.OrderedDict()

		Breakdown = tab.find_element_by_xpath('.//td[1]').text
		GP = tab.find_element_by_xpath('.//td[2]').text
		Min = tab.find_element_by_xpath('.//td[3]').text
		Pts = tab.find_element_by_xpath('.//td[4]').text
		FGM = tab.find_element_by_xpath('.//td[5]').text
		FGA = tab.find_element_by_xpath('.//td[6]').text
		FGper = tab.find_element_by_xpath('.//td[7]').text
		threePM = tab.find_element_by_xpath('.//td[8]').text
		threePA = tab.find_element_by_xpath('.//td[9]').text
		threePper = tab.find_element_by_xpath('.//td[10]').text	
		FTM = tab.find_element_by_xpath('.//td[11]').text
		FTA = tab.find_element_by_xpath('.//td[12]').text
		FTper = tab.find_element_by_xpath('.//td[13]').text
		OReb = tab.find_element_by_xpath('.//td[14]').text
		DReb = tab.find_element_by_xpath('.//td[15]').text
		Reb = tab.find_element_by_xpath('.//td[16]').text
		Ast = tab.find_element_by_xpath('.//td[17]').text
		TOv = tab.find_element_by_xpath('.//td[18]').text
		Stl = tab.find_element_by_xpath('.//td[19]').text
		Blk = tab.find_element_by_xpath('.//td[20]').text
		PF = tab.find_element_by_xpath('.//td[21]').text
		DD2 = tab.find_element_by_xpath('.//td[22]').text
		TD3 = tab.find_element_by_xpath('.//td[23]').text
		plusMinus = tab.find_element_by_xpath('.//td[24]').text

		tab_dict['Breakdown'] = Breakdown
		tab_dict['GP'] = GP
		tab_dict['Min'] = Min
		tab_dict['Pts'] = Pts
		tab_dict['FGM'] = FGM
		tab_dict['FGA'] = FGA
		tab_dict['FGper'] = FGper
		tab_dict['threePM'] = threePM
		tab_dict['threePA'] = threePA
		tab_dict['threePper'] = threePper
		tab_dict['FTM'] = FTM
		tab_dict['FTA'] = FTA
		tab_dict['FTper'] = FTper
		tab_dict['OReb'] = OReb
		tab_dict['DReb'] = DReb
		tab_dict['Reb'] = Reb
		tab_dict['Ast'] = Ast
		tab_dict['TOv'] = TOv
		tab_dict['Stl'] = Stl
		tab_dict['Blk'] = Blk
		tab_dict['PF'] = PF
		tab_dict['DD2'] = DD2
		tab_dict['TD3'] = TD3
		tab_dict['plusMinus'] = plusMinus
		writers.writerow(tab_dict.values())

def playertable(lin):
	driver.get(lin[0])
	time.sleep(5)
	csv_files = open(lin[1] + '.csv', 'wb') 
	global writers
	writers = csv.writer(csv_files)
	writers.writerow(['BREAKDOWN', 'GP', 'MIN', 'PTS', 'FGM', 'FGA', 'FG%', '3PM', '3PA', '3P%', 'FTM', 'FTA', 'FT%', \
					  'OREB', 'DREB', 'REB', 'AST', 'TOV', 'STL', 'BLK', 'PF', 'DD2', 'TD3', '+/-'])
	for i in range(7):
		tabl= driver.find_elements_by_xpath('/html/body/main/div[2]/div/div/div[3]/div/div/div/nba-stat-table[' \
									   		+ str(i + 1) + ']/div[1]/div[1]/table/tbody/tr')
		playerstats(tabl)
	csv_files.close()

def deftable(lin):
	driver.get(lin[0].replace('traditional', 'defense-dash'))
	time.sleep(5)
	csv_files = open(lin[1] + 'Def.csv', 'wb') 
	global writerss
	writerss = csv.writer(csv_files)
	writerss.writerow(['DEFENSE CATEGORY', 'DFGM', 'DFGA', 'DFG%', 'FREQ', 'FG%', 'DIFF%'])
	tabs = driver.find_elements_by_xpath('/html/body/main/div[2]/div/div/div[3]/div/div/div/nba-stat-table[1]/div[1]/div[1]/table/tbody/tr')
	for tab in tabs:
		tab_dict = collections.OrderedDict()

		DefCat = tab.find_element_by_xpath('.//td[1]').text
		DFGM = tab.find_element_by_xpath('.//td[4]').text
		DFGA = tab.find_element_by_xpath('.//td[5]').text
		DFGper = tab.find_element_by_xpath('.//td[6]').text
		Freq = tab.find_element_by_xpath('.//td[7]').text
		FGper = tab.find_element_by_xpath('.//td[8]').text
		DIFFper = tab.find_element_by_xpath('.//td[9]').text

		tab_dict['DefCat'] = DefCat
		tab_dict['DFGM'] = DFGM
		tab_dict['DFGA'] = DFGA
		tab_dict['DFGper'] = DFGper
		tab_dict['Freq'] = Freq
		tab_dict['FGper'] = FGper
		tab_dict['DIFFper'] = DIFFper
		writerss.writerow(tab_dict.values())

	csv_files.close()

def gamelogtable(lin):
	driver.get(lin[0].replace('traditional', 'gamelogs'))
	time.sleep(4)
	while True:
		try:
			button = driver.find_element_by_xpath('/html/body/main/div[2]/div/div/div[3]/div/div/div/nba-stat-table/div[2]/div/a')
			button.click()
		except:
			break
	csv_files = open(lin[1] + 'gamelog.csv', 'wb')
	writersss = csv.writer(csv_files)
	writersss.writerow(['MATCHUP', 'W/L', 'MIN', 'PTS', 'FGM', 'FGA', 'FG%', '3PM', '3PA', '3P%', \
						'FTM', 'FTA', 'FT%', 'OREB', 'DREB', 'REB', 'AST', 'STL', 'BLK', 'TOV', 'PF', '+/-'])
	tabs = driver.find_elements_by_xpath('/html/body/main/div[2]/div/div/div[3]/div/div/div/nba-stat-table/div[1]/div[1]/table/tbody/tr')
	for tab in tabs:
		tab_dict = collections.OrderedDict()

		Matchup = tab.find_element_by_xpath('.//td[1]').text
		WL = tab.find_element_by_xpath('.//td[2]').text
		Min = tab.find_element_by_xpath('.//td[3]').text
		Pts = tab.find_element_by_xpath('.//td[4]').text
		FGM = tab.find_element_by_xpath('.//td[5]').text
		FGA = tab.find_element_by_xpath('.//td[6]').text
		FGper = tab.find_element_by_xpath('.//td[7]').text	
		threePM = tab.find_element_by_xpath('.//td[8]').text
		threePA = tab.find_element_by_xpath('.//td[9]').text
		threePper = tab.find_element_by_xpath('.//td[10]').text
		FTM = tab.find_element_by_xpath('.//td[11]').text
		FTA = tab.find_element_by_xpath('.//td[12]').text
		FTper = tab.find_element_by_xpath('.//td[13]').text
		OReb = tab.find_element_by_xpath('.//td[14]').text
		DReb = tab.find_element_by_xpath('.//td[15]').text
		Reb = tab.find_element_by_xpath('.//td[16]').text
		Ast = tab.find_element_by_xpath('.//td[17]').text
		Stl = tab.find_element_by_xpath('.//td[18]').text
		Blk = tab.find_element_by_xpath('.//td[19]').text
		TOv = tab.find_element_by_xpath('.//td[20]').text
		PF = tab.find_element_by_xpath('.//td[21]').text
		plusMinus = tab.find_element_by_xpath('.//td[22]').text
		
		tab_dict['Matchup'] = Matchup
		tab_dict['WL'] = WL
		tab_dict['Min'] = Min
		tab_dict['Pts'] = Pts
		tab_dict['FGM'] = FGM
		tab_dict['FGA'] = FGA
		tab_dict['FGper'] = FGper
		tab_dict['threePM'] = threePM
		tab_dict['threePA'] = threePA
		tab_dict['threePper'] = threePper
		tab_dict['FTM'] = FTM
		tab_dict['FTA'] = FTA
		tab_dict['FTper'] = FTper
		tab_dict['OReb'] = OReb
		tab_dict['DReb'] = DReb
		tab_dict['Reb'] = Reb
		tab_dict['Ast'] = Ast
		tab_dict['Stl'] = Stl
		tab_dict['Blk'] = Blk
		tab_dict['TOv'] = TOv
		tab_dict['PF'] = PF
		tab_dict['plusMinus'] = plusMinus
		writersss.writerow(tab_dict.values())
	csv_files.close()

for i in links:
	deftable(i)
for i in links:
	playertable(i)
for i in links:
	gamelogtable(i)

driver.close()
















