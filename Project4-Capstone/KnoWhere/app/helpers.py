"""
Importing everything here instead of in functions
to import once and speed up REST calls
"""
import pandas as pd
import numpy as np
import pandas.tseries.offsets as pdo
#import pickle
import json
# from sklearn import preprocessing
# from sklearn.cluster import AgglomerativeClustering
from math import radians, cos, sin, asin, sqrt
#from time import time
from random import shuffle
pd.options.mode.chained_assignment = None

commute_distance = 0

def query_db_convert_id(reader, collection, id_cols=None,
						sort_col=None, method=None, _filter={},
						username=None, sensor=None,
						min_date=None, max_date=None, include_max_date=False):
	if not method:
		df = reader.get_dataframe(collection=collection, filter_args=_filter).sort_values(sort_col)
	elif method == "unrolled":
		df = reader.get_dataframe_unrolled(collection=collection, filter_args=_filter).sort_values(sort_col)
	elif method == "pivoted":
		df = reader.get_dataframe_pivoted(collection=collection, username=username, sensor=sensor,
										min_date=min_date, max_date=max_date, include_max_date=include_max_date).sort_index()
	
	if method != "pivoted":
		for col in id_cols:
			df.ix[:,col] = df.ix[:,col].map(str)
	
	return df


# helper in converting dataframe to json array
def make_lat_long(row):
    if row["GPS Latitude"] != None:
        return {
            "date":str(row.name).replace("T", " "),
            "latitude":row["GPS Latitude"],
            "longitude":row["GPS Longitude"]
        }


def haversine(lon1, lat1, lon2, lat2):
    """
    Calculate the great circle distance between two points
    on the earth (specified in decimal degrees, AKA Latitude / Longitude)

    All args must be of equal length.    

    """
    if type(lon1) != float:
        lon1 = lon1.astype(float)
        lat1 = lat1.astype(float)
        lon2 = lon2.astype(float)
        lat2 = lat2.astype(float)

    # convert decimal degrees to radians 
    lon1, lat1, lon2, lat2 = map(np.radians,[lon1, lat1, lon2, lat2])

    #haversine formula
    dlon = lon2 - lon1
    dlat = lat2 - lat1

    a = np.sin(dlat/2.0)**2 + np.cos(lat1) * np.cos(lat2) * np.sin(dlon/2.0)**2

    c = 2 * np.arcsin(np.sqrt(a))
    miles = 3956 * c # Radius of earth in miles. Use 6370 for kilometers
    return miles


def set_distance(gps_data, json_array):
    """
    Calculate the distance a user has traveled over a given date range. Involves all modes of transportation, 
    and is calculated using Great-circle distance.
    """

    hourly_distances = [('Date', 'Distance')]

    #Use haversine function to get distances between all GPS points
    dist_traveled = haversine(gps_data['GPS Longitude'].shift(), gps_data['GPS Latitude'].shift(), 
          gps_data.ix[1:, 'GPS Longitude'], gps_data.ix[1:, 'GPS Latitude'])


    dist_grouped = dist_traveled.groupby(pd.Grouper(freq='1H')).sum()
    
    for ts, dist in dist_grouped.iteritems():
        h = "{0:02}-{1:02}-{2:02} {3:02}:{4:02}:{5:02}".format(
            ts.year, ts.month, ts.day, ts.hour, ts.minute, ts.second
        )

        if np.isnan(dist):
            dist = 0

        hourly_distances.append((h, dist))

    json_array.append({"total_distance": dist_traveled.sum()})
    json_array.append({"hourly_distances":hourly_distances})


