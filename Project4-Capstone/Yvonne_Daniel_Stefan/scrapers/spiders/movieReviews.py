import scrapy
from scrapy.selector import Selector
from scraping.items import ReviewItem
import logging
import sqlite3 as lite
import re

class MovieReviewsSpider(scrapy.Spider):
    name = "moviereviewsspider"
    allowed_domains = ["metacritic.com"]

    custom_settings = {
        'ITEM_PIPELINES': {
            'scraping.pipelines.WriteItemPipelineReview': 100
        }
    }

    con = lite.connect(r'D:\capstone-v2.db')
    cur = con.cursor()
    #cur.execute('SELECT DISTINCT m.link FROM tblMovie m LEFT JOIN tblReview r ON m.ROWID = r.movieID WHERE r.movieID IS NULL;') #only for movies where no critic reviews are present
    #rows = cur.fetchall()
    start_urls = []
    #[start_urls.append('http://www.metacritic.com' + row[0] + '/critic-reviews') for row in rows]
    # [start_urls.append('http://www.metacritic.com' + row[0] + '/user-reviews') for row in rows]

    #cur.execute('SELECT m.link FROM tblMovie m LEFT JOIN tblMovieTmp mt ON m.ROWID = mt.movieID WHERE mt.movieID IS NULL;')  # no user reviews so far, so get them all
    #strSQL = 'SELECT m.link FROM tblMovie m LEFT JOIN tblMovieTmp mt ON m.ROWID = mt.movieID WHERE mt.movieID IS NULL;'
    strSQL = ''
    cur.execute(strSQL)
    rows = cur.fetchall()
    [start_urls.append('http://www.metacritic.com' + row[0] + '/user-reviews') for row in rows]
    # start_urls = [
    #     'http://www.metacritic.com/movie/moonlight-2016/critic-reviews',
    #     'http://www.metacritic.com/movie/moonlight-2016/user-reviews'
    # ]

    def lastPageNumber(self, response):
        try:
            lastPageNumber = int(response.xpath('//li[@class="page last_page"]/a/text()').extract()[0])
            return lastPageNumber
        except:
            logging.log(logging.DEBUG, 'Some error on page', response.url)
            return 0

    def parse(self, response):
        item = ReviewItem()
        link = response.url.replace('http://www.metacritic.com', '').replace('/critic-reviews', '').replace('/user-reviews', '')

        con = lite.connect(r'D:\capstone.db')
        cur = con.cursor()

        cur.execute("SELECT ROWID FROM tblMovie WHERE link = '" + link + "'")
        movieID = cur.fetchone()[0]

        if response.url.find('/critic-reviews') > 0:
            for element in response.xpath('//div[@class="critic_reviews"]/div').extract():
                try:
                    item['publication'] = Selector(text=element).xpath('//span[@class="source"]/a/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Publication not found: ' + link)
                    item['publication'] = ''

                try:
                    item['author'] = Selector(text=element).xpath('//span[@class="author"]/a/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Author not found: ' + link)
                    item['author'] = ''

                try:
                    item['score'] = Selector(text=element).xpath('//div[@class="review pad_top1 pad_btm1"]/div[@class="left fl"]/div/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Score not found: ' + link)
                    item['score'] = ''

                try:
                    item['text'] = Selector(text=element).xpath('//div[@class="summary"]/a/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Text not found: ' + link)
                    item['text'] = ''

                try:
                    item['date'] = Selector(text=element).xpath('//span[@class="date"]/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Date not found: ' + link)
                    item['date'] = ''

                item['link'] = link
                item['movieID'] = movieID

                item['gameID'] = -1
                item['tvShowID'] = -1

                item['thumbsUp'] = 0
                item['thumbsDown'] = 0
                item['reviewType'] = 'c'

                yield item
        elif response.url.find('/user-reviews') > 0:
            for element in response.xpath('//div[@class="user_reviews"]/div').extract():
                try:
                    item['author'] = Selector(text=element).xpath('//span[@class="author"]/a/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Author not found: ' + link)
                    item['author'] = ''

                try:
                    item['score'] = Selector(text=element).xpath('//div[@class="review pad_top1"]/div[@class="left fl"]/div/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Score not found: ' + link)
                    item['score'] = ''

                try:
                    # long review
                    item['text'] = Selector(text=element).xpath('//span[@class="blurb blurb_expanded"]/text()').extract()[0].encode('utf-8').strip()
                except:
                    try:
                        # short review
                        item['text'] = Selector(text=element).xpath('//div[@class="review_body"]/span/text()').extract()[0].encode('utf-8').strip()
                    except:
                        logging.error('Text not found: ' + link)
                        item['text'] = ''

                try:
                    item['date'] = Selector(text=element).xpath('//span[@class="date"]/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Date not found: ' + link)
                    item['date'] = ''

                try:
                    item['thumbsUp'] = int(Selector(text=element).xpath('//span[@class="thumb_up"]/span[@class="count"]/text()').extract()[0].encode('utf-8').strip())
                except:
                    logging.error('Thumbs Up not found: ' + link)
                    item['thumbsUp'] = 0

                try:
                    item['thumbsDown'] = int(Selector(text=element).xpath('//span[@class="thumb_down"]/span[@class="count"]/text()').extract()[0].encode('utf-8').strip())
                except:
                    logging.error('Thumbs Down not found: ' + link)
                    item['thumbsDown'] = 0

                item['link'] = link
                item['movieID'] = movieID

                item['gameID'] = -1
                item['tvShowID'] = -1

                item['publication'] = ''
                item['reviewType'] = 'u'
                yield item