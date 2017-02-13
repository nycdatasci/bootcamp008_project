# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

from scrapy import Item, Field


class SkincareItem(Item):
	Url = Field()
	Product = Field()
	OverallScore = Field()
	Image = Field()
	Category =Field()
	UserRating = Field()
	UserReviewTitle = Field()
	ReviewText = Field()
	ReviewTextMore = Field()
	Featured = Field()
	Rank = Field()
	Brand = Field()
	UserName = Field()
	Date = Field()