def get_locs(user_data, user_name, json_array):
    global commute_distance
    #ts = time()
    #print "START get_locs:", ts
    locs = json.load(open("data/locations.txt", "r"))[user_name]
    #print 109, "get_locs", ":" * 10, (time()-ts)

    commute_distance = haversine(locs["home"]["long"], locs["home"]["lat"],
                                locs["work"]["long"], locs["work"]["lat"])


    json_array.append(locs)
    ud = user_data[['GPS Latitude','GPS Longitude']]
    ud.reset_index(inplace=True)

    def loc_dist(df):
        d_h = haversine(df["GPS Longitude"], df["GPS Latitude"],
                        locs["home"]["long"], locs["home"]["lat"])
        d_w = haversine(df["GPS Longitude"], df["GPS Latitude"],
                        locs["work"]["long"], locs["work"]["lat"])
        
        if not (d_h < 0.25 or d_w < 0.25):
            loc = "other"
        elif d_h == min(d_h, d_w):
            loc = "home"
        else:
            loc = "work"
            
        return loc

    ud["dist"] = ud.apply(loc_dist, axis=1)

    #print 131, "get_locs", ":" * 10, (time()-ts)

    home = ud[ud.dist == "home"]
    work = ud[ud.dist == "work"]
    other = ud[ud.dist == "other"]
    home = home.groupby(lambda x: home['index'][x].day).agg({"index": lambda i: (max(i)-min(i)).total_seconds()})
    work = work.groupby(lambda x: work['index'][x].day).agg({"index": lambda i: (max(i)-min(i)).total_seconds()})
    other = other.groupby(lambda x: other['index'][x].day).agg({"index": lambda i: (max(i)-min(i)).total_seconds()})
    #print 136, "get_locs", ":" * 10, (time()-ts)
    seconds_home = np.sum(home["index"])
    seconds_work = np.sum(work["index"])
    seconds_other = np.sum(other["index"])
    seconds_total = seconds_home + seconds_work + seconds_other
    percent_home = round(100*(float(seconds_home) / seconds_total), 2)
    percent_work = round(100*(float(seconds_work) / seconds_total), 2)
    percent_other = round(100*(float(seconds_other) / seconds_total), 2)

    json_array.append({"percent_home":percent_home, "percent_work":percent_work, "percent_other":percent_other})


def animal_riding_time():
    animals = ['bear','tortoise','kangaroo','pig','unicorn','cheetah','human','cow', 'train']
    shuffle(animals)
    the_animal = animals[0]
    animal_speeds = {
        'bear': 35.0, 'tortoise': 0.2, 'kangaroo': 43.0, 'pig': 10.0,
        'unicorn': 567.0, 'cheetah': 75.0, 'human': 3.1, 'cow': 25.0, 'train': 17.0
    }

    speed = animal_speeds[the_animal]
    commute_time = (commute_distance / speed) * 60
    return {
        "speed": round(speed,2),
        "time": round(commute_time,2),
        "distance": round(commute_distance,2),
        "animal": the_animal
    }


def get_activity_percents(reader):
    import pickle
    # import numpy as np
    import preprocess_data as pdata
    pkl = pickle.load(open("data/pickle_glen_C_032617.p", "rb"))
    glen24th = reader.get_dataframe_pivoted(
        collection="iphone", username="glen",
        sensor=["Acceleration", "Magnetometer"], commute=True, 
        min_date="2017-03-24 00:00:00", max_date="2017-03-25 00:00:00")

    glen24th = reader.get_dataframe_pivoted(collection="iphone", username="glen", sensor=["Acceleration", "Magnetometer"], commute=True, 
                                min_date="2017-03-24 00:00:00", max_date="2017-03-25 00:00:00")

    glen24th = pdata.Preprocess_Data(glen24th)
    glen24th.Norm()
    data = glen24th.Feature_additions()
    X = glen24th.load_data_test()

    activity_labels = {
        0:"driving", 1:"elevator", 2:"standing",
        3:"train", 4:"train", 5:"walking"}

    pred = np.vectorize(lambda x: activity_labels[x])(pkl.predict(X))
    df = pd.DataFrame({"date":data.index, "label":pred})
    df["hm"] = df["date"].apply(lambda x: "{0}{1}".format(x.hour, x.minute))
    df = df.groupby(["label", "hm"]).agg({"date": lambda i: (max(i)-min(i)).total_seconds()})

    # date actually = seconds.
    df = df.reset_index().groupby("label").sum().reset_index()
    df.columns = ["label", "seconds"]

    total_seconds = np.sum(df.seconds)
    activity_percents = {}

    def set_percents(x):
        activity_percents[x.label] = round(x.seconds/total_seconds*100,2)

    df.apply(set_percents, axis=1)

    return activity_percents

# def get_locs(reader, user_data, user_name, json_array):
#     """
#     Predict clusters from cluster
#     """
#     ts = time()
#     print "START get_locs:", ts
#     H_model = get_model(user_name)
#     print 106, "get_locs", ":" * 10, (time()-ts)
#     H_data = user_data[['GPS Altitude','GPS Latitude','GPS Longitude']]
#     print 108, "get_locs", ":" * 10, (time()-ts)
#     preprocess = preprocessing.scale(H_data)
#     print 110, "get_locs", ":" * 10, (time()-ts)
#     clusters = H_model.fit_predict(H_data)
#     print 112, "get_locs", ":" * 10, (time()-ts)
#     H_data.reset_index(inplace=True)
#     print 114, "get_locs", ":" * 10, (time()-ts)

