#coding=utf8
from google_play_spider.items import GooglePlaySpiderItem
import scrapy

class PttSpider(scrapy.Spider):
      name = "playspider"      
      start_urls = ["https://play.google.com/store/apps/top"]

      def parse(self,response):
          top=response.xpath('//div[@class="cluster-heading"]/h2[@class="single-title-link"]')
          urlList=top.xpath('span/a/@href').extract()
          pageurl=['https://play.google.com/'+ l for l in urlList]

          for i in range(len(pageurl)):
              yield scrapy.Request(str(pageurl[i]),callback=self.parse_Top)

      def parse_Top(self,response):
          tp=response.xpath('//div[@class="cluster-heading"]/h2/text()').extract()
          tp_S=''.join(tp)
          sl=response.xpath('//div[@class="id-card-list card-list two-cards"]/div[@class="card no-rationale square-cover apps small"]')
          suburlList=sl.xpath('@data-docid').extract()
          
          pageurl=['https://play.google.com/store/apps/details?id='+ a for a in suburlList]
          
         
          for i in range(len(pageurl)):
              yield scrapy.Request(str(pageurl[i]), callback=self.parse_Each,meta={'tp':tp_S})

      def parse_Each(self, response):  
          tp=response.meta['tp']
          category=response.xpath('//a[@class="document-subtitle category"]/span/text()').extract()
          category_S=''.join(category)
          app_name=response.xpath('//div[@class="id-app-title"]/text()').extract()
          app_S=''.join(app_name)
          playitem = GooglePlaySpiderItem()
          brand=response.xpath('//a[@class="document-subtitle primary"]/span/text()').extract()
          brand_S=''.join(brand)
          for object_per in response.xpath('//div[@class="single-review"]'):
              head=object_per.xpath('div[@class="review-header"]/div[@class="review-info"]')
              date=head.xpath('span[@class="review-date"]/text()').extract()[0]
             
              review=object_per.xpath('div[@class="review-body with-review-wrapper"]/text()').extract()
              review_S = ''.join(review)
            
              
              name = ''.join(head.xpath('span[@class="author-name"]/text()').extract()).strip()

              if name=='':
                 name = "anonymous"
    
             
              star = head.xpath('div[@class="review-info-star-rating"]/div[@class="tiny-star star-rating-non-editable-container"]/@aria-label').extract()
              star_S=''.join(star)


              playitem['tp']=tp
              playitem['name'] = name
              playitem['date'] = date.strip()
              playitem['rating'] = star_S.strip()
              playitem['review'] = review_S.strip()
              playitem['app']=app_S.strip()
              playitem['brand']=brand_S.strip()
              playitem['category']=category_S.strip()
              yield playitem

#scrapy crawl playspider