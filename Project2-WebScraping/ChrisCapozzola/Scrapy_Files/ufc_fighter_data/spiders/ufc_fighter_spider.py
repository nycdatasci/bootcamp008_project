from scrapy import Request
from scrapy import Spider
from scrapy.selector import Selector
from scrapy.utils.response import get_base_url
from ufc_fighter_data.items import UfcFighterDataItem


class UfcFighterDataSpider(Spider):
    name = "ufc_fighter_spider"
    allowed_urls = ['http://www.ufc.com/']
    start_urls = ['http://www.ufc.com/fighter/Weight_Class/']

    def parse(self, response):
        part1 = 'http://www.ufc.com/fighter/Weight_Class/filterFighters?offset='
        part2 = '&max=1897&sort=lastName&order=asc&weightClass=&fighterFilter=All'
        for i in xrange(0,1881,20):
            page_url = part1 + str(i) + part2
            yield Request(page_url, callback=self.parse_fighter_listing_page)


    def parse_fighter_listing_page(self, response):
        rel_fighter = response.xpath('//a[@class="fighter-name"]/@href').extract()
        for i in rel_fighter:
            base = 'http://www.ufc.com'
            fighter_url = base + str(i)
            yield Request(fighter_url, callback=self.parse_fighter_page_contents)


    def parse_fighter_page_contents(self, response):
        
        item = UfcFighterDataItem()

        fighter_name = response.url.split('/')[-1]
        fight_record = str(response.xpath('//*[@id="fighter-skill-record"]//text()').extract_first())
        hometown = str(response.xpath('//*[@id="fighter-from"]//text()').extract_first()).replace("\t","").replace("\n","")
        fight_out_of = str(response.xpath('//*[@id="fighter-lives-in"]//text()').extract_first()).replace("\t","").replace("\n","")
        age = str(response.xpath('//*[@id="fighter-age"]//text()').extract_first())
        height = str(response.xpath('//*[@id="fighter-height"]//text()').extract_first())
        weight = str(response.xpath('//*[@id="fighter-weight"]//text()').extract_first())
        reach = str(response.xpath('//*[@id="fighter-reach"]//text()').extract_first())
        leg_reach = str(response.xpath('//*[@id="fighter-leg-reach"]//text()').extract_first())
        try:
            attempted_strikes = str(response.xpath('//*[@id="fight-history"]/div[7]/div[1]/div[3]//text()').extract_first())
            standing_strikes_landed = str(response.xpath('//*[@id="types-of-successful-strikes-graph"]/div[9]/div//text()').extract_first())
            ground_strikes_landed = str(response.xpath('//*[@id="types-of-successful-strikes-graph"]/div[10]/div//text()').extract_first())
            other_strikes_landed = str(response.xpath('//*[@id="types-of-successful-strikes-graph"]/div[11]/div//text()').extract_first())
            attempted_takedowns = str(response.xpath('//*[@id="fight-history"]/div[8]/div[1]/div[3]//text()').extract_first())
            successful_takedowns = str(response.xpath('//*[@id="total-takedowns-number"]//text()').extract()[1])
            submissions = str(response.xpath('//*[@id="successful-submissions"]//text()').extract_first())
            passes = str(response.xpath('//*[@id="successful-passes"]//text()').extract_first())
            sweeps = str(response.xpath('//*[@id="successful-sweeps"]//text()').extract_first())
            strikes_avoided_pct = str(response.xpath('//*[@id="striking-defense-pecentage"]//text()').extract_first()).replace("\n","").replace(" ","")
            takedowns_defended_pct = str(response.xpath('//*[@id="takedown-defense-percentage"]//text()').extract_first()).replace("\n","").replace(" ","")
        except IndexError:
            attempted_strikes = ""
            standing_strikes_landed = ""
            ground_strikes_landed = ""
            other_strikes_landed = ""
            attempted_takedowns = ""
            successful_takedowns = ""
            submissions = ""
            passes = ""
            sweeps = ""
            strikes_avoided_pct = ""
            takedowns_defended_pct = ""


        item['fighter_name'] = fighter_name
        item['fight_record'] = fight_record
        item['hometown'] = hometown
        item['fight_out_of'] = fight_out_of
        item['age'] = age
        item['height'] = height
        item['weight'] = weight
        item['reach'] = reach
        item['leg_reach'] = leg_reach
        item['attempted_strikes'] = attempted_strikes
        item['standing_strikes_landed'] = standing_strikes_landed
        item['ground_strikes_landed'] = ground_strikes_landed
        item['other_strikes_landed'] = other_strikes_landed
        item['attempted_takedowns'] = attempted_takedowns
        item['successful_takedowns'] = successful_takedowns
        item['submissions'] = submissions
        item['passes'] = passes
        item['sweeps'] = sweeps
        item['strikes_avoided_pct'] = strikes_avoided_pct
        item['takedowns_defended_pct'] = takedowns_defended_pct       

        yield item

