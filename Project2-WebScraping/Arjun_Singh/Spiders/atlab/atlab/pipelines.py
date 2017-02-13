# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html


class WriteItemPipeline(object):
	def __init__(self):
		self.filename = 'Atlab_LLC.csv'	

	def open_spider(self, spider):
		self.file = open(self.filename, 'wb')
		
	def close_spider(self, spider):
		self.file.close()

	def process_item(self, item, spider):
		line = str(item['name']) + '\t'
		self.file.write(line)
		return item
