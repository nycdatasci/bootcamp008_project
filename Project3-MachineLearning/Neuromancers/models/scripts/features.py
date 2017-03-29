from pandas import to_datetime
from geopy.distance import vincenty
import numpy as np
import pandas as pd
import re


def scrub(df):
    """
    function designed to perform data cleaning on the training data set
    """
    df['building_id'].replace(to_replace='0', value=np.nan, inplace=True)
    df["created"] = to_datetime(df["created"])
    return df


def basic_numeric_features(df):
    df["num_photos"] = df["photos"].apply(len)
    df["num_features"] = df["features"].apply(len)
    df["num_description_words"] = df[
        "description"].apply(lambda x: len(x.split(" ")))
    df["created_year"] = df["created"].dt.year
    df["created_month"] = df["created"].dt.month
    df["created_day"] = df["created"].dt.day
    return df


def num_keyword(df):
    # n_num_keyword: check if a key word makes a difference in terms of
    # interest_level:
    match_list = [map(lambda x: re.search('elevator|cats|dogs|doorman|dishwasher|no fee|laundry|fitness', x.lower()),
                      list(df['features'])[i]) for i in np.arange(0, len(df['features']), 1)]
    nfeat_list = []
    for i in match_list:
        if i is None:
            nfeat_list.append(0)
        else:
            if not any(i):  # check to filter out lists with no all None values
                nfeat_list.append(0)
            else:
                lis1 = []
                map(lambda x: lis1.append(1) if x is None else lis1.append(0), i)
                nfeat_list.append(sum(lis1))

    # new variable n_num_keyfeat_score
    nfeat_score = []
    for i in nfeat_list:
        if i <= 5:
            nfeat_score.append(0)
        elif i == 6:
            nfeat_score.append(1)
        elif i == 7:
            nfeat_score.append(2)
        elif i == 8:
            nfeat_score.append(3)
        elif i == 9:
            nfeat_score.append(4)
        elif i == 10:
            nfeat_score.append(5)
        else:
            nfeat_score.append(6)

    df['n_num_keyfeat_score'] = nfeat_score
    return df


def no_photo(df):
    df['n_no_photo'] = [1 if i == 0 else 0 for i in map(len, df['photos'])]
    return df


def count_caps(df):
    def get_caps(message):
        caps = sum(1 for c in message if c.isupper())
        total_characters = sum(1 for c in message if c.isalpha())
        if total_characters > 0:
            caps = caps / (total_characters * 1.0)
        return caps
    df['amount_of_caps'] = df['description'].apply(get_caps)
    return df


def has_phone(df):
    # http://stackoverflow.com/questions/16699007/regular-expression-to-match-standard-10-digit-phone-number
    phone_regex = "(\d{3}[-\.\s]??\d{3}[-\.\s]??\d{4}|\(\d{3}\)\s*\d{3}[-\.\s]??\d{4}|\d{3}[-\.\s]??\d{4})"
    has_phone = df['description'].str.extract(phone_regex)
    df['has_phone'] = [type(item) == unicode for item in has_phone]
    return df


def n_log_price(df):
    # n_price_sqrt improves original 'price' variable smoothing extreme
    # right skew and fat tails.
    # Use either 'price' or this new var to avoid multicolinearity.
    df['n_log_price'] = np.log(df['price'])
    return df


def n_expensive(df):
    # 'Low' interest make 70% population. Statistical analysis shows price
    # among 'Low' interest exhibits the highest kurtosis and skew.
    # n_expensive is 1 when the price is above 75% percentile aggregate
    # prices and 0 otherwise.
    # you can use it along with either price or n_price_sqrt.
    threshold_75p = df[['price']].describe().loc['75%', 'price']
    df['n_expensive'] = [
        1 if i > threshold_75p else 0 for i in list(df['price'])]
    return df


def dist_from_midtown(df):
    
    # pip install geopy
    # https://github.com/geopy/geopy
    # calculates vincenty dist
    # https://en.wikipedia.org/wiki/Vincenty's_formulae
    lat = df['latitude'].tolist()
    long_ = df['longitude'].tolist()
    midtown_lat = 40.7586
    midtown_long = -73.9838
    distance = []
    for i in range(len(lat)):
        distance.append(
            vincenty((lat[i], long_[i]), (midtown_lat, midtown_long)).meters)
    df['distance_from_midtown'] = distance
    return df


def nearest_neighbors(df, n):
    # Input: df and num of meighbors
    # Output: df with price_vs_median for each row
    df_sub = df[['latitude', 'longitude', 'price', 'bedrooms', 'bathrooms']]
    rows = range(df.shape[0])
    diffs = map(lambda row: compare_price_vs_median(df_sub, n, row), rows)
    df['price_vs_median_' + str(n)] = diffs
    return df


