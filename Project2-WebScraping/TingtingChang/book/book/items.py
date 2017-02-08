# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class BookItem(scrapy.Item):
    
  review_title = scrapy.Field()
  review_author = scrapy.Field()
  review_date = scrapy.Field()
  review_text = scrapy.Field()
  url = scrapy.Field()
