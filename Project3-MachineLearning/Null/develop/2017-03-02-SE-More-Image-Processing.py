#the purpose of this file os to setup a basic framework for parsing the image directory (and subdirectories)
#and build a dataframe with the listing_id (aka the directory names and picture file 'prefix') to be merged with the main dataframe
import numpy as np
import os
import pandas as pd
import exifread
from PIL import Image
import matplotlib.pyplot as plt
imgdir = "/Users/scottedenbaum/Downloads/complete/images/" #sets relative path to images
img_list = []
itr = 0
try:
    set(os.listdir(imgdir))
except Exception, e:
    print "error with: " + imgdir

for listing in set(os.listdir(imgdir)): #parsing each listing's directory
    print "\n\n\n" +  "listing: " + str(itr) + '\n'
    itr += 1
    count_ = 0
    brightness_t = 0
    lum_t = 0
    filesize_t = 0
    img_dict = {}
    meta_data_t = 0
    R_t = 0
    G_t = 0
    B_t = 0
    width_t = 0
    height_t = 0
    listingdir = imgdir + listing
    if listing == '.DS_Store':  #ignore os x hidden system file
        print '-' * 1000 + '\n' + '&' * 1000 + '\n'
        print "hit .DS_Store!" + '\n'
        print '-' * 1000 + '\n' + '&' * 1000 + '\n'
    else:
        print "Opening listing_id : " + listing + '\n'
        img_dict['listing_id'] = listing
        n = len(os.listdir(listingdir))
        img_dict['img_quantity'] = n
        print "Contains: " + str(len(os.listdir(listingdir))) + " Image Files \n"

        for img in set(os.listdir(listingdir)): #parsing each image file
                       if img.find('.jpg') > 0:
                           print '\n\n\n\n' + "Filename: " + img + '\n'
                           print "Count: " + str(count_) + '\n'
                           f = open(imgdir + listing + '/' + img, 'rb')
                           tags = exifread.process_file(f)
                           if len(tags) > 0:
                               meta_data_t = meta_data_t + 1
                           count_ += 1
                           imag = Image.open(imgdir + listing + '/'+ img)
                           imag = imag.convert('RGB')
                           X,Y = 0,0
                           pixelRGB = imag.getpixel((X,Y))
                           R,G,B = pixelRGB
                           R_t = R_t + R
                           print 'R: ' + str(R)
                           print 'G: ' + str(G)
                           print 'B: ' + str(B)
                           G_t = G_t + G
                           B_t = B_t + B
                           width_t = width_t + imag.size[0]
                           height_t = height_t + imag.size[1]
                           brightness = sum([R,G,B])/3
                           brightness_t = brightness_t + brightness
                           print "Brightness is: " + str(brightness) + "\n"
                           #Standard brightness value [0, 255] 0 -> dark, 255 -> bright
                           LuminanceA = (0.2126*R) + (0.7152*G) + (0.0722*B)
                           print "Luminance A is: " + str(LuminanceA) + "\n"
                           #Percieved A - alternative brightness #1
                           LuminanceB = (0.299*R + 0.587*G + 0.114*B)
                           #Perceived B - alternative brightness #2
                           print "Luminance B is: " + str(LuminanceB) + "\n"
                           LuminanceC = np.sqrt( 0.241*R*R + 0.691*G*G + 0.068*B*B )
                           #Perceived C - alternative brightness #3
                           print "Luminance C is: " + str(LuminanceC) + "\n"
                           print "File size is: " + str( os.path.getsize(imgdir + listing + '/' + img) / 1024) + "KB\n"
                           filesize_t = filesize_t + os.path.getsize(imgdir + listing + '/' + img) #running sum of image file size
                           lum_t = lum_t + (LuminanceA + LuminanceB + LuminanceC) / 3 # running average of lum alt brightness
                           img_dict['avg_brightness'] = brightness_t / n
                           img_dict['avg_luminance'] = lum_t /n
                           img_dict['avg_imagesize'] = filesize_t / n
                           img_dict['avg_R'] = R_t / n
                           img_dict['avg_G'] = G_t / n
                           img_dict['avg_B'] = B_t / n
                           img_dict['avg_metadata'] = meta_data_t / n
                           img_dict['avg_imgwidth'] = width_t / n
                           img_dict['avg_imgheight'] = height_t / n

                           if count_ == n:
                               print "Avg Brightness: " + str(brightness_t / n) + "\nAvg Luminance: " + str(lum_t /n) + "\nAvg Image size: " + str(filesize_t / n) + '\n'
                               print 'Avg Metadata: ' + str(meta_data_t / n)
                               print 'Avg Image Width: ' + str(width_t / n)
                               print 'Avg Image Height: ' + str(height_t / n)
                               print '-' * 120

        img_list.append(img_dict)
df_image = pd.DataFrame(img_list)
print df_image.columns
print df_image.index
print df_image
df_image.to_csv('../data/imagestats2.csv')

