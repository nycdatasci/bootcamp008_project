import datetime

author_list = lists_final.groupby("author").agg("count").iloc[:,0].sort_values(ascending=False)
title_list = lists_final.groupby(["author", "title"]).agg("count").iloc[:,0].sort_values(ascending=False)

publisher = pd.merge(pd.DataFrame(corp_owner.values(), corp_owner.keys()), pd.DataFrame(genre.values(), genre.keys()), how = "outer", left_index=True, right_index=True)
publisher.columns= ['parent', 'genre']
publisher.index = publisher.index.str.upper()
list_pub = pd.merge(lists_final, publisher, left_on='publisher', right_index=True, how="outer")

list_pub.loc[list_pub.genre=="Literary",].groupby('publisher').agg('count').iloc[:,0].sort_values(ascending=False)

list_pub['parent'][list_pub['parent'].isnull()] = "Small Imprint"
list_pub['genre'][list_pub['genre'].isnull()] = "Small Imprint"

def convert_date(x):
    x= str(x)
    if x.find("/") > -1:
        return datetime.datetime.strptime(x, "%m/%d/%Y").date()
    else:
        try:
            return datetime.datetime.strptime(x, "%Y-%m-%d").date()
        except:
            return (x)

list_pub['published_date']=list_pub['published_date'].apply(convert_date)
list_pub = list_pub.dropna(thresh=5)
list_pub['year']=[x.year for x in list_pub['published_date']]
list_pub['parent'][(list_pub.published_date>datetime.date(2013, 7, 12)) & ((list_pub.parent=='Penguin')\
                                                                           | (list_pub.parent=="Random House"))]="Penguin Random"
