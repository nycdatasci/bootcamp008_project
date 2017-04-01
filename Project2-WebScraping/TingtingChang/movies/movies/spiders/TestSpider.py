# -*- coding: utf-8 -*-

import scrapy
from scrapy.selector import Selector
from movies.items import MoviesItem

class ReviewsSpider(scrapy.Spider):
  name = "test_spider"
  allowed_domains = ["rottentomatoes.com"]
  download_delay = 1
 
  base_url = "https://www.rottentomatoes.com/m/"
  start_urls = [
     # base_url + "zootopia/reviews",
     # base_url + "moonlight_2016/reviews",
     # base_url + "hell_or_high_water/reviews",
     # base_url + "la_la_land/reviews",
     # base_url + "arrival_2016/reviews",
     # base_url + "the_jungle_book_2016/reviews",
     # base_url + "manchester_by_the_sea/reviews",
     # base_url + "love_and_friendship/reviews",
     # base_url + "finding_dory/reviews",
     # base_url + "kubo_and_the_two_strings_2016/reviews",
     # base_url + "things_to_come_2016/reviews",
     # base_url + "hunt_for_the_wilderpeople/reviews",
     # base_url + "moana_2016/reviews",
     # base_url + "dont_think_twice/reviews",
     # base_url + "captain_america_civil_war/reviews",
     # base_url + "paterson/reviews",
     # base_url + "sing_street/reviews",
     # base_url + "weiner/reviews",
     # base_url + "tower_2016/reviews",
     # base_url + "the_nice_guys/reviews",
     # base_url + "cameraperson/reviews",
     # base_url + "eye_in_the_sky/reviews",
     # base_url + "embrace_of_the_serpent/reviews",
     # base_url + "only_yesterday_1991/reviews",
     # base_url + "the_witch_2016/reviews",
     # base_url + "little_men_2016/reviews",
     # base_url + "oj_made_in_america/reviews",
     # base_url + "the_wailing/reviews",
     # base_url + "fences_2016/reviews",
     # base_url + "doctor_strange_2016/reviews",
     # base_url + "the_edge_of_seventeen/reviews",
     # base_url + "10_cloverfield_lane/reviews",
     # base_url + "under_the_shadow/reviews",
     # base_url + "the_fits_2016/reviews",
     # base_url + "long_way_north/reviews",
     # base_url + "april_and_the_extraordinary_world_2016/reviews",
     # base_url + "de_palma/reviews",
     # base_url + "13th/reviews",
     # base_url + "cemetery_of_splendor/reviews",
     # base_url + "krisha_2016/reviews",
     # base_url + "rams/reviews",
     # base_url + "dark_horse_2016/reviews",
     # base_url + "almost_holy/reviews",
     # base_url + "aferim/reviews",
     # base_url + "the_handmaiden/reviews",
     # base_url + "aquarius/reviews",
     # base_url + "the_dark_horse_2016/reviews",
     # base_url + "neruda_2016/reviews",
     # base_url + "train_to_busan/reviews",
     # base_url + "marguerite/reviews",
     # base_url + "jackie_2016/reviews",
     # base_url + "gimme_danger/reviews",
     # base_url + "tickled/reviews",
     # base_url + "the_beatles_eight_days_a_week_the_touring_years/reviews",
     # base_url + "rogue_one_a_star_wars_story/reviews",
     # base_url + "green_room_2016/reviews",
     # base_url + "gleason_2016/reviews",
     # base_url + "queen_of_katwe_2016/reviews",
     # base_url + "nuts_2016/reviews",
     # base_url + "life_animated/reviews",
     # base_url + "lo_and_behold_reveries_of_the_connected_world/reviews",
     # base_url + "the_love_witch/reviews",
     # base_url + "toni_erdmann/reviews",
     # base_url + "loving_2016/reviews",
     # base_url + "hail_caesar_2016/reviews",
     # base_url + "the_lobster/reviews",
     # base_url + "our_little_sister/reviews",
     # base_url + "the_eagle_huntress/reviews",
     # base_url + "the_innocents_2016/reviews",
     # base_url + "the_little_prince_2016/reviews",
     # base_url + "southside_with_you/reviews",
     # base_url + "sully/reviews",
     # base_url + "i_daniel_blake/reviews",
     # base_url + "fire_at_sea_2016/reviews",
     # base_url + "miss_hokusai/reviews",
     # base_url + "deadpool/reviews",
     # base_url + "a_bigger_splash_2016/reviews",
     # base_url + "hacksaw_ridge/reviews",
     # base_url + "i_am_not_a_serial_killer/reviews",
     # base_url + "the_last_man_on_the_moon/reviews",
     # base_url + "florence_foster_jenkins_2016/reviews",
     # base_url + "dont_breathe_2016/reviews",
     # base_url + "eat_that_question_frank_zappa_in_his_own_words/reviews",
     # base_url + "dheepan/reviews",
     # base_url + "lion_2016/reviews",
     # base_url + "star_trek_beyond/reviews",
     # base_url + "demon_2016/reviews",
     # base_url + "certain_women_2016/reviews",
     # base_url + "la_belle_saison/reviews",
     # base_url + "petes_dragon_2016/reviews",
     # base_url + "everybody_wants_some/reviews",
     # base_url + "elle_2016/reviews",
     # base_url + "barbershop_the_next_cut_2016/reviews",
     # base_url + "zero_days/reviews",
     # base_url + "a_war/reviews",
     # base_url + "the_witness_2016/reviews",
     # base_url + "a_man_called_ove/reviews",
     # base_url + "the_measure_of_a_man_2016/reviews",
     # base_url + "city_of_gold_2016/reviews",
     # base_url + "kung_fu_panda_3/reviews",
     base_url + "city_of_gold_2016/reviews",

     

     ]

  # moviesDict = {}


  def parse(self, response):

    page_text = response.xpath('//*[@id="reviews"]/div[2]/div[5]/span/text()').extract()[0]
    current_page = int(page_text[5])
    last_page = int(page_text[-2::]) 

    if last_page < 1:
      return
    else:
      page_urls = [response.url + "?page=" + str(current_page) for current_page in range(1, last_page + 1)]
      print page_urls
      for page_url in page_urls:
        yield scrapy.Request(page_url,
                            callback = self.parse_listing_results_page)

  

  def parse_listing_results_page(self, response):
    rows = response.xpath('//*[@class="review_table"]/div').extract()

    for i in range(0, len(rows)):
      critic_name = Selector(text=rows[i]).xpath('//div[1]/div[1]/div[3]/a[1]/text()').extract()[0]
      source_name = Selector(text=rows[i]).xpath('//div[1]/div[1]/div[3]/a[2]/em/text()').extract()[0]
      review_date = Selector(text=rows[i]).xpath('//div[2]/div[2]/div[1]/text()').extract()[0]
      review_detail = Selector(text=rows[i]).xpath('//div[2]/div[2]/div[2]/div[1]/text()').extract()[0]
      
      reviewsItem = MoviesItem()
      reviewsItem['critic_name'] = critic_name
      reviewsItem['source_name'] = source_name

      reviewsItem['review_date'] = review_date
      reviewsItem['review_detail'] = review_detail

      yield reviewsItem
  

 

    