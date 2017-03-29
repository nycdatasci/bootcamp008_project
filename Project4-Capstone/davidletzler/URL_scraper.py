import requests
from bs4 import BeautifulSoup
import time

URL_List = reviews['url']

for URL in URL_List:
    r = requests.get(URL)
    html = r.text
    if BeautifulSoup(html, "lxml").find_all('p', {"itemprop":"articleBody"})!=[]:
        article = BeautifulSoup(html, "lxml").find_all('p', {"itemprop":"articleBody"})
    elif BeautifulSoup(html, "lxml").find_all('p', {"itemprop":"reviewBody"})!=[]:
        article = BeautifulSoup(html, "lxml").find_all('p', {"itemprop":"reviewBody"})
    elif BeautifulSoup(html, "lxml").find_all('p', {"class":"story-body-text story-content"})!=[]:
        article =BeautifulSoup(html, "lxml").find_all('p', {"class":"story-body-text story-content"})
    else:
        article =BeautifulSoup(html, "lxml").find_all('p')
    body = ["None"]*len(article)
    for i in range(0, len(article)):
        body[i]=article[i].get_text()
    text ="\n".join(body)
    reviews.loc[reviews.url==URL, 'text'] = text
    time.sleep(1)

reviews.to_csv("reviews.csv", na_rep=np.nan, index=False, encoding="utf-8")
