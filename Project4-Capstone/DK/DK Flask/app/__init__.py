from flask import Flask, render_template, request, redirect, url_for, flash
from content_management import Content
from flask_sqlalchemy import SQLAlchemy
import pandas as pd
import bestteams, optimizer
from flask import jsonify

TOPIC_DICT = Content()

app = Flask(__name__)
app.secret_key = 'some_secret'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///predictions.db'

db = SQLAlchemy(app)
class Predictions(db.Model):

    __tablename__ = "players"

    id = db.Column(db.Integer, primary_key=True)
    Player = db.Column(db.String, nullable=False)
    Points = db.Column(db.Float, nullable=False)
    Salary = db.Column(db.Integer, nullable=False)

    def __init__(self, Player, Points, Salary):
        self.Player = Player
        self.Points = Points
        self.Salary = Salary

    def __repr__(self):
        return '{} {} {}'.format(self.Player, self.Points, self.Salary)

@app.route('/')
def homepage():
    return render_template("main.html")


@app.route('/login/', methods=["GET", "POST"])
def login_page():
    error = ''
    try:

        if request.method == "POST":

            attempted_username = request.form['username']
            attempted_password = request.form['password']

            # flash(attempted_username)
            # flash(attempted_password)

            if attempted_username == "admin" and attempted_password == "password":
                return redirect(url_for('dashboard'))

            else:
                error = "Invalid credentials. Try Again."

        return render_template("login.html", error=error)

    except Exception as e:
        # flash(e)
        return render_template("login.html", error=error)


@app.route('/register/', methods=["GET", "POST"])
def register_page():
    try:
        c, conn = connection()
        return ("okay")
    except Exception as e:
        return (str(e))



@app.route('/background_process', methods=['GET', "POST"])
def background_process():
    z = []
    # if request.method == "POST":

    print '*' * 50
    x = dict(request.form)
    for i in x.keys():
        if x[i] == [u'true']:
            z.append(i)
    print z
    # try:
    return jsonify(bestteams.showteams(z))
    # except Exception as e:
    #     return str(e)


@app.route('/dashboard/')
def dashboard():
    # flash("test")

    # create the database
    db.session.query(Predictions).delete()
    db.create_all()
    # x = pd.read_csv(str(pd.to_datetime('today'))[:10]+'preds.csv')
    x = pd.read_csv('2017-03-26preds.csv')
    x= x.sort_values('DK Sal',ascending=False)

    # instert
    for i in xrange(len(x)):
        db.session.add(Predictions(x.loc[i]['PLAYER'], x.loc[i]['0'], x.loc[i]['DK Sal']))

    # commit
    db.session.commit()

    predictions = db.session.query(Predictions).all()
    # lineup = bestteams.showteams()
    gametimes = optimizer.gametime
    print "=" * 50
    return render_template("dashboard.html", TOPIC_DICT=TOPIC_DICT, predictions=predictions, gametimes=gametimes)



@app.errorhandler(404)
def page_not_found(e):
    return render_template("404.html")

if __name__ == "__main__":
    app.run(debug=True)
