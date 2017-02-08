# -*- coding: utf-8 -*-

import scrapy
from scrapy.selector import Selector
from book.items import BookItem

class BookSpider(scrapy.Spider):
  name = "bookspider"
  allowed_domains = ["amazon.com"]
  # get search results
  # for each search result parse page
  # next page
  # repeat until no more
  #Use working product URL below
  start_urls = [
     "https://www.amazon.com/Cookbook-Analysis-Statistics-Graphics-Cookbooks/product-reviews/0596809158/"
     ]

  def last_pagenumber_in_search(self, response):
    #try:
    last_page_number = int(response.xpath('//ul[@class="a-pagination"]/li[last()-1]/a/@href')
      .extract()[0]
      .split('pageNumber=')[1])
    print last_page_number
    print '=' * 50
    return last_page_number

    # except IndexError:
    #   return "your index is out of the range"


  def parse(self, response):
    last_page_number = self.last_pagenumber_in_search(response)

    if last_page_number < 1:
      return
    else:
      page_urls = [response.url + "?pageNumber=" + str(pageNumber) for pageNumber in range(1, last_page_number + 1)]
      print page_urls
      for page_url in page_urls:
        yield scrapy.Request(page_url,
                            callback = self.parse_listing_results_page)


  def parse_listing_results_page(self, response):

    rows = response.xpath('//*[@id="cm_cr-review_list"]/div').extract()

    if rows:
      for i in range(1, len(rows)):
        review_title = Selector(text=rows[i]).xpath('//div[1]/a[2]/text()').extract()[0]
        review_author = Selector(text=rows[i]).xpath('//div[2]/span[1]/a/text()').extract()[0]
        review_date = Selector(text=rows[i]).xpath('//div[2]/span[4]/text()').extract()[0]
        review_text = Selector(text=rows[i]).xpath('//div[4]/span/text()').extract()[0]

    

        item = BookItem()
        item['review_title'] = review_title
        item['review_author'] = review_author
        item['review_date'] = review_date
        item['review_text'] = review_text

        item['url'] = response.url
         
        yield item
  


    