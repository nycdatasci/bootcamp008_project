# -*- coding: utf-8 -*-
import scrapy
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from zocdoc.items import ZocdocItem
import re
import urllib.request 
import json
# https://www.zocdoc.com/insuranceinformation/ProfessionalInsurances?id=195238&_=1486076148389
class DoctorSpider(CrawlSpider):
    def clean_item(self,items):
          if items:
                new_items=[]
                for item in items:
                      new_items.append(item.strip())
                return new_items
          else:
                return items
    name = "doctor_csv"
    allowed_domains = ["zocdoc.com"]
    with urllib.request.urlopen("https://dl.dropboxusercontent.com/u/9526991/zocdocurls.csv") as response:
      start_urls = [url.strip().decode("utf-8")  for url in response.readlines()]
          
    def parse(self,response):
      item = ZocdocItem()
      location_ids= response.selector.re("l\|:\|([0-9]{1,10})\|")
      page_data = response.selector.re("<script>[\s\S]*?profile\.Start\(({[\s\S]*?})\)[\s\S]*?</script>")
      try:
        if page_data:
          page_data = page_data[0].replace("\r","").replace("\n","")
        # http://stackoverflow.com/questions/4033633/handling-lazy-json-in-python-expecting-property-name
          page_data = re.sub(r"{\s*'?(\w)", r'{"\1', page_data)
          page_data = re.sub(r",\s*'?(\w)", r',"\1', page_data)
          page_data = re.sub(r"(\w)'?\s*:(?!/)", r'\1":', page_data)
          page_data = re.sub(r":\s*'(\w+)'\s*([,}])", r':"\1"\2', page_data) 
          page_data = re.sub(r",\s*]", "]", page_data)
          page_data='{"'+page_data[page_data.find("id"):]
          page_data = page_data.replace('{"0}-{"1}-{"2}',"")
          page_data=json.loads(page_data)
          for name,data in page_data.items():
            item["page_data"+str(name)] = data
      except:
        print("Page Data Failed")
        item['page_data'] = page_data
      location_ids= response.selector.re("l\|:\|([0-9]{1,10})\|")
      item['location_ids'] =location_ids
      item['url'] = response.url
      item['og:title'] = response.css('meta[property="og:title"]::attr(content)').extract_first()
      item['og:description']= response.css('meta[property="og:description"]::attr(content)').extract_first()
      item['og:type']= response.css('meta[property="og:type"]::attr(content)').extract_first()
      
      item['long_name'] = response.css(".docLongName::text").extract_first()
      item['professsion'] = response.css(".profSpecTitle::text").extract_first()
      item['street_address']= response.css("div[itemprop=streetAddress]::text").extract_first()
      item['addressLocality'] = response.css("span[itemProp=addressLocality]::text").extract_first()
      item['postalCode'] = response.css("*[itemprop=postalCode]::text").extract_first()
      item['addressRegion'] = response.css("*[itemprop=addressRegion]::text").extract_first()
      item['boardCert'] = response.css(".detailsColumn > div.details > div > ul.section-set >li::text").extract_first()
      if item['boardCert']:
            item['boardCert'] = item['boardCert'].strip()
      item['lat'] = response.css(".sg-columns.map-container::attr(data-latitude)").extract_first()
      item['long']= response.css(".sg-columns.map-container::attr(data-longitude)").extract_first()
      item['data_icons'] = response.css(".sg-columns.map-container::attr(data-icons)").extract_first()
      item['photos'] = response.selector.re("See all (.*) photos")
      if len(item['photos'])==0:
        item['photos'] =  len(response.css(".profile-photo").extract())
      item['name'] = response.css('[itemprop="name"]::text').extract_first()
      item['type'] = response.css('.sg-header8.sg-navy::text').extract_first()
      rating = response.css('.profile-header-rating.sg-rating::attr(class)').extract_first()
      if rating is not None: 
        item['rating'] = rating[-3:].replace("_",".")
      else:
        item['rating'] = "NA"
      schools= response.css('div:nth-child(3) > div.sg-columns.sg-small-8.sg-end > div> ul > li::text').extract()
      item['schools'] = self.clean_item(schools)
      languages = response.css('div:nth-child(5) > div.sg-columns.sg-small-8.sg-end > div> ul > li::text').extract()
      item['languages'] = self.clean_item(languages)
      board_cert= response.css('div:nth-child(7) > div.sg-columns.sg-small-8.sg-end > div> ul > li::text').extract()
      item['board_cert'] = self.clean_item(board_cert)
      professional_memberships=response.css('div:nth-child(9) > div.sg-columns.sg-small-8.sg-end > div> ul > li::text').extract()
      item['professional_memberships'] = self.clean_item(professional_memberships)
      in_network_insurances = response.css('div:nth-child(11) > div.sg-columns.sg-small-8.sg-end > div> ul > li::text').extract()
      item['in_network_insurances'] = self.clean_item(in_network_insurances)
      specialties= response.css('div:nth-child(13) > div.sg-columns.sg-small-8.sg-end > div> ul > li::text').extract()
      item['specialties'] = self.clean_item(specialties)
      professional_statement=response.css('[itemprop="description"]::text').extract()
      item['professional_statement']= self.clean_item(professional_statement)
      zocdoc_awards= response.css('.js-badge::attr(data-title)').extract()
      item['zocdoc_awards'] = self.clean_item(zocdoc_awards)
      for review in response.css('.sg-row.profile-review'):
        if review.css('[itemprop="datePublished"]::text').extract_first() is not None:
          item.setdefault("review_date_published",list()).append(review.css('[itemprop="datePublished"]::text').extract_first())
        else: 
          item.setdefault("review_date_published",list()).append("NA")
        item.setdefault("review_author",list()).append(review.css('[itemprop="author"]::text').extract_first())
        ratings = review.css('.sg-rating-small::attr(class)').extract()
        clean_ratings = list(map(lambda x: x[-3:].replace("_","."), ratings ))
        if len(clean_ratings)==1:
          clean_ratings.extend(["NA","NA"])
        item.setdefault("review_overall_rating",list()).append(clean_ratings[0])
        item.setdefault("review_bedside_manner",list()).append(clean_ratings[1])
        item.setdefault("review_wait_time",list()).append(clean_ratings[2])
        if len(review.css('.sg-para4.sg-cool-grey::text').extract()) == 2:
          item.setdefault("verified",list()).append(review.css('.sg-para4.sg-cool-grey::text').extract()[1])
        else:
          item.setdefault("verified",list()).append("NA")
        if review.css('[itemprop="reviewBody"]::text').extract_first() is not None:
          item.setdefault("review_text",list()).append(review.css('[itemprop="reviewBody"]::text').extract_first())
        else:
          item.setdefault("review_text",list()).append("NA")
      if "review_date_published" in item:
        item['review_date_published'] = "|".join(item['review_date_published'])
      yield item

