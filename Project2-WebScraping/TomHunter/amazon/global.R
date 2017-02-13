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
         new =   c("OneStarPct",
                   "TwoStarPct",
                   "ThreeStarPct",
                   "FourStarPct",
                   "FiveStarPct",
                   "California_Residents",
                   "Avg_Customer_Rating",
                   "Date_First_Available",
                   "Department",
                   "Discontinued_by_manufacturer",
                   "Shipping_Type",
                   "Item_Weight",
                   "Model_Number",
                   "Manufacturer",
                   "Manufacturer_Recommended_Age",
                   "Media",
                   "Origin",
                   "Pricing",
                   "Dimensions",
                   "Release_Date",
                   "Shipping_Advisory",
                   "Shipping_Weight",
                   "About",
                   "Average_Rating_",
                   "Category",
                   "Description",
                   "List_Price",
                   "Number_of_Customer_Questions",
                   "Number_of_Reviews",
                   "Product_Title",
                   "Reviews_URL",
                   "Sale_Price",
                   "URL")
)





