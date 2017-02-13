import scrapy
from scrapy.selector import Selector
from scrapy.contrib.spiders import CrawlSpider,Rule
from scrapy.contrib.linkextractors import LinkExtractor
from meetup.items import MeetupItem

class MeetupSpider(scrapy.Spider):
	name = "meetup"
	allowed_domains = ["meetup.com"]
	start_urls = ['https://www.meetup.com']
	
	def check_value(self ,uni):
		if len(str(uni)) == 0:
			return ""
		if len(str(uni)) > 25: 
			return str(uni)[:-1].strip()
		else:
			return str(uni).strip()
	
	def parse(self,response):
		tiles = response.xpath('//*[@id="homeCategories"]/div[2]/ul/li').extract()
#		for tile in range(1,2):
		for tile in range(1,len(tiles)+1):
			print "-"*10 + "Tile # %d " % (tile) + "-"*10
			page_url  = response.xpath('//*[@id="homeCategories"]/div[2]/ul/li[%d]/a/@href' % (tile)).extract_first()
			print "+"*10, page_url
			category = response.xpath('//*[@id="homeCategories"]/div[2]/ul/li[%d]/a/h4/text()' % (tile)).extract_first()
			yield scrapy.Request(page_url,callback=self.parse_group_page, meta={'category': category})
									
	def parse_group_page(self, response):
		rows = response.xpath('//*[@id="simple-view"]/div[1]/ul/li').extract()
		for row in range(1,len(rows) + 1):
#		for row in range(1,2): # Use this for testing
			print "*" * 10 + "Row # %d" % (row) + "*" * 10
			page_url  = response.xpath('//*[@id="simple-view"]/div[1]/ul/li[%d]/div/a[1]/@href' % (row)).extract_first()
			print "-" * 10, page_url
			yield scrapy.Request(page_url, callback=self.parse_group_results_page, meta=response.meta)
	
	def parse_group_results_page(self, response):
		group_name = str(response.xpath('//*[@id="chapter-banner"]/h1/a/@title').extract_first())
		
		category = str(response.meta['category'])
		group_members = self.check_value(response.xpath('//*[@id="C_metabox"]/div[1]/ul/li[1]/a/span[2]/text()').extract_first())
		group_reviews = self.check_value(response.xpath('//*[@id="C_metabox"]/div[1]/ul/li[2]/a/span[2]/text()').extract_first())
		upcoming_meetings = self.check_value(response.xpath('//*[@id="C_metabox"]/div[1]/ul/li[3]/a/span[2]/text()').extract_first())
		past_meetings = self.check_value(response.xpath('//*[@id="C_metabox"]/div[1]/ul/li[4]/a/span[2]/text()').extract_first())

		upcoming_meeting_date =  self.check_value(response.xpath('//*[@id="ajax-container"]/li[1]/div[1]/ul/li[1]/time/span[1]/text()').extract_first())
		upcoming_meeting_time =  self.check_value(response.xpath('//*[@id="ajax-container"]/li[1]/div[1]/ul/li[1]/time/span[2]/text()').extract_first())
		upcoming_address =  self.check_value(response.xpath('//*[@id="ajax-container"]/li/div[2]/dl/dd/text()').extract_first())

		item = MeetupItem()
		item['group_name'] = group_name
		item['group_members'] = group_members
		item['group_reviews'] = group_reviews
		item['upcoming_meetings'] = upcoming_meetings
		item['past_meetings'] = past_meetings
		item['category'] = category
		item['upcoming_meeting_date'] = upcoming_meeting_date
		item['upcoming_meeting_time'] = upcoming_meeting_time
		item['upcoming_address'] = upcoming_address

		yield item
	
	
#//*[@id="C_metabox"]/div[1]/ul/li[1]/a/span[1]
#//*[@id="C_metabox"]/div[1]/ul/li[1]/a/span[2]
