# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy

class GooglePlaySpiderItem(scrapy.Item):
     category=scrapy.Field()
     name = scrapy.Field()
     review = scrapy.Field()
     date = scrapy.Field()
     rating=scrapy.Field()
     app=scrapy.Field()
     brand=scrapy.Field()
     tp=scrapy.Field()