from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import collections
import time
import csv


driver = webdriver.Chrome()

driver.get('http://stats.nba.com/teams/traditional/#!?sort=W_PCT&dir=-1')
time.sleep(2)

csv_file = open('nbateamstats.csv', 'wb')
writer = csv.writer(csv_file)
writer.writerow(['TEAM', 'GP', 'W', 'L', 'WIN%', 'MIN', 'PTS', 'FGM', 'FGA', 'FG%', '3PM', '3PA', '3P%', 'FTM', 'FTA', 'FT%', \
				 'OREB', 'DREB', 'REB', 'AST', 'TOV', 'STL', 'BLK', 'BLKA', 'PF', 'PFD', '+/-'])

teams = driver.find_elements_by_xpath('/html/body/main/div[2]/div/div[2]/div/div/nba-stat-table/div[1]/div[1]/table/tbody/tr')

links = []

for team in teams:
	teams_dict = collections.OrderedDict()
	link = team.find_element_by_xpath('.//td[2]/a').get_attribute('href')
 	Team = team.find_element_by_xpath('.//td[2]').text
	GP = team.find_element_by_xpath('.//td[3]').text
	W = team.find_element_by_xpath('.//td[4]').text
	L = team.find_element_by_xpath('.//td[5]').text
	Winper = team.find_element_by_xpath('.//td[6]').text
	Min = team.find_element_by_xpath('.//td[7]').text
	Pts = team.find_element_by_xpath('.//td[8]').text
	FGM = team.find_element_by_xpath('.//td[9]').text
	FGA = team.find_element_by_xpath('.//td[10]').text
	FGper = team.find_element_by_xpath('.//td[11]').text
	threePM = team.find_element_by_xpath('.//td[12]').text
	threePA = team.find_element_by_xpath('.//td[13]').text
	threePper = team.find_element_by_xpath('.//td[14]').text
	FTM = team.find_element_by_xpath('.//td[15]').text
	FTA = team.find_element_by_xpath('.//td[16]').text
	FTper = team.find_element_by_xpath('.//td[17]').text
	OReb = team.find_element_by_xpath('.//td[18]').text
	DReb = team.find_element_by_xpath('.//td[19]').text
	Reb = team.find_element_by_xpath('.//td[20]').text
	Ast = team.find_element_by_xpath('.//td[21]').text
	TOv = team.find_element_by_xpath('.//td[22]').text
	Stl = team.find_element_by_xpath('.//td[23]').text
	Blk = team.find_element_by_xpath('.//td[24]').text
	BlkA = team.find_element_by_xpath('.//td[25]').text
	PF = team.find_element_by_xpath('.//td[26]').text
	PFD = team.find_element_by_xpath('.//td[27]').text
	plusMinus = team.find_element_by_xpath('.//td[28]').text
	links.append([link, Team.replace(' ','')])

	teams_dict['Team'] = Team
	teams_dict['GP'] = GP
	teams_dict['W'] = W
	teams_dict['L'] = L
	teams_dict['Winper'] = Winper
	teams_dict['Min'] = Min
	teams_dict['Pts'] = Pts
	teams_dict['FGM'] = FGM
	teams_dict['FGA'] = FGA
	teams_dict['FGper'] = FGper
	teams_dict['threePM'] = threePM
	teams_dict['threePA'] = threePA
	teams_dict['threePper'] = threePper
	teams_dict['FTM'] = FTM
	teams_dict['FTA'] = FTA
	teams_dict['FTper'] = FTper
	teams_dict['OReb'] = OReb
	teams_dict['DReb'] = DReb
	teams_dict['Reb'] = Reb
	teams_dict['Ast'] = Ast
	teams_dict['TOv'] = TOv
	teams_dict['Stl'] = Stl
	teams_dict['Blk'] = Blk
	teams_dict['BlkA'] = BlkA
	teams_dict['PF'] = PF
	teams_dict['PFD'] = PFD
	teams_dict['plusMinus'] = plusMinus
	writer.writerow(teams_dict.values())


csv_file.close()

def teamstats(tabs):
	for tab in tabs:
		tab_dict = collections.OrderedDict()

		Breakdown = tab.find_element_by_xpath('.//td[1]').text
		GP = tab.find_element_by_xpath('.//td[2]').text
		Min = tab.find_element_by_xpath('.//td[3]').text
		Pts = tab.find_element_by_xpath('.//td[4]').text
		W = tab.find_element_by_xpath('.//td[5]').text
		L = tab.find_element_by_xpath('.//td[6]').text
		Winper = tab.find_element_by_xpath('.//td[7]').text
		FGM = tab.find_element_by_xpath('.//td[8]').text
		FGA = tab.find_element_by_xpath('.//td[9]').text
		FGper = tab.find_element_by_xpath('.//td[10]').text
		threePM = tab.find_element_by_xpath('.//td[11]').text
		threePA = tab.find_element_by_xpath('.//td[12]').text
		threePper = tab.find_element_by_xpath('.//td[13]').text	
		FTM = tab.find_element_by_xpath('.//td[14]').text
		FTA = tab.find_element_by_xpath('.//td[15]').text
		FTper = tab.find_element_by_xpath('.//td[16]').text
		OReb = tab.find_element_by_xpath('.//td[17]').text
		DReb = tab.find_element_by_xpath('.//td[18]').text
		Reb = tab.find_element_by_xpath('.//td[19]').text
		Ast = tab.find_element_by_xpath('.//td[20]').text
		TOv = tab.find_element_by_xpath('.//td[21]').text
		Stl = tab.find_element_by_xpath('.//td[22]').text
		Blk = tab.find_element_by_xpath('.//td[23]').text
		PF = tab.find_element_by_xpath('.//td[24]').text
		plusMinus = tab.find_element_by_xpath('.//td[25]').text

		tab_dict['Breakdown'] = Breakdown
		tab_dict['GP'] = GP
		tab_dict['Min'] = Min
		tab_dict['Pts'] = Pts
		tab_dict['W'] = W
		tab_dict['L'] = L
		tab_dict['Winper'] = Winper
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
		tab_dict['plusMinus'] = plusMinus
		writers.writerow(tab_dict.values())

