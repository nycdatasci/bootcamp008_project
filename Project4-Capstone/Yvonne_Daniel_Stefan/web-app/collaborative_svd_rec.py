# load pickle file of preloaded pivot table
from scipy.sparse.linalg import svds
import pickle

# import helper<s function
import collaborative_helpers as hp


#to load a pickle file
with open('user_item_matrix.pickle', 'rb') as f:
    user_item_matrix = pickle.load(f) 

 # get the index from fake user
last = user_item_matrix.shape[0]

d ={1:10, 2:10}
# add score from user who lands in the page
user_item_matrix = hp.add_score(d,user_item_matrix)

#get predictions on dataframe
preds_df = hp.predict_svd(user_item_matrix)

# collaborative recommendations
suggestions = hp.collaborative_recommend(last, preds_df, user_item_matrix,5)    

print suggestions[0]

