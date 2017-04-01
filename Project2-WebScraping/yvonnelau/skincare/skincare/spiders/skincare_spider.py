from scrapy.spiders import Spider
from scrapy.http import Request
from scrapy.selector import Selector
from skincare.items import SkincareItem

class SkincareSpider(Spider):
    name = "skincare_spider"
    allowed_urls = ['http://www.totalbeauty.com/']

    start_urls = ["http://www.totalbeauty.com/reviews/face/page%s" % page for page in xrange(1,1703)]

    #parse main page with list of documents
    def parse(self,response):
        products = response.xpath('//li[@class = "clearfix"]')
        # first 8 products
        for product in products:
            item = SkincareItem()
            item['Url'] = product.xpath('div[@class = "prodName clearfix"]/a[1]/@href').extract()[0]
            item['Product'] = product.xpath('div[@class = "prodName clearfix"]/a[1]/text()').extract()[0]
            item['Image'] = product.xpath('div[@class = "prodImg"]/a/img/@src').extract()[0]
            # Check that there is an actual review to scrape
            try:
            	item['OverallScore'] = product.xpath('div[@class = "prodName clearfix"]/p/text()').extract()[0]
            	item['Rank'] = 0
            
            	# send in request
            	url = 'http://www.totalbeauty.com'+ product.xpath('div[@class = "prodName clearfix"]/a[1]/@href').extract()[0]+"/reviews?sort=5"

            	request = Request(url, callback = self.review_parse)
            	request.meta['item'] = item
            	yield request
            except IndexError:
            	url = 'http://www.totalbeauty.com'+ product.xpath('div[@class = "prodName clearfix"]/a[1]/@href').extract()[0]
            	request = Request(url, callback = self.product_parse)
            	request.meta['item'] = item
            	yield request

        #last product
        last = response.xpath('//li[@class = "last clearfix"]')
        item = SkincareItem()
        item['Url'] = last[0].xpath('div[@class = "prodName clearfix"]/a[1]/@href').extract()[0]
        item['Product'] = last[0].xpath('div[@class = "prodName clearfix"]/a[1]/text()').extract()[0]

        try:
        	item['OverallScore'] = last[0].xpath('div[@class = "prodName clearfix"]/p/text()').extract()[0]
        	item['Image'] = last[0].xpath('div[@class = "prodImg"]/a/img/@src').extract()[0]
        	url = 'http://www.totalbeauty.com/'+ last[0].xpath('div[@class = "prodName clearfix"]/a[1]/@href').extract()[0] + "/reviews?sort=5"
        	request = Request(url, callback = self.review_parse)
        	request.meta['item'] = item
        	yield request
        except IndexError:
        	url = 'http://www.totalbeauty.com'+ product.xpath('div[@class = "prodName clearfix"]/a[1]/@href').extract()[0]
        	request = Request(url, callback = self.product_parse)
        	request.meta['item'] = item
        	yield request

    #parsing function for the product page
    def review_parse(self, response):
        Category = response.xpath('//div[@class = "rt_more_brands_heading"]/div[2]/h2/text()').extract()[0]
        Brand = response.xpath('//div[@class = "rt_more_brands_heading"]/div[2]/h2/text()').extract()[1]
        item = response.meta['item']
        item['Category'] = Category
        item['Brand'] = Brand
        #Rank = 1

        #Extract featured reviews
        features = response.xpath('//li[@class = "memberReview featured"]')
        if features != []:
            for feature in features:
                item['Rank'] = item['Rank'] + 1 
                item['UserRating'] = feature.xpath('div[@class = "ratingStarSmall"]/text()').extract()[0]
                item['UserReviewTitle'] = feature.xpath('div[@class = "userReview"]/p/text()').extract()[0]
                item['ReviewText'] = feature.xpath('div[@class = "userReview"]/div[@class = "reviewText"]/span[1]/text()').extract()[0].strip()
                # catch extra text
                try:
                    item['ReviewTextMore'] = feature.xpath('div[@class = "userReview"]/div[@class = "reviewText"]/span[1]/span[2]/text()').extract()[0].strip()
                except IndexError:
                    item['ReviewTextMore'] = None
                item['Featured']='1'
                item['UserName']=feature.xpath('div[@class = "userReview"]/div[@class = "myTbThumb"]/div[@class = "thumbrt"]/cite[@class="reviewedBy"]/a/text()').extract()[0]
                item['Date'] = feature.xpath('div[@class = "userReview"]/div[@class = "reviewText"]/span[2]/text()').extract()[0]
                yield item

        #Extract normal reviews
        reviews = response.xpath('//li[@class = "memberReview"]')
        for review in reviews:
            item['Rank'] = item['Rank'] + 1 
            item['UserRating'] = review.xpath('div[@class = "ratingStarSmall"]/text()').extract()[0]
            item['UserReviewTitle'] = review.xpath('div[@class = "userReview"]/p/text()').extract()[0]
            item['ReviewText'] = review.xpath('div[@class = "userReview"]/div[@class = "reviewText"]/span[1]/text()').extract()[0].strip()
            # catch extra text
            try:
                item['ReviewTextMore'] = review.xpath('div[@class = "userReview"]/div[@class = "reviewText"]/span[1]/span[2]/text()').extract()[0].strip()
            except IndexError:
                item['ReviewTextMore'] = None

            item['Featured']='0' 
            item['UserName']=review.xpath('div[@class = "userReview"]/div[@class = "myTbThumb"]/div[@class = "thumbrt"]/cite[@class="reviewedBy"]/a/text()').extract()[0]   
            item['Date'] = review.xpath('div[@class = "userReview"]/div[@class = "reviewText"]/span[2]/text()').extract()[0]

            yield item

        # Extract last review of the page, which can be featured or just a normal review
        reviews = response.xpath('//li[@class = "memberReview last"]')
        if reviews == []:
            reviews = response.xpath('//li[@class = "memberReview featured last"]')
            item['Featured']='1'
        else:
            item['Featured']='0'    

        review = reviews[0]
        item['Rank'] = item['Rank'] + 1 
        item['UserRating'] = review.xpath('div[@class = "ratingStarSmall"]/text()').extract()[0]
        item['UserReviewTitle'] = review.xpath('div[@class = "userReview"]/p/text()').extract()[0]
        item['ReviewText'] = review.xpath('div[@class = "userReview"]/div[@class = "reviewText"]/span[1]/text()').extract()[0].strip()
        # catch extra text
        try:
            item['ReviewTextMore'] = review.xpath('div[@class = "userReview"]/div[@class = "reviewText"]/span[1]/span[2]/text()').extract()[0].strip()
        except IndexError:
            item['ReviewTextMore'] = None

        item['UserName']=review.xpath('div[@class = "userReview"]/div[@class = "myTbThumb"]/div[@class = "thumbrt"]/cite[@class="reviewedBy"]/a/text()').extract()[0]
        item['Date'] = review.xpath('div[@class = "userReview"]/div[@class = "reviewText"]/span[2]/text()').extract()[0]

        yield item


        # yield request for next page of reviews
        next_page_url = response.xpath('//*[@id="pagNext"]/a/@href').extract_first()
        if next_page_url!=[]:
            absolute_next_page_url = response.urljoin(next_page_url)
            request = Request(absolute_next_page_url, callback = self.review_parse)
            request.meta['item'] = item
            yield request

     # parsing function for products with no reviews
    def product_parse(self, response):
        Category = response.xpath('//div[@class = "rt_more_brands_heading"]/div[2]/h2/text()').extract()[0]
        Brand = response.xpath('//div[@class = "rt_more_brands_heading"]/div[2]/h2/text()').extract()[1]
        item = response.meta['item']
        item['Category'] = Category
        item['Brand'] = Brand
        yield item 