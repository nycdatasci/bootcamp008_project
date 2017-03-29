from scipy.sparse.linalg import svds
import pandas as pd
import numpy as np
"""
add_score: adds a dictionary of values rated obtained from user to the user_matrix
d should be formated as: type: dictionary, format: {'uniqueID': 'score'}
"""
def add_score(d, user_matrix):
    last = len(user_matrix)
    user_matrix.loc[len(user_matrix),d.keys()[0]] = d.values()[0]
    if len(d)>1:
        for i in range(1, len(d)):
            user_matrix.loc[last,d.keys()[i]] = d.values()[i]
    return user_matrix.fillna(0)


"""
predict_svd: takes a user_item_matrix and returns a matrix of same shape with all ratings predictions
"""
def predict_svd(user_item_matrix):
    # change type and normalize ratings for SVD
    R = user_item_matrix.as_matrix()
    user_ratings_mean = np.mean(R, axis = 1)
    R_demeaned = R - user_ratings_mean.reshape(-1, 1)
    
    # svd
    U, sigma, Vt = svds(R_demeaned, k = 50)
    sigma = np.diag(sigma)
    
    all_user_predicted_ratings = np.dot(np.dot(U, sigma), Vt) + user_ratings_mean.reshape(-1, 1)
    
    preds_df = pd.DataFrame(all_user_predicted_ratings, columns = user_item_matrix.columns)
    
    return preds_df

"""
collaborative_recommend returns a list with of uniqueIDs of recommended items
"""
def collaborative_recommend(user_row_number, preds_df, user_item_df, top_n=5):
    sorted_user_predictions = preds_df.loc[user_row_number,user_item_df.iloc[user_row_number,:]==0].sort_values(ascending=False)
    recommendation = sorted_user_predictions.sort_values(ascending=False).iloc[:top_n]
    return recommendation.index
    