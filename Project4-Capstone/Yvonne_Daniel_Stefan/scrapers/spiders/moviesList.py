import scrapy
from scrapy.selector import Selector
from scraping.items import MoviesListItem
import logging

class MoviesListSpider(scrapy.Spider):
    name = "movieslistspider"
    allowed_domains = ["metacritic.com"]

    start_urls = []
    years = range(2007, 2018)
    [start_urls.append('http://www.metacritic.com/browse/movies/score/metascore/year/filtered?year_selected=' + str(year) + '&sort=desc') for year in years]

    custom_settings = {
        'ITEM_PIPELINES' : {
            'scraping.pipelines.WriteItemPipelineMoviewsList': 100
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
        item = MoviesListItem()

        for element in response.xpath('//table[@class="list score"]/tr').extract():
            if len(Selector(text=element).xpath('//tr[@class="summary_row"]/td[@class="title_wrapper"]/div/a/text()').extract()) > 0:
                item['name'] = str(Selector(text=element).xpath('//tr[@class="summary_row"]/td[@class="title_wrapper"]/div/a/text()').extract()[0].encode('utf-8').strip())
                item['link'] = str(Selector(text=element).xpath('//tr[@class="summary_row"]/td[@class="title_wrapper"]/div/a/@href').extract()[0].strip())
                item['date'] = str(Selector(text=element).xpath('//tr[@class="summary_row"]/td[@class="date_wrapper"]/span[1]/text()').extract()[0].strip())
                yield item