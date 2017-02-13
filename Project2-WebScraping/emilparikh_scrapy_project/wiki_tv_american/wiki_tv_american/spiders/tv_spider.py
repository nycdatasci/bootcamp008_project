import scrapy
from scrapy import Spider
from scrapy.selector import Selector
from wiki_tv_american.items import TVItem
from wiki_tv_american.helpers import *

# solely for sampling for test runs
#import numpy as np

class TVSpider(Spider):
	name = "tv_spider"
	allowed_urls = ["en.wikipedia.org/"]

	# start_url 1
	#start_urls = ["https://en.wikipedia.org/wiki/List_of_American_television_programs_by_date"]

	# start_url 2
	start_urls = ["https://en.wikipedia.org/wiki/List_of_American_television_series"]

	def parse(self, response):

		# tv show urls from start_url 1
		# urls = response.xpath("//h3//following-sibling::ul" + \
		# 	"//a[starts-with(@href, '/wiki/')]/@href").extract()

		# tv show urls from start_url 2
		urls = response.xpath("//i//a/@href").extract()

		# to manually read urls from a file
		# with open("input/urls.csv", "r") as f:
		# 	urls = [line.strip() for line in f.readlines()]


		# pick random URLs
		#urls = np.random.choice(urls,10, replace=False)

		# follow URL to get show details
		for url in urls:
			yield (scrapy.Request(response.urljoin(url),
				callback=self.parse_tv_show)
			)
			#for manual URLs
			# yield (scrapy.Request(url,
			# 	callback=self.parse_tv_show)
			# )


	def parse_tv_show(self, response):
		item = TVItem()
		item["url"] = response.url
		
		try:
			info_table = (response.xpath(
				"//table[contains(@class, 'infobox')]"
				).extract()[0]
			)

			title = (Selector(text=info_table).xpath(
				"//th/text()"
				).extract()[0]
			)

			# list of genres
			genres = (Selector(text=info_table).xpath(
				"//*[th='Genre']//following-sibling::td//*/text()[normalize-space()]"
				).extract()
			)

			# if genre empty, then neither in <a> nor <li>
			if genres == []:
				genres = (Selector(text=info_table).xpath(
					"//*[th='Genre']//following-sibling::td/text()"
					).extract()
				)

			try:
				running_time = (Selector(text=info_table).xpath(
					"//*[th='Running time']//following-sibling::td/text()"
					).extract_first().split(u'\u2013')
				)
			except:
				#okay if running time doesn't exist, but good to have
				pass

			# single string
			original_network = (Selector(text=info_table).xpath(
				"//*[th='Original network']//following-sibling::td/a/text()"
				).extract_first()
			)

			dates = (Selector(text=info_table).xpath(
				"//*[th='Original release']//following-sibling::td/text()"
				).extract()
			)

			(start_date, end_date) = clean_dates(dates, info_table)


			# if there is an exception, only a url will be passed in except block
			item["title"] = str(title).lower()
			item["genres"] = genres
			item["running_time"] = running_time
			item["original_network"] = str(original_network).lower()
			item["start_date"] = start_date.lower()
			item["end_date"] = end_date.lower()

			yield item
		except:
			#pass url to pipeline if bad url
			yield item
