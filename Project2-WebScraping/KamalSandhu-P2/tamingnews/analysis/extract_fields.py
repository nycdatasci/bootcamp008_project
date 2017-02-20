
import numpy as np
import pandas as pd
from os import listdir
import json
from operator import itemgetter
import numpy as np

dir = r'C:/Users/sandh/Dropbox/FRM/Bootcamp/Projects/Project 2/tamingnews/' \
      r'analysis/data/'
response_files = listdir(dir + 'response/')



id, spider, gSent, gMag, \
gtopic1, gtopic2, gtopic3, gtopic4, gtopic5, \
gentity1, gentity2, gentity3, gentity4, gentity5, \
gentity1salience, gentity2salience, gentity3salience, gentity4salience, gentity5salience, \
gentity1type, gentity2type, gentity3type, gentity4type, gentity5type, \
tentity1, tentity2, tentity3, tentity4, tentity5, \
tentity1type, tentity2type, tentity3type, tentity4type, tentity5type, \
tentity1salience, tentity2salience, tentity3salience, tentity4salience, tentity5salience, \
lenArticle,lenGoogleAPItokens, lenGoogleAPIentities, lenTextrazorAPIentailments,\
lenTextrazorAPIproperties, lenTextrazorAPItopics, lenTextrazorAPIsentences,\
lenTextrazorAPIrelations, lenTextRazorAPIcoarseTopics, lenTextrazorAPIentities = ([] for i in range(49))
num = 1

