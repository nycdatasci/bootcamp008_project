import pandas as pd
import numpy as np
from matplotlib import pylab as plt

data = pd.read_json("../data/train.json")

build_counts = pd.DataFrame(data.building_id.value_counts())
build_counts["building_counts"] = build_counts["building_id"]
build_counts["building_id"] = build_counts.index
build_counts["building_count_log"] = np.log10(build_counts["building_counts"])

log10 = np.log10(build_counts.building_counts[1:]).tolist()
log2 = np.log2(build_counts.building_counts[1:]).tolist()
log = np.log(build_counts.building_counts[1:]).tolist()

plt.plot(log10, label="blue")
plt.plot(log2, label="red")
plt.plot(log, label="green")

# log2 looks most representative and useful.
plt.show()
