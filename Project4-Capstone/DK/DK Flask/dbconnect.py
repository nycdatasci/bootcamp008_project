import MySQLdb


def connection():
    conn = MySQLdb.connect(host="localhost",
                           user="root",
                           passwd="cookies!",
                           db="pythonprogramming")
    c = conn.cursor()

    return c, conn
