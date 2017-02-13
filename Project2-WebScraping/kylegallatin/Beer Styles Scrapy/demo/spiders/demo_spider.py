# -*- coding: utf-8 -*-
from scrapy import Spider
from scrapy.selector import Selector
from demo.items import DemoItem

class DemoSpider(Spider):
	name = 'demo_spider'
	allowed_urls = ['beeradvocate.com']
	x = 'https://www.beeradvocate.com/beer/style/158/?sort=revsD&start='
	start_urls = [x + str(i) for i in range(0,4519,50)]


	def parse(self, response):
	#	Style = response.xpath('//div[@class="titleBar"]/h1/text()').extract()
		table = response.xpath('//*[@id="ba-content"]/table/tr').extract()
		## print table

		for i in table:
                        Name = Selector(text=i).xpath('//*/td[1]/a/b/text()').extract()
			Brewery = Selector(text=i).xpath('.//td[2]/a/text()').extract()
			ABV = Selector(text=i).xpath('.//td[3]/span/text()').extract()
			Avg = Selector(text=i).xpath('.//td[4]/b/text()').extract()
			Ratings = Selector(text=i).xpath('.//td[5]/b/text()').extract()
			Bros = Selector(text=i).xpath('.//td[6]/a/b/text()').extract()

			item = DemoItem()
	#		items['Style'] = Style
			item['Name'] = Name
			item['Brewery'] = Brewery
			item['ABV'] = ABV
			item['Avg'] = Avg
			item['Ratings'] = Ratings
			item['Bros'] = Bros

			yield item
