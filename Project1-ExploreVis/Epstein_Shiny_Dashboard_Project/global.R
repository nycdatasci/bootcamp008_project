
attach('./data/combined_movies.rda')

movie_dataset <- combined_movies


#remove row numbers
rownames(combined_movies) <- NULL
