import scrapy
from amazon.items import AmazonCategoryItem


class AmazonProductSpider(scrapy.Spider):
    name = "BestSellerCategories"
    allowed_domains = ["amazon.com"]

    start_urls = ['https://www.amazon.com/Best-Sellers/zgbs/']

    #re-write to return each item individually
    def parse(self, response):
        categories = AmazonCategoryItem()
        names = response.xpath(
            '//ul[@id="zg_browseRoot"]/ul/li//text()').extract()
        urls = response.xpath(
            '//ul[@id="zg_browseRoot"]/ul/li//@href').extract()

        categories['name'] = str(name)
        categories['url'] = str(url)
        yield categories
