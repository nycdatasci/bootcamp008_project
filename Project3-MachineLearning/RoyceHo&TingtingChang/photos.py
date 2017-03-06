# import os
# import pandas as pd
# import csv
# import cv2
# from PIL import Image 
# from PIL import ImageStat
# def brightness(im_file):
#     try:
#         im = Image.open(im_file).convert('L')
#         stat = ImageStat.Stat(im)
#         return stat.mean[0]
#     except:
#         return 0
# csv_file = open('photos.csv', 'wb')
# writer = csv.writer(csv_file)
# writer.writerow(['listing_id', 'photo_len', 'photo_wid', 'photo_rat', 'photo_colscal', ' photo_pix', 'photo_bri'])
# for item in os.listdir('images'):
#     x = 'images/' + item
#     if os.path.isdir(os.path.join(x)):
#         for pics in os.listdir(x):
#             if '.jpg' in pics:
#                 y = x + '/' + pics
#                 print y
#                 img = cv2.imread(y)
#                 writer.writerow([item, img.shape[1], img.shape[0], float(img.shape[1])/img.shape[0], img.shape[2], img.size, brightness(y)])
# csv_file.close()

# x = pd.read_csv('photos.csv').drop(['photo_colscal'], axis = 1)
# y = x.groupby('listing_id')
# ymean = y.mean().reset_index()
# ymax = y.max().reset_index()
# ymin = y.min().reset_index()

# ymean.columns = ['listing_id', 'photo_len_mean', 'photo_wid_mean', 'photo_rat_mean', ' photo_pix_mean', 'photo_bri_mean']
# ymax.columns = ['listing_id', 'photo_len_max', 'photo_wid_max', 'photo_rat_max', ' photo_pix_max', 'photo_bri_max']
# ymin.columns = ['listing_id', 'photo_len_min', 'photo_wid_min', 'photo_rat_min', ' photo_pix_min', 'photo_bri_min']

# photos_df = ymean.merge(ymax, on = 'listing_id').merge(ymin, on = 'listing_id')
# photos_df.to_csv('photos2.csv')
