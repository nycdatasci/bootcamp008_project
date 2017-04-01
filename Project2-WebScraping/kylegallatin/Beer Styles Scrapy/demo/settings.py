# -*- coding: utf-8 -*-
BOT_NAME = 'demo'

SPIDER_MODULES = ['demo.spiders']
NEWSPIDER_MODULE = 'demo.spiders'

DOWNLOAD_DELAY = 3 #delay before changing URLs to avoid error 

ITEM_PIPELINES = {'demo.pipelines.BeerPipeline': 100, }