for file_ in response_files:
    print "Reading file num: ", num
    data_file = open(dir + 'response/' + str(file_), 'r')
    data = json.load(data_file)
    data_file.close()

    article = data['article']
    id.append(hash(article))
    spider.append(data['spider'])
    gSent.append(data['googleAPIsentiment'][0])
    gMag.append(data['googleAPIsentiment'][1])

    try:
        a1 = data['textrazorAPItopics'][0]['label']
    except (IndexError, TypeError, KeyError) as e:
        a1 = np.nan
    try:
        a2 = data['textrazorAPItopics'][1]['label']
    except (IndexError, TypeError, KeyError) as e:
        a2 = np.nan
    try:
        a3 = data['textrazorAPItopics'][2]['label']
    except (IndexError, TypeError, KeyError) as e:
        a3 = np.nan
    try:
        a4 = data['textrazorAPItopics'][3]['label']
    except (IndexError, TypeError, KeyError) as e:
        a4 = np.nan
    try:
        a5 = data['textrazorAPItopics'][4]['label']
    except (IndexError, TypeError, KeyError) as e:
        a5 = np.nan
    gtopic1.append(a1)
    gtopic2.append(a2)
    gtopic3.append(a3)
    gtopic4.append(a4)
    gtopic5.append(a5)

    try:
        a1 = data['googleAPIentities'][0]['name']
    except (IndexError, TypeError, KeyError) as e:
        a1 = np.nan
    try:
        a2 = data['googleAPIentities'][1]['name']
    except (IndexError, TypeError, KeyError) as e:
        a2 = np.nan
    try:
        a3 = data['googleAPIentities'][2]['name']
    except (IndexError, TypeError, KeyError) as e:
        a3 = np.nan
    try:
        a4 = data['googleAPIentities'][3]['name']
    except (IndexError, TypeError, KeyError) as e:
        a4 = np.nan
    try:
        a5 = data['googleAPIentities'][4]['name']
    except (IndexError, TypeError, KeyError) as e:
        a5 = np.nan
    gentity1.append(a1)
    gentity2.append(a2)
    gentity3.append(a3)
    gentity4.append(a4)
    gentity5.append(a5)

    try:
        a1 = data['googleAPIentities'][0]['type']
    except (IndexError, TypeError, KeyError) as e:
        a1 = np.nan
    try:
        a2 = data['googleAPIentities'][0]['type']
    except (IndexError, TypeError, KeyError) as e:
        a2 = np.nan
    try:
        a3 = data['googleAPIentities'][0]['type']
    except (IndexError, TypeError, KeyError) as e:
        a3 = np.nan
    try:
        a4 = data['googleAPIentities'][0]['type']
    except (IndexError, TypeError, KeyError) as e:
        a4 = np.nan
    try:
        a5 = data['googleAPIentities'][0]['type']
    except (IndexError, TypeError, KeyError) as e:
        a5 = np.nan
    gentity1type.append(a1)
    gentity2type.append(a2)
    gentity3type.append(a3)
    gentity4type.append(a4)
    gentity5type.append(a5)

    try:
        a1 = data['googleAPIentities'][0]['salience']
    except (IndexError, TypeError, KeyError) as e:
        a1 = np.nan
    try:
        a2 = data['googleAPIentities'][1]['salience']
    except (IndexError, TypeError, KeyError) as e:
        a2 = np.nan
    try:
        a3 = data['googleAPIentities'][2]['salience']
    except (IndexError, TypeError, KeyError) as e:
        a3 = np.nan
    try:
        a4 = data['googleAPIentities'][3]['salience']
    except (IndexError, TypeError, KeyError) as e:
        a4 = np.nan
    try:
        a5 = data['googleAPIentities'][4]['salience']
    except (IndexError, TypeError, KeyError) as e:
        a5 = np.nan
    gentity1salience.append(a1)
    gentity2salience.append(a2)
    gentity3salience.append(a3)
    gentity4salience.append(a4)
    gentity5salience.append(a5)


    df = pd.DataFrame(data['textrazorAPIentities'])
    df = df[df['confidenceScore'] > 8]
    df = df.sort_values(by='relevanceScore', ascending=False)
    df = df.drop_duplicates('entityEnglishId')
    df = df.head(5)

    try:
        a1 = df['entityEnglishId'].iloc[0]
    except (IndexError, TypeError, KeyError) as e:
        a1 = np.nan
    try:
        a2 = df['entityEnglishId'].iloc[1]
    except (IndexError, TypeError, KeyError) as e:
        a2 = np.nan
    try:
        a3 = df['entityEnglishId'].iloc[2]
    except (IndexError, TypeError, KeyError) as e:
        a3 = np.nan
    try:
        a4 = df['entityEnglishId'].iloc[3]
    except (IndexError, TypeError, KeyError) as e:
        a4 = np.nan
    try:
        a5 = df['entityEnglishId'].iloc[4]
    except (IndexError, TypeError, KeyError) as e:
        a5 = np.nan
    tentity1.append(a1)
    tentity2.append(a2)
    tentity3.append(a3)
    tentity4.append(a4)
    tentity5.append(a5)

    try:
        a1 = df['type'].iloc[0][0]
    except (IndexError, TypeError, KeyError) as e:
        a1 = np.nan
    try:
        a2 = df['type'].iloc[1][0]
    except (IndexError, TypeError, KeyError) as e:
        a2 = np.nan
    try:
        a3 = df['type'].iloc[2][0]
    except (IndexError, TypeError, KeyError) as e:
        a3 = np.nan
    try:
        a4 = df['type'].iloc[3][0]
    except (IndexError, TypeError, KeyError) as e:
        a4 = np.nan
    try:
        a5 = df['type'].iloc[4][0]
    except (IndexError, TypeError, KeyError) as e:
        a5 = np.nan

    tentity1type.append(a1)
    tentity2type.append(a2)
    tentity3type.append(a3)
    tentity4type.append(a4)
    tentity5type.append(a5)

    try:
        a1 = df['relevanceScore'].iloc[0]
    except (IndexError, TypeError, KeyError) as e:
        a1 = np.nan
    try:
        a2 = df['relevanceScore'].iloc[1]
    except (IndexError, TypeError, KeyError) as e:
        a2 = np.nan
    try:
        a3 = df['relevanceScore'].iloc[2]
    except (IndexError, TypeError, KeyError) as e:
        a3 = np.nan
    try:
        a4 = df['relevanceScore'].iloc[3]
    except (IndexError, TypeError, KeyError) as e:
        a4 = np.nan
    try:
        a5 = df['relevanceScore'].iloc[4]
    except (IndexError, TypeError, KeyError) as e:
        a5 = np.nan
    tentity1salience.append(a1)
    tentity2salience.append(a2)
    tentity3salience.append(a3)
    tentity4salience.append(a4)
    tentity5salience.append(a5)

    lenArticle.append(len(data['article']))
    lenGoogleAPItokens.append(len(data['article'])*2)

    l1 = 0
    for s in data['googleAPIentities']:
        for k, v in s.items():
            try:
                l1 = l1 + len(str(v))
            except (UnicodeEncodeError, TypeError, KeyError) as e:
                pass
    lenGoogleAPIentities.append(l1)

    def count(l, le=0):
        if type(l) is not type([]) or type({}):
            return len(str(l))
        elif type(l) is type([]):
            for l1 in l:
                le = le + count(l1, le)
        elif type(l) is type({}):
            for k, v in l.items():
                le = le + count(v, le)


    lenTextrazorAPIentailments.append(count(data['textrazorAPIentailments']))
    lenTextrazorAPIproperties.append(count(data['textrazorAPIproperties']))
    lenTextrazorAPItopics.append(count(data['textrazorAPItopics']))
    lenTextrazorAPIsentences.append(count(data['textrazorAPIsentences']))
    lenTextrazorAPIrelations.append(count(data['textrazorAPIsentences']))
    lenTextRazorAPIcoarseTopics.append(count(data['textrazorAPIcoarseTopics']))
    lenTextrazorAPIentities.append(count(data['textrazorAPIentities']))

    num += 1

