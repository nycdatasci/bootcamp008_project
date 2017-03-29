import warnings
import pymongo
import boto3
import ConfigParser
import pickle
import pandas as pd
from numpy import mean
from bson.objectid import ObjectId
from dateutil.parser import parse as parse_date
from dateutil.relativedelta import relativedelta
from datetime import datetime

class Reader:

    def __init__(self, db_name='test'):
        parser = ConfigParser.RawConfigParser()
        parser.read('credentials.cfg')
        self.ip = parser.get('server', 'ip')
        self.user = parser.get('Reader', 'user')
        self.pwd = parser.get('Reader', 'pwd')
        self.db_name = db_name
        self.client = None
        self.db = None
        self.connect()

    def connect(self):
        connect_string = "mongodb://{user}:{pwd}@{ip}/{db_name}".format(user=self.user, pwd=self.pwd,
                                                                        ip=self.ip, db_name=self.db_name)
        self.client = pymongo.MongoClient(connect_string)
        self.db = self.client[self.db_name]   

    def get_user_id(self, username):
        user_id = None
        user_data = self.read('users', filter_args={'username': username}, find_one=True)
        if user_data:
            user_id = user_data.get('_id')
        if user_id is None:
            raise Exception('Could not get user_id for user {}'.format(username))
        return user_id
        
    def build_filter(self, username=None, user_id=None, sensor=None, commute=None, min_date=None, max_date=None, include_max_date=False): 
        filter_args = {}
        if username:
            user_id = self.get_user_id(username)
        if user_id:
            filter_args['user_id'] = user_id            
        if sensor:
            if isinstance(sensor, (list, tuple)):
                filter_args['sensor'] = {'$in': sensor}
            else:
                filter_args['sensor'] = sensor
        if commute is not None:
            filter_args['commute'] =str(commute)
        if min_date or max_date:
            date_filter = {}
            if min_date:
                date_filter['$gte'] = parse_date(min_date)
            if max_date:
                if include_max_date:
                    date_filter['$lte'] = parse_date(max_date)
                else:
                    date_filter['$lt'] = parse_date(max_date)
            filter_args['timestamp'] = date_filter
        return filter_args

    def get_dataframe(self, collection, filter_args={}):
        data = [entry for entry in self.read(collection, filter_args)]
        return pd.DataFrame(data)
        
    def get_dataframe_unrolled(self, collection, username=None, user_id=None, sensor=None, commute=None,
                                min_date=None, max_date=None, include_max_date=False):
        def entry_to_rows(entry):
            return map(lambda (data_name, data_raw):
                    {'timestamp': entry['timestamp'], 'user_id': entry['user_id'], 'sensor': entry['sensor'], 
                    'data_name': data_name, 'data_raw': data_raw},
                    entry['data'].iteritems()
                    )
                    
        # build filter_args
        filter_args = self.build_filter(username, user_id, sensor, commute, min_date, max_date, include_max_date)
        entries = self.read(collection, filter_args)
        # turn each entry into a list (called row), so we have a list of list
        rows = map(lambda entry: entry_to_rows(entry), entries)
        # join all the rows into one list
        data = reduce(lambda a,b: a + b, rows, [])
        return pd.DataFrame(data)
        
    def get_dataframe_pivoted_old(self, collection, username=None, user_id=None, sensor=None, commute=None, 
                                    min_date=None, max_date=None, include_max_date=False):
        # build filter_args
        filter_args = self.build_filter()
        if not user_id and not username:
            warnings.warn('Excluding user_id from filter can cause errors during pivot', Warning)
        # get the unrolled version so we can pivot the dataframe
        rdf = self.get_dataframe_unrolled(collection, username, user_id, sensor, commute, min_date, max_date, include_max_date)
        rdf['sensor_name'] = rdf.apply(lambda row: row.sensor + ' (' + row.data_name + ')', axis=1)
        rdf.drop(['sensor', 'data_name'], axis=1, inplace=True)
        rdf_pivoted = rdf.pivot(index='timestamp', columns='sensor_name', values='data_raw')
        return rdf_pivoted
        
    def get_dataframe_pivoted(self, collection, username=None, user_id=None, sensor=None, commute=None, 
                                min_date=None, max_date=None, include_max_date=False, grouping='timestamp'):
        
        def merge_sensor_data(entry):
            new_entry = {'timestamp': entry['_id']}
            map(lambda d: new_entry.update(d), entry['sensor_data'])
            return new_entry
        
        filter_args = self.build_filter(username, user_id, sensor, commute, min_date, max_date, include_max_date)
        dd = self.read_group(collection=collection, grouping=grouping, filter_args=filter_args)
        dd = map(lambda entry: merge_sensor_data(entry), dd)
        df = pd.DataFrame(dd)
        df = df.set_index('timestamp')
        return df
    
    def get_audiobooks_dataframe(self, collection='audiobooks', recent=True, category=None, limit=500):
        filter_args = {'OverallRating': {'$gt': 3.5}}
        if recent:
            filter_args['RelDate'] = {'$gte': datetime.now() + relativedelta(years=-1)}
        if category:
            filter_args['Category'] = category
        pipeline = [
            {'$match': filter_args},
            {'$project': {
                'Length': 1, 'NarratedBy': 1, 'NumOverRating':1, 'Catagory': 1, 
                'OverallRating': 1, 'RelDate': 1, 'Title': 1, 'WrittenBy': 1,
                'TotalScore': {'$multiply': [{'$ln': '$NumOverRating'}, '$OverallRating']}}
            },
            {'$sort': {'TotalScore': -1}},
            {'$limit': limit}
        ]
        dd = self.db[collection].aggregate(pipeline, allowDiskUse = True)
        dd = [entry for entry in dd]
        df = pd.DataFrame(dd)
        df = df.rename(index=str, columns={'Catagory': 'Category'})
        return df
    
    def read(self, collection, filter_args={}, find_one=False):
        if find_one:
            return self.db[collection].find_one(filter_args)
        return self.db[collection].find(filter_args)
        
    def read_group(self, collection, grouping, filter_args={}):
        grouping = '$' + grouping if grouping[0] != '$' else grouping
        pipeline = [
            {"$match": filter_args},
            {"$group": {"_id": grouping, "sensor_data": {"$push": "$data" }}}
        ]
        return self.db[collection].aggregate(pipeline, allowDiskUse = True)
        
    def close(self):
        self.client.close()


