from scrapy import Spider
from scrapy.selector import Selector
from scrapy import Request
from audible.items import AudibleItem
from re import sub
from re import search

class AudibleSpider(Spider):
    name = "audible_spider"
    # Set the allowed urls and the audible start page
    allowed_urls = ['http://www.audible.com/']
    start_urls = ['http://www.audible.com/search/ref=a_search_c8_1_srchPg?field_language=9178177011&field_content_type-bin=9178163011&searchSize=50']
    
    def parse(self,response):
       pages = [sub('\n+', 'http://www.audible.com', x) for x in response.xpath('//*[contains(@class,"adbl-prod-title")]/a/@href').extract()]
       for page in pages:
           SubRequest = Request(page,callback=self.page_parse)
           yield SubRequest
       Next_page = sub('^', 'http://www.audible.com',response.xpath('//*[contains(@class,"adbl-page-next")]/a/@href').extract()[0])
       if Next_page == None: 
           return
       else:
           Next_request = Request(Next_page,callback=self.parse)
           yield Next_request 

    def page_parse(self, response):
        # get the items from the main audible page
        item = AudibleItem()
        item['Catagory'] = response.xpath('//*[@id="center_2"]/div[2]/div[1]/div[2]/a/span/text()').extract()
        item['Title'] = response.xpath('//*[@id="center_2"]/div[2]/div[2]/div[2]/h1/text()').extract()
        item['WrittenBy'] = response.xpath('//*[@id="AuthorSearchLink"]/span/text()').extract() 
        item['NarratedBy'] = response.xpath("//*[contains(@class,'adbl-narrator-row')]/span[2]/a/span/text()").extract()
        item['Length'] = response.xpath('//*[contains(@class,"adbl-run-time")]/text()').extract()
        item['CompOrAb'] = response.xpath('//*[contains(@class,"adbl-format-type")]/text()').extract() 
        item['RelDate'] = response.xpath('//*[contains(@class,"adbl-date adbl-release-date")]/text()').extract()
        item['Publisher'] = response.xpath('//*[contains(@class,"adbl-publisher")]/a/text()').extract()
        item['Price'] = response.xpath('//*[contains(@class,"adbl-reg-price")]/text()').extract()
        OverallRating = response.xpath('//*[contains(@class,"adbl-product-rating-star-text-wrap boldrating")]/text()').extract()
        if OverallRating == []:
            item['OverallRating'] = 0 
            item['StoryRating'] =  0
            item['PerformRating'] = 0
            item['NumOverRating'] = 0
            item['NumStoryRating'] = 0
            item['NumPerformRating'] = 0
        else:
            item['OverallRating'] = response.xpath('//*[contains(@class,"adbl-product-rating-star-text-wrap boldrating")]/text()').extract()[0]
            item['StoryRating'] =  response.xpath('//*[contains(@class,"adbl-product-rating-star-text-wrap boldrating")]/text()').extract()[1]
            item['PerformRating'] = response.xpath('//*[contains(@class,"adbl-product-rating-star-text-wrap boldrating")]/text()').extract()[2]
            item['NumOverRating'] = sub('\(','',sub('\s+\)','',response.xpath('//*[contains(@class,"adbl-product-rating-star-text-wrap")]/text()[normalize-space()]').extract()[1]))
            item['NumStoryRating'] = sub('\(','',sub('\s+\)','',response.xpath('//*[contains(@class,"adbl-product-rating-star-text-wrap")]/text()[normalize-space()]').extract()[13]))
            item['NumPerformRating'] = sub('\(','',sub('\s+\)','',response.xpath('//*[contains(@class,"adbl-product-rating-star-text-wrap")]/text()[normalize-space()]').extract()[25])) 
        yield item




