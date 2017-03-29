import logging
import sqlite3 as lite
import datetime


class WriteItemPipelineGamesList(object):
    def __init__(self):
        # Possible we should be doing this in spider_open instead, but okay
        self.con = lite.connect(r'D:\capstone-v2.db')
        self.cur = self.con.cursor()
        logging.basicConfig(filename='spider.log', level=logging.DEBUG,
                            format='%(asctime)s - %(levelname)s - %(message)s');

    # Take the item and put it in database - do not allow duplicates
    def process_item(self, item, spider):
        self.cur.execute("SELECT * FROM tblGame WHERE link='" + item['link'] + "'")
        result = self.cur.fetchone()
        if result:
           logging.debug("Item already in database: %s" % item)
        else:
            self.cur.execute(
                "INSERT INTO tblGame (name, link) VALUES (?, ?)", (item['name'], item['link'])
            )
            self.con.commit()

            logging.debug("INSERT INTO tblGame (name, link) VALUES (?, ?)", (item['name'], item['link']))

            logging.debug("Item stored: " + item['name'] + ', ' + item['link'])
        return item

    def handle_error(self, e):
        logging.debug(e)


class WriteItemPipelineMoviesList(object):
    def __init__(self):
        # Possible we should be doing this in spider_open instead, but okay
        self.con = lite.connect(r'D:\capstone.db')
        self.cur = self.con.cursor()
        logging.basicConfig(filename='spider.log', level=logging.DEBUG,
                            format='%(asctime)s - %(levelname)s - %(message)s');

    # Take the item and put it in database - do not allow duplicates
    def process_item(self, item, spider):
        self.cur.execute("SELECT * FROM tblMovie WHERE link='" + item['link'] + "'")
        result = self.cur.fetchone()
        if result:
           logging.debug("Item already in database: %s" % item)
        else:
            dtInsert = datetime.datetime.strptime(item['date'], '%B %d, %Y')
            self.cur.execute(
                "INSERT INTO tblMovie (name, date, link) VALUES (?, ?, ?)", (item['name'], dtInsert, item['link'])
            )
            self.con.commit()

            logging.debug("INSERT INTO tblMovie (name, link) VALUES (?, ?)", (item['name'], item['link']))

            logging.debug("Item stored: " + item['name'] + ', ' + item['link'])
        return item

    def handle_error(self, e):
        logging.debug(e)


class WriteItemPipelineTVShowsList(object):
    def __init__(self):
        # Possible we should be doing this in spider_open instead, but okay
        self.con = lite.connect(r'D:\capstone.db')
        self.cur = self.con.cursor()
        logging.basicConfig(filename='spider.log', level=logging.DEBUG,
                            format='%(asctime)s - %(levelname)s - %(message)s');

    # Take the item and put it in database - do not allow duplicates
    def process_item(self, item, spider):
        self.cur.execute("SELECT * FROM tblTVShow WHERE link='" + item['link'] + "'")
        result = self.cur.fetchone()
        if result:
           logging.debug("Item already in database: %s" % item)
        else:
            dtInsert = datetime.datetime.strptime(item['date'], '%b %d, %Y')
            self.cur.execute(
                "INSERT INTO tblTVShow (name, date, link) VALUES (?, ?, ?)", (item['name'], dtInsert, item['link'])
            )
            self.con.commit()

            logging.debug("INSERT INTO tblTVShow (name, link) VALUES (?, ?)", (item['name'], item['link']))

            logging.debug("Item stored: " + item['name'] + ', ' + item['link'])
        return item

    def handle_error(self, e):
        logging.debug(e)


