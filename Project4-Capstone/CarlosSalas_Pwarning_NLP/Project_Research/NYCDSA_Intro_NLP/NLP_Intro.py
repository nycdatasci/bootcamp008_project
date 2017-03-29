################################### NLP INTRO ################################################

# Foundation of Linguistics:
# 1) Phonetics and Phonology: The study of sounds 
# 2) Morphology: The study of the meaningful components of words 
# 3) Syntax: The study of the structural relationship between words 
# 4) Semantics: The study of meaning 
# 5) Pragmatics: The study of how language is used to accomplish goals 
# 6) Discourse: The study of linguistic units larger than a single utterance

# What's ambiguity? it is the worst NLP enemy as all the models aimed at reducing it:
Bank # ambiguity happens in words with different meanings
Our company is training workers # ambiguity also is present on syntax structure=> this sentence can be understood in 3 ways depending on parsing:
# 1) (Our Company) is training workers
# 2) (Our Company) is (training workers) 
# 3) (Our Company) is (training) workers.

# methods to solve ambguity:

# A) POS Tagging: https://en.wikipedia.org/wiki/Part-of-speech_tagging
# - Part-of-speech tagging (POS tagging or POST), also called grammatical tagging or word-category disambiguation
# - POS Tagging is the process of marking up a word in a text (corpus) as corresponding to a particular part of speech, based on both its definition and its context
# - A simplified form of this is commonly taught to school-age children, in the identification of words as nouns, verbs, adjectives, adverbs, etc.
# - POS-tagging algorithms fall into two distinctive groups: rule-based and stochastic
# https://www.safaribooksonline.com/library/view/python-3-text/9781782167853/ch06s10.html

# POS - TAGS of Part of speech
1. CC Coordinating conjunction 					19. PRP$ Possessive pronoun 
2. CD Cardinal number 							20. RB Adverb
3. DT Determiner 								21. RBR Adverb, comparative   	
4. EX Existential there 						22. RBS Adverb, superlative
5. FW Foreign word 								23. RP Particle
6. IN Preposition or subordinating conjunction 	24. SYM Symbol 
7. JJ Adjective 								25. TO to
8. JJR Adjective, comparative					26. UH Interjection           
9. JJS Adjective, superlative 					27. VB Verb base form
10. LS List item marker 						28. VBD Verb, past tense
11. MD Modal 									29. VBG Verb, gerund or present participle
12. NN Noun, singular or mass 					30. VBN Verb, past participle
13. NNS Noun, plural 							31. VBP Verb, non-3rd person singular present
14. NNP Proper noun, singular 					32. VBZ Verb, 3rd person singular present
15. NNPS Proper noun, plural 					33. WDT Wh-determiner
16. PDT Predeterminer 							34. WP Wh-pronoun
17. POS Possessive ending 						35. WP$ Possessive wh-pronoun
18. PRP Personal pronoun 						36. WRB Wh-adverb


# B) Probabilistic Parsing:https://en.wikipedia.org/wiki/Stochastic_context-free_grammar
# - PCFGs extend context-free grammars similar to how hidden Markov models extend regular grammars. 
# - Each production is assigned a probability, or parse, that is the product of the probabilities of the productions used in that derivation.
# - These probabilities can be viewed as parameters of the model, and for large problems it is convenient to learn these parameters via machine learning.
# - Issues such as grammar ambiguity must be resolved. The grammar design affects results accuracy.
# - N-grams (mainly bigrams and trigrams) use conditional probability under Markovs assumption to calculate occurence probabilities
https://en.wikipedia.org/wiki/Bigram
https://www.slideshare.net/ssrdigvijay88/ngrams-smoothing
https://en.wikipedia.org/wiki/N-gram # bigrams (low margin) and trigrams (New York City) are the most used since when n>3 sparsity becomes a problem

# Any NLP mode is concerned about the next errors:
Type I Error 	# (False Positive) Matching strings we don’t want : “canal” and “anova”
Type II Error 	# (False Negative) Not matching the ones we want : when we miss caps

# RegEx is an essential tool: identify text sequences an patterns

[Pp]erson 		# Person, person 
[0123456789] 	# Any digit 
[A-Z]			# Any uppercase letter 
[a-z] 			# Any lowercase letter 
[0-9] 			# Any single digit 
[^1] 			# Negation: Not a one 
/a/ 			# matches any “a” but not “A” => My n"a"me is Andrew. 
/name_is/ 		# My "name is" Andrew
\s				# any whitespace => \s+ = all whitespaces

