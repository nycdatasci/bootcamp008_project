import re
from scrapy.exceptions import DropItem
from scrapy.selector import Selector


### REGEX PATTERNS
alphanum_re = re.compile("\w+")
num_re = re.compile("\d+")
year_re = re.compile("\d{4}")
month_re = re.compile("[a-zA-Z]+")
day_re = re.compile("\d{1,2}")

def raise_drop_item(file, items, message):
	file.write( "{0}\n{1}\n\n".format(message, items) )
	raise DropItem(message)



def process_genres(genres):

	# if genre doesn't exist or empty, return 0
	try:
		genlen = len(genres)

		if genlen == 0:
			raise Exception()
	except:
		return 0

	genres = map(lambda x: x.lower(), genres)
	return "|".join(genres)



def process_running_time(running_time):
	
	# if running time doesn't exist or empty, return 0
	try:
		rtlen = len(running_time)

		if rtlen == 0:
			raise Exception()
	except:
		return 0

	# if running time has too much junk in it, get all descendents
	if rtlen > 2:
		running_time = (filter(
			lambda x: num_re.search(x),
			Selector(text=info_table).xpath(
				"//*[th='Running time']//following-sibling::td//*/text()"
				).extract()
		))

	if rtlen == 1:
		return int(num_re.search(running_time[0]).group())
	elif rtlen == 2:
		rt1 = int(num_re.search(running_time[0]).group())
		rt2 = int(num_re.search(running_time[1]).group())
		return 0.5 * (rt1 + rt2)


def clean_dates(dates, info_table):
	# if len of [] != 2
	# both dates are in one string
	# or the start date is in a span
	if len(dates) == 1 and u'\u2013' in dates[0]:
		(start_date, end_date) = dates[0].split(u'\u2013')
		if num_re.search(start_date) == None:
			start_date = (Selector(text=info_table).xpath(
				"//*[th='Original release']//following-sibling::td/span/text()"
				).extract()[1]
			)
		#end_date = dates[0]

	elif len(dates) == 2:
		(start_date, end_date) = dates
	elif len(dates) > 2:
		(start_date, end_date) = dates[:2]

	return (start_date, end_date)


def process_date(start, end):
	start = start.encode("ascii","ignore").strip()
	end = end.encode("ascii","ignore").strip()

	month = month_re.search(start).group()
	day = day_re.search(start).group()

	#if no year in the start date, it's the same as the end date
	if year_re.search(start) == None:
		year = year_re.search(end).group()
		start = "{0} {1}, {2}".format(month, day, year)
	else:
		year = year_re.search(start).group()
		start = "{0} {1}, {2}".format(month, day, year)

	#if end doesn't have month, use month/date from start
	if month_re.search(end) == None:
		end = "{0} {1}, {2}".format(month, day, end)

	return {"start": start, "end": end}



### OKAY IF GENRE OR RUNNING TIME MISSING ###
def any_missing(item):
	# check if keys exist
	# if (any(k not in item for k in 
	# ("title", "genres", "running_time", "original_network", "start_date", "end_date"))):
	# 	return True

	if (any(k not in item for k in 
	("title", "original_network", "start_date", "end_date"))):
		return True

	# or if empty
	title_missing = item["title"].strip() == ""
	#genres_missing = item["genres"] == []
	#running_time_missing = item["running_time"] == []
	network_missing = item["original_network"].strip() == ""
	start_date_missing = item["start_date"].strip() == ""
	end_date_missing = item["end_date"].strip() == ""

	

	# if not genres_missing:
	# 	if alphanum_re.search(item["genres"][0]) == None:
	# 		return True

	if not network_missing:
		if alphanum_re.search(item["original_network"][0]) == None:
			return True

	# if not running_time_missing:
	# 	if alphanum_re.search(item["running_time"][0]) == None:
	# 		return True


	if (any([title_missing,	network_missing,
	start_date_missing, end_date_missing])):
		return True
	else:
		return False

	# if (any([title_missing, genres_missing, running_time_missing,
	# 	network_missing, start_date_missing, end_date_missing])):
	# 	return True
	# else:
	# 	return False