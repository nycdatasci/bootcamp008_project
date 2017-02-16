# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy

class JeopardyItem(scrapy.Item):

    Episode = scrapy.Field()
    Date = scrapy.Field()
    Round = scrapy.Field()
    Category = scrapy.Field()
    Value = scrapy.Field()
    Clue = scrapy.Field()
    Answer = scrapy.Field()
    Order = scrapy.Field()
    Right = scrapy.Field()
    Wrong1 = scrapy.Field()
    Wrong2 = scrapy.Field()
    Wrong3= scrapy.Field()
    Wrong4=scrapy.Field()
    DailyDouble = scrapy.Field()
