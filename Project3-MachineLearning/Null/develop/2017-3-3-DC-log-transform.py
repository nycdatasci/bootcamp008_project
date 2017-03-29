"""
Log transform doesn't seeem appropriate, I don't think.
"""

import pandas as pd
from matplotlib import pylab as plt

data = pd.read_json("../data/train.json")

man_counts = pd.DataFrame(data.manager_id.value_counts())
man_counts["manager count"] = man_counts["manager_id"]
man_counts["manager_id"] = man_counts.index

logs_test = np.log(man_counts["manager count"])

print(logs_test.head())

# plot log
plt.plot(np.log(man_counts["manager count"]), label="natural log")

# plot log base 10
plt.plot(np.log10(man_counts["manager count"]), label="log base 10")

# plot log base 2
plt.plot(np.log2(man_counts["manager count"]), label="log base 2")

plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc=3,
           ncol=2, mode="expand", borderaxespad=0.)

plt.show()
