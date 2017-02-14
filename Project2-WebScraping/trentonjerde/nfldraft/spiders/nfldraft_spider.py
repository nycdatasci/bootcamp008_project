from scrapy import Spider
from scrapy.loader import ItemLoader
from nfldraft.items import NfldraftItem
from scrapy import Selector

class NfldraftSpider(Spider):
	name = "nfldraft"

	def start_requests(self):
		urls = [
			'https://en.wikipedia.org/wiki/2006_NFL_Draft',
			'https://en.wikipedia.org/wiki/2007_NFL_Draft',
			'https://en.wikipedia.org/wiki/2008_NFL_Draft',
			'https://en.wikipedia.org/wiki/2009_NFL_Draft',
			'https://en.wikipedia.org/wiki/2010_NFL_Draft',
			'https://en.wikipedia.org/wiki/2011_NFL_Draft',
			'https://en.wikipedia.org/wiki/2012_NFL_Draft',
			'https://en.wikipedia.org/wiki/2013_NFL_Draft',
            'https://en.wikipedia.org/wiki/2014_NFL_Draft',
            'https://en.wikipedia.org/wiki/2015_NFL_Draft',
            'https://en.wikipedia.org/wiki/2016_NFL_Draft'
		]
		for url in urls:
			# yield scrapy.Request(url=url, callback=self.parse)
			yield self.make_requests_from_url(url)

	def parse(self, response):
		
		rows = response.xpath('//table[@class="wikitable sortable"][1]/tr').extract()[1:]

		for row in rows:
			rnd = Selector(text=row).xpath('//th[1]/text()').extract_first()
			pick = Selector(text=row).xpath('//th[2]//text()').extract_first()
			team = Selector(text=row).xpath('//td[2]//text()').extract_first()
			player = Selector(text=row).xpath('//td[3]//text()').extract_first()
			position = Selector(text=row).xpath('//td[4]//text()').extract_first()
			college = Selector(text=row).xpath('//td[5]//text()').extract_first()
			conf = Selector(text=row).xpath('//td[6]//text()').extract_first()

			item = NfldraftItem()
			item['rnd'] = rnd
			item['pick'] = pick
			item['team'] = team
			item['player'] = player
			item['position'] = position
			item['college'] = college
			item['conf'] = conf

			yield item