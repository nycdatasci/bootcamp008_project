import pandas as pd
import numpy as np
from sklearn.preprocessing import LabelEncoder
from imblearn.over_sampling import SMOTE
from collections import Counter

class Preprocess_Data:
    def __init__(self, df):
        self.df = df
    
    def Norm(self):
        '''Subset and take the name of the columns'''
        # remove extraneous columns
        #self.df = self.df[['Acceleration x','Acceleration y','Acceleration z',\
        #                   'Magnetometer x','Magnetometer y','Magnetometer z',\
        #                   'classification']]
        self.df = self.df[['Acceleration x','Acceleration y','Acceleration z',\
                           'Magnetometer x','Magnetometer y','Magnetometer z']]
        
        self.df.iloc[:,0:6].astype(float)
        # Get the norm of acceleration and Magnetometer
        self.df['Acceleration'] =  np.sqrt(self.df['Acceleration x']**2 + self.df['Acceleration y']**2 +\
                                           self.df['Acceleration z']**2)
        self.df['Magnetometer'] =  np.sqrt(self.df['Magnetometer x']**2 + self.df['Magnetometer y']**2 +\
                                           self.df['Magnetometer z']**2)
        # Drop the old columns
        #self.df = self.df[['Acceleration', 'Magnetometer', 'classification']]
        self.df = self.df[['Acceleration', 'Magnetometer']]
        self.df = self.df.dropna()
        return(self.df)
    
    def Feature_additions(self):
        '''Add the windows and the Mean, Std, and max for each window'''
        # set window 1
        window1 = 2
        window2 = 5
        window3 = 7
        window4 = 10
        window5 = 15
        # Window 1
        # Rolling Means
        self.df['RollingMeanAcceleration2'] = self.df['Acceleration'].rolling(window=window1,center=False).mean()
        self.df['RollingMeanMagnetometer2'] = self.df['Magnetometer'].rolling(window=window1,center=False).mean()
        # Rolling st dev
        self.df['RollingSDAcceleration2'] = self.df['Acceleration'].rolling(window=window1,center=False).std()
        self.df['RollingSDMagnetometer2'] = self.df['Magnetometer'].rolling(window=window1,center=False).std()
        # Rolling Max
        self.df['RollingMeanAcceleration2'] = self.df['Acceleration'].rolling(window=window1,center=False).max()
        self.df['RollingMaxMagnetometer2']  = self.df['Magnetometer'].rolling(window=window1,center=False).max()
        # Window 2
        # Rolling Means
        self.df['RollingMeanAcceleration5'] = self.df['Acceleration'].rolling(window=window1,center=False).mean()
        self.df['RollingMeanMagnetometer5'] = self.df['Magnetometer'].rolling(window=window1,center=False).mean()
        # Rolling st dev
        self.df['RollingSDAcceleration5'] = self.df['Acceleration'].rolling(window=window1,center=False).std()
        self.df['RollingSDMagnetometer5'] = self.df['Magnetometer'].rolling(window=window1,center=False).std()
        # Rolling Max
        self.df['RollingMeanAcceleration5'] = self.df['Acceleration'].rolling(window=window1,center=False).max()
        self.df['RollingMaxMagnetometer5'] = self.df['Magnetometer'].rolling(window=window1,center=False).max()
        # Window 3
        # Rolling Means
        self.df['RollingMeanAcceleration7'] = self.df['Acceleration'].rolling(window=window3,center=False).mean()
        self.df['RollingMeanMagnetometer7'] = self.df['Magnetometer'].rolling(window=window3,center=False).mean()
        # Rolling st dev
        self.df['RollingSDAcceleration7'] = self.df['Acceleration'].rolling(window=window3,center=False).std()
        self.df['RollingSDMagnetometer7'] = self.df['Magnetometer'].rolling(window=window3,center=False).std()
        # Rolling Max
        self.df['RollingMeanAcceleration7'] = self.df['Acceleration'].rolling(window=window3,center=False).max()
        self.df['RollingMaxMagnetometer7'] = self.df['Magnetometer'].rolling(window=window3,center=False).max()
        # set window 4
        # Rolling Means
        self.df['RollingMeanAcceleration10'] = self.df['Acceleration'].rolling(window=window4,center=False).mean()
        self.df['RollingMeanMagnetometer10'] = self.df['Magnetometer'].rolling(window=window4,center=False).mean()
        # Rolling st dev
        self.df['RollingSDAcceleration10'] = self.df['Acceleration'].rolling(window=window4,center=False).std()
        self.df['RollingSDMagnetometer10'] = self.df['Magnetometer'].rolling(window=window4,center=False).std()
        # Rolling Max
        self.df['RollingMeanAcceleration10'] = self.df['Acceleration'].rolling(window=window4,center=False).max()
        self.df['RollingMaxMagnetometer10'] = self.df['Magnetometer'].rolling(window=window4,center=False).max()
        # set window 5
        # Rolling Means
        self.df['RollingMeanAcceleration15'] = self.df['Acceleration'].rolling(window=window5,center=False).mean()
        self.df['RollingMeanMagnetometer15'] = self.df['Magnetometer'].rolling(window=window5,center=False).mean()
        # Rolling st dev
        self.df['RollingSDAcceleration15'] = self.df['Acceleration'].rolling(window=window5,center=False).std()
        self.df['RollingSDMagnetometer15'] = self.df['Magnetometer'].rolling(window=window5,center=False).std()
        # Rolling Max
        self.df['RollingMeanAcceleration15'] = self.df['Acceleration'].rolling(window=window5,center=False).max()
        self.df['RollingMaxMagnetometer15'] = self.df['Magnetometer'].rolling(window=window5,center=False).max()
        self.df = self.df.dropna()

        #self.df = self.df.iloc[:,range(0,2) + range(3,28) + [2]]
        return(self.df)

    def load_data_test(self):
        return(self.df.values[:,0:26])


