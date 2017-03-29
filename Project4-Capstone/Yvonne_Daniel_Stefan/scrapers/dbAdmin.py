import sqlite3 as lite
import re

con = lite.connect(r'D:\capstone-v2.db')
cur = con.cursor()

cmd = ''

if cmd == 'mkGameSys':
    con.execute('ALTER TABLE tblGame ADD COLUMN system TEXT;')
    con.commit()

    rows = con.execute('SELECT ROWID, link FROM tblGame')
    for row in rows:
        sys = re.findall('([a-z0-9\-]+)(?=[/]{1})', row[1])[1]
        con.execute('UPDATE tblGame SET system="' + sys.encode('UTF-8') + '" WHERE ROWID=' + str(row[0]))
        con.commit()

elif cmd == 'mkUniqueID':
    i = 1

    for tbl in ['tblGame', 'tblMovie', 'tblTVShow']:
        con.execute('ALTER TABLE ' + tbl + ' ADD COLUMN uniqueID INT;')
        con.commit()

        rows = con.execute('SELECT ROWID FROM ' + tbl)
        for row in rows:
            con.execute('UPDATE ' + tbl + ' SET uniqueID=' + str(i) + ' WHERE ROWID=' + str(row[0]))
            con.commit()

        ids = {
            'tblGame': 'gameID',
            'tblMovie': 'movieID',
            'tblTVShow': 'tvShowID'
        }

        thisID = ids[tbl]

        con.execute(
            'UPDATE tblReview SET uniqueID = (SELECT uniqueID FROM ' + tbl + ' WHERE ' + thisID + '=tblReview.gameID) '\
            'WHERE EXISTS (SELECT uniqueID FROM ' + tbl + ' WHERE ' + thisID + '=tblReview.gameID) AND ' + thisID + ' > 0;)'
        )
        con.commit()

elif cmd == 'mkAvgRating':
    con.execute('CREATE TABLE tblAvgRating (uniqueID INT, critRat DECIMAL(4,2), userRat DECIMAL(4,2));')
    con.commit()

    strSQL = '' \
             'INSERT INTO ' \
                'tblAvgRating ' \
                 '(uniqueID, ' \
                 'critRat, ' \
                 'userRat) ' \
             'SELECT ' \
                 't1.uniqueID, ' \
                 'critRat, ' \
                 'userRat ' \
             'FROM ' \
                 '(SELECT ' \
                    'uniqueID, ' \
                    'AVG(score) AS critRat ' \
                'FROM ' \
                    'tblReview ' \
                'WHERE ' \
                    'reviewType='c' ' \
                'GROUP BY ' \
                    'uniqueID) AS t1 ' \
             'LEFT JOIN ' \
                '(SELECT ' \
                    'uniqueID, ' \
                    'AVG(score) AS userRat ' \
                'FROM ' \
                    'tblReview ' \
                'WHERE ' \
                    'reviewType='u' ' \
                'GROUP BY ' \
                    'uniqueID) AS t2 ' \
                'ON ' \
                    't1.uniqueID = t2.uniqueID '
    con.execute(strSQL)
    con.commit()