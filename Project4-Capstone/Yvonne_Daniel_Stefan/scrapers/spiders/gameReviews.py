import scrapy
from scrapy.selector import Selector
from scraping.items import ReviewItem
import logging
import sqlite3 as lite
import re

class GameCriticReviewsSpider(scrapy.Spider):
    name = "gamereviewsspider"
    allowed_domains = ["metacritic.com"]

    custom_settings = {
        'ITEM_PIPELINES' : {
            'scraping.pipelines.WriteItemPipelineReview': 100
        }
    }

    con = lite.connect(r'D:\capstone-v2.db')
    cur = con.cursor()
    start_urls = []
    # cur.execute('SELECT DISTINCT g.link FROM tblGame g LEFT JOIN tblReview r ON g.ROWID = r.gameID WHERE r.gameID IS NULL;') #only for games where no critic reviews are present
    # [start_urls.append('http://www.metacritic.com' + row[0] + '/critic-reviews') for row in cur.fetchall()]

    strSQL = 'SELECT g.link FROM tblGame g LEFT JOIN tblGameTmp gt ON g.ROWID = gt.gameID WHERE gt.gameID IS NULL;'
    cur.execute(strSQL)  # no user reviews for abovementioned games
    rows = cur.fetchall()
    [start_urls.append('http://www.metacritic.com' + row[0] + '/user-reviews') for row in rows]
    # start_urls = [
    #     'http://www.metacritic.com/game/playstation-4/grand-theft-auto-v/critic-reviews',
    #     'http://www.metacritic.com/game/playstation-4/grand-theft-auto-v/user-reviews'
    # ]

    def lastPageNumber(self, response):
        try:
            lastPageNumber = int(response.xpath('//li[@class="page last_page"]/a/text()').extract()[0])
            return lastPageNumber
        except:
            logging.info('Some error on page with page num nshit: ' + response.url)
            return -1

    def parse(self, response):
        if response.url.find('/critic-reviews') > 0:
            # Critics reviews only have one page
            yield scrapy.Request(response.url, callback=self.parse_listings_results_page)
        elif response.url.find('/user-reviews') > 0:
            # User reviews can have multiple pages
            last_page_number = self.lastPageNumber(response)
            logging.info('pgnum: ' + str(last_page_number))

            if last_page_number < 0:
                logging.info('wtf')
                yield scrapy.Request(response.url, callback=self.parse_listings_results_page)
            else:
                page_urls = [response.url + "?page=" + str(pageNumber) for pageNumber in range(0, last_page_number)]
                for page_url in page_urls:
                    yield scrapy.Request(page_url, callback=self.parse_listings_results_page)

    def parse_listings_results_page(self, response):
        logging.info('wtf2')

        item = ReviewItem()
        link = response.url.replace('http://www.metacritic.com', '').replace('/critic-reviews', '').replace('/user-reviews', '')
        link = re.sub("\?page=\d{1,3}", '', link)

        con = lite.connect(r'D:\capstone-v2.db')
        cur = con.cursor()

        logging.info('wtf3')

        cur.execute("SELECT ROWID FROM tblGame WHERE link = '" + link + "'")
        gameID = cur.fetchone()[0]

        if response.url.find('/critic-reviews') > 0:
            for element in response.xpath('//ol[@class="reviews critic_reviews"]/li//div[@class="review_section"]').extract():
                try:
                    # w/o link to publication
                    item['publication'] = Selector(text=element).xpath('//div/div/div[@class="review_critic"]/div[@class="source"]/text()').extract()[0].encode('utf-8').strip()
                except:
                    try:
                        # link to publication
                        item['publication'] = Selector(text=element).xpath('//div/div/div[@class="review_critic"]/div[@class="source"]/a/text()').extract()[0].encode('utf-8').strip()
                    except:
                        logging.error('Publication not found: ' + link)
                        item['publication'] = ''

                try:
                    item['score'] = Selector(text=element).xpath('//div/div/div[@class="review_grade"]/div/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Score not found: ' + link)
                    item['score'] = ''

                try:
                    item['text'] = Selector(text=element).xpath('//div/div[@class="review_body"]/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Text not found: ' + link)
                    item['text'] = ''

                try:
                    item['date'] = Selector(text=element).xpath('//div/div/div[@class="review_critic"]/div[@class="date"]/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Date not found: ' + link)
                    item['date'] = ''

                item['link'] = link
                item['gameID'] = gameID

                item['movieID'] = -1
                item['tvShowID'] = -1

                item['author'] = ''
                item['thumbsUp'] = 0
                item['thumbsDown'] = 0
                item['reviewType'] = 'c'

                yield item
        elif response.url.find('/user-reviews') > 0:
            for element in response.xpath('//ol[@class="reviews user_reviews"]/li//div[@class="review_content"]').extract():
                try:
                    item['author'] = Selector(text=element).xpath('//div/div[@class="review_section"]/div/div[@class="review_critic"]/div[@class="name"]/a/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Author not found: ' + link)
                    item['author'] = ''

                try:
                    item['score'] = Selector(text=element).xpath('//div/div[@class="review_section"]/div/div[@class="review_grade"]/div/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Score not found: ' + link)
                    item['score'] = ''

                try:
                    # long review
                    item['text'] = str(Selector(text=element).xpath('//div/div[@class="review_section"]/div[@class="review_body"]/span/span[@class="blurb blurb_expanded"]/text()').extract()).encode('utf-8').strip()
                except:
                    try:
                        # short review
                        item['text'] = str(Selector(text=element).xpath('//div/div[@class="review_section"]/div[@class="review_body"]/span/text()').extract()[0].encode('utf-8').strip())
                    except:
                        logging.error('Text not found: ' + link)
                        item['text'] = ''

                try:
                    item['date'] = Selector(text=element).xpath('//div/div[@class="review_section"]/div/div[@class="review_critic"]/div[@class="date"]/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Date not found: ' + link)
                    item['date'] = ''

                try:
                    item['thumbsUp'] = int(Selector(text=element).xpath('//div/div[@class="review_section review_actions "]//span[@class="total_ups"]/text()').extract()[0].encode('utf-8').strip())
                except:
                    logging.error('Thumbs Up not found: ' + link)
                    item['thumbsUp'] = 0

                try:
                    # This is actually the total amount of thumbs, therefore subtract thumbs up
                    item['thumbsDown'] = int(Selector(text=element).xpath('//div/div[@class="review_section review_actions "]//span[@class="total_thumbs"]/text()').extract()[0].encode('utf-8').strip())
                    item['thumbsDown'] -= item['thumbsUp']
                except:
                    logging.error('Thumbs Down not found: ' + link)
                    item['thumbsDown'] = 0

                item['link'] = link
                item['gameID'] = gameID

                item['movieID'] = -1
                item['tvShowID'] = -1

                item['publication'] = ''
                item['reviewType'] = 'u'
                yield item