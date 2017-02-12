# general case for elements in lists
def get_element(soup, element_name):
    elements = []
    try:
        data = soup.find("a", {"name": element_name})
        data = data.parent.parent
        # year_published has a special case
        if element_name == "yearpublished":
            data = data.find_all("div")[-1]
            elements = [element.get_text() for element in data.span.find_all("span")]
        else:
            elements = [element.a.get_text() for element in data.find_all("div")]
        elements = filter(lambda d: len(d) > 1, elements)
    except Exception as e:
        print e, element_name
    finally:
        return '|'.join(set(elements))


def bgg_scrape_credits(soup, game_data):
    game_data['designers'] = get_element(soup, "boardgamedesigner")
    game_data['categories'] = get_element(soup, "boardgamecategory")
    game_data['mechanics'] = get_element(soup, "boardgamemechanic")
    game_data['year_published'] = get_element(soup, "yearpublished")