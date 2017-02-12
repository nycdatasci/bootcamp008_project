# -*- coding: utf-8 -*-
import scrapy
from tamingnews.items import TamingnewsItem
from scrapy.http import Request
import urlparse
import datetime
import socket

class FoxbasicSpider(scrapy.Spider):
    name = "foxbasic"
    #allowed_domains = ["http://www.foxnews.com/about/rss/"]
    start_urls = (
        'http://www.foxnews.com/about/rss/',
    )

    def parse(self, response):
        item_selector = response.xpath("//*[contains(concat( \" \", @class, \" \" ), "
                                       "concat( \" \", \"feed_url\", \" \" ))]/@data-url")
        for url in item_selector.extract():
            yield Request(urlparse.urljoin(response.url, str(url)), callback = self.parse_page2,
                          meta={'page1': url})

    def parse_page2(self, response):
        item_selector = response.xpath('//guid/text()')
        page1 = response.meta['page1']
        for url in item_selector.extract():
            yield Request(urlparse.urljoin(response.url, str(url)), callback = self.parse_page3,
                          meta={'page1': page1, 'page2': url})

    def parse_page3(self, response):
        item = TamingnewsItem()

        title=response.xpath('///h1/text()')
        title = ''.join(title.extract())
        article = ''.join(response.xpath('//*[contains(concat( " ", @class, " " ), '
                                          'concat( " ", "article-text", " " ))]//p/text()').extract())

        pTimestamp = ''.join(response.xpath('//*[contains(concat( " ", @class, " " ), '
                                            'concat( " ", "article-info", " " ))]//time/text()').extract())
        item['page1'] = response.meta['page1']
        item['page2'] = response.meta['page2']
        item['page3'] = socket.gethostname()

        item['category'] = 'foxbasic'
        item['title'] = title
        item['article'] = article
        item['pTimestamp'] = pTimestamp

        item['scrape_time'] = datetime.datetime.now()
        item['spider'] = self.name

        return item