#     H_data["ymdh"] = H_data["index"].apply(lambda t: "{year}{month}{day}{hour}".format(
#         year=t.year, month=t.month, day=t.day, hour=t.hour
#     ))
#     print 119, "get_locs", ":" * 10, (time()-ts)
#     H_data["hour"] = H_data["index"].apply(lambda t: t.hour)
#     print 121, "get_locs", ":" * 10, (time()-ts)
#     H_data["cluster"] = pd.Series(clusters)
#     print 123, "get_locs", ":" * 10, (time()-ts)
#     H_data.loc[:,"GPS Latitude"] = H_data["GPS Latitude"].astype(float)
#     H_data.loc[:,"GPS Longitude"] = H_data["GPS Longitude"].astype(float)
#     H_data.loc[:,"GPS Altitude"] = H_data["GPS Altitude"].astype(float)
#     print 127, "get_locs", ":" * 10, (time()-ts)
#     get_label_latlongs(H_data, json_array)
#     print 129, "get_locs", ":" * 10, (time()-ts)


# def get_label_latlongs(df, json_array):
#     ts = time()
#     print "START get_label_latlongs:", ts
#     df_grouped = df.groupby(["cluster", "hour"]).median()
#     zero = df_grouped.loc[0,:]; one = df_grouped.loc[1,:]
#     zero_full = df[df.cluster==0]; one_full = df[df.cluster==1]
#     labels = {"home":{},"work":{}}
#     home=None; work=None
#     home_full=None; work_full=None
#     print 142, "get_label_latlongs", ":" * 10, (time()-ts)

#     gb = df.groupby(["cluster"]).agg(
#         {"hour": lambda x: float(((0 <= x) & (x < 6)).sum())/((0 <= x) & (x < 24)).sum()}
#     )

#     home_idx = gb[gb["hour"] == max(gb["hour"])].index[0]
#     print 149, "get_label_latlongs", ":" * 10, (time()-ts)


#     if home_idx != 0:
#         (home, work) = (one, zero)
#         (home_full, work_full) = (one_full, zero_full)
#     else:
#         (home, work) = (zero, one)
#         (home_full, work_full) = (zero_full, one_full)

#     print 159, "get_label_latlongs", ":" * 10, (time()-ts)

#     set_loc_percents(home_full, work_full, json_array)

#     print 163, "get_label_latlongs", ":" * 10, (time()-ts)

#     min_home = home.loc[home.index == min(home.index),:]
#     min_work = work.loc[work.index == work.index[len(work.index)/2],:]

#     print 168, "get_label_latlongs", ":" * 10, (time()-ts)

#     labels["home"]["lat"] = float(min_home["GPS Latitude"])
#     labels["home"]["long"] = float(min_home["GPS Longitude"])
#     labels["work"]["lat"] = float(min_work["GPS Latitude"])
#     labels["work"]["long"] = float(min_work["GPS Longitude"])

#     print 175, "get_label_latlongs", ":" * 10, (time()-ts)
#     print labels
#     json_array.append(labels)

#     print 179, "get_label_latlongs", ":" * 10, (time()-ts)


# def get_model(username):
#     filename = "data/hclust_{0}.p".format(username)
#     return pickle.load(open(filename, "rb" ))


# def set_loc_percents(home, work, json_array):
#     home = home.groupby(lambda x: home['index'][x].day).agg({"index": lambda i: (max(i)-min(i)).total_seconds()})
#     work = work.groupby(lambda x: work['index'][x].day).agg({"index": lambda i: (max(i)-min(i)).total_seconds()})
#     # datediff_home = max(home["index"]) - min(home["index"])
#     # datediff_work = max(work["index"]) - min(work["index"])
#     seconds_home = np.sum(home["index"])
#     seconds_work = np.sum(work["index"])
#     seconds_total = seconds_home + seconds_work
#     percent_home = round(100*(float(seconds_home) / seconds_total), 2)
#     percent_work = round(100*(float(seconds_work) / seconds_total), 2)

#     json_array.append({"percent_home":percent_home, "percent_work":percent_work})

