import scrapy
from scrapy.selector import Selector
from scraping.items import TVShowsListItem
import logging

class TVShowsListSpider(scrapy.Spider):
    name = "tvshowslistspider"
    allowed_domains = ["metacritic.com"]
    start_urls = ['http://www.metacritic.com/browse/tv/score/metascore/all/filtered?sort=desc']

    custom_settings = {
        'ITEM_PIPELINES' : {
            'scraping.pipelines.WriteItemPipelineTVShowsList': 100
        }
    }

    def lastPageNumber(self, response):
        try:
            lastPageNumber = int(response.xpath('//li[@class="page last_page"]/a/text()').extract()[0])
            return lastPageNumber
        except:
            logging.log(logging.DEBUG, 'Some error on page', response.url)
            return 0

    def parse(self, response):
        last_page_number = self.lastPageNumber(response)
        if last_page_number < 0:
            return
        else:
            page_urls = [response.url + "&page=" + str(pageNumber) for pageNumber in range(0, last_page_number)]
            for page_url in page_urls:
                yield scrapy.Request(page_url, callback=self.parse_listings_results_page)

    def parse_listings_results_page(self, response):
        item = TVShowsListItem()

        for element in response.xpath('//div[@class="product_rows"]/div').extract():
            if len(Selector(text=element).xpath('//div/div[@class="product_item product_title"]/a/text()').extract()) > 0:
                item['name'] = str(Selector(text=element).xpath('//div/div[@class="product_item product_title"]/a/text()').extract()[0].encode('utf-8').strip())
                item['link'] = str(Selector(text=element).xpath('//div/div[@class="product_item product_title"]/a/@href').extract()[0].strip())
                item['date'] = str(Selector(text=element).xpath('//div/div[@class="product_item product_date"]/text()').extract()[0].strip())
                yield item