import numpy as np
import pandas as pd
import pickle
import copy

# Calculate cosine similarity between two vecotrs 
def cossim(v1, v2): 
    return np.dot(v1, v2) / np.sqrt(np.dot(v1, v1)) / np.sqrt(np.dot(v2, v2)) 

# return top_n values from a list
def top_n_index(l,n):
    return sorted(range(len(l)), key=lambda i: l[i])[-(n+1):-1] #-1 to take off the own product from the returned index list

# return a list of unique_id for a given category list formated as ["games", "movies","tv"]
def category_id_range(category_list):
    # range of ids for each category
    games_range = range(1,20417)
    movies_range = range(20417, 25887)
    tv_range = range(25887, 27865)
    
    category_range = []
    for i in category_list:
        if i=="games":
            category_range = category_range + games_range
        elif i=="movies":
            category_range = category_range + movies_range
        else:
            category_range = category_range + tv_range
    
    return category_range

"""
item_id: user input
top_n: refers to the number of products we want returned 
inputs: pickle file - summary_critics_docvecs
category_list = list of categories from user i.e. ["games", "movies","tv"]

content_recommend returns item_id and cossim of recommendation

"""
def content_recommend(item_id, top_n, inputs, category_list):
    input_vec = inputs[item_id - 1]
    
    #compute similarity array
    sim_array = map(lambda v: cossim(input_vec, v), inputs)
    
    # recommendation's index (set to 500 to get enough to filter out later)
    recommendation_index = top_n_index(sim_array, 500)
    
    # recommendation's unique id
    recommendation_unique_id = [i+1 for i in recommendation_index]
    
    # recommendation's cossim values
    recommendation_cossim = [sim_array[i] for i in recommendation_index]
    
    top_products = zip(recommendation_unique_id, recommendation_cossim)
    
    # get the range of unique id for a given category prefered by user
    category_range = category_id_range(category_list)
    
    result = [i for i in top_products if i[0] in category_range]
    
    return result[-top_n:] 