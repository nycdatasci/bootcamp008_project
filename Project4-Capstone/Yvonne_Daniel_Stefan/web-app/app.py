from flask import Flask, render_template, request
import os
import yaml
import pickle
import pandas as pd
import json
import logging
import re
import urllib2
from keras.models import load_model
import mysql.connector
from mysql.connector import errorcode
import content_helpers as hpContent
import collaborative_helpers as hpCollab
from keras.preprocessing import sequence
os.environ["THEANO_FLAGS"] = "warn.round=False"

project_root = os.path.dirname(__file__)
template_path = os.path.join(project_root, 'templates')
app = Flask(__name__, template_folder=template_path)

cfg = yaml.safe_load(open('_inc.yaml'))

modelFiles = ['item_item_matrix.pickle', 'summary_critics_docvecs.pickle', 'tk.pickle', 'user_item_matrix.pickle']

# Contend-based
# summary_critics_docvecs = pickle.load(open('D:/models/summary_critics_docvecs-bin.pickle', 'rb'))
summary_critics_docvecs = pickle.loads(urllib2.urlopen('http://steeefan-bkt-03.s3.amazonaws.com/models/summary_critics_docvecs-bin.pickle').read())
# summary_critics_docvecs = -1

# Collaborative
+ user_item_matrix = pickle.load(open('D:/models/user_item_matrix_smaller-bin.pickle', 'rb'))
user_item_matrix = pickle.loads(urllib2.urlopen('http://steeefan-bkt-03.s3.amazonaws.com/models/user_item_matrix_smaller-bin.pickle').read())
# user_item_matrix = -1

# Item
# item_item_matrix = pickle.load(open('D:/models/item_item_matrix-bin.pickle', 'rb'))
item_item_matrix = pickle.loads(urllib2.urlopen('http://steeefan-bkt-03.s3.amazonaws.com/models/item_item_matrix-bin.pickle').read())
# item_item_matrix = -1

# Sentiment
# tk = pickle.load(open('D:/models/tk-bin-v2.pickle', 'rb'))
tk = pickle.loads(urllib2.urlopen('http://steeefan-bkt-03.s3.amazonaws.com/models/tk-bin.pickle').read())
# tk = -1
# h5 = load_model('D:/models/sentiment_model-bin.h5')
h5 = load_model(urllib2.urlopen('http://steeefan-bkt-03.s3.amazonaws.com/models/sentiment_model-bin.h5').read())
# h5 = -1

def sqlCon():
    try:
        cnx = mysql.connector.connect(user=cfg['mysql']['user'], password=cfg['mysql']['pwd'],
                                      host=cfg['mysql']['server'], database=cfg['mysql']['db'])
        return cnx
    except mysql.connector.Error as e:
        if e.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            return "Something is wrong with your user name or password"
        elif e.errno == errorcode.ER_BAD_DB_ERROR:
            return "Database does not exist"
        else:
            return e


def mcImg(url):
    defaultImg = 'http://static.metacritic.com/images/products/games/98w-game.jpg'
    return defaultImg if url is None else url if url[-12:] == '98w-game.jpg' else \
        url.replace('-98.jpg', '.jpg').replace('.jpg', '-98.jpg')


def cleaning_text(sentence):
    sentence = sentence.lower()
    sentence = re.sub(r'\\r, u', ' ', sentence)
    sentence = re.sub(r'\\', "'", sentence)
    sentence = sentence.split()
    sentence = [re.sub("([^a-z0-9' \t])", '', x) for x in sentence]
    cleaned = [s for s in sentence if s != '']
    cleaned = ' '.join(cleaned)
    return cleaned


@app.route('/', methods=['GET', 'POST'])
def index():
    return render_template('index.html')


