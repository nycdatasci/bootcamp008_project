# -*- coding: utf-8 -*-
import scrapy
from scrapy import Spider
from scrapy.selector import Selector
from scrapy.contrib.spiders import CrawlSpider,Rule
from scrapy.contrib.linkextractors import LinkExtractor
from atlab.items import AtlabItem
import re

class FirstSpider(scrapy.Spider):
    name = "first"
    allowed_domains = ["https://www.slashgear.com"]
    start_urls = [
        'https://www.slashgear.com/lego-mindstorms-ev3-review-03327308/',
        
    ]
    def parse(self, response):
        # follow links to author pages
        text =  response.xpath('//p/text()').extract()
        
        
        yield {
        	'slashgear_Comments' : text
        	}



   # def parse_age(self, response):
    #	txt = response.xpath('//[@class="postlist restrain"]//blockquote[@class="postcontent restore"]/text()').extract()[0]
    #	print txt
    	
    	