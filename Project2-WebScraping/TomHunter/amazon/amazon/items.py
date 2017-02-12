from scrapy import Item, Field


class AmazonProductBaseItem(Item):
    url = Field()
    product_title = Field()
    category = Field()
    list_price = Field()
    sale_price = Field()
    shipping = Field()
    num_reviews = Field()
    num_questions = Field()
    reviews_url = Field()
    avg_rating = Field()
    in_stock = Field()
    description = Field()


class AmazonCategoryItem(Item):
    name = Field()
    url = Field()


class AmazonListingItem(Item):
    url = Field()
