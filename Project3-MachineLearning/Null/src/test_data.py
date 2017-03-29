import pandas as pd

from sklearn import svm
from sklearn import naive_bayes
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import make_hastie_10_2
from sklearn.ensemble import GradientBoostingClassifier


def print_scores(test_name, train, test):
    print "{0} train score: {1}\n{0} test score: {2}\n".format(test_name,
                                                               train,
                                                               test)

def test(data, test_size=0.2, random_state=42):
    interest = data['interest_level']
    variables = data.drop(['interest_level'], axis=1)

    X_tr, X_te, Y_tr, Y_te = train_test_split(variables,
                                              interest,
                                              test_size=test_size,
                                              random_state=random_state)

    # Support vector machine
    clf = svm.SVC(decision_function_shape='ovo',
                  tol=0.00000001)
    print_scores("Support Vector Machine",
                 clf.fit(X_tr, Y_tr),
                 accuracy_score(Y_te, clf.predict(X_te)))

    # Multinomial Naive Bayes
    mnb = naive_bayes.MultinomialNB()
    mnb.fit(X_tr, Y_tr)
    print_scores("Multinomial Naive Bayes",
                 mnb.score(X_tr, Y_tr),
                 accuracy_score(Y_te, mnb.predict(X_te)))

    # Random Forest
    clf1 = RandomForestClassifier(n_estimators=10)
    clf1 = clf1.fit(X_tr, Y_tr)
    print_scores("Random Forest",
                 clf1.score(X_tr, Y_tr),
                 accuracy_score(Y_te, clf1.predict(X_te)))

    # GradientBoostingClassifier
    clf2 = GradientBoostingClassifier(n_estimators=20,
                                      learning_rate=1.0,
                                      max_depth=1,
                                      random_state=0).fit(X_tr, Y_tr)
    clf2 = clf2.fit(X_tr, Y_tr)
    print_scores("Gradient Boosting Classifier",
                 clf2.score(X_tr, Y_tr),
                 accuracy_score(Y_te, clf2.predict(X_te)))


data = pd.read_json("../data/processed_train.json")

useless = ['description', 'display_address', 'photos', 'street_address', 'manager_id', 'building_id', 'created',
           'longitude', 'latitude', 'features']

# Run test on broad set
d = data.drop(useless, axis=1)
print "Run test on processed data including variables: {}".format(d.columns)
test(d)
