# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class UfcFighterDataItem(scrapy.Item):
    # define the fields for your item here like:
    fighter_name = scrapy.Field()
    fight_record = scrapy.Field()
    hometown = scrapy.Field()
    fight_out_of = scrapy.Field()
    age = scrapy.Field()
    height = scrapy.Field()
    weight = scrapy.Field()
    reach = scrapy.Field()
    leg_reach = scrapy.Field()
    attempted_strikes = scrapy.Field()
    standing_strikes_landed = scrapy.Field()
    ground_strikes_landed = scrapy.Field()
    other_strikes_landed = scrapy.Field()
    attempted_takedowns = scrapy.Field()
    successful_takedowns = scrapy.Field()
    submissions = scrapy.Field()
    passes = scrapy.Field()
    sweeps = scrapy.Field()
    strikes_avoided_pct = scrapy.Field()
    takedowns_defended_pct = scrapy.Field()