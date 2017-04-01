from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import csv

driver = webdriver.Chrome()
#open up the page
driver.get('https://www.beeradvocate.com/beer/profile/29/1524/')

#create the csv
csv_file = open('nattyLight.csv', 'wb')
writer = csv.writer(csv_file)
writer.writerow(['date','attributes', 'rDev', 'name'])

#to append to the original url
url = '?view=beer&sort=&start='

#find the number of reviews/last page
last = driver.find_element_by_xpath('//*[@id="item_stats"]/dl/dd[1]/span').text
last = int(last.replace(',', ''))

#name and brewery
name = driver.find_element_by_xpath('//*[@id="content"]/div/div/div[3]/div/div/div[1]/h1').text

index = 0
while index < last:
    try:
        print "Page" + str(index)
        driver.get('https://www.beeradvocate.com/beer/profile/29/1524/' + url + str(index))
        index = index + 25
        reviews = driver.find_elements_by_xpath('//div[@id="rating_fullview"]/div')
        for review in reviews:
                 rDict = {}
                 name = name
                 rDev = review.find_element_by_xpath('.//span[3]').text
                 attributes = review.find_element_by_xpath('.//span[@class="muted"]').text
                 date = review.find_element_by_xpath('.//div//span[@class="muted"]/a[2]').text
                 

                 rDict['name'] = name
                 rDict['rDev'] = rDev
                 rDict['attributes'] = attributes
                 rDict['date'] = date
                 writer.writerow(rDict.values())
##        button = driver.find_element_by_xpath('.//div//span//a[5]')
##        button.click()
        time.sleep(2)
    except Exception as e:
        print e
        csv_file.close()
        driver.close()
        break
