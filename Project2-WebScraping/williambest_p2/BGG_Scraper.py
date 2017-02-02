# standard libraries
import time
import re
import argparse
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


# Specialized BGG scraping functions

# pre-processed regexs for function below
game_designer_re = re.compile("/boardgamedesigner/.*")
full_credits_re = re.compile("\s*Full Credits\s*")
designers_re = re.compile("Designers")
def bgg_parse_game_page(browser, bgg_data, game_page):
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


# first scrape of data
# Expansions don't seem to show up with a bgg_rank
def bgg_scrape_rank_page(browser, bgg_data, number_to_get):
    number_gotten = 0
    # if we want to scrape all images, number_to_get will be float(inf)
    while number_gotten < number_to_get:
        soup = BeautifulSoup(browser.page_source, "html.parser")
        rows = soup.find_all("tr", {"id": "row_"})
        for row in rows:
            if number_gotten >= number_to_get:
                continue
            columns = row.find_all("td")
            rank = int(columns[0].get_text())
            game_name = columns[2].find("a").get_text()
            game_page = columns[2].find("a")['href']
            bgg_rating = float(columns[3].get_text())
            user_rating = float(columns[4].get_text())
            num_votes = int(columns[5].get_text())
            game_data = {'rank': rank, 'name': game_name, 'page': game_page, "bbg_rating": bgg_rating,
                         "user_rating": user_rating, "num_votes": num_votes}
            bgg_data[rank] = game_data
            number_gotten += 1
            print number_gotten,'games collected'
        if not bgg_go_to_next_page(browser):
            break


def bgg_sort_all_games(browser):
    # the waits used here are so the page can re-load, we don't want to click on the same element exactly again
    browser.find_element_by_xpath("//*[@id='header_top']/div[2]/ul/li[2]/a").click()
    browser.find_element_by_xpath("//*[@id='main_content']/form/p/input[1]").click()
    browser.find_element_by_xpath("//*[@id='collectionitems']/tbody/tr[1]/th[1]/a").click()

# Generalized selenium and beautiful soup functions


# goes to a url and waits 1 second, in hopes of keeping the scraper from being blocked
def go_to_page(browser, url):
    browser.get(url)
    time.sleep(10)


def main(max_games = 5000, output_file = None, continue_file = None):
    # load from continuation data if we have a file, else use a blank dict
    bgg_data = {} if not continue_file else load_continuation_data(continue_file)
    try:
        print 'Opening Browser'
        browser = webdriver.Firefox()
        browser.implicitly_wait(15)
        print 'Going to list'
        go_to_page(browser, "https://boardgamegeek.com/")
        bgg_sort_all_games(browser)
        print 'Scraping', max_games, 'games'
        bgg_scrape_rank_page(browser, bgg_data, max_games)
        for rank, game_data in bgg_data.iteritems():
            print rank, game_data
            game_page = game_data['page']
            bgg_parse_game_page(browser, bgg_data, game_page)
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