# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html
from scrapy.exporters import CsvItemExporter
from wiki_tv_american.helpers import *
from datetime import datetime as dt

class CleanAndValidateItemPipeline(object):
	def __init__(self):
		self.filename = ("{dir}/{name}_{date}.{ext}".format(
			dir = "output",
			name = "error",
			date = dt.now().strftime("%Y%m%d_%H%M"),
			ext = "log"
		))

	def open_spider(self, spider):
		self.errfile = open(self.filename, 'wb')

	def close_spider(self, spider):
		self.errfile.close()
		
	def process_item(self, item, spider):
		if(any_missing(item)):
			raise_drop_item(self.errfile, item, "at least one missing value...")
		else:
			try:
				item["genres"] = process_genres(item["genres"])
				item["running_time"] = process_running_time(item["running_time"])
				date = process_date(item["start_date"], item["end_date"])
				item["start_date"] = date["start"]
				item["end_date"] = date["end"]
				return item
			except:
				raise_drop_item(self.errfile, item, "could not set item dictionary...")



class WriteItemPipeline(object):
	def __init__(self):
		self.filename = ("{dir}/{name}_{date}.{ext}".format(
			dir = "output",
			name = "tvshows",
			date = dt.now().strftime("%Y%m%d_%H%M"),
			ext = "csv"
		))
		
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
#encode("ascii","ignore").strip() to strip unicode
#split(u'\u2013') to split by hypthen in run time

