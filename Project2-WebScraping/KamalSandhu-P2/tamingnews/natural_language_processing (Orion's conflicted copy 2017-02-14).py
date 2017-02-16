import json
from google.cloud import language
import textrazor
import re
import random
from os import listdir
import numpy as np

"""
Reads all files written in get_scraped_data and sends them to
Google Natural Language Processing and TextRazor Natural Language
Processing API's.

Writes all the responses in the dir/response folders as individual
json files. Comments on data structures of responses are outlined below.
"""

def wrapper(dir, numArticles):
    # get list of files in the raw folder
    raw_files = listdir(dir + 'raw/')
    print 'Total files in the directory: ', len(raw_files)

    # eleminate the ones that are in the response folder
    seen = listdir(dir + 'response/')
    seen = [r[6:] for r in seen]
    for f in seen:
        if re.search('$son', str(f)) == None:
            f = str(f) + '.json'
    print len(seen), ' files already seen'

    raw_files = [f for f in raw_files if f not in seen]
    print 'Selected: ', len(raw_files), ' files.'
    print '-' * 50,  '\n\n'

    num = 0
    doNext = True
    while doNext:
        file_ = random.choice(raw_files)

        data_file = open(dir + 'raw/' + str(file_), 'r')
        data = json.load(data_file)
        data_file.close()

        aboutTrump = (re.search('.*[Tt]rump.*', data['article']) != None)
        long = (len(data['article']) > 300)
        if aboutTrump and long:

            print 'Sending out request number: ', num, ' for: ' + file_
            data = googleAPI(data)
            print 'Waiting...'
            data = textrazorAPI(data)
            print 'Received response', '\n'

            with open(dir + 'response/' + '14Feb_' + str(file_), 'w') as f:
                json.dump(data, f)
            num += 1

        else:
            print 'Skipped an article. Long: ', long, '. About-Trump: ', aboutTrump

        if num > len(raw_files) or num > numArticles:
            doNext = False

def googleAPI(df):
    text_content = df['article']
    client = language.Client()
    document = client.document_from_text(text_content)
    annotations = document.annotate_text(include_sentiment=True, include_syntax=True,
                                         include_entities=True)

    sentenceList = []
    for sentence in annotations.sentences:
        sentenceList.append(sentence.content)
    df['googleAPIsentences'] = sentenceList

    tokenList = []
    for token in annotations.tokens:
        tokenList.append({token.text_content: token.part_of_speech})
    df['googleAPItokens'] = tokenList

    df['googleAPIsentiment'] = [annotations.sentiment.score, annotations.sentiment.magnitude]

    entityList = []
    for entity in annotations.entities:
        entityList.append({'name': entity.name,
                           'type': entity.entity_type,
                           'wikipedia_url': entity.wikipedia_url,
                           'metadata': entity.metadata,
                           'salience': entity.salience})
    df['googleAPIentities'] = entityList

    return df

def textrazorAPI(df):
    text_content = df['article']
    client = textrazor.TextRazor(extractors=["entities", "topics", "dependency-trees",
                                             "relations", "entailments", "senses"])
    response = client.analyze(text_content)

    response_json = response.json

    # list of dictionaries. Dictionary keys are id, label, score, wikiLink, wikidataId
    try:
        df['textrazorAPItopics'] = response_json['response']['topics']
    except KeyError:
        df['textrazorAPItopics'] = np.nan

    # list of dictionaries. Dictionary keys are id, label, score, wikiLink, wikidataId
    try:
        df['textrazorAPIcoarseTopics'] = response_json['response']['coarseTopics']
    except KeyError:
        df['textrazorAPIcoarseTopics'] = np.nan

    #  list of dictionaries. Dictionary keys are
    try:
        df['textrazorAPIentities'] = response_json['response']['entities']
    except KeyError:
        df['textrazorAPIentities'] = np.nan

    # list of two dictionaries. Dictionaries are two entities with relation:
    # keys are id, param - list of dict, keys are:
    # relation, wordPositions (key to list of ints)
    try:
        df['textrazorAPIrelations'] = response_json['response']['relations']
    except KeyError:
        df['textrazorAPIrelations'] = np.nan

    # list of dictionaries. Dictionary keys are:
    # position - int with the position of the sentence
    # words - dict with keys endingPos, lemma, parentPosition, partOfSpeech, position,
    # relationToParent, startingPos, stem, token
    try:
        df['textrazorAPIsentences'] = response_json['response']['sentences']
    except KeyError:
        df['textrazorAPIsentences'] = np.nan

    # list of dictionaries. Dictionary keys are contextScore, entailedTree(key to a list),
    # entailedWords(key to a list), id, prior score, score, wordPositions(key to a list)
    try:
        df['textrazorAPIentailments'] = response_json['response']['entailments']
    except KeyError:
        df['textrazorAPIentailments'] = np.nan

    # list of dictionaries. Dictionary keys are id, propertyPositions(key to a list),
    # wordPositions(key to a list)
    try:
        df['textrazorAPIproperties'] = response_json['response']['properties']
    except KeyError:
        df['textrazorAPIproperties'] = np.nan

    return df

dir = 'C:/Users/sandh/Dropbox/FRM/Bootcamp/Projects/Project 2/tamingnews/analysis/data/'#place where response will be saved
numArticles = 450
textrazor.api_key = #use your own

wrapper(dir, numArticles)
