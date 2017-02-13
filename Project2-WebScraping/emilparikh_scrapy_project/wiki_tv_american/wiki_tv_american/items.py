# -*- coding: utf-8 -*-
from scrapy import Item, Field


class TVItem(Item):
	title = Field()
	genres = Field()
	running_time = Field()
	original_network = Field()
	start_date = Field()
	end_date = Field()
	url = Field()