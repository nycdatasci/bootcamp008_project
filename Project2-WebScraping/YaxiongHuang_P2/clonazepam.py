import requests
from bs4 import BeautifulSoup as bf

def ChangingURL(n):
    return 'https://www.drugs.com/comments/clonazepam/?page='+str(n)


def get_review(soup):
    ul=soup.find_all('div',{'class':'block-wrap comment-wrap'})
    #DrugReviews = [i.find_all('div')  for i in ul]
    result = []
    
    
    for DrugReview in ul:
        d={}
        
        try:
            
            Condition = DrugReview.find('div', {'class':'user-comment'}).b.get_text()
            
            #print Condition
            try:
                Review = DrugReview.find('div', {'class':'user-comment'}).span.get_text()
                Rating = DrugReview.find('div',{'class': "rating-score"}).get_text()
            #print Rating
            
            except:
                #Review = ""
                Rating = ""
            
            finally:
                d['Condition'] = Condition
                d['Review'] = Review
                d['Rating'] = Rating
                result.append(d)
    
    except:
        pass
    
                    return result


import pandas as pd

appended_data = []

for page in range(1,43):
    
    text =requests.get(ChangingURL(page)).text
    
    soup =bf(text)
    
    appended_data.append(pd.DataFrame(get_review(soup)))
appended_data = pd.concat(appended_data, axis=0).reset_index(drop=True)

import csv
appended_data.to_csv('ClonazepamReviews.csv',header = True, encoding='utf-8')
