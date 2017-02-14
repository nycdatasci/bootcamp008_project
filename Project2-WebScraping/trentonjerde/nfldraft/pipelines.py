# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html


class NfldraftPipeline(object):

	def __init__(self):
		self.filename = 'nfldraft.txt'

	def open_spider(self, spider):
		self.file = open(self.filename, 'wb')

	def close_spider(self, spider):
		self.file.close()

	def process_item(self, item, spider):
		line = str(item['rnd']) + '\t'\
				+ str(item['pick']) + '\t'\
				+ str(item['team']) + '\t'\
				+ str(item['player']) + '\t'\
				+ str(item['position']) + '\t'\
				+ str(item['college']) + '\t'\
				+ str(item['conf']) + '\n'
		self.file.write(line)
		return item