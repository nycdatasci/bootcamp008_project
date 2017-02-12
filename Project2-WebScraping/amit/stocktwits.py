from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import calendar
import time
import csv,json


driver = webdriver.Chrome()
max_time = 100000
driver.get("https://stocktwits.com/symbol/AAPL?q=AAPL")

csv_file = open('stock_twits.csv', 'wb')
writer = csv.writer(csv_file)
csv_file.truncate()

abbr_to_num = {name: num for num, name in enumerate(calendar.month_abbr) if num}

def timeStamp(x):
    x1= x[:(x.find('at')-1)].replace('.','').split()
    mon = x1[0]
    day = x1[1]
    time = x[(x.find('at')+3):]
    year = strToYear(mon)
    mm = abbr_to_num[mon]
    return str(day)+'/'+str(mm)+'/'+str(year)+' '+time

def strToYear(strMonth):
    strMonth = strMonth.lower() 
    if  strMonth == 'jan': return '2017'
    elif strMonth == 'feb': return '2017'
    elif strMonth == 'mar': return '2016'
    elif strMonth == 'apr': return '2016'
    elif strMonth == 'may': return '2016'
    elif strMonth == 'jun': return '2016'
    elif strMonth == 'jul': return '2016'
    elif strMonth == 'aug': return '2016'
    elif strMonth == 'sep': return '2016'
    elif strMonth == 'oct': return '2016'
    elif strMonth == 'nov': return '2016'
    elif strMonth == 'dec': return '2016'

t = 1
while (t < 1000):
	t = t+1
	driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
	time.sleep(15)
	
for element in driver.find_elements_by_xpath("//ol[@class='stream-list show-conversation stream-poller']/li"):	
	try:
		element.location_once_scrolled_into_view
		tweet ={}
		tweet_user = element.find_element_by_xpath(".//div[@class='message-header']/a").text
	##	tweet_Date = element.find_element_by_xpath(".////div[@class='message-date']/a").text
		tweet_date =element.find_element_by_css_selector('div[class="message-date"]').text
		try:
			tweet_text = element.find_element_by_css_selector('div[class="message-content"]').text
		except Exception as e:
			print e
			tweet_text = null
			continue
		tweet_sentiment = element.find_element_by_css_selector('span[class^="sentiment"]').text
		#tweet_sentiment = element.find_element_by_xpath('.//div[@class="message-content"]/span').text()
		tweet['user'] = tweet_user
		tweet['TweetDate'] = timeStamp(tweet_date)
		tweet['TweetText'] = tweet_text
		tweet['Sentiment'] = tweet_sentiment

		writer.writerow(tweet.values())
		

		# print 'tweet username:',tweet_user
		# print 'tweet date:',tweet_date
		# print 'tweet text:',tweet_text
		# print 'tweet sentiment:',tweet_sentiment
	except Exception as e:
		print e
		continue
csv_file.close()

