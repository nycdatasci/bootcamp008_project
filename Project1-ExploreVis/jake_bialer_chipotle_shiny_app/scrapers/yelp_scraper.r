consumerKey = "csbyfWcdWFWiEPr5n6aAOg"
consumerSecret = "cL5arLJ1wXICaEauI6wf9oHzhwM"
token = "_HJB_zNlmAoRQ-oiAmr2HLkMTa-CW3Tw"
token_secret = "Gn52hUisdqUXdHev8YxBcGo1crg"

require(httr)
require(httpuv)
require(jsonlite)
# authorization

disclaimers = read.csv("/Users/jakebialer/chipotle_shiny_app/allchipotledatawithdisclaimer.csv", stringsAsFactors = FALSE)
us.disclaimers= disclaimers[disclaimers$country=="US",]
chip_zips = unique(us.disclaimers$zipcode)

myapp = oauth_app("YELP", key=consumerKey, secret=consumerSecret)
sig=sign_oauth1.0(myapp, token=token,token_secret=token_secret)

# 10 bars in Chicago
get_chipotle = function(zip){
  limit <- 20
  tryCatch({  yelpurl <- paste0("http://api.yelp.com/v2/search/?limit=",limit,"&location=",zip,"&term=chipotle")
 
  locationdata=GET(yelpurl, sig)
  locationdataContent = content(locationdata)
  if(length(locationdataContent)==0){
    return(NULL)
  }
  locationdataList=jsonlite::fromJSON(toJSON(locationdataContent))
  return(locationdataList$businesses)
  },  error = function(e) {
    print(e)
    return(NULL)
    
  })
# or 10 bars by geo-coordinates
}
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

chipotle_locations = NULL
for(zip in chip_zips[1691:length(chip_zips)]){
  print(zip)
  zip = trim(zip)
  data = as.data.frame(get_chipotle(zip))
  location = data$location
  coordinate_data = location$coordinate 
  location$address = sapply(location$address,function(x){x[1]})
  location  = location[ ,!names(location) %in% c("coordinate","neighborhoods")]
  
  location$display_address = sapply(location$display_address,function(x) paste(x,collapse=" "))
  data  = data[ ,!names(data) %in% c("location","menu_date_updated","menu_provider","cross_streets","categories")]
  data = as.data.frame(data)
  data = cbind(data, location)
  data = cbind(data, coordinate_data)
  
  if(!is.null(chipotle_locations)){
    data = data[,names(chipotle_locations)]
  }
  chipotle_locations = rbind(chipotle_locations,data)
  chipotle_locations = unique(chipotle_locations)
  chipotle_locations <- data.frame(lapply(chipotle_locations, as.character), stringsAsFactors=FALSE)
    
  }

chipotle_locations_good=filter(chipotle_locations,name=="Chipotle Mexican Grill")
write.csv(chipotle_locations_good,"final_final_chipotle_yelp_data.csv")


