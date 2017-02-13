# -*- coding: utf-8 -*-
import scrapy
from tamingnews.items import TamingnewsItem
from scrapy.http import Request
import urlparse
import datetime
import socket


class CnnbasicSpider(scrapy.Spider):
    name = "cnnbasic"
    #allowed_domains = ["http://www.cnn.com/services/rss/"]
    start_urls = (
        'http://edition.cnn.com/services/rss/',
    )

    def parse(self, response):
        item_selector = response.xpath('//*[contains(concat( " ", @class, " " ), '
                                       'concat( " ", "cnnRSS", " " ))]//a/@href')
        for url in item_selector.extract():
            yield Request(urlparse.urljoin(response.url, str(url)), callback=self.parse_page2,
                          meta={'page1': url})


    def parse_page2(self, response):
        item_selector = response.xpath('//guid/text()')
        page1 = response.meta['page1']
        for url in item_selector.extract():
            yield Request(urlparse.urljoin(response.url, str(url)), callback = self.parse_page3,
                          meta={'page1': page1, 'page2': url})

    def parse_page3(self, response):
        item = TamingnewsItem()

        title=response.xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "pg-headline", " " ))]/text()')
        title = ''.join(title.extract())

        article = ''.join(response.xpath('//*[contains(concat( " ", @class, " " ), concat( " ", '
                                         '"zn-body__paragraph", " " ))]/text()').extract())

        pTimestamp = ''.join(response.xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "update-time", '
                                            '" " ))]/text()').extract())

        if title == '':
            title = response.xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "article-title", " " ))]/text()')
            title = ''.join(title.extract())

            article = ''.join(response.xpath('//*[(@id = "storytext")]//p | //h2/text()').extract())

            pTimestamp = ''.join(response.xpath('//*[contains(concat( " ", @class, " " ), '
                                                'concat( " ", "byline-timestamp", " " ))]//*'
                                                '[contains(concat( " ", @class, " " ), '
                                                'concat( " ", "cnnDateStamp", " " ))]/text()').extract())

        item['page1'] = response.meta['page1']
        item['page2'] = response.meta['page2']
        item['page3'] = socket.gethostname()

        item['category'] = 'category'
        item['title'] = title
        item['article'] = article
        item['pTimestamp'] = pTimestamp

        item['scrape_time'] = datetime.datetime.now()
        item['spider'] = self.name

        return item


