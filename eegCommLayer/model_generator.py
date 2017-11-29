from sklearn.externals import joblib
import numpy as np
import scipy as sp
import pandas as pd
import scipy.io
from sklearn.preprocessing import Imputer
from sklearn.cluster import KMeans
from sklearn.neighbors import KNeighborsClassifier
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import train_test_split 

filepathOne = "trainingOne.csv" 
#read the csv into a dataframe
df_one = pd.read_csv(filepathOne, header = None)
df_one[len(df_one.columns)] = 0

filepathTwo = "trainingTwo.csv" 
#read the csv into a dataframe
df_two = pd.read_csv(filepathTwo, header = None)
df_two[len(df_two.columns)] = 1

dataFrames = [df_one, df_two]

df = pd.concat(dataFrames)

df.dropna()
print(df)

knnClassifier = KNeighborsClassifier(n_neighbors=4)
knnClassifier.fit(df.iloc[:, 2:6], df.iloc[:, 7])

filename = 'KNN_model.sav'
joblib.dump(knnClassifier, filename)




