# -*- coding: utf-8 -*-
from scrapy.exporters import CsvItemExporter

class BeerPipeline(object):

        def __init__(self):
                self.filename = 'beer.csv'

        def open_spider(self, spider):
                self.csvfile = open(self.filename, 'wb')
                self.exporter = CsvItemExporter(self.csvfile)
                self.exporter.start_exporting()

        def close_spider(self, spider):
                self.exporter.finish_exporting()
                self.csvfile.close()

        def process_item(self, item, spider):
                self.exporter.export_item(item)
                return item

        

