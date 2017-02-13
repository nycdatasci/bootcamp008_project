import numpy as np
import pandas as pd
from hubstorage import HubstorageClient


"""
Simple program to fetch scraped data from the scrapinghub cloud storage.

Scraped pages are fetched one at a time from the cloud, cleaned and saved
as an individual json file. Name of the file is the hash code (generated
by python's inbuilt function). Files are saved individually in json folders
so that memory needs stay at a minimum during this and other operations.
Handling files in this way removes the limitation due to large combined
size of the file during this and analysis operations.

Program output: 12 Feb 2016
##################################################
Fetched:  1649  from spider:  reutersbasic
1579  were written to the folder
--------------------------------------------------


##################################################
Fetched:  7867  from spider:  cnnbasic
7661  were written to the folder
--------------------------------------------------


##################################################
Fetched:  1253  from spider:  foxbasic
1253  were written to the folder
--------------------------------------------------



Process finished with exit code 0
"""

def get_scraped_data(dir,items_job, key, spider):
    # establish a connection with scrapyhub and get a items generator
    hc = HubstorageClient(auth=key)

    empty, totalItems, keptItems = 0, 0, 0
    for job in hc.get_project(items_job).jobq.list(spider=spider):
        for item in hc.get_job(job['key']).items.list():

            totalItems += 1
            item = pd.Series(item)
            if item['title'] != '' or item['article'] != '':
                item['spider'] = spider
                item = item.drop('category')
                item = item.replace(["page1", "page2", "page3", "scrape_time", "", "basic"],
                                    [np.nan, np.nan, np.nan, np.nan, np.nan, "reutersbasic"])
                item = item.replace({'<.*?>': '', '\[.*?\]': '', '\(.*?\)': ''}, regex=True)

                #add article hash code as the id of the article
                item['id'] = hash(item['article'])

                #write item(as records) to a json file
                file = dir + 'raw/' + str(item['id']) + '.json'
                item.to_json(file)

                keptItems += 1

            else:
                empty += 1

    print '#' * 50
    print 'Fetched: ', totalItems, ' from spider: ', item['spider']
    print keptItems, ' were written to the folder'
    print '-' * 50, '\n\n'

items_job = #name of the project in scrapinghub
key = #scrapinghub api key
spiders = #list of spider names
dir = #place where response will be saved

for spider in spiders:
    get_scraped_data(dir, items_job, scrapinghub_key, spider)