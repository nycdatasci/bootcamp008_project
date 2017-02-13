import csv
import re
import json
import csv


with open("/Users/jakebialer/Desktop/items_doctor_csv_8.json","r") as file,open("doctor_reviews.csv","w") as outfile:
  parsed_data = json.loads(file.read())
  file_writer = csv.writer(outfile)
  file_writer.writerow(['review_text','review_author','review_bedside_manner','review_date_published','review_overall_rating','review_wait_time','doctor_id'])
  for row in parsed_data:
        try:
          doctor_id = re.match('.*?([0-9]+)$', row['url']).group(1)
          if "review_author" in row:
            for num in range(len(row['review_author'])):
                  review_text = row['review_text'][num]
                  # review_text = review_text.encode('utf-8')
                  new_row = [review_text,row['review_author'][num],row['review_bedside_manner'][num],row['review_date_published'][num],row['review_overall_rating'][num],row['review_wait_time'][num],doctor_id]
                  file_writer.writerow(new_row)
        except Exception as e:
          print(e)
          print(row['url'])
        # print(row[48],row[49],row[50],row[51],row[52],row[53],row[54])


