from bgg_regex import integer_re
from re import findall as re_findall


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


@if_error(['',''])
def bgg_player_count(soup):
    gameplay = soup.find('ul', {'class': 'gameplay'})
    players = gameplay.find_all('li')[0]
    players = players.find_all('div')[0]
    players = players.span.get_text()
    players = ''.join(players)
    players = re_findall(integer_re, players)
    if len(players) == 1:
        mn = players[0]
        mx = ''
    elif len(players) > 1:
        mn = players[0]
        mx = players[1]
    else:
        mn = ''
        mx = ''
    return [mn, mx]


@if_error('')
def bgg_best_players(soup):
    gameplay = soup.find('ul', {'class': 'gameplay'})
    players = gameplay.find_all('li')[0]
    players = players.find_all('div')[1]
    players = players.span.find_all('span')[-1].get_text()
    players = ''.join(players)
    players = re_findall(integer_re, players)
    if len(players) == 1:
        bp = players[0]
    else:
        bp = ''
    return bp


@if_error(['',''])
def bgg_get_playtime(soup):
    gameplay = soup.find('ul', {'class': 'gameplay'})
    playtime = gameplay.find_all('li')[1]
    playtime = playtime.find_all('div')[0]
    playtime = playtime.span.get_text()
    playtime = ''.join(playtime)
    playtime = re_findall(integer_re, playtime)
    if len(playtime) == 1:
        mn = playtime[0]
        mx = ''
    elif len(playtime) > 1:
        mn = playtime[0]
        mx = playtime[1]
    else:
        mn = ''
        mx = ''
    return [mn, mx]


@if_error('')
def bgg_min_age(soup):
    gameplay = soup.find('ul', {'class': 'gameplay'})
    min_age = gameplay.find_all('li')[2]
    min_age = min_age.find_all('div')[0]
    min_age = min_age.span.get_text()
    min_age = ''.join(min_age)
    min_age = re_findall(integer_re, min_age)
    if len(min_age) >= 1:
        min_age = min_age[0]
    else:
        min_age = ''
    return min_age


# do this last, browser needs to be on the game page already so we don't have to load it again
def bgg_scrape_header(soup, game_data):
    mn, mx = bgg_player_count(soup)
    game_data['min_players'] = mn
    game_data['max_players'] = mx
    game_data['best_player'] = bgg_best_players(soup)
    mn, mx = bgg_get_playtime(soup)
    game_data['min_playtime'] = mn
    game_data['max_playtime'] = mx
    game_data['min_age'] = bgg_min_age(soup)