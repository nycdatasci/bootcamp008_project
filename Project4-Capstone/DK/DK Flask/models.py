# from app import db
#
# class Predictions(db.Model):
#
#     __tablename__ = "players"
#
#     id = db.Column(db.Integer, primary_key=True)
#     Player = db.Column(db.String, nullable=False)
#     Points = db.Column(db.Float, nullable=False)
#     Salary = db.Column(db.Integer, nullable=False)
#
#     def __init__(self, Player, Points, Salary):
#         self.Player = Player
#         self.Points = Points
#         self.Salary = Salary
#
#     def __repr__(self):
#         return '{} {} {}'.format(self.Player, self.Points, self.Salary)
