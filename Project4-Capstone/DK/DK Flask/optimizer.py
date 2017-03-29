import random
from operator import add
import pandas as pd

class Player():
    def __init__(self, pg, sg, sf, pf, c, name, salary, points):
        self.self = self
        self.pg = pg
        self.sg = sg
        self.sf = sf
        self.pf = pf
        self.c = c
        self.name = name
        self.salary = salary
        self.points = points

    def __iter__(self):
        return iter(self.list)

    def __str__(self):
        return "{} {} {} {} {} {} {} {}".format(self.name, self.pg, self.sg, self.sf, self.pf, self.c, self.salary,
                                                self.points)

import roto1
gametime = sorted(roto1.today['GTime(ET)'].unique())
