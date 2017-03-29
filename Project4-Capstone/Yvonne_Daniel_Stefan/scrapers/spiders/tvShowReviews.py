import scrapy
from scrapy.selector import Selector
from scraping.items import ReviewItem
import logging
import sqlite3 as lite
import re

class TVShowReviewsSpider(scrapy.Spider):
    name = "tvshowreviewsspider"
    allowed_domains = ["metacritic.com"]

    custom_settings = {
        'ITEM_PIPELINES': {
            'scraping.pipelines.WriteItemPipelineTVShowReview': 100
        }
    }

    con = lite.connect(r'D:\capstone-tvshows.db')
    cur = con.cursor()
    cur.execute('SELECT DISTINCT tvs.link FROM tblTVShow tvs LEFT JOIN tblReview r ON tvs.ROWID = r.tvShowID WHERE r.tvShowID IS NULL;') #only for movies where no critic reviews are present
    rows = cur.fetchall()
    start_urls = []
    [start_urls.append('http://www.metacritic.com' + row[0] + '/critic-reviews') for row in rows]
    [start_urls.append('http://www.metacritic.com' + row[0] + '/user-reviews') for row in rows]

    # cur.execute('SELECT DISTINCT g.link FROM tblGame g;')  # no user reviews so far, so get them all
    # [start_urls.append('http://www.metacritic.com' + row[0] + '/user-reviews') for row in cur.fetchall()]
    # start_urls = [
    #     'http://www.metacritic.com/tv/friends/critic-reviews',
    #     'http://www.metacritic.com/tv/friends/user-reviews'
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
        cur.execute("SELECT ROWID FROM tblTVShow WHERE link LIKE '" + link + "/%' OR link = '" + link + "'")
        tvShowID = cur.fetchone()[0]

        if response.url.find('/critic-reviews') > 0:
            for element in response.xpath('//ol[@class="reviews critic_reviews"]/li').extract():
                try:
                    # Link to publication
                    item['publication'] = Selector(text=element).xpath('//div[@class="source"]/a/text()').extract()[0].encode('utf-8').strip()
                except:
                    try:
                        # No link to publication
                        item['publication'] = Selector(text=element).xpath('//div[@class="source"]/text()').extract()[0].encode('utf-8').strip()
                    except:
                        logging.error('Publication not found: ' + link)
                        item['publication'] = ''

                try:
                    # with link
                    item['author'] = Selector(text=element).xpath('//div[@class="author"]/a/text()').extract()[0].encode('utf-8').strip()
                except:
                        try:
                            # w/o link
                            item['author'] = Selector(text=element).xpath('//div[@class="author"]/text()').extract()[0].encode('utf-8').strip()
                        except:
                                try:
                                    # not bold
                                    item['author'] = Selector(text=element).xpath('//div[@class="author"]/span[@class="no_link"]/text()').extract()[0].encode('utf-8').strip()
                                except:
                                    logging.error('Author not found: ' + link)
                                    item['author'] = ''

                try:
                    item['score'] = Selector(text=element).xpath('//div[@class="review_grade has_author"]/div/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Score not found: ' + link)
                    item['score'] = ''

                try:
                    item['text'] = Selector(text=element).xpath('//div[@class="review_body"]/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Text not found: ' + link)
                    item['text'] = ''

                try:
                    item['date'] = Selector(text=element).xpath('//div[@class="date"]/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Date not found: ' + link)
                    item['date'] = ''

                item['link'] = link
                item['tvShowID'] = tvShowID

                item['gameID'] = -1
                item['movieID'] = -1

                item['thumbsUp'] = 0
                item['thumbsDown'] = 0
                item['reviewType'] = 'c'

                yield item
        elif response.url.find('/user-reviews') > 0:
            for element in response.xpath('//ol[@class="reviews user_reviews"]/li').extract():
                try:
                    item['author'] = Selector(text=element).xpath('//div[@class="name"]/a/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Author not found: ' + link)
                    item['author'] = ''

                try:
                    item['score'] = Selector(text=element).xpath('//div[@class="review_grade"]/div/text()').extract()[0].encode('utf-8').strip()
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
                    item['date'] = Selector(text=element).xpath('//div[@class="date"]/text()').extract()[0].encode('utf-8').strip()
                except:
                    logging.error('Date not found: ' + link)
                    item['date'] = ''

                try:
                    item['thumbsUp'] = int(Selector(text=element).xpath('//span[@class="total_ups"]/text()').extract()[0].encode('utf-8').strip())
                except:
                    logging.error('Thumbs Up not found: ' + link)
                    item['thumbsUp'] = 0

                try:
                    # This is actually the total amount of thumbs, therefore subtract thumbs up
                    item['thumbsDown'] = int(Selector(text=element).xpath('//span[@class="total_thumbs"]/text()').extract()[0].encode('utf-8').strip())
                    item['thumbsDown'] -= item['thumbsUp']
                except:
                    logging.error('Thumbs Down not found: ' + link)
                    item['thumbsDown'] = 0

                item['link'] = link
                item['tvShowID'] = tvShowID

                item['gameID'] = -1
                item['movieID'] = -1


                item['publication'] = ''
                item['reviewType'] = 'u'
                yield item