def compare_price_vs_median(df, n, i):
    # Help function For nearest_neighbors
    # Requires geopy.distance
    # for each lat long
    # calculate dist from all other lat longs with same beds and bathrooms
    # find n nearest neighbors
    # calculate median price of n nearest neighbors
    # compare price vs median
    row = df.iloc[i, :]
    lat = row['latitude']
    lon = row['longitude']
    bed = row['bedrooms']
    bath = row['bathrooms']
    price = row['price']
    df.index = range(df.shape[0])
    all_other_data = df.drop(df.index[[i]])
    with_same_bed_bath = all_other_data[all_other_data['bedrooms'] == bed]
    with_same_bed_bath = with_same_bed_bath[
        with_same_bed_bath['bathrooms'] == bath]
    longs = with_same_bed_bath['longitude'].tolist()
    lats = with_same_bed_bath['latitude'].tolist()
    distances = []
    for j in range(len(lats)):
        distance = vincenty((lats[j], longs[j]), (lat, lon)).meters
        distances.append(distance)
    # http://stackoverflow.com/questions/13070461/get-index-of-the-top-n-values-of-a
    dist_positions = sorted(range(len(distances)),
                            key=lambda k: distances[k], reverse=True)[-n:]
    top_dist_df = with_same_bed_bath.iloc[dist_positions, :]
    med_price = with_same_bed_bath['price'].median()
    diff = price / med_price
    return diff

def price_vs_mean_30(df):
    # userfriendly for def_nearest_neighbour created earlier.
    # Output: df with price_vs_median for each row
    # The code below solves NA issues and round some results to save execution errors
    temp = pd.read_json("price_vs_median30.json")['price_vs_median_30']
    mean = np.mean(temp) 
    import math
    df['price_vs_median_30'] = [mean if math.isnan(i)== True  else round(i,2) for i in temp]
    return df

def price_vs_mean_72(df):
    # userfriendly for def_nearest_neighbour created earlier.
    # Output: df with price_vs_median for each row
    # The code below solves NA issues and round some results to save execution errors
    temp = pd.read_json("price_vs_median72.json")['price_vs_median_72']
    mean = np.mean(temp) 
    import math
    df['price_vs_median_72'] = [mean if math.isnan(i)== True  else round(i,2) for i in temp]
    return df

def nearest_neighbors_with_date(df, n,days):
    from datetime import datetime
    # Input: df and num of meighbors
    # Output: df with price_vs_median for each row
    df_sub = df[['latitude', 'longitude', 'price', 'bedrooms', 'bathrooms','created']]
    df_sub['date']=df_sub['created'].apply(lambda d: datetime.strptime(d.split(" ")[0], "%Y-%m-%d"))
    rows = range(df.shape[0])
    diffs = map(lambda row: compare_price_vs_median_with_date(df_sub, n, row,days), rows)
    df['price_vs_median_' + str(n)] = diffs
    return df



def compare_price_vs_median_with_date(df, n, i,days):
    from datetime import datetime,timedelta
    # Help function For nearest_neighbors
    # Requires geopy.distance
    # for each lat long
    # filter for only places with same beds and bathroom
    # filter for places that were posted within z days
    # calculate dist from all other lat longs with same beds and bathrooms
    # find n nearest neighbors
    # calculate median price of n nearest neighbors
    # compare price vs median
    row = df.iloc[i, :]
    lat = row['latitude']
    lon = row['longitude']
    bed = row['bedrooms']
    bath = row['bathrooms']
    price = row['price']
    date = row['date']
    date_after_n_days = date + timedelta(days=days)
    date_before_n_days = date + timedelta(days=-days)
    df.index = range(df.shape[0])
    all_other_data = df.drop(df.index[[i]])
    with_same_bed_bath = all_other_data[all_other_data['bedrooms'] == bed]
    with_same_bed_bath = with_same_bed_bath[with_same_bed_bath['bathrooms'] == bath]
    with_same_bed_bath = with_same_bed_bath[(with_same_bed_bath['date'] > date_before_n_days) & (with_same_bed_bath['date'] < date_after_n_days)]
    longs = with_same_bed_bath['longitude'].tolist()
    lats = with_same_bed_bath['latitude'].tolist()
    distances = []
    for j in range(len(lats)):
        distance = vincenty((lats[j], longs[j]), (lat, lon)).meters
        distances.append(distance)
    # http://stackoverflow.com/questions/13070461/get-index-of-the-top-n-values-of-a
    dist_positions = sorted(range(len(distances)),
                            key=lambda k: distances[k], reverse=True)[-n:]
    top_dist_df = with_same_bed_bath.iloc[dist_positions, :]
    med_price = with_same_bed_bath['price'].median()
    diff = price / med_price
    return diff


