# standard libraries
import time, os, sys, argparse, sqlite3, string
# specific imports
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException, TimeoutException
# internal modules
from bgg_stats_scraper import bgg_scrape_stats
from bgg_credits_scraper import bgg_scrape_credits
from bgg_header_scraper import bgg_scrape_header
from bgg_rank_scraper import bgg_scrape_ranks
from bgg_expansion_scraper import bgg_scrape_expansions

## Globals
path_to_phantomjs = r'C:\Program Files (x86)\PhantomJS\bin\phantomjs.exe'
bgg_search_page_format = 'https://boardgamegeek.com/search/boardgame/page/{}?sort=rank&advsearch=1&sortdir=asc'


def write_data_to_sqlite(db_data, game_id, game_data):
    db_conn = None
    try:
        db_name = db_data['db_name']
        table_name = db_data['table_name']
        column_names = db_data['column_names']

        db_conn = sqlite3.connect(db_name, timeout=15)
        # clean quotes out of game_Data
        for k,v in game_data.iteritems():
            game_data[k] = u"{}".format(v).replace('"', "'")
        ordered_data = [u'"{}"'.format(game_data[col] if col in game_data.keys() else '') for col in column_names]
        insert_command = u'INSERT INTO {} VALUES ({});'.format(table_name, ', '.join(ordered_data))

        db_conn.cursor().execute(insert_command)
        db_conn.commit()
    except Exception as e:
        print 'Failed to write to DB'
        print e
    finally:
        if db_conn:
            db_conn.close()


def bgg_parse_game_page(browser, game_id, game_data, game_page, db_data):
    game_name = game_data['name']
    game_name = game_name.encode('utf-8')
    print r'Scraping data for: {} ({}), Rank #{}'.format(game_name, game_id, game_data['rank'])

    browser.get(game_page + '/stats')
    #_ = browser.find_element_by_xpath('//h3[@class="panel-title"]')
    soup = BeautifulSoup(browser.page_source, 'html.parser')
    bgg_scrape_stats(soup, game_data)

    browser.get(game_page + '/credits')
    #_ = browser.find_element_by_xpath('//h3[@class="panel-title"]')
    soup = BeautifulSoup(browser.page_source, 'html.parser')
    bgg_scrape_credits(soup, game_data)

    browser.get(game_page + '/expansions')
    #_ = browser.find_element_by_xpath('//h3[@class="panel-title"]')
    soup = BeautifulSoup(browser.page_source, 'html.parser')
    bgg_scrape_expansions(soup, game_data)

    # re-use previous soup
    bgg_scrape_header(soup, game_data)

    write_data_to_sqlite(db_data, game_id, game_data)


def bgg_scrape_all_games(browser, bgg_data, db_data):
    for game_id, game_data in bgg_data.iteritems():
        bgg_parse_game_page(browser, game_id, game_data, game_data['page'], db_data)
        bgg_data[game_id] = game_data


def initialize_webdriver(headless, implicit_wait_time=15):
    print 'Opening Browser'
    if headless:
        browser = webdriver.PhantomJS(executable_path=path_to_phantomjs,
                                      service_log_path=os.path.devnull)
    else:
        browser = webdriver.Firefox()
    browser.implicitly_wait(implicit_wait_time)
    return browser


def create_table_if_not_exists(db_data):
    db_conn = None
    try:
        db_name = db_data['db_name']
        table_name = db_data['table_name']
        column_names = db_data['column_names']

        db_conn = sqlite3.connect(db_name, timeout=15)
        cursor = db_conn.cursor()

        cursor.execute('SELECT name FROM sqlite_master WHERE type="table" AND name=?;', (table_name,))
        exists = bool(cursor.fetchone())

        if not exists:
            # c command
            create_command = u'CREATE TABLE {} ({});'.format(table_name, ', '.join(column_names))
            db_conn.cursor().execute(create_command)
            db_conn.commit()
            print 'Table Created'
    except Exception as e:
        print 'Failed to create table'
        print e
    finally:
        if db_conn:
            db_conn.close()


def main(start_page, end_page, db_name, headless=False):
    # load from continuation data if we have a file, else use a blank dict
    bgg_data = {}
    browser = None
    try:
        browser = initialize_webdriver(headless, 30)

        table_name = 'board_games'
        column_names = ['game_id', 'name', 'page', 'year_published', 'rank',
                        'num_votes', 'geek_rating', 'avg_rating', 'avg_rating_std_deviations',
                        'num_comments', 'num_fans', 'weight',
                        'designers', 'mechanics', 'categories',
                        'min_players', 'max_players', 'best_players', 'min_age',
                        'min_playtime', 'max_playtime',
                        'num_expansions',
                        'total_plays', 'owned', 'prev_owned'
                        ]

        db_data = {'db_name': db_name, 'table_name': table_name, 'column_names': column_names}

        create_table_if_not_exists(db_data)

        t = time.time()
        bgg_scrape_ranks(browser, bgg_search_page_format, bgg_data, start_page, end_page)
        bgg_scrape_all_games(browser, bgg_data, db_data)
        tt = time.time() - t
        t_mu = tt / len(bgg_data)

        print 'Average Time:', t_mu
        estimated_time = t_mu * 5000.0 / 3600.0 / (50 / (start_page - end_page))
        print 'Total Est: {}'.format(estimated_time)

    except TimeoutException as te:
        print te
    except NoSuchElementException as nse:
        print 'Selenium could not find element'
        print nse.msg
    except Exception as e:
        import traceback
        exc_type, exc_value, exc_traceback = sys.exc_info()
        print traceback.print_tb(exc_traceback)
        print e
    finally:
        if browser:
            browser.close()
            browser.quit()

parser = argparse.ArgumentParser(description='Scrapes Game Data from Board Game Geek')
parser.add_argument('--start_page', '-s', nargs='?', dest='start_page', const=int, default=1,
                    help='Rank page to start on')
parser.add_argument('--end_page', '-e', nargs='?', dest='end_page', const=int, default=50,
                    help='Rank page to end on')
parser.add_argument('--database', '-db', nargs='?', dest='sqlite_db', const=str, default=r'C:\Users\William\test.db',
                    help='Full path to csv to write data to')
parser.add_argument('--headless', '-hh', dest='headless', action='store_true',
                    help='Option to run the browser headless using PhantomJS')
args = parser.parse_args()

if __name__ == '__main__':
    print 'Scraping BGG'
    print 'Scraping rank pages {} to {}'.format(args.start_page, args.end_page)
    print 'Writing to:', args.sqlite_db if args.sqlite_db else 'NOWHERE'
    print 'Running Headless:', args.headless
    main(int(args.start_page), int(args.end_page), args.sqlite_db, args.headless)
