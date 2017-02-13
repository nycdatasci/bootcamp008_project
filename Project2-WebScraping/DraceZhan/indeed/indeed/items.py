# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class IndeedItem(scrapy.Item):

	link = scrapy.Field()
	worklife = scrapy.Field()
	compensation = scrapy.Field()
	jobsecurity = scrapy.Field()
	management = scrapy.Field()
	culture = scrapy.Field()
	companyScore = scrapy.Field()

	salary = scrapy.Field()
	position = scrapy.Field()
	company = scrapy.Field()
	
	reviewJob = scrapy.Field()
	review = scrapy.Field()
	pro = scrapy.Field()
	con = scrapy.Field()
	companyReview = scrapy.Field()