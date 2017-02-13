# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html

class TamingnewsPipeline(object):
    def __init__(self):
        self.filename = 'reuters.txt'

    def open_spider(self, spider):
        self.file = open(self.filename, 'wb')

    def close_spider(self, spider):
        self.file.close()

    def process_item(self, item, spider):
        lines = item['page1'].encode('utf8') + ' \t ' + item['page2'].encode('utf8') + ' \t ' \
                + item['page3'].encode('utf8') + ' \t ' + item['category'].encode('utf8') + ' \t ' \
                + item['title'].encode('utf8') + ' \t ' + item['article'].encode('utf8') + ' \t ' \
                + item['pTimestamp'].encode('utf8') + ' \t ' + str(item['scrape_time']) + ' \t ' \
                + item['spider'].encode('utf8') + '\n'

        self.file.write(lines)

        return item
