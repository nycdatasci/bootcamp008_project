library(dplyr)
library(DT)
library(VIM)
library(Hmisc)

setwd('/Users/mu/Dropbox/learning/NYCDSA/bootcamp008_project/Project2-WebScraping/TomHunter/amazon/')
df <- fread('./data/products_cleaned.csv', stringsAsFactors = FALSE, data.table = FALSE)
df$Manufacturer <- as.factor(df$Manufacturer)
df$Origin <- as.factor(df$Origin) 
df$category <- as.factor(df$category)
df$Product_Dimensions <- as.factor(df$Product_Dimensions)
setnames(df, old = c("1_star",
                     "2_star",
                     "3_star",
                     "4_star",
                     "5_star",
                     "California_residents",
                     "Customer_Reviews",
                     "Date_First_Available",
                     "Department",
                     "Discontinued_by_manufacturer",
                     "Domestic_Shipping",
                     "Item_Weight",
                     "Item_model_number",
                     "Manufacturer",
                     "Manufacturer_recommended_age",
                     "Media",
                     "Origin",
                     "Pricing",
                     "Product_Dimensions",
                     "Release_date",
                     "Shipping_Advisory",
                     "Shipping_Weight",
                     "about",
                     "avg_rating",
                     "category",
                     "description",
                     "list_price",
                     "num_questions",
                     "num_reviews",
                     "product_title",
                     "reviews_url",
                     "sale_price",
                     "url"), 
         new =   c("1 Star %",
                   "2 Star %",
                   "3 Star %",
                   "4 Star %",
                   "5 Star %",
                   "California Residents",
                   "Avg Customer Rating",
                   "Date First Available",
                   "Department",
                   "Discontinued by manufacturer",
                   "Shipping Type",
                   "Item Weight",
                   "Model Number",
                   "Manufacturer",
                   "Manufacturer Recommended Age",
                   "Media",
                   "Origin",
                   "Pricing",
                   "Dimensions",
                   "Release Date",
                   "Shipping Advisory",
                   "Shipping Weight",
                   "About",
                   "Average Rating ",
                   "Category",
                   "Description",
                   "List Price",
                   "Number of Customer Questions",
                   "Number of Reviews",
                   "Product Title",
                   "Reviews URL",
                   "Sale Price",
                   "URL")
)





