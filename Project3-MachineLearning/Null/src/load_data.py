"""
File for loading data.
"""

import os

import pandas as pd

from preprocess import process_data


PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def save_data(filename):
    """
    Save kaggle json data file called 'filename' to 'processed_<filename>'
    after pre-processing it.
    """
    print "Creating processed datafile for '{}'".format(filename)

    data_path = os.path.join(PROJECT_ROOT, 'data', filename)
    proc_path = os.path.join(PROJECT_ROOT, 'data',
                             "processed_" + filename)
    try:
        pre = os.path.basename(data_path)
        post = os.path.basename(proc_path)

        print "\nOpening '{}'...".format(pre)
        with open(data_path, 'r') as datafile:
            data = pd.read_json(datafile)
        data = process_data(data)

        print "Writing processed data to '{}'...".format(post)

        with open(proc_path, "w") as processed_file:
            data.to_json(processed_file)

        print "Finished processing '{}' into '{}'.".format(pre, post)
    except IOError as ioe:
        print "Failed to process {} to file.".format(data_path)
        print ioe


def load_processed_data(dataname):
    """
    Load the processed data for 'dataname'. 'dataname' is either 'train.json'
    or 'test.json'.
    """
    data_path = os.path.join(PROJECT_ROOT, 'data',
                             "processed_" + dataname)
    with open(data_path) as datafile:
        data = pd.read_json(datafile)

    return data
