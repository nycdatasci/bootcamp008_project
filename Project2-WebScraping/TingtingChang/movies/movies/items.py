# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class MoviesItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
   
  # movie_rank = scrapy.Field()
  # movie_rating = scrapy.Field()
  # movie_title = scrapy.Field()
  # movie_href = scrapy.Field()
  # count_reviews = scrapy.Field()


  # year = scrapy.Field()
  # review_title = scrapy.Field()
  # review_author = scrapy.Field()
  # review_date = scrapy.Field()
  # review_text = scrapy.Field()
  # url = scrapy.Field()

  critic_name = scrapy.Field()
  source_name = scrapy.Field()

  review_date = scrapy.Field()
  review_detail = scrapy.Field()