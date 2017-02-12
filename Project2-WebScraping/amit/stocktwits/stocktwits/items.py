import scrapy


class tweetData(scrapy.Item):
	# user metadata
	userName 		   = scrapy.Field()
	userID 			   = scrapy.Field()
	isSuggested 	   = scrapy.Field()
	isInvestorRelation = scrapy.Field()

	# tweet (meta)data
	date 			   = scrapy.Field()
	time 			   = scrapy.Field()
	tweetID 		   = scrapy.Field()
	tweetBody 		   = scrapy.Field()
	sentiment 		   = scrapy.Field()
	totalLikes 		   = scrapy.Field()
	likesList 		   = scrapy.Field()
	totalReshares 	   = scrapy.Field()
	mentionedUsers 	   = scrapy.Field()
	replyTo 		   = scrapy.Field()