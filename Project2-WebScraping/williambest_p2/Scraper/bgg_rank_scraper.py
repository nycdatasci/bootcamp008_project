from bs4 import BeautifulSoup
from re import search as re_search
from bgg_regex import clean_integer, clean_float


# get initial game data of all games on given rank page
def bgg_scrape_rank_page(soup):
    partial_bgg_data = {}
    rows = soup.find_all('tr', {'id': 'row_'})
    for row in rows:
        columns = row.find_all('td')
        rank = clean_integer(columns[0].get_text())
        game_name = columns[2].find('a').get_text()
        game_page = columns[2].find('a')['href']
        game_page = 'https://boardgamegeek.com' + game_page
        geek_rating = clean_float(columns[3].get_text())
        avg_rating = clean_float(columns[4].get_text())
        num_votes = clean_integer(columns[5].get_text())
        game_id = re_search('\d+', game_page).group(0)
        game_data = {'game_id': game_id, 'rank': rank, 'name': game_name, 'page': game_page, 'geek_rating': geek_rating,
                     'avg_rating': avg_rating, 'num_votes': num_votes}
        partial_bgg_data[game_id] = game_data
    return partial_bgg_data


# first scrape of data
# start building bgg_data
def bgg_scrape_ranks(browser, search_page_format, bgg_data, start_page, end_page):
    for page_number in xrange(start_page, end_page + 1):
        url = search_page_format.format(page_number)
        browser.get(url)
        # make sure page has loaded
        _ = browser.find_element_by_xpath('//*[@id="row_"]/td[1]')
        soup = BeautifulSoup(browser.page_source, 'html.parser')
        bgg_data.update(bgg_scrape_rank_page(soup))
        number_gotten = len(bgg_data)
