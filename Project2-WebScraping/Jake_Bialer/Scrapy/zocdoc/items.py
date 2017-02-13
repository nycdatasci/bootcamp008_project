# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class ZocdocItem(scrapy.Item):
  def __setitem__(self, key, value):
    if key not in self.fields:
        self.fields[key] = scrapy.Field()
    self._values[key] = value