from app import db
from models import Lineup
import pandas as pd

#create the database
db.session.query(Lineup).delete()
db.create_all()
x = pd.read_csv(str(pd.to_datetime('today'))[:10]+'preds.csv')


# instert
for i in xrange(len(x)):
    db.session.add(Lineup(x.loc[i]['PLAYER'],x.loc[i]['0'].round(2),x.loc[i]['DK Sal']))


# commit
db.session.commit()