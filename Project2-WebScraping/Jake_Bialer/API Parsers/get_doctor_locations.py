import csv
import re 
import requests 
import json
from datetime import datetime
import sqlite3

# add total reviews 
def get_schedule_info(id,location_id,date):
  # id="57507";location_id="39068";date="2017-02-10"
  # get_schedule_info("57507", "39068","2017-02-10") -> lost of data 
  # https://www.zocdoc.com/api/2/professionallocation/timeslots?professional_location_ids=57507_39068&date=2017-02-10&days_ahead=45
  doctor_data = {}
  time_data = {}
  url="https://www.zocdoc.com/api/2/professionallocation/timeslots?professional_location_ids="+str(id)+"_"+str(location_id)+"&date="+str(date)+"&days_ahead=45"
  data = requests.get(url)
  data =data.text
  parsed_data = json.loads(data)
  professional_locations = parsed_data['data']['professional_locations'][0]
  doctor_data['doctor_id'] = id
  doctor_data['location_id'] = location_id 
  doctor_data['date'] = date
  doctor_data['profession_id'] = professional_locations['professional']['professional_id']
  doctor_data['total_reviews'] = professional_locations['professional']['rating']['total_reviews']
  doctor_data['overall_rating'] = professional_locations['professional']['rating']['overall']
  doctor_data['bedside_manner'] = professional_locations['professional']['rating']['bedside_manner']
  doctor_data['wait_time'] = professional_locations['professional']['rating']['wait_time']
  doctor_data['gender'] = professional_locations['professional']['gender']
  doctor_data['main_specialty_id'] = professional_locations['professional']['main_specialty_id']
  doctor_data['main_specialty_name'] = professional_locations['professional']['main_specialty_name']
  doctor_data['profile_url'] = professional_locations['professional']['profile_url']
  doctor_data['location_ids'] = professional_locations['professional']['location_ids'][0]
  doctor_data['location_id'] = professional_locations['location']['location_id']
  doctor_data['address_1'] = professional_locations['location']['address_1']
  doctor_data['address_2'] = professional_locations['location']['address_2']
  doctor_data['address_3'] = professional_locations['location']['address_3']
  doctor_data['city'] =  professional_locations['location']['city']
  doctor_data['state'] = professional_locations['location']['state']
  doctor_data['zip'] = professional_locations['location']['zip']
  doctor_data['phone'] = professional_locations['location']['phone']
  doctor_data['latitude'] = professional_locations['location']['latitude']
  doctor_data['longitude'] = professional_locations['location']['longitude']
  doctor_data['utc_offset'] = professional_locations['location']['utc_offset']
  doctor_data['utc_offset_seconds'] = professional_locations['location']['utc_offset_seconds']
  doctor_data['is_in_network'] = professional_locations['is_in_network']
  doctor_data['is_zocdoc'] = professional_locations['is_zocdoc']
  doctor_data['specialty_id']=parsed_data['data']['base_booking_parameters']['specialtyId']
  doctor_data['procedureId']=parsed_data['data']['base_booking_parameters']['procedureId']
  doctor_data['insuranceCarrier']=parsed_data['data']['base_booking_parameters']['insuranceCarrier']
  doctor_data['insurancePlan']=parsed_data['data']['base_booking_parameters']['insurancePlan']
  timeslots = professional_locations['timeslots']
  time_data['start_time'] = []
  time_data['timestamp'] = []
  time_data['constrainta'] = []
  time_data['utc_offset_seconds'] = []
  for timeslot in timeslots:
    time_data['start_time'].append(timeslot['start_time'])
    time_data['timestamp'].append(timeslot['timestamp'])
    if timeslot['constraint'] is None:
      time_data['constrainta'].append("NA")
    else:
      time_data['constrainta'].append(timeslot['constraint'])
    time_data['utc_offset_seconds'].append(timeslot['utc_offset_seconds'])
    # Create list of doctor, location_ids 
  time_data['location_id'] = [location_id]*len(time_data['start_time'])
  time_data['doctor_id'] = [id]*len(time_data['start_time'])
  time_data['search_date'] = [date]*len(time_data['start_time'])
  time_data['current_time'] =  [str(datetime.now())]*len(time_data['start_time']) 
  return time_data, doctor_data

 
def insert_data(id,location_id,date,conn):
  cur = conn.cursor()
  data = get_schedule_info(id, location_id, date)
  time_data = data[0]
  time_columns = ','.join(time_data.keys())
  time_values= list(zip(*time_data.values()))
  for time_value in time_values:
    query = 'INSERT INTO doctor_times ({}) VALUES {}'.format(time_columns, time_value)
    cur.execute(query)
  doctor_data = data[1]
  doctor_values = tuple(str(value) for value in tuple(doctor_data.values()))
  doctor_columns = ','.join(doctor_data.keys())
  query = 'INSERT INTO doctor ({}) VALUES {}'.format(doctor_columns, doctor_values)
  print(query)
  cur.execute(query, doctor_data)
  conn.commit()
  cur.close()
  

if __name__ == '__main__':
  conn = sqlite3.connect('doctor1.db')
  date= "2017-02-11"
  with open("/Users/jakebialer/Desktop/items_doctor_csv_8.csv","r") as file:
    file_reader = csv.reader(file)
    next(file_reader)
    for row in file_reader:
      try:
        location_ids=row[9].split(",")
        doctor_id = re.match('.*?([0-9]+)$', row[59]).group(1)
        for location_id in location_ids:
          try:
            insert_data(doctor_id, location_id, date,conn)
          except Exception as e:
            print(e)
            print("something went wrong")
      except:
        print(row[59])
  
  conn.close()