colou?r 		# Optional previous character => color, colour 
oo*h! 			# 0 or more of previous character => oh!, ooh!, oooh!, ooooh!, etc… 
o+h! 			# 1 or more of previous character oh!, ooh!, oooh!, ooooh!, etc… 
baa+ 			# baa, baaa, baaaa, etc... 
beg.n 			# begin, begun, beg3n, beg’n, etc...

\.$ 			# The end"."" 
^[A-Z] 			# "N"ew York

# example: finding "an" instances in a text with lowe and upper case letters:
'an ' 			# Misses caps 
'[Aa]n' 		# Also returns words like “canal” and “anova”
' \b[Aa]n\b '   # our solution

# Tokenization: synonym for text segmentation, yet in lexical analysis means to break the text in meaningful units ~ specific type of text segmentation
# Common tokenization problems:
New York City # one or 3 tokens?
state-of-the-art
M.B.A

# Normalization methods to solve tokenization:
# i) Case Folding: https://en.wikipedia.org/wiki/Letter_case#Case_folding
# - Case-insensitive operations are sometimes said to fold case, from the idea of folding the character code table so that upper- and lower-case letters coincide

# ii) Lemmatization: https://en.wikipedia.org/wiki/Lemmatisation
# - Grouping together inflected forms of a word based on their meaning and context (neighbouring sentence and whole document) so they can be analysed as a single item
book, books, book’s, books’ # → book
am, are, is, was, been # → be 
# - Lemmatisation is different from stemming since the latter ignores the meaning and context and it's only concerned about the words morphology=> same word stem = base =  root form
produc = produce, produces, production, productive, productively # stemming example
# Stemming algos:
# Porter Stemmer: Pocess for removing the commoner morphological and inflexional endings from words in English.
# https://tartarus.org/martin/PorterStemmer/
# Others: Snowball, Lancaster, ISRI, Regexp, etc
# http://snowball.tartarus.org/algorithms/porter/stemmer.html

###########################################################################################################


# https://elitedatascience.com/python-nlp-libraries

# Libraries:
# A) textat: calculate statistics from text, which helps to decide readability, complexity and grade level of a particular corpus 
# https://github.com/shivam5992/textstat , https://pypi.python.org/pypi/textstat 
# 
# B) nltk: 
# i) excellent for learning and exploring NLP concepts, but it's not meant for production
# ii) 
# http://www.nltk.org/
# 
# 
# 



#################################### NLP IN PYTHONL NLTK ##################################################

http://www.nltk.org/book/

# prepare enironment
from bs4 
import BeautifulSoup 
import urllib2 
import re 
import nltk
# nltk.download('all') #only once

# Language processing task		NLTK modules			Functionality
##################################################################################
# Accessing corpora				corpus					standardized interfaces to corpora and lexicons
# String processing				tokenize, stem			tokenizers, sentence tokenizers, stemmers
# Collocation discovery			collocations			t-test, chi-squared, point-wise mutual information
# Part-of-speech tagging		tag						n-gram, backoff, Brill, HMM, TnT
# Machine learning				classify, cluster, tbl	decision tree, maximum entropy, naive Bayes, EM, k-means
# Chunking						chunk					regular expression, n-gram, named-entity
# Parsing						parse, ccg				chart, feature-based, unification, probabilistic, dependency
# Semantic interpretation		sem, inference			lambda calculus, first-order logic, model checking
# Evaluation metrics			metrics					precision, recall, agreement coefficients
# Probability and estimation	probability				frequency distributions, smoothed probability distributions
# Applications					app, chat				graphical concordancer, parsers, WordNet browser, chatbots
# Linguistic fieldwork			toolbox					manipulate data in SIL Toolbox format

####################################### 1. BASE PYTHON NLP TRICKS ############################################
http://www.nltk.org/book/ch01.html

sentence = 'Monthy Python'
sentence.split() #  turns it into:
text = ['Monthy','Python']
len(text) # count tokens/words
len(set(text)) # text vocabulary / unique words
sorted(set(text)) # sorted vocabulary
[x for x in text] # use list comprehension to operate easily
set(w.lower() for w in text if w.isalpha()) # derive the vocabulary, collapsing case distinctions and ignoring punctuation

