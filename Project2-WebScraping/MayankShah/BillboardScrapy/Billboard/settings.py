# -*- coding: utf-8 -*-
BOT_NAME = 'Billboard'

SPIDER_MODULES = ['Billboard.spiders']
NEWSPIDER_MODULE = 'Billboard.spiders'

DOWNLOAD_DELAY = 3

ITEM_PIPELINES = {'Billboard.pipelines.WriteItemPipeline': 100, }
