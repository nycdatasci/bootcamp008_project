from scrapy import Spider
from grassroot.items import GrassRootItem
from scrapy import Selector
from scrapy import Request

class Grassroot_Spider(Spider):
    name = 'grassroot_spider'
    allowed_urls = ['https://ft.com/world']
    start_urls = ['https://ft.com/world/us?page=1']

    def parseOnePage(self, response):
        rows = response.xpath('//li[@class = "o-teaser-collection__item o-grid-row"]').extract()
        for row in rows:
            Time = Selector(text = row).xpath('//div[@class = "stream-card__date"]/time/text()').extract()
            Title = Selector(text = row).xpath('//div[@class = "o-teaser__heading js-teaser-heading"]/a/text()').extract()

            item = GrassRootItem()
            item['Time'] = Time
            item['Title'] = Title
            yield item

    def parse(self, response):
        last_page_number = 1000
        first_page_number = 1
        page_urls = ['https://www.ft.com/world/us?page=' + str(num) for num in range(first_page_number, last_page_number + 1)]
        for page_url in page_urls:
            yield Request(page_url, callback=self.parseOnePage)
