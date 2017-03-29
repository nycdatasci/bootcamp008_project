import scrapy
from scraping.items import TVShowDetailsItem
import logging
import sqlite3 as lite

class GameDetailsSpider(scrapy.Spider):
    name = "tvshowdetailsspider"
    allowed_domains = ["metacritic.com"]

    con = lite.connect(r'D:\capstone.db')
    cur = con.cursor()
    cur.execute('SELECT link FROM tblTVShow WHERE genre IS NULL')
    start_urls = []
    [start_urls.append('http://www.metacritic.com' + row[0]) for row in cur.fetchall()]
    # start_urls = ['http://www.metacritic.com/tv/friends/season-1']

    custom_settings = {
        'ITEM_PIPELINES' : {
            'scraping.pipelines.WriteItemPipelineTVShowDetails': 100
        }
    }

    def parse(self, response):
        item = TVShowDetailsItem()
        link = response.url

        try:
            item['image'] = response.xpath('//meta[@itemprop="image"]/@content').extract()[0].encode('utf-8').strip()
        except:
            logging.error('Image not found: ' + link)
            item['image'] = ''

        try:
            creators = []
            [creators.append(crea.encode('utf-8').strip()) for crea in response.xpath('//li[@class="summary_detail developer"]/span[@class="data"]/span/a/span/text()').extract()]
            item['creator'] = creators
        except:
            logging.error('Creator not found: ' + link)
            item['creator'] = ''

        try:
            item['genre'] = response.xpath('//li[@class="summary_detail product_genre"]/span[@itemprop="genre"]/text()').extract()[0].encode('utf-8').strip()
        except:
            logging.error('Genre not found: ' + link)
            item['genre'] = ''

        try:
            item['rlsDate'] = response.xpath('//li[@class="summary_detail release_data"]/span[@class="data"]/text()').extract()[0].encode('utf-8').strip()
        except:
            logging.error('Release date not found: ' + link)
            item['rlsDate'] = ''

        try:
            item['summary'] = response.xpath('//li[@class="summary_detail product_summary"]/span[@class="data"]/span/span[@class="blurb blurb_expanded"]/text()').extract()[0].encode('utf-8').strip()
        except:
            logging.debug('Summary not found: ' + link)
            item['summary'] = ''

        try:
            item['runtime'] = response.xpath('//li[@class="summary_detail product_runtime"]/span[@class="data"]/text()').extract()[0].encode('utf-8').strip()
        except:
            logging.debug('Runtime not found: ' + link)
            item['runtime'] = 0

        item['link'] = link

        yield item