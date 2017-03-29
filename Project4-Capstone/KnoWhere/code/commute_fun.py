import db.knowhere_db as kdb

# returns a random, recent, popular book in the given genre)
def reccomend_book(category=None):
	reader = kdb.Reader('knowhere')
	df = reader.get_audiobooks_dataframe(recent=True, category=category)
	df.filter(['Length', 'NarratedBy', 'Title', 'WrittenBy', 'Category'])
	return df.sample(1, axis=0)
	
animal_speeds = {'bear': 35, 'tortoise': 0.2, 'kangaroo': 43}	
	
def animal_riding_time(commute_distance, animal):
	speed = animal_speeds[animal]
	return commute_distance / speed
    
def catapult(commute_distance):
    velocity = (commute_distance * 9.8) ** 0.5
    time = commute_distance / (velocity * (2 ** 0.5) / 2.0)
    time_y = time / 2.0
    max_height = velocity * time_y + (-9.8 / 2.0) * (time_y ** 0.5)
    return velocity, time, max_height