def teamtable(lin):
	driver.get(lin[0])
	time.sleep(4)
	csv_files = open(lin[1] + '.csv', 'wb')
	global writers
	writers = csv.writer(csv_files)
	writers.writerow(['BREAKDOWN', 'GP', 'MIN', 'PTS', 'W', 'L', 'WIN%', 'FGM', 'FGA', 'FG%', '3PM', '3PA', '3P%', 'FTM', \
					  'FTA', 'FT%', 'OREB', 'DREB', 'REB', 'AST', 'TOV', 'STL', 'BLK', 'PF', '+/-'])
	for i in range(6):
		tabl= driver.find_elements_by_xpath('/html/body/main/div[2]/div/div/div[3]/div/div/div/nba-stat-table[' \
									   		+ str(i + 1) + ']/div[1]/div[1]/table/tbody/tr')
		teamstats(tabl)
	csv_files.close()

def oppstats(tabs):
	for tab in tabs:
		tab_dict = collections.OrderedDict()

		Breakdown = tab.find_element_by_xpath('.//td[1]').text
		OppFGM = tab.find_element_by_xpath('.//td[7]').text
		OppFGA = tab.find_element_by_xpath('.//td[8]').text
		OppFGper = tab.find_element_by_xpath('.//td[9]').text
		OppthreePM = tab.find_element_by_xpath('.//td[10]').text
		OppthreePA = tab.find_element_by_xpath('.//td[11]').text
		OppthreePper = tab.find_element_by_xpath('.//td[12]').text	
		OppFTM = tab.find_element_by_xpath('.//td[13]').text
		OppFTA = tab.find_element_by_xpath('.//td[14]').text
		OppFTper = tab.find_element_by_xpath('.//td[15]').text
		OppOReb = tab.find_element_by_xpath('.//td[16]').text
		OppDReb = tab.find_element_by_xpath('.//td[17]').text
		OppReb = tab.find_element_by_xpath('.//td[18]').text
		OppAst = tab.find_element_by_xpath('.//td[19]').text
		OppTOv = tab.find_element_by_xpath('.//td[20]').text
		OppStl = tab.find_element_by_xpath('.//td[21]').text
		OppBlk = tab.find_element_by_xpath('.//td[22]').text
		OppBlkA = tab.find_element_by_xpath('.//td[23]').text
		OppPF = tab.find_element_by_xpath('.//td[24]').text
		OppPts = tab.find_element_by_xpath('.//td[26]').text
		
		tab_dict['Breakdown'] = Breakdown
		tab_dict['OppFGM'] = OppFGM
		tab_dict['OppFGA'] = OppFGA
		tab_dict['OppFGper'] = OppFGper
		tab_dict['OppthreePM'] = OppthreePM
		tab_dict['OppthreePA'] = OppthreePA
		tab_dict['OppthreePper'] = OppthreePper
		tab_dict['OppFTM'] = OppFTM
		tab_dict['OppFTA'] = OppFTA
		tab_dict['OppFTper'] = OppFTper
		tab_dict['OppOReb'] = OppOReb
		tab_dict['OppDReb'] = OppDReb
		tab_dict['OppReb'] = OppReb
		tab_dict['OppAst'] = OppAst
		tab_dict['OppTOv'] = OppTOv
		tab_dict['OppStl'] = OppStl
		tab_dict['OppBlk'] = OppBlk
		tab_dict['OppBlkA'] = OppBlkA
		tab_dict['OppPF'] = OppPF
		tab_dict['OppPts'] = OppPts
		writerss.writerow(tab_dict.values())

def opptable(lin):
	driver.get(lin[0].replace('traditional', 'opponent'))
	time.sleep(4)
	csv_files = open(lin[1] + 'Opp.csv', 'wb')
	global writerss
	writerss = csv.writer(csv_files)
	writerss.writerow(['BREAKDOWN', 'OPP FGM', 'OPP FGA', 'OPP FG%', 'OPP 3PM', 'OPP 3PA', 'OPP 3P%', \
					  'OPP FTM', 'OPP FTA', 'OPP FT%', 'OPP OREB', 'OPP DREB', 'OPP REB', 'OPP AST', \
					  'OPP TOV', 'OPP STL', 'OPP BLK', 'OPP BLKA', 'OPP PF', 'OPP PTS'])
	for i in range(6):
		tabl= driver.find_elements_by_xpath('/html/body/main/div[2]/div/div/div[3]/div/div/div/nba-stat-table[' \
									   		+ str(i + 1) + ']/div[1]/div[1]/table/tbody/tr')
		oppstats(tabl)
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
						'FTM', 'FTA', 'FT%', 'OREB', 'DREB', 'REB', 'AST', 'STL', 'BLK', 'TOV', 'PF'])
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
		writersss.writerow(tab_dict.values())
	csv_files.close()

for i in links:
 	opptable(i)
	teamtable(i)
	gamelogtable(i)

driver.close()
























