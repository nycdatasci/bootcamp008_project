import re
from bs4 import BeautifulSoup
from scrapy import Spider
from scrapy import Selector
from scrapy import Request
from jeopardy.items import JeopardyItem

class JeopardySpider(Spider):
    name = "jeopardy_spider"
    allowed_urls = ["http://www.j-archive.com/"]
    start_urls = ["http://www.j-archive.com/showgame.php?game_id=1"]


    def parse(self, response):
        page_urls = ["http://www.j-archive.com/showgame.php?game_id=" + str(x) for x in range(1, 5518)]
        for page_url in page_urls:
            yield Request(page_url, callback=self.parse_game)


    def parse_game(self, response):
        #Step 1--Compile single line of one-off show-level data
        Show = re.split(" - ", response.xpath('//*/h1/text()').extract()[0])
        Episode = Show[0]
        Date = Show[1]
        contestants = response.xpath('//*/p[@class="contestants"]/a[1]/text()').extract()
        first_round = response.xpath('//*[@id="jeopardy_round"]').extract()[0]
        table1 = BeautifulSoup(first_round)
        jquestions = table1.find_all('td', {'class': 'clue'})

        second_round = response.xpath('//*[@id="double_jeopardy_round"]').extract()[0]
        table2 = BeautifulSoup(second_round)
        dquestions = table2.find_all('td', {'class': 'clue'})

        Rounds = [first_round, second_round]
        BSRounds = [jquestions, dquestions]

        for j in range(0, len(Rounds)):
            BaseValue = int(Selector(text=Rounds[j]).xpath('//*/table[1]//*/table/tr[1]/td/div/table/tr/td[2]/text()').extract()[0].replace('$', "").replace(',',""))
            for i in range(0,30):
                Round = Selector(text=Rounds[j]).xpath('//*/h2/text()').extract()[0]
                Category = Selector(text=Rounds[j]).xpath('//*/table[1]/tr[1]/*/table/tr[1]//*/text()').extract()[i%6]
                Value = BaseValue * (1 + i/6)
                try:
                    Clue = BSRounds[j][i].find('td', {'class': 'clue_text'}).get_text()
                except:
                    Clue = "Not asked"
                try:
                    Answer = BeautifulSoup(BSRounds[j][i].div.get('onmouseover')).find('em', {'class':'correct_response'}).get_text()
                except:
                    Answer = "Not asked"
                try:
                    Order = BSRounds[j][i].find('td', {'class': 'clue_order_number'}).get_text()
                except:
                    Order = "Not asked"
                try:
                    DailyDouble = re.split(" ", BSRounds[j][i].find('td', {'class': 'clue_value_daily_double'}).get_text())[1]
                except:
                    DailyDouble = "NA"
                try:
                    Right = BeautifulSoup(BSRounds[j][i].div.get('onmouseover')).find('td', {'class':'right'}).get_text()
                    for k in range(0, len(contestants)):
                        if Right in re.split(" ", contestants[k]):
                            Right = contestants[k]
                except:
                    Right = "No answer"
                try:
                    Wrong1 = BeautifulSoup(BSRounds[j][i].div.get('onmouseover')).find('td', {'class':'wrong'}).get_text()
                    for k in range(0, len(contestants)):
                        if Wrong1 in re.split(" ", contestants[k]):
                            Wrong1 = contestants[k]
                except:
                    Wrong1 = "NA"
                try:
                    Wrong2 = BeautifulSoup(BSRounds[j][i].div.get('onmouseover')).find_all('td', {'class':'wrong'})[1].get_text()
                    for k in range(0, len(contestants)):
                        if Wrong2 in re.split(" ", contestants[k]):
                            Wrong2 = contestants[k]
                except:
                    Wrong2 = "NA"
                try:
                    Wrong3 = BeautifulSoup(BSRounds[j][i].div.get('onmouseover')).find_all('td', {'class':'wrong'})[2].get_text()
                    for k in range(0, len(contestants)):
                        if Wrong3 in re.split(" ", contestants[k]):
                            Wrong3 = contestants[k]
                except:
                    Wrong3 = "NA"
                try:
                    Wrong4 = BeautifulSoup(BSRounds[j][i].div.get('onmouseover')).find_all('td', {'class':'wrong'})[3].get_text()
                except:
                    Wrong4 = "NA"

                #Assign data to Item
                item = JeopardyItem()
                item['Episode'] = Episode
                item['Date'] = Date
                item['Round'] = Round
                item['Category'] = Category
                item['Value'] = Value
                item['Clue'] = Clue
                item['Answer'] = Answer
                item['Order'] = Order
                item['DailyDouble'] = DailyDouble.replace('$','').replace(',','')
                item['Right'] = Right
                item['Wrong1'] = Wrong1
                item['Wrong2'] = Wrong2
                item['Wrong3'] = Wrong3
                item['Wrong4'] = Wrong4

                yield item
