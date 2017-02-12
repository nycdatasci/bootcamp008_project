import scrapy, json, csv
from stocktwits.items import tweetData

class tweetSpider(scrapy.Spider):
	name = "StockTwitsSpider"
	allowed_domains = ["stocktwits.com"]
	start_urls = ["https://stocktwits.com/symbol/AAPL?q=aapl"]
	
	def parse(self,response):
##		for user in self.users:#self.users: # get tweets from each user
##			yield scrapy.Request("http://stocktwits.com/"+user+"/",callback=self.getTweets)

##	def getTweets(self,response):# get all tweets from first user page
		tweets = response.xpath("//ol[@class='stream-list show-conversation stream-poller']/li/@data-src").extract()
		

		for tweet in tweets: # structure user and tweet data
			rawData = json.loads(tweet)
			data = tweetData()

			# user metadata
			data['userName'] 		   = rawData['user']['username']
			data['userID'] 			   = rawData['user']['id']
			data['isSuggested'] 	   = self.isSuggested(rawData['classes'])
			data['isInvestorRelation'] = rawData['investor_relations']
			# tweet (meta)data
			data['date'] 			   = self.date(rawData['created_at'])
			data['time'] 			   = self.time(rawData['created_at'])
			data['tweetID'] 		   = rawData['id']
			data['tweetBody'] 		   = rawData['body']
			if rawData['sentiment'] is not None:
				data['sentiment'] 		   = rawData['sentiment']['name']
			else:
				data['sentiment'] 		   = None
			data['totalLikes'] 		   = rawData['total_likes']
			data['likesList'] 		   = self.trimLikesList(rawData['latest_likes'])
			data['totalReshares'] 	   = rawData['total_reshares']
			data['mentionedUsers'] 	   = rawData['mention_ids']
			data['replyTo'] 		   = rawData['in_reply_to_message_id']

			yield(data)

##	def getUserList(self):
##		users = []
##		with open("userStats.csv", 'r') as userFile:
##			reader = csv.reader(userFile)
##			reader.next() # skip headers
##			for row in reader:
##				users.append(row[0])
##		return users

	def isSuggested(self,classifications): 
		return 'suggested' in classifications.split(' ')

	def date(self,timestamp): #format = yyyy-mm-dd
		spl = timestamp.split(' ')[1:4]
		spl[1] = self.strToMonthNum(spl[1])
		return '-'.join(spl)

	def strToMonthNum(self,strMonth):
		strMonth = strMonth.lower() # just in *case* (ha)
		if 	 strMonth == 'jan': return '01'
		elif strMonth == 'feb': return '02'
		elif strMonth == 'mar': return '03'
		elif strMonth == 'apr': return '04'
		elif strMonth == 'may': return '05'
		elif strMonth == 'jun': return '06'
		elif strMonth == 'jul': return '07'
		elif strMonth == 'aug': return '08'
		elif strMonth == 'sep': return '09'
		elif strMonth == 'oct': return '10'
		elif strMonth == 'nov': return '11'
		elif strMonth == 'dec': return '12'
		return '99' # catch errors

	def time(self,timestamp): #format = hh:mm:ss
		return(timestamp.split(' ')[4])

	def trimLikesList(self,rawList):
		return [obj['login'] for obj in rawList]
