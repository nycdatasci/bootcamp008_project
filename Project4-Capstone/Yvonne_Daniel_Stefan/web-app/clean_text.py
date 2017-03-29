import re

def cleaning_text(sentence):
    sentence = sentence.lower()
    sentence = re.sub(r'\\r, u', ' ', sentence)
    sentence = re.sub(r'\\', "'", sentence)
    sentence = sentence.split()
    sentence = [re.sub("([^a-z0-9' \t])", '', x) for x in sentence]
    cleaned = [s for s in sentence if s != '']
    cleaned = ' '.join(cleaned)
    return cleaned