class WriteItemPipelineGameDetails(object):
    def __init__(self):
        # Possible we should be doing this in spider_open instead, but okay
        self.con = lite.connect(r'D:\capstone-v2.db')
        self.cur = self.con.cursor()
        logging.basicConfig(filename='spider.log', level=logging.DEBUG,
                            format='%(asctime)s - %(levelname)s - %(message)s');

    # Take the item and put it in database - do not allow duplicates
    def process_item(self, item, spider):
        self.cur.execute("SELECT * FROM tblGame WHERE link='" + item['link'] + "' AND developer!=''")
        result = self.cur.fetchone()
        if result:
           logging.debug("Item already in database: %s" % item)
        else:
            dtInsert = datetime.datetime.strptime(item['rlsDate'], '%b %d, %Y')
            sqlString = \
                "UPDATE " \
                    "tblGame " \
                "SET " \
                    "image = '" + item['image'] + "', " \
                    "developer = '" + item['developer'].replace('"', '').replace("'", "") + "', " \
                    "genre = '" + item['genre'] + "', " \
                    "rating = '" + item['rating'] + "', " \
                    "rlsDate = '" + str(dtInsert) + "', " \
                    "summary = '" + item['summary'].replace('"', '').replace("'", "") + "' " \
                "WHERE " \
                    "link = '" + item['link'].replace('http://www.metacritic.com', '') + "'"

            self.cur.execute(sqlString)
            self.con.commit()

            logging.debug("Item updated: " + item['link'])
        return item

    def handle_error(self, e):
        logging.debug(e)


class WriteItemPipelineReview(object):
    def __init__(self):
        # Possible we should be doing this in spider_open instead, but okay
        self.con = lite.connect(r'D:\capstone-v2.db')
        self.cur = self.con.cursor()
        logging.basicConfig(filename='spider.log', level=logging.DEBUG,
                            format='%(asctime)s - %(levelname)s - %(message)s');

    # Take the item and put it in database - do not allow duplicates
    def process_item(self, item, spider):
        if item['gameID'] > 0:
            idCol = 'gameID'
            id = item['gameID']
        elif item['movieID'] > 0:
            idCol = 'movieID'
            id = item['movieID']
        elif item['tvShowID'] > 0:
            idCol = 'tvShowID'
            id = item['tvShowID']

        self.cur.execute(
            "SELECT * FROM tblReview WHERE " + idCol + "=" + str(id) + " AND " \
            "(publication='" + item['publication'] + "' OR author='" + item['author'] + "')"
        )
        result = self.cur.fetchone()
        result = False
        if result:
            logging.debug("Item already in database: %s" % item)
        else:
            if item['date'] != '':
                dtInsert = datetime.datetime.strptime(item['date'], '%b %d, %Y')
            else:
                dtInsert = ''

            sqlString = \
                "INSERT INTO " \
                    "tblReview" \
                    "(" + idCol + ", author, publication, text, score, date, thumbsUp, thumbsDown, reviewType) "\
                "VALUES " \
                    "(" + str(id) + ", '" + item['author'] + "', '" + item['publication'] + "', '" + item['text'].replace('"', '').replace("'", "") + "', " + \
                    str(item['score'] if item['score'] != '' else 0) + ", '" + str(dtInsert) + "', " + str(item['thumbsUp']) + ", " + str(item['thumbsDown']) + ", '" + item['reviewType'] + "')"

            self.cur.execute(sqlString)
            self.con.commit()

            logging.debug("Item inserted: " + item['link'])
        return item

    def handle_error(self, e):
        logging.debug(e)


class WriteItemPipelineMovieDetails(object):
    def __init__(self):
        # Possible we should be doing this in spider_open instead, but okay
        self.con = lite.connect(r'D:\capstone.db')
        self.cur = self.con.cursor()
        logging.basicConfig(filename='spider.log', level=logging.DEBUG,
                            format='%(asctime)s - %(levelname)s - %(message)s');

    # Take the item and put it in database - do not allow duplicates
    def process_item(self, item, spider):
        self.cur.execute("SELECT * FROM tblMovie WHERE link='" + item['link'] + "' AND genre IS NOT NULL")
        result = self.cur.fetchone()
        if result:
           logging.debug("Item already in database: %s" % item)
        else:
            dtInsert = datetime.datetime.strptime(item['rlsDate'], '%B %d, %Y')
            sqlString = \
                "UPDATE " \
                    "tblMovie " \
                "SET " \
                    "image = '" + item['image'] + "', " \
                    "director = '" + item['director'] + "', " \
                    "genre = '" + item['genre'] + "', " \
                    "rating = '" + item['rating'] + "', " \
                    "rlsDate = '" + str(dtInsert) + "', " \
                    "runTime = " + item['runtime'].replace('min', '').replace('h', '') + ", " \
                    "summary = '" + item['summary'].replace('"', '').replace("'", '') + "' " \
                "WHERE " \
                    "link = '" + item['link'].replace('http://www.metacritic.com', '') + "'"

            self.cur.execute(sqlString)
            self.con.commit()

            logging.debug("Item updated: " + item['link'])
        return item

    def handle_error(self, e):
        logging.debug(e)