dic = {
    'Source': spider,
        'id':id,
         'gSent': gSent,
            'gMag': gMag,
                'gtopic1': gtopic1,
                    'gtopic2': gtopic2,
                        'gtopic3': gtopic3,
                            'gtopic4': gtopic4,
                                'gtopic5': gtopic5,

    'gentity1': gentity1,
        'gentity1type': gentity1type,
            'gentity1salience': gentity1salience,

    'gentity2': gentity2,
        'gentity2type': gentity2type,
            'gentity2salience': gentity2salience,

    'gentity3': gentity3,
        'gentity3type': gentity3type,
            'gentity3salience': gentity3salience,

    'gentity4': gentity4,
        'gentity4type': gentity4type,
            'gentity4salience': gentity4salience,

    'gentity5': gentity5,
        'gentity5type': gentity5type,
            'gentity5salience': gentity5salience,

    'tentity1': tentity1,
        'tentity1type': tentity1type,
            'tentity1salience': tentity1salience,

    'tentity2': tentity2,
        'tentity2type': tentity2type,
            'tentity2salience': tentity2salience,

    'tentity3': tentity3,
        'tentity3type': tentity3type,
            'tentity3salience': tentity3salience,

        'tentity4': tentity4,
            'tentity4type': tentity4type,
                'tentity4salience': tentity4salience,

        'tentity5': tentity5,
            'tentity5type': tentity5type,
                'tentity5salience': tentity5salience,

        'lenArticle': lenArticle,
            'lenGoogleAPItokens': lenGoogleAPItokens,
                'lenGoogleAPIentities': lenGoogleAPIentities,
            'lenTextrazorAPIentailments': lenTextrazorAPIentailments,
                'lenTextrazorAPIproperties': lenTextrazorAPIproperties,
                    'lenTextrazorAPItopics': lenTextrazorAPItopics,
        'lenTextrazorAPIsentences': lenTextrazorAPIsentences,
                'lenTextrazorAPIrelations': lenTextrazorAPIrelations,
                    'lenTextRazorAPIcoarseTopics': lenTextRazorAPIcoarseTopics,
        'lenTextrazorAPIentities': lenTextrazorAPIentities}


df = pd.DataFrame(dict([(k, pd.Series(v)) for k,v in dic.iteritems()]))
df.to_csv(r'C:/Users/sandh/Dropbox/FRM/Bootcamp/Projects/Project 2/tamingnews/analysis/data/data.csv', encoding='utf-8')