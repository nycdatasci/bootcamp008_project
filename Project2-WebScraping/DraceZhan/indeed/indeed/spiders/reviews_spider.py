import scrapy 
from indeed.items import IndeedItem
from scrapy import Selector

class IndeedSpider(scrapy.Spider):
	name = "reviews_spider"
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
					yield scrapy.Request(item['link']+'/reviews', callback = self.parse_reviews)
					#items.append(item['link'])
					#items.append(item['title'])
				

			if len(Selector(text=divs).css('div.sjcl').extract()) == 0:
				if len(Selector(text=divs).css('h2.jobtitle').extract()) > 0:
					for refs in Selector(text=divs).css('h2.jobtitle').extract():
					#for refs in response.css('h2.jobtitle'):
						item['link'] = 'https://www.indeed.com' + str(Selector(text=divs).css('span.company a::attr(href)').extract())[3:-2]
						yield scrapy.Request(item['link']+'/reviews', callback = self.parse_reviews)


				#if response.css('span.company').extract() is not None:	
					
			
		next_page = response.css('div.pagination a::attr(href)').extract()[-1]
		#print 'this should be a link', next_page
		if next_page is not None:
			next_page = response.urljoin(next_page)
			yield scrapy.Request(next_page, callback=self.parse_page)

			

		
	def parse_reviews(self, response):
		item = IndeedItem()

		reviewJob = response.css('span.cmp-reviewer-job-title span::text').extract()
		review = response.css('div.cmp-review-description span::text').extract()
		pro = response.css('div.cmp-review-pro-text::text').extract()
		con = response.css('div.cmp-review-con-text::text').extract()
		item['companyReview'] = response.xpath('//*[@id="cmp-name-and-rating"]/h2/text()').extract_first()
		
		item['review'] = [rev + 'XXX' for rev in review]
		item['reviewJob'] = [title + 'XXX' for title in reviewJob]
		item['pro'] = [plus + 'XXX' for plus in pro]
		item['con'] = [minus + 'XXX' for minus in con]
		

		yield item