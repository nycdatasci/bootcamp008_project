# -*- coding: utf-8 -*-
import scrapy
from scrapy import Spider
from scrapy.contrib.spiders import CrawlSpider,Rule
from scrapy.contrib.linkextractors import LinkExtractor
from atlab.items import AtlabItem
import re

class FirstSpider(scrapy.Spider):
    name = "first"
    allowed_domains = ["www.atlabshoponline.com"]
    start_urls = [
        'http://www.atlabshoponline.com/primary?limit=100',
        'http://www.atlabshoponline.com/kindergarten?limit=100',
        'http://www.atlabshoponline.com/middle-high-school?limit=100',
        'http://www.atlabshoponline.com/high-school-university?limit=100','http://www.atlabshoponline.com/university?limit=100',
    ]
   # Rule = [
   # 	Rule(LinkExtractor(allow=['/high-school-university/\?limit=\d*']),
   # 		callback='parse_item',
   # 		follow = True)
   # 	]

    def parse(self, response):

    	# item = AtlabItem()
    	# item['name'] = response.xpath('//div[@class="product-list"]/a/text()').extract_first()
		

        # yield item
        for el in response.xpath('//div[@class="product-info"]//div[@class="description"]/a/text()').extract():
        	yield {
				'product_age_group': el

				}