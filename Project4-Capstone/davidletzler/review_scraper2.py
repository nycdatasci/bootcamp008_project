import json
import datetime
import pycurl
import pandas as pd
import numpy as np
from StringIO import StringIO
from api import NYT_API
import time

print "What date's best-seller list do you want to start with?  First, the year (YYYY):"
year_start = int(raw_input('> '))
print "Now the month (MM):"
month_start = int(raw_input('> '))
print "Now the day (DD):"
day_start = int(raw_input('> '))
print "What date's best-seller list do you want to end with? First, the year (YYYY):"
year_end = int(raw_input('> '))
print "Now the month (MM):"
month_end = int(raw_input('> '))
print "Now the day (DD):"
day_end = int(raw_input('> '))

date_start = datetime.date(year_start, month_start, day_start)
date_end = datetime.date(year_end, month_end, day_end)
difference = date_end - date_start
dates = [date_start + datetime.timedelta(days=x) for x in range(0, difference.days + 1, 1)]

full_reviews = pd.DataFrame()
csv_name = str(date_start) + "_to_" + str(date_end)+ ".csv"

for date in dates:

    current_URL = "http://api.nytimes.com/svc/books/v3/reviews.json?publication_dt=%s&api-key=%s" %(date, NYT_API)
    buffer = StringIO()
    c = pycurl.Curl()
    c.setopt(c.URL, current_URL)
    c.setopt(c.WRITEDATA, buffer)
    c.perform()
    c.close()
    current_reviews = buffer.getvalue()
    try:
        dict_reviews = json.loads(current_reviews)
        if dict_reviews['num_results'] == 0:
            day_none = open('empty_day.txt', 'a')
            day_none.write(date)
            day_none.write("\n")
            day_none.close()
            df_reviews = pd.DataFrame()
        else:
            df_reviews = pd.DataFrame(dict_reviews['results'])
            df_reviews = df_reviews[['book_author', "book_title", "byline", "publication_dt", "url"]]
    except:
        df_reviews = pd.DataFrame()
        print "DID NOT GET " + str(date)

    full_reviews = full_reviews.append(df_reviews)
    time.sleep(2)

full_reviews.to_csv(csv_name, na_rep=np.nan, index=False, encoding="utf-8")
