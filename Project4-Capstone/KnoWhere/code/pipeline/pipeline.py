import shutil
import pandas as pd
from re import search
from bson import ObjectId
from datetime import datetime
from db.knowhere_db import Reader


def iphone(username, file_in, file_out, commute=False):
    df = read_from_csvs(username, file_in, file_out)
    df = clean_iphone_data(df)
    dd = aggregate_data(df, commute)
    return dd
    

def android(username, file_in, file_out, commute=False):    
    df = read_from_csvs(username, file_in, file_out)
    df = clean_android_data(df)
    dd = aggregate_data(df, commute)
    return dd
    
    
def get_user_id(df, username):
    reader = Reader('knowhere')
    user_id = reader.get_user_id(username)
    if user_id is None:
        raise Exception('Could not get id for user {}'.format(username))
    df['user_id'] = user_id
    return df

    
def read_from_csvs(username, file_in, file_out):
    with open(file_in, 'r+') as fin, open(file_out, 'w+') as fout:
        fout.write('timestamp, sensor, data_name, data_display, data_raw\n')
        next(fin)
        for line in fin:
            if line[0] is not '"':
                continue
            if not search('Screen', line):
                fout.write(line)
    df = read_single_csv(file_out)
    df = get_user_id(df, username)
    return df
  
  
def read_single_csv(file_with_path):
    df = pd.read_csv(file_with_path, sep=', ', index_col=0, skiprows=0, engine='python', thousands=',', skip_blank_lines=True)
    df.index = pd.to_datetime(df.index.str.replace('"',''))
    return df

        
def clean_iphone_data(df):
    df = df.applymap(lambda x: str.strip(x) if type(x)==str else x)
    #df = df.applymap(lambda x: pd.to_numeric(x, errors='ignore'))
	# drop some data we don't need or want
    desired_sensors = ['GPS', 'Acceleration (via User)', 'Acceleration (via Gravity)', 'Gyrometer (raw)', 'Magnetometer (raw)', 'Altimeter (Barometer)', 'Microphone']
    df = df[df.data_name != 'Enabled']
    df = df[df.data_name != 'Authorisation Status']
    df = df[df.data_name != 'Floor']
    df = df[df.sensor.isin(desired_sensors)]
    # Rename some sensor data so it's easier to deal with
    df.replace(to_replace={'sensor': {'Acceleration (via Gravity)': 'Gravity', 
                                      'Acceleration (via User)': 'Acceleration',
									  'Gyrometer (raw)': 'Gyrometer',
									  'Magnetometer (raw)': 'Magnetometer'
									  }
						}, inplace=True)
    return df


def clean_android_data(df):
    df = df.applymap(lambda x: str.strip(x) if type(x)==str else x)
    #df = df.applymap(lambda x: pd.to_numeric(x, errors='ignore'))
	# drop some data we don't need or want
    desired_sensors = ['GPS', 'Acceleration', 'Gravity', 'Gyromete', 'Magnetometer', 'Altimeter (Barometer)']
    df = df[df.data_name != 'Enabled']
    df = df[df.data_name != 'Authorisation Status']
    df = df[df.data_name != 'Floor']
    df = df[df.sensor.isin(desired_sensors)]
    return df

    
def rename_keys(d, sensor=''):
    new_dict = {}
    for key, value in d.items():
        if isinstance(value, dict):
            new_value = {}
            for subkey, subvalue in value.items():
                new_key = sensor + ' ' + subkey
                new_value[new_key] = subvalue
            value = new_value
        new_dict[key] = value

    return new_dict 
    
    
def aggregate_data(df, commute=False):
    df = df.filter(items=['user_id', 'sensor', 'data_name', 'data_raw'])
    # group by some columns to join the others
    df = df.groupby([df.index, 'user_id', 'sensor']).agg(lambda x: tuple(x))
    # above function makes user_id and sensor indexs, so undo this
    df = df.reset_index(level=['user_id', 'sensor'])
    df['data'] = df.apply(lambda row: {name: value for name, value in zip(row['data_name'], row['data_raw'])}, axis=1)
    df = df.reset_index(level=0)
    df.timestamp = pd.to_datetime(df.timestamp)
    df = df.filter(items=['timestamp', 'user_id', 'sensor', 'data'])	
    df.user_id = df.user_id.apply(ObjectId)
    df['commute'] = str(commute)
    dd = df.to_dict(orient='records')
    dd = map(lambda d: rename_keys(d, d['sensor']), dd)
    return dd
    