
BOT_NAME = 'grassroot'

SPIDER_MODULES = ['grassroot.spiders']
NEWSPIDER_MODULE = 'grassroot.spiders'

DOWNLOAD_DELAY = 0
ITEM_PIPELINES = {'grassroot.pipelines.WriteItemPipeline': 100, }