# Function			Meaning
############################################################################
s.startswith(t)		# test if s starts with t
s.endswith(t)		# test if s ends with t
t in s				# test if t is a substring of s
s.islower()			# test if s contains cased characters and all are lowercase
s.isupper()			# test if s contains cased characters and all are uppercase
s.isalpha()			# test if s is non-empty and all characters in s are alphabetic
s.isalnum()			# test if s is non-empty and all characters in s are alphanumeric
s.isdigit()			# test if s is non-empty and all characters in s are digits
s.istitle()			# test if s contains cased characters and is titlecased (i.e. all words in s have initial capitals)

s.find(t)			# index of first instance of string t inside s (-1 if not found)
s.rfind(t)			# index of last instance of string t inside s (-1 if not found)
s.index(t)			# like s.find(t) except it raises ValueError if not found
s.rindex(t)	 		# like s.rfind(t) except it raises ValueError if not found
s.join(text)		# combine the words of the text into a string using s as the glue
s.split(t)			# split s into a list wherever a t is found (whitespace by default)
s.splitlines()		# split s into a list of strings, one per line
s.lower()			# a lowercased version of the string s
s.upper()			# an uppercased version of the string s
s.title()			# a titlecased version of the string s
s.strip()			# a copy of s without leading or trailing whitespace
s.replace(t, u)		# replace instances of t with u inside s

text1.concordance('word_inside_text1') # A concordance view shows us every occurrence of a given word, together with some context
text1.similar('word_inside_text1') # A similar view shows us similar words to our selected word 

####################################### 2. TEXT CORPORA AND LEXICAL RESOURCES############################################
http://www.nltk.org/book/ch02.html
# i) Corpora is a large, structured collection of texts 
# ii) NLTK comes with many corpora, e.g., the Brown Corpus, nltk.corpus.brown.
# iii) Some text corpora are categorized, e.g., by genre or topic; sometimes the categories of a corpus overlap each other.
# iv) A conditional frequency distribution is a collection of frequency distributions, each one for a different condition. They can be used for counting word frequencies, given a context or a genre.
# v) WordNet is a semantically-oriented dictionary of English, consisting of synonym sets — or synsets — and organized into a network.

# Corpora: 
# - Corpora is a body of utterances, as words or sentences, assumed to be representative of and used for lexical, grammatical, or other linguistic analysis. 
# - Brown Corpora is the American English general accepted corpora, yet depending on the text to be analyzed a more specific corpora should be used (Finance=> Loughran and Mcdonald (2011) ﬁnancial dictionary)
#  Lexicon:
# - A lexicon, or lexical resource, is a collection of words and/or phrases along with associated information such as part of speech and sense definitions
import nltk
from nltk.corpus import * # import all available corpora in ntlk
from nltk.corpus import gutenberg # gutenber corpora contains classic noveles like moby_dick, mcBeth or Emma
gutenberg.fileids() # check novels inside
emma = gutenberg.words('austen-emma.txt') # choose Emma as corpora
from nltk.corpus import gutenberg # gutenber corpora contains classic noveles like moby_dick, mcBeth or Emma

from nltk.corpus import brown # Most famous corpora is Brown upon American Englih Literature
brown.categories() # check categories: science fiction, news, religion, romance,etc
news_text = brown.words(categories='news')
fdist = nltk.FreqDist(w.lower() for w in news_text) # check each word frequency in news corpora

from nltk.corpus import reuters # 10,788 news documents totaling 1.3 million words. The documents have been classified into 90 topics,
reuters.fileids()
reuters.categories()
# Reuters accepts to mix stories and  methods accept a single fileid or a list of fileids.
reuters.categories('training/9865')
reuters.fileids(['barley', 'corn'])
reuters.words(categories=['barley', 'corn']) # reuters.words(categories=['barley', 'corn'])

# Use your own corpus:
from nltk.corpus import PlaintextCorpusReader
corpus_root = '/usr/share/dict'  # adress
wordlists = PlaintextCorpusReader(corpus_root, '.*') 
wordlists.fileids()

# Stopwords:
from nltk.corpus import stopwords
stopwords.words('english') # shows high-frequency words like the, to and also that we sometimes want to filter out of a document
# calculate % words that are not stopwords:
def content_fraction(text):
	stopwords = nltk.corpus.stopwords.words('english')
	content = [w for w in text if w.lower() not in stopwords] # you can calculate %stopwords using "in"
	return len(content) / len(text)



