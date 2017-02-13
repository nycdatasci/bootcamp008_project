from bgg_regex import std_re, comments_re, fans_re, weight_re, clean_integer, plays_re, prev_owned_re, own_re


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


@if_error()
def bgg_get_std_deviation(soup):
    std_deviation = soup.find("div", text=std_re)
    std_deviation = std_deviation.parent
    std_deviation = std_deviation.find_all("div")[-1]
    std_deviation = std_deviation.get_text()
    std_deviation = float(std_deviation)
    return std_deviation


@if_error()
def bgg_get_num_comments(soup):
    num_comments = soup.find("div", text=comments_re)
    num_comments = num_comments.parent
    num_comments = num_comments.find_all("div")[-1]
    num_comments = num_comments.a.get_text()
    num_comments = clean_integer(num_comments)
    return num_comments


@if_error()
def bgg_get_num_fans(soup):
    num_fans = soup.find("div", text=fans_re)
    num_fans = num_fans.parent
    num_fans = num_fans.find_all("div")[-1]
    num_fans = num_fans.a.get_text()
    num_fans = clean_integer(num_fans)
    return num_fans


@if_error()
def bgg_get_weight(soup):
    weight = soup.find("div", text=weight_re)
    weight = weight.parent
    weight = float(weight.find("span").get_text())
    return weight


@if_error()
def bgg_get_owned(soup):
    owned = soup.find("div", text=own_re)
    owned = owned.parent
    owned = owned.find_all("div")[1]
    owned = clean_integer(owned.find("a").get_text())
    return owned


@if_error()
def bgg_get_prev_owned(soup):
    prev_owned = soup.find("div", text=prev_owned_re)
    prev_owned = prev_owned.parent
    prev_owned = prev_owned.find_all("div")[1]
    prev_owned = clean_integer(prev_owned.find("a").get_text())
    return prev_owned


@if_error()
def bgg_get_total_plays(soup):
    plays = soup.find("div", text=plays_re)
    plays = plays.parent
    plays = plays.find_all("div")[1]
    plays = clean_integer(plays.find("a").get_text())
    return plays


def bgg_scrape_stats(soup, game_data):
    game_data['avg_rating_std_deviations'] = bgg_get_std_deviation(soup)
    game_data['num_comments'] = bgg_get_num_comments(soup)
    game_data['num_fans'] = bgg_get_num_fans(soup)
    game_data['weight'] = bgg_get_weight(soup)
    game_data['total_plays'] = bgg_get_total_plays(soup)
    game_data['owned'] = bgg_get_owned(soup)
    game_data['prev_owned'] = bgg_get_prev_owned(soup)
    pass