import scrapy
from scraping.items import GameDetailsItem
import logging
import sqlite3 as lite

class GameDetailsSpider(scrapy.Spider):
    name = "gamedetailsspider"
    allowed_domains = ["metacritic.com"]

    con = lite.connect(r'D:\capstone-v2.db')
    cur = con.cursor()
    cur.execute('SELECT link FROM tblGame WHERE developer IS NULL')
    rows = cur.fetchall()
    start_urls = []
    [start_urls.append('http://www.metacritic.com' + row[0]) for row in rows]
    #start_urls = ['http://www.metacritic.com/game/playstation-4/grand-theft-auto-v']

    custom_settings = {
        'ITEM_PIPELINES' : {
            'scraping.pipelines.WriteItemPipelineGameDetails': 100
        }
    }

    def parse(self, response):
        item = GameDetailsItem()
        link = response.url

        try:
            item['image'] = response.xpath('//meta[@itemprop="image"]/@content').extract()[0].encode('utf-8').strip()
        except:
            logging.error('Image not found: ' + link)
            item['image'] = ''

        try:
            item['developer'] = response.xpath('//li[@class="summary_detail developer"]/span[@class="data"]/text()').extract()[0].encode('utf-8').strip()
        except:
            logging.error('Developer not found: ' + link)
            item['developer'] = ''

        try:
            item['genre'] = response.xpath('//li[@class="summary_detail product_genre"]/span[@class="data"]/text()').extract()[0].encode('utf-8').strip()
        except:
            logging.error('Genre not found: ' + link)
            item['genre'] = ''

        try:
            item['rlsDate'] = response.xpath('//li[@class="summary_detail release_data"]/span[@class="data"]/text()').extract()[0].encode('utf-8').strip()
        except:
            logging.error('Release date not found: ' + link)
            item['rlsDate'] = ''

        try:
            item['rating'] = response.xpath('//li[@class="summary_detail product_rating"]/span[@class="data"]/text()').extract()[0].encode('utf-8').strip()
        except:
            logging.error('Rating not found: ' + link)
            item['rating'] = ''

        try:
            # Long summary
            item['summary'] = response.xpath('//li[@class="summary_detail product_summary"]/span[@class="data"]/span/span[@class="blurb blurb_expanded"]/text()').extract()[0].encode('utf-8').strip()
        except:
            try:
                # Short summary
                item['summary'] = response.xpath('//li[@class="summary_detail product_summary"]/span[@class="data"]/span/text()').extract()[0].encode('utf-8').strip()
            except:
                # No summary
                logging.debug('Summary not found: ' + link)
                item['summary'] = ''

        item['link'] = link

        yield item