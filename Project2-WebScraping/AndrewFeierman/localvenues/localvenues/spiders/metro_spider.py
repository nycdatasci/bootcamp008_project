# -*- coding: utf-8 -*-
import scrapy
from scrapy import Spider, Request
from scrapy.selector import Selector
from localvenues.items import LocalvenuesItem

class SongkickSpider(scrapy.Spider):
    name = "metro_spider"
    allowed_domains = ["www.songkick.com"]
    start_urls = ['https://www.songkick.com/metro_areas/7644-us-new-york',
                  'https://www.songkick.com/metro_areas/17835-us-los-angeles',
                  'https://www.songkick.com/metro_areas/9426-us-chicago',
                  'https://www.songkick.com/metro_areas/35129-us-dallas-fort-worth',
                  'https://www.songkick.com/metro_areas/15073-us-houston',
                  'https://www.songkick.com/metro_areas/1409-us-washington',
                  'https://www.songkick.com/metro_areas/5202-us-philadelphia',
                  'https://www.songkick.com/metro_areas/4120-us-atlanta',
                  'https://www.songkick.com/metro_areas/9776-us-miami',
                  'https://www.songkick.com/metro_areas/18842-us-boston-cambridge',
                  'https://www.songkick.com/metro_areas/11104-us-nashville'
                    ]

    def parse(self, response):
        concert = response.xpath('//*[@id="event-listings"]/ul/li[@title]').extract() 

        print("START OF PAGE")
        print(response.url )
        print(len(concert))
        
        
        for show in range(len(concert)):
            try:
                venue = Selector(text=concert[show]).xpath('//p/span/a/text()').extract()[0]
                date = Selector(text=concert[show]).xpath('//time').extract()[0]
                if (show == 0 and 'page' not in response.url):
                    print("SHOW IS ZERO")
                    artist = Selector(text=concert[show]).xpath('//p[1]/a/strong/text()').extract()[0]
                else:
                    print("SHOW IS %s") % (show)
                    artist = Selector(text=concert[show]).xpath('//p[1]/a/span/strong/text()').extract()[0]
            except IndexError:
                pass
            else:

                item = LocalvenuesItem()
                item['venue'] = venue
                item['artist'] = artist
                item['date'] = date
                item['url'] = response.url

                yield item

        next_page = response.css('a.next_page::attr(href)').extract_first()
        
        if next_page is not None:
            next_page = response.urljoin(next_page)
            yield scrapy.Request(next_page, callback=self.parse)