@app.route('/reco', methods=['GET', 'POST'])
def reco():
    if request.method == 'POST':
        type = request.form.get('type')

        if type == 'content' or type == 'item':
            item = int(request.form.get('item'))
            amount = int(request.form.get('amount'))
            recoCat = request.form.get('cat').split(',')
        elif type=='collab':
            input = request.form.get('input').split(',')
    elif request.method == 'GET':
        type = request.args.get('type')

        if type == 'content' or type == 'item':
            item = int(request.args.get('item'))
            amount = int(request.args.get('amount'))
            recoCat = request.args.get('cat').split(',')
        elif type == 'collab':
            input = request.args.get('input').split(',')
    else:
        item = -1

    if type == 'content':
        # get recommendation
        recos = hpContent.content_recommend(item, amount, summary_critics_docvecs, recoCat)
        ids = [x[0] for x in recos]
        recos = pd.DataFrame(sorted(recos, key=lambda x: x[1], reverse=True), columns=['uniqueID', 'sim'])
    elif type == 'item':
        sorted_table = item_item_matrix.sort_values([item], ascending=[False])

        index_list = pd.DataFrame(sorted_table.index.values[1:amount + 1], columns=['uniqueID'])
        similarity_list = pd.DataFrame(list(sorted_table[item][1:amount + 1]), columns=['sim'])
        recos = pd.concat([index_list, similarity_list], axis=1)

        ids = list(sorted_table.index.values[1:amount + 1])
    elif type == 'collab':
        last = user_item_matrix.shape[0]

        inputValues = {}
        for i in input:
            inputValues[int(i.split(';')[0])] = int(i.split(';')[1])

        # add score from user who lands in the page
        user_item_matrix_lcl = hpCollab.add_score(inputValues, user_item_matrix)

        # get predictions on dataframe
        preds_df = hpCollab.predict_svd(user_item_matrix_lcl)

        # collaborative recommendations
        collabRecos = list(hpCollab.collaborative_recommend(last, preds_df, user_item_matrix_lcl, 5))
        recos = pd.DataFrame({'uniqueID': collabRecos, 'sim': [-1]*len(collabRecos)})  # fake 'sim' column for later
        ids = list(collabRecos)
    else:
        ids = [0, 0, 0]
        recos = ''

    cnx = sqlCon()
    strSQL = 'SELECT uniqueID, name, "Game" AS itemType, image, link, systemNice AS system FROM tblGame WHERE uniqueID IN (' + ', '.join(str(x) for x in ids) + ')' \
             'UNION ' \
             'SELECT uniqueID, name, "Movie" AS itemType, image, link, "" AS system FROM tblMovie WHERE uniqueID IN (' + ', '.join(str(x) for x in ids) + ')' \
             'UNION ' \
             'SELECT uniqueID, name, "TV" AS itemType, image, link, "" AS system FROM tblTVShow WHERE uniqueID IN (' + ', '.join(str(x) for x in ids) + ')'

    recosInfo = pd.read_sql(strSQL, cnx)
    recos = recos.merge(recosInfo, how='left', on='uniqueID')
    cnx.close()

    reco = []
    [reco.append({
        'uniqueID': row['uniqueID'],
        'name': row['name'],
        'sim': round(row['sim']*100, 2) if row['sim'] > 1 else '',
        'itemType': row['itemType'] + ' (' + row['system'] + ')' if row['itemType'] == 'Game' else row['itemType'],
        'image': mcImg(row['image']),
        'link': row['link']
        }) for index, row in recos.iterrows()
    ]
    return json.dumps(reco)


@app.route('/reviewGrader', methods=['GET', 'POST'])
def reviewGrader():
    if request.method == 'POST':
        review = request.form.get('review')
        rating = int(request.form.get('rating'))
    elif request.method == 'GET':
        review = request.args.get('review')
        rating = int(request.args.get('rating'))
    else:
        item = -1

    dummy = ''
    cleaned = str(cleaning_text(review))
    sequences = tk.texts_to_sequences([dummy, cleaned])
    padded_sequences = sequence.pad_sequences(sequences, maxlen=203, padding='post')
    # drop_dummy = padded_sequences[1]
    preds = h5.predict(padded_sequences)

    # either 0 or 1
    predicted_rating = round(preds[1])

    # print input
    # print rating
    # print predicted_rating

    if rating < 6 and predicted_rating == 1:
        retStr = 'Are you sure about that score? It seems like you liked it'
    elif rating > 7 and predicted_rating == 0:
        retStr = 'Hmm, it seems like you don\'t really like this game, are you sure about that rating?'
    else:
        retStr = 'ok'

    return json.dumps([{'result': retStr}])


