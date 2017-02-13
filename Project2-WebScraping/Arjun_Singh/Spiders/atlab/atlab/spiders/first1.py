# -*- coding: utf-8 -*-
import scrapy
from scrapy import Spider
from scrapy.selector import Selector
from scrapy.contrib.spiders import CrawlSpider,Rule
from scrapy.contrib.linkextractors import LinkExtractor
from atlab.items import AtlabItem
import re

class FirstSpider(scrapy.Spider):
    name = "first1"
    allowed_domains = ["www.atlabshoponline.com"]
    start_urls = [
        'http://www.atlabshoponline.com/primary?limit=100',
        'http://www.atlabshoponline.com/kindergarten?limit=100',
        'http://www.atlabshoponline.com/middle-high-school?limit=100',
        'http://www.atlabshoponline.com/high-school-university?limit=100','http://www.atlabshoponline.com/university?limit=100',
    ]
    def parse(self, response):
    	for href in response.xpath('//div[@class="product-list"]//div[@class="name"]/a/@href').extract():
    		yield {
                'url_age' : href
                }
