import scrapy
import yaml
import getpass
import time
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
from ebates.items import EbatesItem

class EbatesSpider(scrapy.Spider):
    name = 'ebates'
    #start_urls = ['https://www.ebates.com/stores/all/index.htm']
    start_urls = ['https://www.ebates.com/category/womens-clothing.htm']

    def __init__(self):
        self.driver = webdriver.Chrome()
        self.driver.implicitly_wait(10)
        self.login_file = './login.yml'

    def start_requests(self):
        try:
            with open(self.login_file, 'r') as f:
                login = yaml.load(f)
        except IOError as e:
            login = dict()
            login['username'] = raw_input('Email: ')
            login['password'] = getpass.getpass('Password: ')
            with open(self.login_file, 'w') as f:
                yaml.dump(login, f)

        self.driver.get(self.start_urls[0])
        self.driver.find_element_by_xpath('//*[@id="join-signup"]/div[1]/a').click()
        self.driver.find_element_by_xpath('//*[@id="email_address"]').send_keys(login['username'])
        self.driver.find_element_by_xpath('//*[@id="password"]').send_keys(login['password'])
        self.driver.find_element_by_xpath('//*[@id="next-button"]').click()

        yield scrapy.Request(url=self.driver.current_url, callback=self.parse)

    def parse(self, response):
        for i in range(1, 10):
            item = EbatesItem()
            try:
                #item_xpath = '//*[@id="moreStoreTable"]/body/tr[1]/td[2]/a'
                item_xpath = '//*[@id="store-sort"]/li[{0}]/span[{1}]/a'
                item['store'] = self.driver.find_element_by_xpath(item_xpath.format(i,1)).text
                item['coupon'] = self.driver.find_element_by_xpath(item_xpath.format(i,2)).text
                item['discount'] = self.driver.find_element_by_xpath(item_xpath.format(i,3)).text
            except AttributeError as e:
                self.logger.warning('Found field(s) missing, item skipped')
                continue

            self.driver.find_element_by_xpath('//*[@id="store-sort"]/li[{0}]/span[1]/a'.format(i)).click()
            
            time.sleep(2)
            try:
                item['total'] = self.driver.find_element_by_xpath("//*[contains(text(), 'Total Cash Back to date')]/../span").text
            except NoSuchElementException as e:
                item['total'] = ""

            self.driver.execute_script('window.history.go(-1)')

            yield item

#        for elem in self.driver.find_elements_by_xpath('//*[@id="store-sort"]/li'):
#            item = EbatesItem()
#            try:
#                item['store'] = elem.find_element_by_xpath('./span[1]/a').text
#                item['coupon'] = elem.find_element_by_xpath('./span[2]/a').text
#                item['discount'] = elem.find_element_by_xpath('./span[3]/a').text
#            except AttributeError as e:
#                self.logger.warning('Found field(s) missing, item skipped')
#                continue

