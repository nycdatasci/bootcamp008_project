# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class GamesListItem(scrapy.Item):
    # define the fields for your item here like:
    name = scrapy.Field()
    link = scrapy.Field()


class MoviesListItem(scrapy.Item):
    name = scrapy.Field()
    link = scrapy.Field()
    date = scrapy.Field()


class TVShowsListItem(scrapy.Item):
    name = scrapy.Field()
    link = scrapy.Field()
    date = scrapy.Field()


class GameDetailsItem(scrapy.Item):
    image = scrapy.Field()
    developer = scrapy.Field()
    genre = scrapy.Field()
    rating = scrapy.Field()
    rlsDate = scrapy.Field()
    summary = scrapy.Field()
    link = scrapy.Field()


class MovieDetailsItem(scrapy.Item):
    image = scrapy.Field()
    director = scrapy.Field()
    genre = scrapy.Field()
    rating = scrapy.Field()
    rlsDate = scrapy.Field()
    summary = scrapy.Field()
    runtime = scrapy.Field()
    link = scrapy.Field()


class TVShowDetailsItem(scrapy.Item):
    image = scrapy.Field()
    creator = scrapy.Field()
    genre = scrapy.Field()
    rlsDate = scrapy.Field()
    summary = scrapy.Field()
    runtime = scrapy.Field()
    link = scrapy.Field()


class ReviewItem(scrapy.Item):
    gameID = scrapy.Field()
    movieID = scrapy.Field()
    tvShowID = scrapy.Field()

    author = scrapy.Field()
    publication = scrapy.Field()
    text = scrapy.Field()
    score = scrapy.Field()
    date = scrapy.Field()
    reviewType = scrapy.Field()

    thumbsUp = scrapy.Field()
    thumbsDown = scrapy.Field()

    link = scrapy.Field()