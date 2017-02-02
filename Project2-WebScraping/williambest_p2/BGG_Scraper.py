# standard libraries
import time
import re
import argparse
import urllib2
# specific imports
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys


def load_continuation_data(continue_file):
    print "CAUTION: CONTINUATION NOT YET IMPLEMENTED"
    continuation_data = {}
    return continuation_data


def write_data_to_file(bgg_data, output_file):
    print "WRITE TO FILE NOT YET IMPLEMENTED"


# Specialized BGG scraping functions and data

bgg_search_page = "https://boardgamegeek.com/search/boardgame/page/1?sort=rank&advsearch=1&sortdir=asc"


# regexes that will be used
ratings_comments_re = re.compile(r"\s*Ratings & Comments\s*")
non_integer_re = re.compile(r"[^\d]")
game_designer_re = re.compile(r"/boardgamedesigner/.*")
full_credits_re = re.compile(r"\s*Full Credits\s*")
designers_re = re.compile(r"Designers")


def bgg_scrape_rating_count(page_source):
    count = ''
    try:
        soup = BeautifulSoup(page_source, "html.parser")
        ratings_panel = soup.find("h3", text=ratings_comments_re).parent.parent
        ratings_info = ratings_panel.find("span", {"class": "panel-body-toolbar-count"}).span
        count = ratings_info.find_all("strong")[-1].string
        count = non_integer_re.sub('', count)
    except Exception, e:
        print e
    return count


def bgg_ratings_distribution(browser, game_data, game_page):
    ratings_breakdown = {}
    for rating in xrange(1,11):
        browser.get("{}/ratings?rating={}".format(game_page, rating))
        time.sleep(3)
        count = bgg_scrape_rating_count(browser.page_source)
        ratings_breakdown[rating] = count
    game_data['ratings_breakdown'] = '|'.join([ratings_breakdown[i] for i in xrange(1, 11)])
    print game_data['ratings_breakdown']


def bgg_parse_game_page(browser, game_data, game_page):
    # ratings_graph = stats_section.find_element_by_xpath(".//div[@class='stats-graph']")
    # ratings_counts = ratings_graph.find_element_by_xpath(".//svg/g[1]/g[4]")
    # got to credits page
    #browser.get(game_page+"/credits")
    #soup = BeautifulSoup(browser.page_source, "html.parser")
    #credit_data = soup.find("h3", text=full_credits_re)
    #credit_data = credit_data.parent
    #credit_data = credit_data.parent
    #credit_data = credit_data.find("span", text=designers_re)
    #print credit_data.prettify()
    #credit_data = credit_data.parent
    #credit_data = credit_data.parent
    #
    #print credit_data.prettify()
    #credit_data = credit_data.parent
    #credit_data = credit_data.next_sibling
    #print credit_data.prettify()
    #designer_elements = credit_data
    #designers = [designer_element.get_text() for designer_element in designer_elements]
    #print designers
    bgg_ratings_distribution(browser, game_data, game_page)
    pass


def bgg_go_to_next_page(browser):
    try:
        browser.find_element_by_xpath("//*[@id='main_content']/p/a[5]/b").click()
    except NoSuchElementException, nse:
        print "End of games list"
        return False
    except Exception, e:
        print "Unexpected Error"
        raise e
    return True


# get initial game data of all games on given rank page
def bgg_scrape_rank_page(page_source):
    bgg_data = {}
    soup = BeautifulSoup(page_source, "html.parser")
    rows = soup.find_all("tr", {"id": "row_"})
    for row in rows:
        columns = row.find_all("td")
        rank = int(columns[0].get_text())
        game_name = columns[2].find("a").get_text()
        game_page = columns[2].find("a")['href']
        game_page = "https://boardgamegeek.com" + game_page
        bgg_rating = float(columns[3].get_text())
        user_rating = float(columns[4].get_text())
        num_votes = int(columns[5].get_text())
        game_id = re.search("\d+", game_page).group(0)
        game_data = {'rank': rank, 'name': game_name, 'page': game_page, "bbg_rating": bgg_rating,
                     "user_rating": user_rating, "num_votes": num_votes}
        bgg_data[game_id] = game_data
    return bgg_data


# first scrape of data
# start building bgg_data
def bgg_scrape_all_rank_pages(browser, bgg_data, number_to_get):
    number_gotten = 0
    while True:
        bgg_data.update(bgg_scrape_rank_page(browser.page_source))
        number_gotten += 1
        print number_gotten,'games collected'
        #if not bgg_go_to_next_page(browser):
        #    break
        break


def main(max_games = 5000, output_file = None, continue_file = None):
    # load from continuation data if we have a file, else use a blank dict
    bgg_data = {} if not continue_file else load_continuation_data(continue_file)
    try:
        print 'Opening Browser'
        browser = webdriver.Firefox()
        browser.implicitly_wait(15)
        print 'Going to list'
        browser.get(bgg_search_page)
        print 'Scraping', max_games, 'games'
        bgg_scrape_all_rank_pages(browser, bgg_data, max_games)
        for game_id, game_data in bgg_data.iteritems():
            print game_id, game_data['rank'], game_data['name']
            game_page = game_data['page']
            bgg_parse_game_page(browser, game_data, game_page)
            bgg_data[game_id] = game_data
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
parser.add_argument("--max_games", "-g", nargs="?", dest="max_games", const=int, default=5000,
                    help="Number of games to scrape from top of games ordered by BGG Rank, Default: All >> float(inf)")
parser.add_argument("--output", "-o", nargs="?", dest="output_file", const=str, default=None,
                    help="Full path to csv to write data to")
parser.add_argument("--continue", "-c", nargs="?", dest="continue_file", const=str, default=None,
                    help="Full path to csv to append to if continuing")
args = parser.parse_args()

if __name__ == "__main__":
    print "Scraping BGG"
    print "Games from top of list:", args.max_games
    print "Writing to:", args.output_file if args.output_file else "NOWHERE"
    print "Continuing Using:", args.continue_file if args.continue_file else "NOWHERE"
    if args.continue_file:
        print "BE ADVISED! CONTINUATION NOT YET IMPLEMENTED!"
    main(int(args.max_games), args.output_file, args.continue_file)