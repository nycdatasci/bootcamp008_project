import scrapy 
from indeed.items import IndeedItem
from scrapy import Selector

class MetaSpider(scrapy.Spider):
	name = "meta_spider"
	start_urls = ['https://www.indeed.com/cmp/Indeed']

	
	def parse(self, response):
		item = IndeedItem()
		for scores in response.xpath('//*[@id="cmp-reviews-attributes"]').extract_first():
			item['worklife'] = response.xpath('//*[@id="cmp-reviews-attributes"]/dd[1]/span[1]').extract_first()
			item['compensation'] = response.xpath('//*[@id="cmp-reviews-attributes"]/dd[2]/span[1]').extract_first()
			item['jobsecurity'] = response.xpath('//*[@id="cmp-reviews-attributes"]/dd[3]/span[1]').extract_first()
			item['management'] = response.xpath('//*[@id="cmp-reviews-attributes"]/dd[4]/span[1]').extract_first()
			item['culture'] = response.xpath('//*[@id="cmp-reviews-attributes"]/dd[5]/span[1]').extract_first()
			
		yield item
		