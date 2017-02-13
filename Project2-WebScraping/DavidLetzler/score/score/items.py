# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class ScoreItem(scrapy.Item):
    Episode = scrapy.Field()
    Date = scrapy.Field()
    Comment = scrapy.Field()
    Contestant = scrapy.Field()
    ScoreFirst = scrapy.Field()
    ScoreSecond = scrapy.Field()
    FinalCorrect = scrapy.Field()
    Final = scrapy.Field()
    FinalCat = scrapy.Field()
    FinalQ = scrapy.Field()
    FinalA = scrapy.Field()