class Writer(Reader):

    def __init__(self, db_name='test'):
        parser = ConfigParser.RawConfigParser()
        parser.read('credentials.cfg')
        self.ip = parser.get('server', 'ip')
        self.user = parser.get('Writer', 'user')
        self.pwd = parser.get('Writer', 'pwd')
        self.db_name = db_name
        self.client = None
        self.db = None
        self.connect()

    def write_dataframe_to_collection(self, df, collection):
        data = df.to_dict(orient='records')
        return self.write(collection=collection, data=data, insert_one=False)
    
    def write(self, collection, data, insert_one=False, update_filter={}, upsert=True):
        if insert_one:
            return self.db[collection].insert_one(data)
        return self.db[collection].insert_many(data)
        
    def overwrite(self, collection, data, insert_one=False, update_filter={}, upsert=True):
        if insert_one:
            return self.db[collection].update_one(update_filter, {'$set': data}, upsert)
        return self.db[collection].update_many(update_filter, {'$set': data}, upsert)
        

class S3:

    def __init__(self, db_name='test'):
        self.connection = boto3.client('s3')
        self.writer = Writer(db_name)
        
    def upload_to_s3(self, username, model_type, model, fname, bucket='knowhere-data', collection='models'):
        pickle_object = pickle.dumps(model)
        user_id = self.writer.get_user_id(username)
        key = '{}/{}'.format(collection, fname)
        self.connection.put_object(Bucket=bucket, Key=key, Body=pickle_object)
        s3_response = self.connection.head_object(Bucket=bucket, Key=key)
        filesize = s3_response['ContentLength'] if s3_response else 0
        if filesize == 0:
            raise Exception('Error uploading to S3. File size is 0B')
        entry = {'user_id': user_id, 'model_type': model_type, 'key': key}
        update_filter = {'user_id': user_id, 'model_type': model_type}
        self.writer.overwrite(collection=collection, data=entry, insert_one=True, update_filter=update_filter)
        
    def retrieve_from_s3(self, username, model_type, bucket='knowhere-data', collection='models'):
        user_id = self.writer.get_user_id(username)
        filter_args = {'user_id': user_id}
        response = self.writer.read(collection, filter_args=filter_args, find_one=True)
        key = response['key']
        m_type = response['model_type']
        model = self.connection.get_object(Bucket=bucket, Key=key)
        model = pickle.loads(model['Body'].read())
        return model
    