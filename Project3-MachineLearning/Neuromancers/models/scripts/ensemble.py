# def geo_mean_ensemble(glob_files, loc_outfile, method="average", weights="uniform"):
#     if method == "average":
#         scores = defaultdict(float)
#     with open(loc_outfile,"wb") as outfile:
#         for i, glob_file in enumerate( glob(glob_files) ):
#             print "parsing:", glob_file
#             # sort glob_file by first column, ignoring the first line
#             lines = open(glob_file).readlines()
#             lines = [lines[0]] + sorted(lines[1:])
#             for e, line in enumerate(lines):
#                 if i == 0 and e == 0:
#                     outfile.write(line)
#                 if e > 0:
#                     row = line.strip().split(",")
#                     if scores[(e,row[0])] == 0:
#                         scores[(e,row[0])] = 1
#                         scores[(e,row[0])] *= float(row[1])
#         for t,k in sorted(scores):
#             outfile.write("%s,%f\n"%(k,math.pow(scores[(t,k)], 1 / (i+1) )))
#         print("wrote to %s"%loc_outfile)

# geo_mean_ensemble(glob_files, loc_outfile)


# scores = {}
# with open(loc_outfile, "wb") as outfile:
#     for i, glob_file in enumerate(glob(glob_files)):
#         print "parsing:", glob_file
#         # sort glob_file by first column, ignoring the first line
#         df = pd.read_csv(glob_file, index_col=['listing_id'])
#         scores[i] = df

# scores_ = [scores[i] for i in scores.keys()]
# models = [i for i in scores.keys()]
# df = pd.concat(scores_, axis = 0, keys = scores.keys())
# # df.to_csv('submission.csv')

# def arth_mean_ensemble(glob_files, loc_outfile, method="average", weights="uniform"):
#     if method == "average":
#         scores = defaultdict(float)
#     scores = []
#     with open(loc_outfile, "wb") as outfile:
#         for i, glob_file in enumerate(glob(glob_files)):
#             print "parsing:", glob_file
#             # sort glob_file by first column, ignoring the first line
#             df = pd.read_csv(glob_file, index_col=['listing_id'])
#             scores.append(df)
#         for t, k in sorted(scores):
#             outfile.write("%s,%f\n" % (k, scores[(t, k)] / (i + 1)))
#         print("wrote to %s" % loc_outfile)
        
# arth_mean_ensemble(glob_files, 'outfile-arth.csv')  