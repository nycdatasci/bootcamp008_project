from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor

import pandas as pd
from amazon.items import AmazonListingItem


class AmazonProductListing(CrawlSpider):
    name = "listings"
    allowed_domains = ["amazon.com"]
    start_urls = list(pd.read_csv('data/categories.csv')['urls'])
    rules = (
        Rule(
            LinkExtractor(
                allow=(),
                restrict_xpaths=('//ol[@class="zg_pagination"]/li/a',)
            ),
            callback="parse_items",
            follow=True,
        ),
    )

    def parse_items(self, response):
        pages = response.xpath(
            '//div[@class="zg_itemWrapper"]/div/a/@href').extract()
        products = []

        for product in pages:
            p = AmazonListingItem()
            root = 'https://www.amazon.com'
            p['url'] = root + product.replace('?_encoding=UTF8&psc=1', '')
            products.append(p)
        return products
