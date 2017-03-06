import numpy as np
import pandas as pd


def tree_errors(rf, x, y, X, Y):
    print "The training error of random forest is: %.5f" % (1 - rf.score(x, y))
    print "The test     error of random forest is: %.5f" % (1 - rf.score(X, Y))


def plotModel(model, x, y, label):
    """
    model: a fitted model
    x, y: two variables, should arrays
    label: true label
    """
    margin = 0.5
    x_min = x.min() - margin
    x_max = x.max() + margin
    y_min = y.min() - margin
    y_max = y.max() + margin
    import matplotlib.pyplot as pl
    from matplotlib import colors
    colDict = {'red': [(0, 1, 1), (1, 0.7, 0.7)],
               'green': [(0, 1, 0.5), (1, 0.7, 0.7)],
               'blue': [(0, 1, 0.5), (1, 1, 1)]}
    cmap = colors.LinearSegmentedColormap('red_blue_classes', colDict)
    pl.cm.register_cmap(cmap=cmap)
    nx, ny = 200, 200
    xx, yy = np.meshgrid(np.linspace(x_min, x_max, nx),
                         np.linspace(y_min, y_max, ny))
    Z = model.predict(np.c_[xx.ravel(), yy.ravel()])
    Z = Z.reshape(xx.shape)
    # plot colormap
    pl.pcolormesh(xx, yy, Z, cmap='red_blue_classes')
    # plot boundaries
    pl.contour(xx, yy, Z, [0.5], linewidths=1., colors='k')
    pl.contour(xx, yy, Z, [1], linewidths=1., colors='k')
    # plot scatters ans true labels
    pl.scatter(x, y, c=label)
    pl.xlim(x_min, x_max)
    pl.ylim(y_min, y_max)
    # if it's a SVM model
    try:
        # if it's a SVC, plot the support vectors
        index = model.support_
        pl.scatter(x[index], y[index], c=label[index], s=100, alpha=0.5)
    except:
        pass


def plot_feature_importance(features, model):
    pd.Series(index=features,
              data=model.feature_importances_).sort_values().plot(kind='bar')


def output(df_test, model, features):
    preds = model.predict_proba(df_test[features])
    out_df = pd.DataFrame(preds)
    out_df.columns = ["high", "medium", "low"]
    out_df["listing_id"] = df_test['listing_id'].values
    return out_df
