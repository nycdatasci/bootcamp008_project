from scrapy import Item, Field


class AmazonProductItem(Item):
    asin = Field()
    product_title = Field()
    bsr = Field()
    category = Field()
    list_price = Field()
    sale_price = Field()
    shipping = Field()
    num_reviews = Field()
    num_questions = Field()
    in_stock = Field()
    description = Field()
    dimensions = Field()
    shipping_wt = Field()


class AmazonCategoryItem(Item):
    name = Field()
    url = Field()


class AmazonListingItem(Item):
    url = Field()
