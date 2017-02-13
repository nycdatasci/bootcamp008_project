# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class MeetupItem(scrapy.Item):
	# define the fields for your item here like:
	# name = scrapy.Field()
	group_name =  scrapy.Field()
	#location = scrapy.Field()
	#group_info = scrapy.Field()
	group_members = scrapy.Field()
	group_reviews = scrapy.Field()
	upcoming_meetings = scrapy.Field()
	past_meetings = scrapy.Field()
	category = scrapy.Field()
	upcoming_meeting_time = scrapy.Field()
	upcoming_meeting_date = scrapy.Field()
	upcoming_address =  scrapy.Field()	