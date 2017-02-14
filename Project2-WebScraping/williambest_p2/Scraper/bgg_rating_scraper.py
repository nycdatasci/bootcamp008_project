from bs4 import BeautifulSoup
from bgg_regex import ratings_comments_re


def bgg_scrape_rating_count(soup):
    count = ''
    try:
        ratings_panel = soup.find('h3', text=ratings_comments_re).parent.parent
        ratings_info = ratings_panel.find('span', {'class': 'panel-body-toolbar-count'}).span
        count = ratings_info.find_all('strong')[-1].string
        count = count.replace(',', '')
    except Exception, e:
        print e
    return count


def bgg_ratings_distribution(browser, game_data, game_page):
    ratings_breakdown = {}
    for rating in xrange(1,11):
        url = '{}/ratings?rating={}'.format(game_page, rating)

        browser.get(url)
        # this is being used as a wait to make sure the data is there
        _ = browser.find_element_by_xpath('//strong')
        page_source = browser.page_source

        soup = BeautifulSoup(page_source, 'html.parser')

        count = bgg_scrape_rating_count(soup)
        ratings_breakdown[rating] = count
    game_data['ratings_breakdown'] = '|'.join([ratings_breakdown[i] for i in xrange(1, 11)])
