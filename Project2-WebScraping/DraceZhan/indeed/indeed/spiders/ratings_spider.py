import scrapy 
from indeed.items import IndeedItem
from scrapy import Selector

class IndeedSpider(scrapy.Spider):
	name = "ratings_spider"
	allowed_domains = ["indeed.com"]
	start_urls = ['https://www.indeed.com/jobs?q=data+scientist']

	
	def start_requests(self):
		urls = ['https://www.indeed.com/jobs?q=data+scientist']
		for url in urls:
			yield scrapy.Request(url = url, callback = self.parse_page)
			
	def parse_page(self, response):
		item = IndeedItem()
		#items = []
		for divs in response.css('div.row.result').extract():
			if len(Selector(text=divs).css('div.sjcl').extract()) > 0:
				for hrefs in Selector(text=divs).css('div.sjcl').extract():

					#link =  Selector(text=divs).css('a.jobtitle.turnstileLink::attr(title)').extract_first()
					#print link
					#print "=" * 50

					item['link'] = 'https://www.indeed.com' + str(Selector(text=hrefs).css('span.company a::attr(href)').extract())[3:-2]
					yield scrapy.Request(item['link'], callback = self.parse_ratings)

					#items.append(item['link'])
					#items.append(item['title'])
				

			if len(Selector(text=divs).css('div.sjcl').extract()) == 0:
				if len(Selector(text=divs).css('h2.jobtitle').extract()) > 0:
					for refs in Selector(text=divs).css('h2.jobtitle').extract():
					#for refs in response.css('h2.jobtitle'):
						item['link'] = 'https://www.indeed.com' + str(Selector(text=divs).css('span.company a::attr(href)').extract())[3:-2]
						yield scrapy.Request(item['link'], callback = self.parse_ratings)


				#if response.css('span.company').extract() is not None:	
					
			
		next_page = response.css('div.pagination a::attr(href)').extract()[-1]
		#print 'this should be a link', next_page
		if next_page is not None:
			next_page = response.urljoin(next_page)
			yield scrapy.Request(next_page, callback=self.parse_page)

			
	
	def parse_ratings(self, response):
		item = IndeedItem()
		for scores in response.xpath('//*[@id="cmp-reviews-attributes"]').extract_first():
			item['worklife'] = response.xpath('//*[@id="cmp-reviews-attributes"]/dd[1]/span[1]').extract_first()
			item['compensation'] = response.xpath('//*[@id="cmp-reviews-attributes"]/dd[2]/span[1]').extract_first()
			item['jobsecurity'] = response.xpath('//*[@id="cmp-reviews-attributes"]/dd[3]/span[1]').extract_first()
			item['management'] = response.xpath('//*[@id="cmp-reviews-attributes"]/dd[4]/span[1]').extract_first()
			item['culture'] = response.xpath('//*[@id="cmp-reviews-attributes"]/dd[5]/span[1]').extract_first()
			item['companyScore'] = response.xpath('//*[@id="cmp-name-and-rating"]/h2/text()').extract_first()

		yield item

