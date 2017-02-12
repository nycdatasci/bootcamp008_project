import scrapy
import pandas as pd
from amazon.items import AmazonProductBaseItem


class AmazonProductSpider(scrapy.Spider):
    name = "products"
    allowed_domains = ["amazon.com"]
    start_urls = list(pd.read_csv('data/listing_urls.csv')['url'])

    # use for LinkExtractors
    # '//div[contains(@id,"summaryStars")]/a' -- links to reviews

    def parse(self, response):

        def gxp(xpath):
            return response.xpath(xpath)

        def clean(text):
            try:
                if type(text) == list:
                    text = ''.join(text).strip()
                    return text.replace('\t', '').replace('\n', '').strip()
                else:
                    return text.replace('\t', '').replace('\n', '').strip()
            except:
                return text

        def clean_list(list_text, join=False):
            return list(map(lambda x:
                            x.replace('\t', '').replace('\n', '').strip(),
                            list_text)
                        )

        def get_product_info(key_xp, vals_xp):
            # still needs to handle for multiple valued cells like BSR
            keys = gxp(key_xp).extract()
            keys = [x.replace(' ', '_')
                    for x in clean_list(keys) if x != '']
            vals = gxp(vals_xp).extract()
            vals = [x for x in clean_list(vals) if x != '' if x != ')']
            return {keys: vals for keys, vals in list(zip(keys, vals))}

        def get_rating_hist():
            keys = gxp(
                '//table[contains(@id,"histogramTable")]/tr/td[1]/a/text()'
            ).extract()
            vals = gxp(
                '//table[contains(@id,"histogramTable")]/tr/td[3]/a/text()'
            ).extract()
            keys = [k.replace(' ', '_') for k in keys]
            return {keys: vals for keys, vals in list(zip(keys, vals))}

        def update_fields(obj, update):
            for k in update.keys():
                obj.fields.update({k: {}})
            return obj

        # xpaths
        product_title = gxp(
            '//h1[@id="title"]/span/text()'
        ).extract()
        category = gxp(
            '//a[@class="a-link-normal a-color-tertiary"]/text()'
        ).extract_first()
        list_price = gxp(
            '//span[contains(@class,"a-text-strike")]/text()'
        ).extract_first()
        sale_price = gxp(
            '//span[contains(@id,"ourprice") \
            or contains(@id,"saleprice")]/text()'
        ).extract_first()
        shipping = gxp(
            '//span[contains(@id,"price-shipping-message") or contains \
            (@id,"price-shipping-message")]/b/text()'
        ).extract_first()
        num_reviews = gxp(
            '//div[contains(@id,"summaryStars")]/a/text()'
        ).extract()
        reviews_url = gxp(
            '//div[contains(@id,"summaryStars")]/a/@href'
        ).extract()
        num_questions = gxp(
            '//div[contains(@id, "ask_feature_div")]/span/a/span/text()'
        ).extract()
        avg_rating = gxp(
            '//div[contains(@id,"summaryStars")]/a/i/span/text()').extract()

        in_stock = gxp('//div[@id="availability"]//text()').extract()

        description = gxp(
            '//div[@id="feature-bullets"]/ul/li/span/text()'
        ).extract()
        description = ''.join([x + '. ' for x in clean_list(description)])

        review_ratings = get_rating_hist()

        prod_info = get_product_info(
            key_xp='//table[contains(@id,"productDetails_detailBullets_sections1")]/tr/th/text()',
            vals_xp='//table[contains(@id,"productDetails_detailBullets_sections1")]/tr/td/text()'
        )

        prod_detail = get_product_info(
            key_xp='//table[contains(@id,"productDetails_detailBullets_sections1")]/tr/th/text()',
            vals_xp='//table[contains(@id,"productDetails_detailBullets_sections1")]/tr/td/text()'
        )

        dict_cont = [review_ratings, prod_info, prod_detail]
        items = AmazonProductBaseItem()
        # update fields various for dict containers
        for dc in dict_cont:
            items = update_fields(items, dc)

        # assign dict containers values to newly created fields
        for dc in dict_cont:
            for k in dc:
                items[k] = dc[k]

        items['url'] = str(response.url)
        items['product_title'] = clean(product_title)
        items['category'] = clean(category)
        items['list_price'] = clean(list_price)
        items['sale_price'] = clean(sale_price)
        items['shipping'] = clean(shipping)
        items['num_reviews'] = clean(num_reviews)
        items['num_questions'] = clean(num_questions)
        items['reviews_url'] = clean(reviews_url)
        items['avg_rating'] = clean(avg_rating)
        items['in_stock'] = clean(in_stock)
        items['description'] = description

        yield items
