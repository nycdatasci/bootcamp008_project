import scrapy
from scrapy.selector import Selector
from scraping.items import GamesListItem
import logging

class GamesListSpider(scrapy.Spider):
    name = "gameslistspider"
    allowed_domains = ["metacritic.com"]

    start_urls = []
    systems = ['ps4', 'xboxone', 'switch', 'pc', 'wii-u', '3ds', 'vita', 'ios', 'ps3', 'ps2', 'ps',
               'xbox360', 'xbox', 'wii', 'ds', 'gamecube', 'n64', 'gba', 'psp', 'dreamcast']
    [start_urls.append('http://www.metacritic.com/browse/games/release-date/available/' + sys + '/metascore/') for sys in systems]

    custom_settings = {
        'ITEM_PIPELINES' : {
            'scraping.pipelines.WriteItemPipelineGamesList': 100
        }
    }

    def lastPageNumber(self, response):
        try:
            lastPageNumber = int(response.xpath('//li[@class="page last_page"]/a/text()').extract()[0])
            return lastPageNumber
        except:
            logging.debug('Only one page for ' + response.url)
            return -1

    def parse(self, response):
        last_page_number = self.lastPageNumber(response)
        if last_page_number < 0:
            yield scrapy.Request(response.url, callback=self.parse_listings_results_page)
        else:
            page_urls = [response.url + "?page=" + str(pageNumber) for pageNumber in range(0, last_page_number)]
            for page_url in page_urls:
                yield scrapy.Request(page_url, callback=self.parse_listings_results_page)

    def parse_listings_results_page(self, response):
        item = GamesListItem()

        for element in response.xpath('//*[@id="main"]/div[1]/div[2]/div[3]/div/ol[@class="list_products list_product_condensed"]/li').extract():
            item['name'] = str(Selector(text=element).xpath('//li/div/div[@class="basic_stat product_title"]/a/text()').extract()[0].encode('utf-8').strip())
            item['link'] = str(Selector(text=element).xpath('//li/div/div[@class="basic_stat product_title"]/a/@href').extract()[0].encode('utf-8').strip())
            yield item