# def manager_skill(df):
#     #new var to create
#     new_var = 'manager_id' #'manager_id_encoded'
#     #response var
#     resp_var = 'interest_level'
#     # Step 1: create manager_skill ranking from training set:
#     train_df = pd.read_json("train.json") # upload training scores => test data cannot create a rank skill
#     temp = pd.concat([train_df[new_var], pd.get_dummies(train_df[resp_var])], axis = 1).groupby(new_var).mean()
#     temp.columns = ['high_frac','low_frac', 'medium_frac']
#     temp['count'] = train_df.groupby(new_var).count().iloc[:,1]
#     temp['manager_skill'] = temp['high_frac']*2 + temp['medium_frac']
#     # Step 2: fill working dataset (e.g. test set) with ranking figures and replace new manager_id not present in our
#     # training set with an average assumption:
#     manager_skill=[]
#     for i in df['manager_id']:
#         for j in temp.index:
#             if i==j:
#                 manager_skill.append(temp['manager_skill'][j])
#             else:
#                 manager_skill.append(-1) # we flag this to replace it for average later and control for manager_ids not present in training _df
#     # Step 3: Replacing new manager_id scores not available in training set with the mean: 
#     mean_manager_skill= np.mean(manager_skill)
#     manager_skill_clean = [mean_manager_skill if i==-1 else i for i in manager_skill] # replace NA (labelled as -1 earlier) for the mean

#     df['manager_skill'] = manager_skill_clean
#     return df


def dist_to_nearest_college(df):
    Baruch = (40.7402, -73.9834)
    Columbia = (40.8075, -73.9626)
    Cooper_Union = (40.7299, -73.9903)
    FIT = (40.7475, -73.9951)
    Hunter_College = (40.7685, -73.9657)
    John_Jay = (40.7704, -73.9885)
    Julliard = (40.7738, -73.9828)
    NYU = (40.7295, -73.9965)
    NYU_Tandon = (40.6942, -73.9866)
    Pace_University=(40.7111, -74.0049)
    Pratt_University = (40.6913, -73.9625)
    The_New_School = (40.7355199, -73.99715879999997)
    Weill_Cornell = (40.7650, -73.9548) 

    schools = [Baruch,Columbia,Cooper_Union,FIT,Hunter_College,John_Jay, Julliard, NYU, NYU_Tandon,
              Pace_University, Pratt_University, The_New_School, Weill_Cornell]

    distance = []
    for i in range(0,len(df['latitude']),1):
        lat_long = (list(df['latitude'])[i],list(df['longitude'])[i])
        temp=[]
        for j in schools:
            temp.append(
            vincenty(lat_long, j).meters)
        distance.append(min(temp))
    df['dist_to_nearest_college']= distance
    return df

def dist_to_nearest_tube(df):
    tube_lat_long = pd.read_csv('http://web.mta.info/developers/data/nyct/subway/StationEntrances.csv') \
        [['Station_Name','Station_Latitude','Station_Longitude']]    

    # unique stations only
    tube_lat_long = tube_lat_long.groupby('Station_Name').agg(['mean']) 

    stations=[]
    for i in range(0,len(tube_lat_long),1):
            stations.append(
                (tube_lat_long.iloc[:,0][i],tube_lat_long.iloc[:,1][i]))

    distance = []
    for i in range(0,len(df['latitude']),1):
        lat_long = (list(df['latitude'])[i],list(df['longitude'])[i])
        temp=[]
        for j in stations:
            temp.append(
            vincenty(lat_long, j).meters)
        distance.append(min(temp))

    df['dist_to_nearest_tube']= distance
    return df

def add_neighbor_features_72(df):
    moredata = pd.read_csv("neighborhood_values_test_72.csv")
    df = pd.merge(df, moredata, how='inner', on=['listing_id', 'listing_id'])
    return df 


def scrub_features(df, method='count'):

    regex_co = {
        "nofee": "no fee",
        "doorman": "doorman",
        "fitness": "fitness|swimming",
        "hardwood": "hardwood",
        "dishwash": "dishwasher",
        "preWar": "prewar|pre-war",
        "furnished": "furnished",
        "laundry": "laundry",
        "allow_pets": "cats|dogs",
    }

    def create_regex(df, regex, colname, method='count'):
        def find_regex(lis, method=method):
            text = ' '.join(lis)
            r = re.compile(regex, flags=re.IGNORECASE)
            matches = r.findall(text)
            num_matches = len(matches)
            if method == 'count':
                return num_matches
            elif method == 'binary':
                if num_matches > 0:
                    return 1
                else:
                    return 0
        df[colname] = df['features'].apply(find_regex)

    for name, regex in regex_co.items():
        create_regex(df, regex, name, method=method)
    return df
