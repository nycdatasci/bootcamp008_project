# import scrapy
# from amazon.items import AmazonItem


# class AmazonProductSpider(scrapy.Spider):
#     name = "products"
#     allowed_domains = ["amazon.com"]

#     asins = ['B0046UR4F4', 'B00JGTVU5A', 'B00O9A48N2', 'B00UZKG8QU']
#     root = 'http://www.amazon.com/dp/'

#     start_urls = [root + x for x in asins]

#     def parse(self, response):
#         items = AmazonItem()

#         # xpaths
#         asin = response.xpath('').extract() #TBD
#         product_title = response.xpath('//h1[@id="title"]/span/text()').extract() #DONE
#         bsr = response.xpath('').extract() 
#         category = response.xpath(
#             '//a[@class="a-link-normal a-color-tertiary"]/text()').extract()
#         list_price = response.xpath('').extract()
#         sale_price = response.xpath(
#             '//span[contains(@id,"ourprice") or contains(@id,"saleprice")]/text()').extract()
#         shipping = response.xpath('').extract()
#         num_reviews = response.xpath('').extract()
#         num_questions = response.xpath('').extract()
#         in_stock = = response.xpath('//div[@id="availability"]//text()').extract()
#         description = response.xpath('').extract()
#         dimensions = response.xpath('').extract()
#         shipping_wt = response.xpath('').extract()

#         # assignment to items object
#         items['asin'] = ''.join(asin).strip()
#         items['product_title'] = ''.join(product_title).strip()
#         items['bsr'] = ''.join(bsr).strip()
#         items['category'] = ','.join(
#             map(lambda x: x.strip(), category)).strip()
#         items['list_price'] = ''.join(list_price).strip()
#         items['sale_price'] = ''.join(sale_price).strip()
#         items['shipping'] = ''.join(shipping).strip()
#         items['num_reviews'] = ''.join(num_reviews).strip()
#         items['num_questions'] = ''.join(num_questions).strip()
#         items['in_stock'] = ''.join(in_stock).strip()
#         items['description'] = ''.join(description).strip()
#         items['dimensions'] = ''.join(dimensions).strip()
#         items['shipping_wt'] = ''.join(shipping_wt).strip()
#         yield items
