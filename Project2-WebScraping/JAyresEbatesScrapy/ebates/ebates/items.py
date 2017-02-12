# -*- coding: utf-8 -*-

import scrapy


class EbatesItem(scrapy.Item):
    # define the fields for your item here like:
    store = scrapy.Field()
    coupon = scrapy.Field()
    discount = scrapy.Field()
    total = scrapy.Field()