"""
Process train/test data. See process_data function at bottom of file.
"""
import os

import numpy as np
import pandas as pd
from nltk.tokenize import word_tokenize
from nltk.probability import FreqDist
from textblob import TextBlob

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

distinct_features = ["By Owner",
                     "Exclusive",
                     "Sublet / Lease-Break",
                     "No Fee",
                     "Reduced Fee",
                     "Short Term Allowed",
                     "Furnished",
                     "Laundry In Unit",
                     "Private Outdoor Space",
                     "Parking Space",
                     "Cats Allowed",
                     "Dogs Allowed",
                     "Doorman",
                     "Elevator",
                     "Fitness Center",
                     "Laundry In Building",
                     "Common Outdoor Space",
                     "Storage Facility"]

DUMMY_FEATURES = None


def _dummy_features(data):
    global DUMMY_FEATURES

    # load cached features if present
    if DUMMY_FEATURES is not None:
        return DUMMY_FEATURES.copy()

    feat = data.features.apply(
        lambda x: pd.Series(
            map(lambda z: 1 if (z in x) else 0, distinct_features) +
            [len(np.setdiff1d(x, distinct_features))]))
    feat.columns = distinct_features + ["unique_count"]

    # cache dummy_features
    DUMMY_FEATURES = feat.copy()

    return feat


def add_dummy_features(data):
    print "Adding dummy features..."

    feat = _dummy_features(data)

    # currently include all features
    data = data.join(feat)

    return data


def add_feature_counts(data):
    print "Add apartment feature counts"

    feat = _dummy_features(data)

    # Use number of distincts and number of uniques instead
    dist_sum = feat.drop('unique_count', axis=1).apply(sum, axis=1).rename(
        "dist_count")

    dists = [dist_sum]
    if 'unique_count' not in data.columns:
        dists += [feat['unique_count']]

    data = data.join(pd.concat(dists, axis=1), how="right")

    return data


def add_building_id_count(data):
    print ("Adding building count...")
    build_counts = pd.DataFrame(data.building_id.value_counts())
    build_counts["building_counts"] = build_counts["building_id"]
    build_counts["building_id"] = build_counts.index
    build_counts["building_count_log"] = np.log2(
        build_counts["building_counts"])

    return pd.merge(data, build_counts, on="building_id")


def add_manager_id_count(data):
    print ("Adding manager count...")
    man_counts = pd.DataFrame(data.manager_id.value_counts())
    man_counts["manager count"] = man_counts["manager_id"]
    man_counts["manager_id"] = man_counts.index
    man_counts["manager_count_log"] = np.log10(man_counts["manager count"])

    return pd.merge(data, man_counts, on="manager_id")


def add_description_text_analysis(data):
    print "Adding description text analysis..."

    d = data.description

    d_words = d.apply(word_tokenize)
    d_words_count = pd.Series(d_words.apply(len))
    d_words_count.reset_index(d.index)
    d_words_count.rename("word_count", inplace=True)

    content = " ".join(d)
    distr = FreqDist(word_tokenize(content))
    distr_len = float(len(distr.values()))
    word_freqs = d_words.apply(lambda x: [distr[z] / distr_len for z in x])

    data['description_diversity'] = word_freqs.apply(
        np.mean)  # this introduces nans

    return data.join(d_words_count)


def add_description_sentiment_analysis(data):
    print "Adding description sentiment analysis..."

    # currently just use textblob
    return data.join(
        data.description.apply(lambda x: TextBlob(x).sentiment.polarity).rename(
            "description_sentiment"))


def add_image_data(data):
    print "Adding image data..."

    images = pd.read_csv(os.path.join(PROJECT_ROOT, 'data', 'image_stats-fixed.csv'),
                         index_col=0)

    return data.merge(images, how='left', on='listing_id')


def process_data(data):
    """
    Read prefile as json, process it, and return the processed data.
    """
    print("Pre-processing data...")

    data = add_dummy_features(data)
    data = add_feature_counts(data)
    data = add_manager_id_count(data)
    data = add_building_id_count(data)
    data = add_description_text_analysis(data)
    data = add_description_sentiment_analysis(data)
    data = add_image_data(data)

    print("Finished processing data.\n")

    return data
