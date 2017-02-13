import re
from bs4 import BeautifulSoup
from requests import session

def main():
	r = session()
	pcount = 1
	request_path = "http://www.umdmusic.com/default.asp?Lang=English&Chart=D"
	data = "billboard100.csv"
	
	with open(data, 'a') as f:
		f.write("Pos.This.Week|")
		f.write("Pos.Last.Week|")
		f.write("Total.Weeks|")
		f.write("Title|")
		f.write("Artist|")
		f.write("Entry.Date|")
		f.write("Pos.Entry|")
		f.write("Overall.Peak.Pos|")
		f.write("Overall.Total.Weeks|")
		f.write("Chart.Date" + "\n")
		
		while True:
			print("Scraping data from " + request_path)
			page = r.get(request_path).content
			soup = BeautifulSoup(page, "html5lib")
			previous_link = soup.find_all(href=re.compile("ChDate=\d+&ChMode=P"))
			pcount = pcount + 1
			if pcount < 1550:
				request_path = previous_link[0]['href']
				request_path = "http://www.umdmusic.com/" + request_path
				m = re.match(".*ChDate=(\d+).*", request_path)
				chartDate = m.group(1)
			else:
				break
				
			main_table = soup.find_all(text = re.compile("Display Chart Table"))[0]
			while main_table.name != "table":
				main_table = main_table.next_element
			for row in main_table.tbody.children:
				if row.name == "tr":
					firstCellPass = False
					for cell in row.children:
						if cell.name == "td":
							if len(cell.contents) == 1:
								f.write(cell.string.strip() + "|")
								firstCellPass = True
							elif len(cell.contents) == 3:
								if not firstCellPass:
									break
								f.write(cell.contents[0].string.encode('utf-8').strip() + "|")
								f.write(cell.contents[2].string.encode('utf-8').strip() + "|")
								print cell.contents[2]
					if firstCellPass:
						f.write(chartDate + "\n")
						
if __name__ == "__main__":
	main()