@app.route('/getItemList', methods=['GET', 'POST'])
def getItemList():
    if request.method == 'POST':
        item = request.form.get('item')
        filter = request.form.get('filter')
        itemCat = request.form.get('cat')
    elif request.method == 'GET':
        item = request.args.get('item')
        filter = request.args.get('filter')
        itemCat = request.args.get('cat')
    else:
        item = ''
        filter = ''

    cnx = sqlCon()
    #cnx = lite.connect("D:\capstone-v2.db")
    cur = cnx.cursor()

    if filter == 'item':
        strSQL = 'SELECT uniqueID FROM tblReview GROUP BY uniqueID HAVING COUNT(*) > 100';
        cur.execute(strSQL)
        whereClause = 'WHERE name LIKE "%' + item + '%" AND uniqueID IN (' + ', '.join(str(x[0]) for x in cur) + ') ' if item != '' else ' '
    else:
        whereClause = 'WHERE name LIKE "%' + item + '%" ' if item != '' else ' '

    strSQL = '' \
            'SELECT ' \
                'uniqueID, ' \
                'name, ' \
                'image, ' \
                'system, ' \
                'itemType ' \
            'FROM ' \
                '(SELECT ' \
                    'uniqueID, ' \
                    'name, ' \
                    'image, ' \
                    'systemNice AS system, ' \
                    '"Game" AS itemType ' \
                'FROM ' \
                    'tblGame ' \
                + whereClause + \
                    (' AND 1 = 0 ' if itemCat.find('games') < 0 else '') + \
                ' ' \
                'UNION ' \
                '' \
                'SELECT ' \
                    'uniqueID, ' \
                    'name, ' \
                    'image, ' \
                    '"" AS system, ' \
                    '"Movie" AS itemType ' \
                'FROM ' \
                    'tblMovie ' \
                    + whereClause + \
                        (' AND 1 = 0 ' if itemCat.find('movies') < 0 else '') + \
             '' \
                'UNION ' \
                '' \
                'SELECT ' \
                    'uniqueID, ' \
                    'name, ' \
                    'image, ' \
                    '"" AS system, ' \
                    '"TV" AS itemType ' \
                'FROM ' \
                    'tblTVShow ' \
                    + whereClause + \
                        (' AND 1 = 0 ' if itemCat.find('tv') < 0 else '') + \
             ') AS tblItem ' \
            'ORDER BY ' \
                'name ASC';
    logging.error(strSQL)
    cur.execute(strSQL)

    items = []
    [items.append({
        'uniqueID': row[0],
        'name': row[1],
        'image': mcImg(row[2]),
        'system': row[3],
        'itemType': row[4]
        }) for row in cur
    ]

    cnx.close()

    return json.dumps(items)


@app.route('/getStats/<which>', methods=['GET', 'POST'])
def getStats(which):
    cnx = sqlCon()
    cur = cnx.cursor()

    statsList = []

    if which == 'basic':
        cur.execute('SELECT COUNT(*) AS cnt FROM tblGame')
        games = next(cur)[0]

        cur.execute('SELECT COUNT(*) AS cnt FROM tblMovie')
        movies = next(cur)[0]

        cur.execute('SELECT COUNT(*) AS cnt FROM tblTVShow')
        tvShows = next(cur)[0]

        cur.execute('SELECT COUNT(*) AS cnt FROM tblReview')
        reviews = next(cur)[0]

        statsList.append({
            'games': games,
            'movies': movies,
            'tvShows': tvShows,
            'reviews': reviews
        })

    elif which == 'gamesPerSystem':
        cur.execute('SELECT systemNice AS system, COUNT(*) AS cnt FROM tblGame GROUP BY system ORDER BY COUNT(*) ASC')

        [statsList.append({
            'system': str(row[0]),
            'count': row[1]
        }) for row in cur]

    elif which == 'reviews':
        cur.execute('SELECT reviewType, COUNT(*) AS cnt FROM tblReview WHERE gameID > 0 GROUP BY reviewType');
        [statsList.append({
            'games': {
                'reviewType': str(row[0]),
                'count': row[1]
            }
        }) for row in cur]

        cur.execute('SELECT reviewType, COUNT(*) AS cnt FROM tblReview WHERE movieID > 0 GROUP BY reviewType');
        [statsList.append({
            'movies': {
                'reviewType': str(row[0]),
                'count': row[1]
            }
        }) for row in cur]

        cur.execute('SELECT reviewType, COUNT(*) AS cnt FROM tblReview WHERE tvShowID > 0 GROUP BY reviewType');
        [statsList.append({
            'tvShows': {
                'reviewType': str(row[0]),
                'count': row[1]
            }
        }) for row in cur]

    return json.dumps(statsList)


if __name__ == '__main__':
    app.run(debug=True)