import scrapy 
from indeed.items import IndeedItem
from scrapy import Selector

class test_spider(scrapy.Spider):
	name = "test_spider"
	start_urls = ['https://www.indeed.com/cmp/Deloitte/salaries']

	
	def parse(self, response):
		item = IndeedItem()

		body = response.xpath('//*[@id="cmp-content"]/div[3]/table').extract()
		for i in range(len(body)):
			table = response.xpath('//*[@id="cmp-content"]/div[3]/table').extract()[i]
			for j in range(len(Selector(text=table).xpath('//tr'))):
				item['position'] = response.css('div.cmp-sal-title a::text').extract_first()[j]
				item['salary'] = response.css('div.cmp-sal-summary span::text').extract_first()[j]

		yield item