# Function					Description
######################################################################
fileids()					# the files of the corpus
fileids([categories])		# the files of the corpus corresponding to these categories
categories()				# the categories of the corpus
categories([fileids])		# the categories of the corpus corresponding to these files
raw()						# the raw content of the corpus
raw(fileids=[f1,f2,f3])		# the raw content of the specified files
raw(categories=[c1,c2])		# the raw content of the specified categories
words()						# the words of the whole corpus
words(fileids=[f1,f2,f3])	# the words of the specified fileids
words(categories=[c1,c2])	# the words of the specified categories
sents()						# the sentences of the whole corpus
sents(fileids=[f1,f2,f3])	# the sentences of the specified fileids
sents(categories=[c1,c2])	# the sentences of the specified categories
abspath(fileid)				# the location of the given file on disk
encoding(fileid)			# the encoding of the file (if known)
open(fileid)				# open a stream for reading the given corpus file
root						# if the path to the root of locally installed corpus
readme()					# the contents of the README file of the corpus

# Conditional Frequency: When texts of a corpus are divided into several categories (by genre, topic, author, etc)
# ConditionalFreqDist() takes a list of pairs:
from nltk.corpus import brown
cfd = nltk.ConditionalFreqDist(
	(genre, word)
	for genre in brown.categories()
	for word in brown.words(categories=genre))

