# -*- coding: utf-8 -*-
import scrapy
from scrapy import Spider
from scrapy.selector import Selector
from localvenues.items import LocalvenuesItem

class SongkickSpider(scrapy.Spider):
    name = "venue_spider"
    allowed_domains = ["www.songkick.com"]
    start_urls = ['https://www.songkick.com/venues/1656338-barclays-center/calendar']

    def parse(self, response):
        concert = response.xpath('//*[@id="event-listings"]/ul/li[@title]').extract() 
        
        for show in range(len(concert)):
            artist = Selector(text=concert[show]).xpath('//p[1]/a/span/strong/text()').extract()[0]
            venue = Selector(text=concert[show]).xpath('//p/span/a/text()').extract()[0]
            date = Selector(text=concert[show]).xpath('//time').extract()[0]     

            item = LocalvenuesItem()
            item['venue'] = venue
            item['artist'] = artist
            item['date'] = date

            yield item

#         next_page_url = response.css("pagination.next > a::attr(href)").extract_first()
#         if next_page_url is not None:
#            yield scrapy.Request(response.urljoin(next_page_url))

