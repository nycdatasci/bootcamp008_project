<img src="yelp-icon.png" alt="Drawing" style="width: 80px;"/>

## Introduction



In this project, the app aims to identify the key features for people in Phoneix to give score on Yelp. Using the Yelp Dataset from [Yelp Dataset Challenge](https://www.yelp.com/dataset_challenge), the app compares the influence of some attributes in the dataset based on the category. In particular, the app analysises every attribute to the appearance of hipsters in order to find out whether the ambiance of hipsters will affect the average score of the store.


## Data Set
According to the description of Yelp Challenge, this dataset includes:

* 4.1M reviews and 947K tips by 1M users for 144K businesses
* 1.1M  business attributes, e.g., hours, parking availability, ambience.
* Aggregated check-ins over time for each of the 125K businesses
* 200,000 pictures from the included businesses

It includes 11 cities such as: Edinburgh in U.K., Karlsruhe in Germany, Montreal and Waterloo in Canada, Pittsburgh, Charlotte, Urbana-Champaign, Phoenix, Las Vegas, Madison, Cleveland in U.S. 

The whole dataset is composed by five json files: business, checkin, review, tip, and user file.  By using `ndjson` package, we read data as a data frame. The app only joins the business and review files by `business_id` in order to get the all business attributes, review counts, star rating. 


## Results
From the graph of category and total reviews, we can see that restauratn's Yelp strongly influences an individual's dining decisions. So the app mainly focus on the stores provide foods.

The Yelp Dataset comes from the Yelp Dataset Challenge webpage. Our project only focus on the Phoniex so we filltered out other countries and states. This left us with 10,629 businesses. I inner joined the business and review table so I have 10,629 observations and 116 variables. In order to directly find out the type of store has the most ambience of hispters, I also filtered out all non-restaurant business and build a subset dataset restaurant. 


From plotting, I find out that there are  some features corresponding to high star rating include： review count, noise level, outdoor seating, classy ambience, hipster ambience, good for kids, good for groups, divey ambience, garage parking, and has TV. For most of the plotting, the app shows that stores that provide food have more count and the average stars in the range from 3.0 to 4.5. 

One of the interesting things from the data is that for stores that good for kids category, Hair Salons and Active Life shows a outstanding high score which makes lots of sense since many parents expecially moms would always go to those places and they need to take care of their children at the same time. If those places have good environment for kids such as day care center, it is not difficult to imagine how much work they will save for moms. The same situation also happens for the Garage Parking in Hair Salons. The data shows that the hair salon stores provide garage parking will always receive higher scores. Those results also let us start to think that the business area which provide service can get a higher score if they keep making customers more convinient by providing parking plot and better environment for kids, etc.




#### Who are hipsters?

According to the Google translator, a hipster is:

> a person who follows the latest trends and fashions, especially those regarded as being outside the cultural mainstream.

Hipsters are those people who walk around town as a beard-and-glasses with plaid shirts, listening to new-ish music and seeking status. For some reasons, many people hates hipsters. The Yelp data I have also take this into consideration when rating a store. I specifically do some plotting and try to find out whether the ambience of hipster will influence the rating of the store. It turns out that hipster independently would not affect the lower rating at all. However, one of the interesting thing is that hipster would normally show up in the food, bars, American restaurants. They seldom go to the Asian resturant except the fusion bars which is much similar with American style bars. Also, I find out hipsters are not the main source of the noise. So in my opinion, it is unreasonable to discriminate against them. Even more, take the ambience of hipster into account of score ranking itself is a discrimination.



<img src="https://i.guim.co.uk/img/static/sys-images/Guardian/Pix/pictures/2014/6/21/1403386083980/How-to-be-a-hipster-001.jpg?w=700&q=55&auto=format&usm=12&fit=max&s=a004b6f44e78444eab60d405db9d7294" alt="Drawing" style="width: 200px; display: inline;"/>


<img src="http://i.telegraph.co.uk/multimedia/archive/03046/hipster-tash_3046941b.jpg" alt="Drawing" style="width: 200px; display: inline;"/>


##### Why people hate hipsters?

Quora says that people hipsters for different reasons. 

> The recent movement of hipsterius civilatus (family name) comes from young middle- and upper-class citizens who are creating their own counter-culture movement. The reason for the hate is because they are generally seen as spoiled, have a certain categoric smugness to themselves. 

> Society's perceptions of youth culture (in other news, see: rock and roll, disco, hippie, grunge, yuppie, emo, punk, and so on)

> Certain key attributes and attitudes that hipsters are seen to have, which include; vegetarianism or veganism, concern about the environment, anti-capitalist, anti-consumerist, a strong love for independent music and movies.



#### Data Analysis related to hipsters

A interesting result is that hipsters seldom shows up in the Asian resturant except some Asian Fusion store from data. The data shows that hipsters more into bars, Gastropubs, American food, Mexican food, Pizza, Sandwiches, Burgers, Art & Entertainment. 


The app also can let us pick two attributes to see the relationship between two attributes. From the Mosiac Plot, the app shows that places provide the outdoor seating will have more chance of ambience of hipsters. 


A strange finding is that the histogram shows that hipsters are fond of the place that good for groups, however, it does not show anyting from mosaic plotting. A counter example is noise level and the ambience of hipster, both bar charts and mosaic plot shows that there is not any direct relationship between them. I cannot explain now why the result from mosaic plot and bar charts is different. But I am sure there must be some statistic insights about how we evalutate the  relationship between these two attributes in different type of plotting. Moreover, mosaic plot tells us that hipsters like to hangout in the place with the price range from 1 to 3. Also, the data shows that places provide outdoor seating are not good for kids at the same time. 


The app specifically compares the ambience of hipsters and ratio of other business attributes such as food good for group, noise level, good for kids, outdoor seating, credit card usage, divey, garage parking, has TV, price range, take out option, reviews count. Regard to the noise level, one of the interesting thing is that hipsters has nothing to do with the noise level which is the opposite to the most people's expectation. For example, as for Arts & Entertainment category, we can see that if there is hipsters the noise level is high but if there is not any ambience of hipsters, the noise level is higher than without hipsters show up. Another example is that Seafood category, we can see that without hipsters, Seafood store is much quiter than the ambience of hipsters. So we cannot sure that hipsters will bring up the noise level preciesly. In addition, hipsters seems like stores with outdoor seating. They also seems into divey and place with garage parking. 



#### Maps

The app shows two maps. First of all, the map marks the place where has the ambience of hipsters. The pop up can tell you the place's name, address and score. If you really are not a fan of hipsters, you can avoid them. Or if you like me who really do not mind, you can use it as a ranking reference. Besides, if you are a potential hipsters or big fan of hipsters, welcome to go to those place and make friends with them. 

The second map is a density map built on the ambience of hipsters. From it you can tell the rough area of the hipsters. The redest area is where hipsters have a larger chance to hang out.

## Future work
In the future, I plan to build a social network between all users and their friends so that I can build a small recommendation system based on their common tastes.

















