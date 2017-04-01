# -*- coding: utf-8 -*-
from scrapy import Spider
from scrapy.selector import Selector
from Billboard.items import BillboardItem

class BillboardSpider(Spider):
	name = 'Billboard_spider'
	allowed_urls = ['http://www.billboard.com/']
	page_number = 1958
	start_urls = ["http://www.billboard.com/archive/charts/{year}/hot-100".format(year=year) for year in range(1958, 2017)]

	def parse(self, response):
		rows = response.xpath('//*[@id="block-system-main"]/div/div/div[2]/table/tbody/tr').extract()

		for row in rows:

			IssueDate = Selector(text=row).xpath('//td[1]/a/span/text()').extract()
			Song = Selector(text=row).xpath('//td[2]/text()').extract()
			Artist = Selector(text=row).xpath('//td[3]/a/text()').extract()


			item = BillboardItem()
			item['IssueDate'] = IssueDate
			item['Song'] = Song
			item['Artist'] = Artist

			
		

			yield item
