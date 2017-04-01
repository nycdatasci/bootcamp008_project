library(httr)
library(jsonlite)


disclaimers = read.csv("/Users/jakebialer/chipotle_shiny_app/allchipotledatawithdisclaimer.csv", stringsAsFactors = FALSE)
chip_zips = unique(disclaimers$zipcode)
chip_zips = unique(ma$zipcode)

# 78756
# 
chip_zips=chip_zips[grep("[[:digit:]]", chip_zips) ]
chip_zips = joined.steak[is.na(joined.steak$rate),]$zipcode
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

alldata = NULL
for(zip in missed_zips){
  print(zip)
  zip = trim(zip)
  apikey = ""
  url=paste0("https://taxrates.api.avalara.com:443/postal?country=usa&postal=",zip,"&apikey=",api_key)
  tryCatch({
  data = GET(url)
  Sys.sleep(5)
  content <- rawToChar(data$content)
  parsed_data <- fromJSON(content)
  data= data.frame(rate=parsed_data$totalRate,zip)
  alldata = rbind(alldata,data)
  }, error = function(e) {
    print(e)
  })

}
missed_zips = chip_zips[!chip_zips %in% alldata$zip]