class WriteItemPipelineTVShowDetails(object):
    def __init__(self):
        # Possible we should be doing this in spider_open instead, but okay
        self.con = lite.connect(r'D:\capstone.db')
        self.cur = self.con.cursor()
        logging.basicConfig(filename='spider.log', level=logging.DEBUG,
                            format='%(asctime)s - %(levelname)s - %(message)s');

    # Take the item and put it in database - do not allow duplicates
    def process_item(self, item, spider):
        self.cur.execute("SELECT * FROM tblTVShow WHERE link LIKE '" + item['link'].replace('http://www.metacritic.com', '') + '/%' + "' AND genre IS NOT NULL")
        result = self.cur.fetchone()
        if result:
           logging.debug("Item already in database: %s" % item)
        else:
            dtInsert = datetime.datetime.strptime(item['rlsDate'], '%b %d, %Y')
            sqlString = \
                "UPDATE " \
                    "tblTVShow " \
                "SET " \
                    "image = '" + item['image'] + "', " \
                    "creator = '" + ', '.join(item['creator']) + "', " \
                    "genre = '" + item['genre'] + "', " \
                    "rlsDate = '" + str(dtInsert) + "', " \
                    "runTime = " + item['runtime'] + ", " \
                    "summary = '" + item['summary'].replace('"', '').replace("'", "") + "' " \
                "WHERE " \
                    "link LIKE '" + item['link'].replace('http://www.metacritic.com', '') + '/%' + "'"

            self.cur.execute(sqlString)
            self.con.commit()

            logging.debug("Item updated: " + item['link'])
        return item

    def handle_error(self, e):
        logging.debug(e)


# class WriteItemPipelineTVShowReview(object):
#     def __init__(self):
#         # Possible we should be doing this in spider_open instead, but okay
#         self.con = lite.connect(r'D:\capstone-tvshows.db')
#         self.cur = self.con.cursor()
#         logging.basicConfig(filename='spider.log', level=logging.DEBUG,
#                             format='%(asctime)s - %(levelname)s - %(message)s');
#
#     # Take the item and put it in database - do not allow duplicates
#     def process_item(self, item, spider):
#         if item['gameID'] > 0:
#             idCol = 'gameID'
#             id = item['gameID']
#         elif item['movieID'] > 0:
#             idCol = 'movieID'
#             id = item['movieID']
#         elif item['tvShowID'] > 0:
#             idCol = 'tvShowID'
#             id = item['tvShowID']
#
#         self.cur.execute(
#             "SELECT * FROM tblReview WHERE " + idCol + "=" + str(id) + " AND " \
#             "(publication='" + item['publication'] + "' OR author='" + item['author'] + "')"
#         )
#         result = self.cur.fetchone()
#         result = False
#         if result:
#             logging.debug("Item already in database: %s" % item)
#         else:
#             if item['date'] != '':
#                 dtInsert = datetime.datetime.strptime(item['date'], '%b %d, %Y')
#             else:
#                 dtInsert = ''
#
#             sqlString = \
#                 "INSERT INTO " \
#                     "tblReview" \
#                     "(" + idCol + ", author, publication, text, score, date, thumbsUp, thumbsDown, reviewType) "\
#                 "VALUES " \
#                     "(" + str(id) + ", '" + item['author'] + "', '" + item['publication'] + "', '" + item['text'].replace('"', '').replace("'", "") + "', " + \
#                     str(item['score'] if item['score'] != '' else 0) + ", '" + str(dtInsert) + "', " + str(item['thumbsUp']) + ", " + str(item['thumbsDown']) + ", '" + item['reviewType'] + "')"
#
#             self.cur.execute(sqlString)
#             self.con.commit()
#
#             logging.debug("Item inserted: " + item['link'])
#         return item
#
#     def handle_error(self, e):
#         logging.debug(e)