genre_word = [(genre, word) 
	for genre in ['news', 'romance'] 
	for word in brown.words(categories=genre)

cfd = nltk.ConditionalFreqDist(genre_word) # Conditional Frequency
cfd.plot() # output in chart format
cfd.tabulate() # output in table format

# creating bigrams using Corpus. Genesis
text = nltk.corpus.genesis.words('english-kjv.txt') 
bigrams = nltk.bigrams(text)
cfd = nltk.ConditionalFreqDist(bigrams)

# Function 							Descr # iption
#####################################################################################################
cfdist = ConditionalFreqDist(pairs)	# create a conditional frequency distribution from a list of pairs
cfdist.conditions()	 				# the conditions
cfdist[condition]					# the frequency distribution for this condition
cfdist[condition][sample]			# frequency for the given sample for this condition
cfdist.tabulate()					# tabulate the conditional frequency distribution
cfdist.tabulate(samples, conditions)# tabulation limited to the specified samples and conditions
cfdist.plot()						# graphical plot of the conditional frequency distribution
cfdist.plot(samples, conditions)	# graphical plot limited to the specified samples and conditions
cfdist1 < cfdist2					# test if samples in cfdist1 occur less frequently than in cfdist2

def lexical_diversity(my_text_data): # my_text_data is a list of words  
	word_count = len(my_text_data)
	vocab_size = len(set(my_text_data))
	diversity_score = vocab_size / word_count
	return diversity_score
# WordNet

from nltk.corpus import wordnet as wn
wn.synsets('motorcar') # "car.n.01" = synonym set
wn.synsets('motorcar').lemma_names() # yields synonym words within synonim set "car.n.01"
wn.synsets('car.n.01').definition() # set meaning
wn.synsets('car.n.01').examples() # set examples
wn.synset('car.n.01').hyponyms() # related specific concepts
wn.synset('car.n.01').hyponyms() # related general concepts
wn.lemma('supply.n.02.supply').antonyms() # 


####################################### 3. PROCESSING RAW TEXT: SCRAPING/OUTPUT/INPUT FILES/REGEX/NORMALIZING ############################################
http://www.nltk.org/book/ch03.html

# Normalizing: special characters and unwanted material (such as headers, footers, markup), that need to be removed before we do any linguistic processing
cleantext = re.sub( '\s+', ' ', text ).strip() # remove whitespace. https://www.w3schools.com/jsref/jsref_regexp_whitespace.asp
cleantext = cleantext.lower() #lower case
cleantext = re.sub( '[.:\',\-!;"()?]', "", cleantext).strip() # remove special characs

# Tokenizing: segmentation of a text into basic units — or tokens — such as words and punctuation 
sentence = """At eight o'clock on Thursday morning Arthur didn't feel very good.""" 
# A) Tokenization using old style:
clean_sentence = re.sub( '\s+', ' ', sentence ).strip() # normalizing
clean_sentence = clean_sentence.lower() #normalizing
clean_sentence = re.sub( '[.:\',\-!;"()?]', "", clean_sentence).strip() # normalizing
old_tokens = clean_sentence.split(" ") # tokenization
# B) Tokenization using word_tokenize: 
tokens = nltk.word_tokenize(sentence) # tokenizing 

# Stemmering: 
# - Use NLTK off-the-shelf stemmers like Porter and Lancaster since they handle a much wider spectrum of irregular cases than bespoke RegEx
# - Porter Stemmer is a good choice if you are indexing some texts and want to support search using alternative forms of words
stemmer = nltk.stem.PorterStemmer()                        	# Create our stemmer 
stemmed_corpus = [stemmer.stem(word) for word in corpus]   	# Apply stemmer

# Lemmatization:
# - Lemmatization is a process that maps the various forms of a word (such as appeared, appears) to the canonical or citation form of the word, also known as the lexeme or lemma (e.g. appear).
# - WordNet lemmatizer only removes affixes if the resulting word is in its dictionary. 
# - This additional checking process makes the lemmatizer slower than the above stemmers
lmtizer=nltk.stem.WordNetLemmatizer()  # Lemmatize using WordNet's built-in morphy function. Returns the input word unchanged if it cannot be found in WordNet.
print lmtizer.lemmatize('was') # was
print lmtizer.lemmatize('was', 'v') # be => it's crucial to add each word class (noun, verve or adjective)


####################################### 4. WRITING STRUCTURED PROGRAMS ############################################

http://www.nltk.org/book/ch04.html


####################################### 5. CATEGORIZING & TAGGING ############################################

http://www.nltk.org/book/ch05.html

# Words can be grouped into classes, such as nouns, verbs, adjectives, and adverbs,  known as lexical categories or parts of speech (POS). 
# POS are assigned short labels, or tags, such as NN, VB, and the process of automatically assigning POS to words in a text is called POS tagging
# Automatic tagging uses: predicting the behavior of previously unseen words, analyzing word usage in corpora, and text-to-speech systems.
# Some linguistic corpora, such as the Brown Corpus, have been POS tagged.
# Tagging methods: default tagger, RegEx tagger, unigram tagger, bigram, n-gram taggers (backoff technique can combine several Tags).
# Taggers can be trained and evaluated using tagged corpora.
# Backoff method: useful to combining models when a more specialized model (such as a bigram tagger) cannot assign a tag in a given context.
# POS  tagging is an important, early example of a sequence classification task in NLP
# A dictionary is used to map between arbitrary types of information, such as a string and a number: freq['cat'] = 12. 
# Dictionaries are created using {}}=> pos = {}, pos = {'furiously': 'adv', 'ideas': 'n', 'colorless': 'adj'}.
# N-gram taggers can be defined for large values of n, but sparsity problems appear when  n is larger than 3 
# Transformation-based tagging involves learning a series of repair rules of the form "change tag s to tag t in context c", where each rule fixes mistakes and possibly introduces a (smaller) number of errors.


# POS:
nltk.help.upenn_tagset() # definitions POS TAGS parts of speech
# remember tokenizatiton example B)... let's tag them now: 
sentence = """At eight o'clock on Thursday morning Arthur didn't feel very good."""
tokens = nltk.word_tokenize(sentence) # tokenizing 
tagged = nltk.pos_tag(tokens) # tag tokens according to POS tags
tagged = nltk.pos_tag(to_be_stemmed, tagset='english') # highlight desired language => default= 'english'
tagged = nltk.pos_tag(to_be_stemmed, tagset= 'universal') # if you only need basic tags

# Corpora included with NLTK like Brown has been tagged:
nltk.corpus.brown.tagged_words() # [('The', 'AT'), ('Fulton', 'NP-TL'), ...] 
nltk.corpus.brown.tagged_words(tagset='universal') # [('The', 'DET'), ('Fulton', 'NOUN'), ...]

# Find the most frequent nouns/verb/adjetive of each noun/verb/adjective POS type:
def findtags(tag_prefix, tagged_text):
    cfd = nltk.ConditionalFreqDist((tag, word) for (word, tag) in tagged_text
                                  if tag.startswith(tag_prefix))
    return dict((tag, cfd[tag].most_common(5)) for tag in cfd.conditions())

tagdict = findtags('NN', nltk.corpus.brown.tagged_words(categories='news'))
for tag in sorted(tagdict):
	print(tag, tagdict[tag])

# Find ambiguous words (more than 3 POS):
brown_news_tagged = brown.tagged_words(categories='news', tagset='universal')
data = nltk.ConditionalFreqDist((word.lower(), tag)
                                 for (word, tag) in brown_news_tagged)
for word in sorted(data.conditions()):
	if len(data[word]) > 3:
		tags = [tag for (tag, _) in data[word].most_common()]
		print(word, ' '.join(tags))

# Automatic Tagger:
# Dictionary remainder
# Function 				Description
##################################################################
d = {}					# create an empty dictionary and assign it to d
d[key] = value			# assign a value to a given dictionary key
d.keys()				# the list of keys of the dictionary
list(d)					# the list of keys of the dictionary
sorted(d)				# the keys of the dictionary, sorted
key in d	 			# test whether a particular key is in the dictionary
for key in d			# iterate over the keys of the dictionary
for (key,value) in dic 	# iterate over the (keys/values) of the dictionary
d.values()				# the list of values in the dictionary
dict([(k1,v1), (k2,v2), ...])	# create a dictionary from a list of key-value pairs
d1.update(d2)			# add all items from d2 to d1
defaultdict(int)		# a dictionary whose default value is zero

# a) Automatic Tagger: automatically add POS
from nltk.corpus import brown
brown_tagged_sents = brown.tagged_sents(categories='news') # we tagged sentenced here
brown_sents = brown.sents(categories='news')

fd = nltk.FreqDist(brown.words(categories='news'))
cfd = nltk.ConditionalFreqDist(brown.tagged_words(categories='news')) #conditional freq words by tag
most_freq_words = fd.most_common(100) 
likely_tags = dict((word, cfd[word].max()) for (word, _) in most_freq_words) # dict (word: tag)
baseline_tagger = nltk.UnigramTagger(model=likely_tags) # our "most likely tag" model
baseline_tagger.evaluate(brown_tagged_sents) # 0.45 tagged properly from tagging most frequent words' most likely tags

# b) Unigram Tagger: automatically add POS
rom nltk.corpus import brown
brown_tagged_sents = brown.tagged_sents(categories='news')
brown_sents = brown.sents(categories='news')
unigram_tagger = nltk.UnigramTagger(brown_tagged_sents)
unigram_tagger.evaluate(brown_tagged_sents) # 0.93 
# validation test:
size = int(len(brown_tagged_sents) * 0.9)
train_sents = brown_tagged_sents[:size]
test_sents = brown_tagged_sents[size:]
unigram_tagger = nltk.UnigramTagger(train_sents)
unigram_tagger.evaluate(test_sents) # 0.81 worse as expected

# c) Bigram Tagger: automatically add POS
bigram_tagger = nltk.BigramTagger(train_sents)
unseen_sent = brown_sents[4203]
bigram_tagger.tag(unseen_sent)
bigram_tagger.evaluate(test_sents)

# Chunking
# Defining patterns in POS helps, for example, to find phrases in a corpus -- especially noun phrases.
# Pros: More control over patterns matched 
# Cons: Difficult to hard code in every rule

sentence = [("the", "DT"), ("little", "JJ"), ("yellow", "JJ"), ("dog", "NN"), ("barked",
            "VBD"), ("at", "IN"), ("the", "DT"), ("cat", "NN")] 
pattern = "NP: {<DT>?<JJ>*<NN>}"          	# define a tag pattern of an NP chunk 
NPChunker = nltk.RegexpParser(pattern)    	# create a chunk parser 
result = NPChunker.parse(sentence)       	# parse the example sentence print result or draw graphically using 
result.draw()  # result drawn graphically

# RegEx patterns for chunking:
"NP: {<DT>?<JJ>*<NN>}" 	# define a tag pattern starting NP (Noun Pronoum) plus 0 or 1 determinants plus 0 or more adjectives and a noun
"{<DT|PP\$>?<JJ>*<NN>}" # determiner/possessive, adjectives and noun: 
"{<NNP>+}"  			# sequences of proper nouns: 
"{<NN>+}"				# consecutive nouns: 

# Minimum Edit Distance
# The Minimum Edit Distance between two string is the minimum number of insertions, deletions, and substitutions needed to transform the string.
sittin => sitting # Min Edit Distance =1 
intention => execution # Min Edit Distance=5

# Text Classification
# 1) Assigning a subject 
# 2) Spam Detection 
# 3) Age/Gender of author 
# 4) Who is the author? 
# 5) Sentiment analysis

####################################### 6.Learning to Classify Text ############################################
http://www.nltk.org/book/ch06.html

# Modeling the linguistic data found in corpora can help us to understand linguistic patterns, and can be used to make predictions about new language data.
# Supervised classifiers use labeled training corpora to build models that predict the label of an input based on specific features of that input.
# Supervised classifiers can perform a wide variety of NLP tasks: document classification, part-of-speech tagging, sentence segmentation, dialogue act type identification, and determining entailment relations, and many other tasks.
# When training a supervised classifier, you should split your corpus into three datasets: i) a training set ; ii) a dev-test set for validation/model tunning; and a test set for peformance evaluation.
# Decision trees classifiers: automatically constructed tree-structured flowcharts  to assign labels to input values based on their features=> not very good at handling cases where feature multicolinearity exists.
# Naive Bayes: each feature independently contributes to the decision of which label should be used=> problematic when two or more features are highly correlated with one another.
# Maximum Entropy classifiers: similar to naive Bayes; however, they employ iterative optimization to find the set of feature weights that maximizes the probability of the training set.
# Most of the models that are automatically constructed from a corpus are descriptive(they told us which features are relevant), but they don't tell if anything upon causality.

####### Creating a Classifier: Naive Bayes Classifier to detect gender:
# 1) Build dictionary to distinguish male/female using built-in corpora 'names' and gender dictionaries 'male.txt' and 'female.txt'
from nltk.corpus import names
labeled_names = ([(name, 'male') for name in names.words('male.txt')] + [(name, 'female') for name in names.words('female.txt')])
import random
random.shuffle(labeled_names) 
# 2) Selecting Feature and creating a feature extractor: it's like the pattern we want to analyze to classify
def gender_features(word):
	return {'last_letter': word[-1]}  # feature in this case is the last letter in a word is good gender predictor
# 3) Obtain features from our dictionary created in 1):
featuresets = [(gender_features(n), gender) for (n, gender) in labeled_names]
# 4) Split data between training and test set:
train_set, test_set = featuresets[500:], featuresets[:500]
# note: large corpora can crash the system so we better do this to save steps 3) and 4):
from nltk.classify import apply_features # apply_features() returns an object that acts like a list but does not store all the feature sets in memory:
train_set = apply_features(gender_features, labeled_names[500:])
test_set = apply_features(gender_features, labeled_names[:500])

# 5) NB models fit:
classifier = nltk.NaiveBayesClassifier.train(train_set)
#  6) NB Test:
nltk.classify.accuracy(classifier, test_set) #0.77
classifier.classify(gender_features('Neo')) # male
classifier.classify(gender_features('Trinity')) # female
# 6) Check most determinant featurws:
classifier.show_most_informative_features(5) # show 5 most important

####### Creating Fetures/Predictors
# Overfitting: too many features will make the algorithm more likely to rely on idiosyncrasies of the training data that eventually won't generalize well to the test.
labeled_names = ([(name, 'male') for name in names.words('male.txt')] + [(name, 'female') for name in names.words('female.txt')])
# i) split data:
train_names = labeled_names[1500:]
devtest_names = labeled_names[500:1500]
test_names = labeled_names[:500]
# ii) Fit model
train_set = [(gender_features(n), gender) for (n, gender) in train_names]
devtest_set = [(gender_features(n), gender) for (n, gender) in devtest_names]
test_set = [(gender_features(n), gender) for (n, gender) in test_names]
classifier = nltk.NaiveBayesClassifier.train(train_set) 
print(nltk.classify.accuracy(classifier, devtest_set)) # 0.75
# iii) Use devtest set to look into the list of errors to fine tune the Feature Creation function:
errors = []
for (name, tag) in devtest_names:
	guess = classifier.classify(gender_features(name))
	if guess != tag:
		errors.append((tag, guess, name))
for (tag, guess, name) in sorted(errors):
	print('correct={:<8} guess={:<8s} name={:<30}'.format(tag, guess, name))

####### Document Classification
# Last example was dealing with word classification, what about an entire text classification?






####################################### 7.  ############################################

# Name Entity Recognition:
sent = nltk.corpus.treebank.tagged_sents()[22] # select sentence 22 from treebank corpus
print(nltk.ne_chunk(sent, binary=True)) #  binary=True [1]: named entities are just tagged as NE; otherwise, the classifier adds category labels such as PERSON, ORGANIZATION, and GPE.
