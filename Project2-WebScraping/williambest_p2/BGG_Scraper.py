# standard libraries
import time
# special libraries
import bs4
import argparse
# specific imports
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys

# sorry for the ugly urls, they are what they are..
# sorted by Board Game Rank
top_games_list = "https://boardgamegeek.com/search/boardgame?sort=rank&advsearch=1&q=&include%5Bdesignerid%5D=&include%5Bpublisherid%5D=&geekitemname=&range%5Byearpublished%5D%5Bmin%5D=&range%5Byearpublished%5D%5Bmax%5D=&range%5Bminage%5D%5Bmax%5D=&range%5Bnumvoters%5D%5Bmin%5D=&range%5Bnumweights%5D%5Bmin%5D=&range%5Bminplayers%5D%5Bmax%5D=&range%5Bmaxplayers%5D%5Bmin%5D=&range%5Bleastplaytime%5D%5Bmin%5D=&range%5Bplaytime%5D%5Bmax%5D=&floatrange%5Bavgrating%5D%5Bmin%5D=&floatrange%5Bavgrating%5D%5Bmax%5D=&floatrange%5Bavgweight%5D%5Bmin%5D=&floatrange%5Bavgweight%5D%5Bmax%5D=&colfiltertype=&searchuser=&playerrangetype=normal&B1=Submit"
bottom_games_list = "https://boardgamegeek.com/search/boardgame?sort=rank&sortdir=desc&advsearch=1&q=&include%5Bdesignerid%5D=&include%5Bpublisherid%5D=&geekitemname=&range%5Byearpublished%5D%5Bmin%5D=&range%5Byearpublished%5D%5Bmax%5D=&range%5Bminage%5D%5Bmax%5D=&range%5Bnumvoters%5D%5Bmin%5D=&range%5Bnumweights%5D%5Bmin%5D=&range%5Bminplayers%5D%5Bmax%5D=&range%5Bmaxplayers%5D%5Bmin%5D=&range%5Bleastplaytime%5D%5Bmin%5D=&range%5Bplaytime%5D%5Bmax%5D=&floatrange%5Bavgrating%5D%5Bmin%5D=1&floatrange%5Bavgrating%5D%5Bmax%5D=10&floatrange%5Bavgweight%5D%5Bmin%5D=&floatrange%5Bavgweight%5D%5Bmax%5D=&colfiltertype=&searchuser=&playerrangetype=normal&B1=Submit"

def load_continuation_data(continue_file):
    print "CAUTION: CONTINUATION NOT YET IMPLEMENTED"
    continuation_data = {}
    return continuation_data


def write_data_to_file(bgg_data, output_file):
    print "WRITE TO FILE NOT YET IMPLEMENTED"


# Specialized BGG scraping functions


# first scrape of data
def bgg_scrape_rank_page(browser, bgg_data, number_to_get):
    number_gotten = 0
    while number_gotten < number_to_get:
        time.sleep(3)
        table = browser.find_element_by_xpath("//table[@class='collection_table']")
        rows = table.find_elements_by_xpath(".//tr[@id='row_']")
        for row in rows:
            if number_gotten >= number_to_get:
                continue
            rank = row.find_element_by_xpath(".//td[1]").text
            game_name = row.find_element_by_xpath(".//td[3]/div[2]/a").text
            game_page = row.find_element_by_xpath(".//td[3]/div[2]/a").get_attribute("href")
            bgg_rating = row.find_element_by_xpath(".//td[4]").text
            user_rating = row.find_element_by_xpath(".//td[5]").text
            num_votes = row.find_element_by_xpath(".//td[6]").text
            game_data = {'rank': rank, 'name': game_name, 'page': game_page, "bbg_rating": bgg_rating,
                         "user_rating": user_rating, "num_votes": num_votes}
            bgg_data[rank] = game_data
            number_gotten += 1
            print number_gotten,'games collected'
        bgg_go_to_next_page(browser)


def bgg_sort_all_games(browser, sort_direction = 1):
    browser.find_element_by_xpath("//*[@id='header_top']/div[2]/ul/li[2]/a").click()
    time.sleep(3)
    browser.find_element_by_xpath("//*[@id='main_content']/form/p/input[1]").click()
    time.sleep(3)
    if sort_direction > 0:
        browser.find_element_by_xpath("//*[@id='collectionitems']/tbody/tr[1]/th[1]/a").click()
        time.sleep(3)
    if sort_direction < 0:
        browser.find_element_by_xpath("//*[@id='collectionitems']/tbody/tr[1]/th[1]/a").click()
        time.sleep(3)


def bgg_go_to_next_page(browser):
    browser.find_element_by_xpath("//*[@id='main_content']/p/a[5]/b").click()

# Generalized selenium and beautiful soup functions


# goes to a url and waits 1 second, in hopes of keeping the scraper from being blocked
def go_to_page(browser, url):
    browser.get(url)
    time.sleep(3)


def main(top_n = 500, bottom_n = None, output_file = None, continue_file = None):
    # load from continuation data if we have a file, else use a blank dict
    bgg_data = {} if not continue_file else load_continuation_data(continue_file)
    try:
        print 'Opening Browser'
        browser = webdriver.Firefox()
        print 'Going to list'
        go_to_page(browser, "https://boardgamegeek.com/")
        bgg_sort_all_games(browser)
        print 'Scraping top', top_n, 'games'
        bgg_scrape_rank_page(browser, bgg_data, top_n)
    except Exception, e:
        print 'SOME ERROR OCCURED'
        print e
    finally:
        browser.close()
        browser.quit()
        if output_file:
            write_data_to_file(bgg_data, output_file)
    pass

parser = argparse.ArgumentParser(description="Scrapes Game Data from Board Game Geek")
parser.add_argument("--top_n", "-t", nargs="?", dest="top_n", const=int, default=500,
                    help="Number of games to scrape from top of games ordered by review, Default: 500")
parser.add_argument("--bottom_n", "-b", nargs="?", dest="bottom_n", const=int, default=None,
                    help="Number of games to scrape from bottom of games ordered by review, Default: None")
parser.add_argument("--output", "-o", nargs="?", dest="output_file", const=str, default=None,
                    help="Full path to csv to write data to")
parser.add_argument("--continue", "-c", nargs="?", dest="continue_file", const=str, default=None,
                    help="Full path to csv to append to if continuing")
args = parser.parse_args()

if __name__ == "__main__":
    print "Scraping BGG"
    print "Games from top of list:", args.top_n if args.top_n else 0
    print "Games from bottom of list:", args.bottom_n if args.bottom_n else 0
    print "Writing to:", args.output_file if args.output_file else "NOWHERE"
    print "Continuing Using:", args.continue_file if args.continue_file else "NOWHERE"
    if args.continue_file:
        print "BE ADVISED! CONTINUATION NOT YET IMPLEMENTED!"
    main(args.top_n, args.bottom_n, args.output_file, args.continue_file)