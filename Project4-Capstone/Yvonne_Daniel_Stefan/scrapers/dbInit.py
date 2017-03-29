import yaml
import sqlite3 as lite
import mysql
from mysql.connector import errorcode

dbType = 'MySQL'

if dbType == 'SQlite':
    con = lite.connect(r'D:\capstone-v2-inte.db')

    tblGame = \
        "CREATE TABLE IF NOT EXISTS " \
            "tblGame (" \
                "name TEXT, " \
                "link TEXT, " \
                "image TEXT, " \
                "developer TEXT, " \
                "genre TEXT, " \
                "rating TEXT, " \
                "rlsDate TEXT, " \
                "summary TEXT, " \
                "system TEXT, " \
                "uniqueID int" \
            ")"
    tblMovie = \
        "CREATE TABLE IF NOT EXISTS " \
            "tblMovie (" \
                "name TEXT, " \
                "date TEXT, " \
                "link TEXT, " \
                "image TEXT, " \
                "genre TEXT, " \
                "rlsDate TEXT, " \
                "runtime INT, " \
                "director TEXT, " \
                "summary TEXT, " \
                "rating TEXT, " \
                "uniqueID int" \
            ")"
    tblTVShow = \
        "CREATE TABLE IF NOT EXISTS " \
            "tblTVShow (" \
                "name TEXT, " \
                "date TEXT, " \
                "link TEXT, " \
                "image TEXT, " \
                "genre TEXT, " \
                "rlsDate TEXT, " \
                "runtime INT, " \
                "creator TEXT, " \
                "summary TEXT, " \
                "uniqueID int" \
            ")"
    tblReview = \
        "CREATE TABLE IF NOT EXISTS " \
            "tblReview (" \
                "gameID INT, " \
                "movieID INT, " \
                "tvShowID INT, " \
                "author TEXT, " \
                "publication TEXT, " \
                "text TEXT, " \
                "score INT, " \
                "date TEXT, " \
                "thumbsUp INT, " \
                "thumbsDown INT, " \
                "reviewType TEXT" \
        ")"

    with con:
        cur = con.cursor()
        cur.execute(tblGame)
        cur.execute(tblMovie)
        cur.execute(tblTVShow)
        cur.execute(tblReview)

elif dbType == 'MySQL':
    cfg = yaml.safe_load(open('_inc.yaml'))
    try:
        cnx = mysql.connector.connect(user=cfg['mysql']['user'], password=cfg['mysql']['pwd'],
                                      host=cfg['mysql']['server'], database=cfg['mysql']['db'])
        cur = cnx.cursor()
    except mysql.connector.Error as e:
        if e.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            print("Something is wrong with your user name or password")
        elif e.errno == errorcode.ER_BAD_DB_ERROR:
            print("Database does not exist")
        else:
            print(e)

    tblGame = \
        "CREATE TABLE IF NOT EXISTS " \
            "tblGame (" \
                "gameID INT NOT NULL, " \
                "name VARCHAR(100), " \
                "link VARCHAR(120), " \
                "image VARCHAR(100), " \
                "developer VARCHAR(80), " \
                "genre VARCHAR(35), " \
                "rating VARCHAR(10), " \
                "rlsDate VARCHAR(20), " \
                "summary TEXT, " \
                "system VARCHAR(20), " \
                "PRIMARY KEY (gameID) " \
            ")"
    tblMovie = \
        "CREATE TABLE IF NOT EXISTS " \
            "tblMovie (" \
                "movieID INT NOT NULL, " \
                "name VARCHAR(75), " \
                "date TIMESTAMP, " \
                "link VARCHAR(120), " \
                "image VARCHAR(150), " \
                "genre VARCHAR(50), " \
                "rlsDate TIMESTAMP, " \
                "runtime INT, " \
                "director VARCHAR(50), " \
                "summary TEXT, " \
                "rating VARCHAR(10), " \
                "PRIMARY KEY (movieID) " \
            ")"
    tblTVShow = \
        "CREATE TABLE IF NOT EXISTS " \
            "tblTVShow (" \
                "tvShowID INT NOT NULL, " \
                "name VARCHAR(75), " \
                "date TIMESTAMP, " \
                "link VARCHAR(120), " \
                "image VARCHAR(150), " \
                "genre VARCHAR(50), " \
                "rlsDate TIMESTAMP, " \
                "runtime INT, " \
                "creator VARCHAR(50), " \
                "summary TEXT, " \
                "PRIMARY KEY (tvShowID) " \
            ")"
    tblReview = \
       "CREATE TABLE IF NOT EXISTS " \
            "tblReview (" \
                "gameID INT, " \
                "movieID INT, " \
                "tvShowID INT, " \
                "author VARCHAR(100), " \
                "publication  VARCHAR(100), " \
                "text TEXT, " \
                "score INT, " \
                "date VARCHAR(20), " \
                "thumbsUp INT, " \
                "thumbsDown INT, " \
                "reviewType CHAR(1)" \
        ")"

    cur.execute(tblGame)
    cur.execute(tblMovie)
    cur.execute(tblTVShow)
    cur.execute(tblReview)

    cnx.close()