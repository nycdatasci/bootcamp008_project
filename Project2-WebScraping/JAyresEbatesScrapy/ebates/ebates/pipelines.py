# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html


# -*- coding: utf-8 -*-

import csv
import time

FILE_PATH = './'


class CSVWriterPipeline(object):

    def __init__(self, filename=None):
        if filename is None:
            self.filename = time.strftime('%Y-%m-%d%Z%H-%M-%S') + '.csv'
        else:
            self.filename = filename

    def open_spider(self, spider):
        self.csv_file = open(FILE_PATH + self.filename, mode='wb')
        fieldnames = ['store', 'coupon', 'discount', 'total']
        self.writer = csv.DictWriter(self.csv_file,
                                     fieldnames=fieldnames,
                                     quoting=csv.QUOTE_NONNUMERIC)
        self.writer.writeheader()

    def close_spider(self, spider):
        self.csv_file.close()

    def process_item(self, item, spider):
        self.writer.writerow(dict(item))
