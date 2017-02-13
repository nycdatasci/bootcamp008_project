# -*- coding: utf-8 -*-
from scrapy import Item, Field

class DemoItem(Item):
	Style = Field()
	Name = Field()
	Brewery = Field()
	ABV = Field()
	Avg = Field()
	Ratings = Field()
	Bros = Field()
