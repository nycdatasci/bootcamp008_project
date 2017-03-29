import scrapy
from scraping.items import MovieDetailsItem
import logging
import sqlite3 as lite

class GameDetailsSpider(scrapy.Spider):
    name = "moviedetailsspider"
    allowed_domains = ["metacritic.com"]

    con = lite.connect(r'D:\capstone.db')
    cur = con.cursor()
    cur.execute('SELECT link FROM tblMovie WHERE genre IS NULL')
    start_urls = []
    [start_urls.append('http://www.metacritic.com' + row[0]) for row in cur.fetchall()]
    # start_urls = ['http://www.metacritic.com/movie/moonlight-2016']

    custom_settings = {
        'ITEM_PIPELINES' : {
            'scraping.pipelines.WriteItemPipelineMovieDetails': 100
        }
    }

    def parse(self, response):
        item = MovieDetailsItem()
        link = response.url

        try:
            item['image'] = response.xpath('//div[@class="summary_left fl inset_right2"]/img/@src').extract()[0].encode('utf-8').strip()
        except:
            logging.error('Image not found: ' + link)
            item['image'] = ''

        try:
            item['director'] = response.xpath('//div[@class="director"]/a/span/text()').extract()[0].encode('utf-8').strip()
        except:
            logging.error('Director not found: ' + link)
            item['director'] = ''

        try:
            item['genre'] = response.xpath('//div[@class="genres"]/span/span/text()').extract()[0].encode('utf-8').strip()
        except:
            logging.error('Genre not found: ' + link)
            item['genre'] = ''

        try:
            item['rlsDate'] = response.xpath('//span[@class="release_date"]/span[2]/text()').extract()[0].encode('utf-8').strip()
        except:
            logging.error('Release date not found: ' + link)
            item['rlsDate'] = ''

        try:
            item['rating'] = response.xpath('//div[@class="rating"]/span[2]/text()').extract()[0].encode('utf-8').strip()
        except:
            logging.error('Rating not found: ' + link)
            item['rating'] = ''

        try:
            item['summary'] = response.xpath('//div[@class="summary_deck details_section"]/span[2]/span/text()').extract()[0].encode('utf-8').strip()
        except:
            logging.debug('Summary not found: ' + link)
            item['summary'] = ''

        try:
            item['runtime'] = response.xpath('//div[@class="runtime"]/span[2]/text()').extract()[0].encode('utf-8').strip()
        except:
            logging.debug('Runtime not found: ' + link)
            item['runtime'] = 0

        item['link'] = link

        yield item