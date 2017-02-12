from stocktwits.exporters import HeadlessCsvItemExporter
import pandas as pd
from scrapy.exceptions import DropItem

class ValidateItemPipeline(object):
	def process_item(self, item, spider): 
		tgt_rec = pd.read_csv('stocktwits.csv',usecols=['userName','tweetID','time','date'])
		check = any((tgt_rec.userName==item['userName']) & (tgt_rec.tweetID==item['tweetID']) & (tgt_rec.time==item['time']) & (tgt_rec.date==item['date']))
		if (check == True):
			raise DropItem("Already exsist")  
		else:
			return item

class WriteItemPipeline(object): 
	def __init__(self):
		self.filename = 'stocktwits.csv'
	def open_spider(self, spider):
		self.csvfile = open(self.filename, 'ab') 
		self.exporter = HeadlessCsvItemExporter(self.csvfile) 
		self.exporter.start_exporting()
	def close_spider(self, spider): 
		self.exporter.finish_exporting() 
		self.csvfile.close()
	def process_item(self, item, spider): 
		self.exporter.export_item(item) 
		return item
