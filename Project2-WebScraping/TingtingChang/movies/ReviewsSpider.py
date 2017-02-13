# -*- coding: utf-8 -*-

import scrapy
from scrapy.selector import Selector
from movies.items import MoviesItem

class ReviewsSpider(scrapy.Spider):
  name = "reviews_spider"
  allowed_domains = ["rottentomatoes.com"]
  download_delay = 1
  # get search results
  # for each search result parse page
  # next page
  # repeat until no more
  #Use working product URL below
  base_url = "https://www.rottentomatoes.com/%s"
  start_urls = [
     "https://www.rottentomatoes.com/"
     ]

  moviesDict = {}
  item[moviesDict] = {}

  def parse(self, response):
    rows = response.xpath('//*[@id="top_movies_main"]/div/table[1]/tr').extract()

    for i in range(0, 100):
      movie_rank = Selector(text=rows[i]).xpath('//td[1]/text()').extract()[0]
      movie_rating = Selector(text=rows[i]).xpath('//td[2]/span/span[2]/text()').extract()[0]
      movie_title = Selector(text=rows[i]).xpath('//td[3]/a/text()').extract()[0]
      count_reviews = Selector(text=rows[i]).xpath('//td[4]/text()').extract()[0]
      movie_href = Selector(text=rows[i]).xpath('//td[3]/a/@href').extract()[0]
      
      print response.status
      url = self.base_url%movie_href
      print url
      
      moviesDict = MoviesItem()
      moviesDict['movie_rank'] = movie_rank
      moviesDict['movie_rating'] = movie_rating

      moviesDict['movie_title'] = movie_title.strip()
      moviesDict['count_reviews'] = count_reviews
      moviesDict['movie_href'] =  movie_href      
      yield moviesDict

      yield scrapy.Request(url, meta={"href": movie_href}, callback=self.parseReviews)

  def parseReviews(self, response):
    # 现在新的url
    href = response.meta["href"] + "/reviews"

    # 不知道怎么请求，我先把爬虫的代码写好
    rows = response.xpath('///*[@class="review_table"]/div').extract()

    for i in range(0, len(rows)):
      critic_name = Selector(text=rows[i]).xpath('//div[1]/div[1]/div[3]/a[1]/text()').extract()[0]
      source_name = Selector(text=rows[i]).xpath('//div[1]/div[1]/div[3]/a[2]/em/text()').extract()[0]
      review_date = Selector(text=rows[i]).xpath('//div[2]/div[2]/div[1]').extract()[0]
      review_detail = Selector(text=rows[i]).xpath('//div[2]/div[2]/div[2]/div[1]').extract()[0]
      
      movie_href = Selector(text=rows[i]).xpath('//td[3]/a/@href').extract()[0]
      


    print href

  # def last_pagenumber_in_search(self, response):
  #   #try:
  #   last_page_number = int(response.xpath('//ul[@class="a-pagination"]/li[last()-1]/a/@href')
  #     .extract()[0]
  #     .split('pageNumber=')[1])
  #   print last_page_number
  #   print '=' * 50
  #   return last_page_number

    # except IndexError:
    #   return "your index is out of the range"


  # def parse(self, response):
  #   last_page_number = self.last_pagenumber_in_search(response)

  #   if last_page_number < 1:
  #     return
  #   else:
  #     page_urls = [response.url + "?pageNumber=" + str(pageNumber) for pageNumber in range(1, last_page_number + 1)]
  #     print page_urls
  #     for page_url in page_urls:
  #       yield scrapy.Request(page_url,
  #                           callback = self.parse_listing_results_page)


  # def parse_listing_results_page(self, response):

  #   rows = response.xpath('//*[@id="cm_cr-review_list"]/div').extract()

  #   if rows:
  #     for i in range(1, len(rows)):
  #       review_title = Selector(text=rows[i]).xpath('//div[1]/a[2]/text()').extract()[0]
  #       review_author = Selector(text=rows[i]).xpath('//div[2]/span[1]/a/text()').extract()[0]
  #       review_date = Selector(text=rows[i]).xpath('//div[2]/span[4]/text()').extract()[0]
  #       review_text = Selector(text=rows[i]).xpath('//div[4]/span/text()').extract()[0]

    

  #       item = BookItem()
  #       item['review_title'] = review_title
  #       item['review_author'] = review_author
  #       item['review_date'] = review_date
  #       item['review_text'] = review_text

  #       item['url'] = response.url
         
  #       yield item
  


    