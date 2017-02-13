import re
from bs4 import BeautifulSoup
from scrapy import Spider
from scrapy import Selector
from scrapy import Request
from score.items import ScoreItem

class ScoreSpider(Spider):
    name = "score_spider"
    allowed_urls = ["http://www.j-archive.com/"]
    start_urls = ["http://www.j-archive.com/showgame.php?game_id=1"]

    def parse(self, response):
        page_urls = ["http://www.j-archive.com/showgame.php?game_id=" + str(x) for x in range(1, 5518)]
        for page_url in page_urls:
            yield Request(page_url, callback=self.parse_game)

    def parse_game(self, response):
        Show = re.split(" - ", response.xpath('//*/h1/text()').extract()[0])
        Episode = Show[0]
        Date = re.split(" ", Show[1])[1] + re.split(" ", Show[1])[2] + re.split(" ", Show[1])[3]
        contestants = response.xpath('//*/p[@class="contestants"]/a[1]/text()').extract()
        scores1 = response.xpath('//*[@id="jeopardy_round"]/table[3]/tr[2]/td').extract()
        scores2 = response.xpath('//*[@id="double_jeopardy_round"]/table[2]/tr[2]/td').extract()
        try:
            if "Tiebreaker Round" in response.xpath('//*[@id="final_jeopardy_round"]/h2/text()').extract()[0]:
                scores3 = response.xpath('//*[@id="final_jeopardy_round"]/table[3]/tr[2]/td').extract()
            else:
                scores3 = response.xpath('//*[@id="final_jeopardy_round"]/table[2]/tr[2]/td').extract()
        except:
            scores3 = response.xpath('//*[@id="final_jeopardy_round"]/table[2]/tr[2]/td').extract()
        try:
            comment = response.xpath('//*/div[@id="game_comments"]/text()').extract()[0]
        except:
            comment = "Regular Play"
        try:
            final = response.xpath('//*[@id="final_jeopardy_round"]/table[1]').extract()
            result = BeautifulSoup(final[0]).div.get('onmouseover')
            right_final = BeautifulSoup(result).find_all('td', {'class': 'right'})
        except:
            right_final = []

        for j in range(0, len(contestants)):
            Contestant = contestants[len(contestants)-1-j]
            FinalCorrect = "No"
            try:
                ScoreFirst = BeautifulSoup(scores1[j]).find('td').get_text()
            except:
                ScoreFirst = "Not available"
            try:
                ScoreSecond = BeautifulSoup(scores2[j]).find('td').get_text()
            except:
                ScoreSecond = "Not available"
            try:
                Final = BeautifulSoup(scores3[j]).find('td').get_text()
                for i in range(0, len(right_final)):
                    if right_final[i].get_text() in re.split(" ", contestants[len(contestants)- 1 - j]):
                        FinalCorrect = "Yes"
                        break
            except:
                Final = "Not available"
                FinalCorrect = "Not available"
            try:
                FinalCat = BeautifulSoup(final[0]).find('td', {'class': 'category_name'}).get_text()
                FinalQ = BeautifulSoup(final[0]).find('td', {'class': 'clue_text'}).get_text()
                FinalA = BeautifulSoup(result).find('em').get_text()
            except:
                FinalCat = "Not available"
                FinalQ = "Not available"
                FinalA = "Not available"
            #Assign data to Item
            item = ScoreItem()
            item['Contestant'] = Contestant
            item['Date'] = Date
            item['Comment'] = comment
            item['Episode'] = Episode
            item['ScoreFirst'] = ScoreFirst.replace('$','').replace(',','')
            item['ScoreSecond'] = ScoreSecond.replace('$','').replace(',','')
            item['Final'] = Final.replace('$','').replace(',','')
            item['FinalCorrect'] = FinalCorrect
            item['FinalCat'] = FinalCat
            item['FinalQ'] = FinalQ
            item['FinalA'] = FinalA

            yield item
