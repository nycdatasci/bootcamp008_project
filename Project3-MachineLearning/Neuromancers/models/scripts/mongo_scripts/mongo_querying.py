from pymongo import MongoClient, GEO2D,ASCENDING
from bson import SON
import numpy
from time import time
import pandas as pd 
from datetime import datetime,timedelta


def stats(lst,price):
  a=numpy.array(lst)
  median = numpy.median(a)
  mean = numpy.mean(a)
  center=numpy.array([median,mean])
  percent_vals= numpy.array(numpy.arange(0,101,10))
  percentiles = numpy.percentile(a, percent_vals)
  all_values = numpy.concatenate((percentiles, center), axis=0)
  f = lambda x:  price/x 
  fv = numpy.vectorize(f)
  return fv(all_values)

   

# For setting up datatime 

# var cursor = collection.find({"properties.created": {"$exists": true, "$type": 2 }}); 
# while (cursor.hasNext()) { 
#     var doc = cursor.next(); 
#     collection.update(
#         {"_id" : doc._id}, 
#         {"$set" : {"properties.created" : new ISODate(doc.properties.created)}}
#     ) 
# };

client = MongoClient()
client = MongoClient('localhost', 27017)
db = client.kaggle
collection = db.renthop_test

collection.create_index([("geometry", GEO2D)])

median_costs = {}
t1 = time()
i = 0
# for doc in collection.find():
#   i = i +1
#   print i
#   costs =[]
#   # date_after_n_days = doc['properties']['created'] + timedelta(days=7)
#   # date_before_n_days = doc['properties']['created'] + timedelta(days=-7)
#   for neighbor in collection.find({
#     # "properties.created":{'$gte':date_before_n_days,'$lt': date_after_n_days},
#     "properties.bedrooms":doc['properties']['bedrooms'],
#     "properties.bathrooms":doc['properties']['bathrooms'],
#     "geometry" : SON([("$near", { "$geometry" : SON([("type", "Point"), ("coordinates", doc['geometry']['coordinates'])])})])}).limit(30):
#     costs.append(neighbor['properties']['price'])
#   median_costs[doc['properties']['listing_id']]= stats(costs)

for doc in collection.find():
  i = i +1
  print i
  costs =[]
  for neighbor in collection.find({
    "properties.bedrooms":doc['properties']['bedrooms'],
    "properties.bathrooms":doc['properties']['bathrooms'],
    "geometry" : SON([("$near", { "$geometry" : SON([("type", "Point"), ("coordinates", doc['geometry']['coordinates'])])})])}).limit(30):
    costs.append(neighbor['properties']['price'])
  median_costs[doc['properties']['listing_id']]= stats(costs,doc['properties']['price'])


t2 = time()
print("Run Time:",t2-t1)


neighborhood_values=pd.DataFrame.from_dict(median_costs,orient='index')
neighborhood_values.columns =['0_per_30','10_per_30','20_per_30','30_per_30','40_per_30','50_per_30','60_per_30','70_per_30','80_per_30','90_per_30','100_per_30','median_30','mean_30']
neighborhood_values.index.name = "listing_id"
neighborhood_values.to_csv("neighborhood_values_v_price_train_30.csv")