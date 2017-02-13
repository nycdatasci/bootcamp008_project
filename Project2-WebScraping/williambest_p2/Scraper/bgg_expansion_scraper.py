def if_error(default=''):
    def worker(function):
        def wrapper(*args, **kwargs):
            rez = default
            try:
                rez = function(*args, **kwargs)
            except Exception as e:
                pass
            finally:
                return rez
        return wrapper
    return worker


@if_error('')
def bgg_count_expansions(soup):
    return len(soup.find_all('li', {'class': 'summary-item'}))


def bgg_scrape_expansions(soup, game_data):
    game_data['num_expansions'] = bgg_count_expansions(soup)