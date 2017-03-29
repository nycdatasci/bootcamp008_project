# Python
from flask import Flask, send_file, request
import json
import pandas as pd
#from datetime import datetime

# User-created
import knowhere_db as kdb
from helpers import *

reader = kdb.Reader(db_name='knowhere')
users = query_db_convert_id(
	reader=reader,
	collection="users",
	id_cols=["_id"],
	sort_col="username",
	method=False,
	_filter={}
)

<<<<<<< Updated upstream:Knowhere/app/app.py
activity_percents = get_activity_percents(reader)
=======
"""
will get every user's data the when the app is run.
need to make this dynamic so new records are fetched
"""
# data = query_db_convert_id(
# 	reader=reader,
# 	collection="iphone",
# 	id_cols=["_id", "user_id"],
# 	sort_col="timestamp",
# 	unrolled=True
# )


>>>>>>> Stashed changes:app/app.py

app = Flask(__name__)

@app.route("/")
def index():
	return send_file("templates/knowhere.html")

@app.route("/query_users", methods=["GET"])
def get_users():
	return json.dumps(users.to_dict(orient='records'));
	#return json.dumps([{"names":["Andrew", "Bill", "Emil", "Glen"]}])

@app.route("/query_iphone_test_GPS", methods=["GET"])
def get_iphone_test():
	user_name = request.args.get("user_name")
	min_date = request.args.get("min_date")
	max_date = request.args.get("max_date")

	# min_date = datetime.strptime(min_date, '%Y-%m-%dT%H:%M:%S.%fZ')
	# max_date = datetime.strptime(max_date, '%Y-%m-%dT%H:%M:%S.%fZ')
	try:
		#ts = time()
		temp_data = query_db_convert_id(
			reader=reader,
			collection="iphone",
			method="pivoted",
			username=user_name,
			sensor="GPS",
			min_date=min_date,
			max_date=max_date
			#_filter={"user_id":kdb.ObjectId(user_id)}
		)

		#print 67, "app.py", ":" * 10, (time()-ts)

		#print temp_data

		user_data = temp_data.apply(make_lat_long, axis=1)
		#print 72, "app.py", ":" * 10, (time()-ts)
		user_data = list(user_data[pd.notnull(user_data)])
		#print 74, "app.py", ":" * 10, (time()-ts)

		get_locs(temp_data, user_name, user_data)
		#print 77, "app.py", ":" * 10, (time()-ts)
		set_distance(temp_data, user_data)
		#print 79, "app.py", ":" * 10, (time()-ts)
		#set_distance_daily(temp_data, user_data)
	except Exception, e:
		print e
		user_data = []

	return json.dumps(user_data);
	#return json.dumps([{"names":["Andrew", "Bill", "Emil", "Glen"]}])


@app.route("/query_animals", methods=["GET"])
def get_animal():
	animal_info = animal_riding_time()
	return json.dumps(animal_info)

@app.route("/query_activities", methods=["GET"])
def get_activities():
	return json.dumps(activity_percents)
	
@app.teardown_appcontext
def close_db(error):
	reader.close()


if __name__ == "__main__":
    app.run(host='0.0.0.0')