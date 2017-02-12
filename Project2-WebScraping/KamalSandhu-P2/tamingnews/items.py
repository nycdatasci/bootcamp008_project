# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy
from scrapy.item import Item, Field


class TamingnewsItem(Item):
    # define the fields for your item here like:
    page1 = Field()
    page2 = Field()
    page3 = Field()

    category = Field()
    title = Field()
    article = Field()
    pTimestamp = Field()

    scrape_time = Field()
    spider = Field()