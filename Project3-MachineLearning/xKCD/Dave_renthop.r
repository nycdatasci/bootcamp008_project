library(jsonlite)
setwd("~/NYCDSA/Project 3/train.json")
listings<-fromJSON("train.json")
#setwd("~/NYCDSA/Project 3/test.json")
#listings<-fromJSON("test.json")
listings2<-listings[-12] #Cut out data-problematic and statistically useless picture files

#Inspect features
features<-tolower(unlist(listings2[[7]]))
features<-table(features)
features<-features[order(features, decreasing=T)]
write.csv(features, "features.csv")

#features<-gsub("-", "", features)

listings2[[7]]<-sapply(listings2[[7]], paste, collapse=" ")
listings2[[7]]<-tolower(listings2[[7]])

listings3<-data.frame(do.call(cbind, listings2)) #Convert to data.frame
listings3[[5]]<-paste(listings3[[5]], listings3[[7]])
listings3<-listings3[-7]
listings3$interest_level<-factor(unlist(listings3$interest_level), levels=c("low", "medium", "high"))

#levels(listings3$interest_level)<-c(1,2,3)
#listings3$interest_level<-as.numeric(as.character(listings3$interest_level))

rm(listings, listings2)

#Mutate new feature columns
listings3$Elevator[grepl("elevator", listings3[[5]])]<-1
listings3$Hardwood[grepl("hardwood", listings3[[5]])]<-1
listings3$Dishwasher[grepl("dishwasher", listings3[[5]])]<-1
listings3$Prewar[grepl("pre.*war", listings3[[5]])]<-1
listings3$Dining[grepl("dining", listings3[[5]])]<-1
listings3$Pool[grepl("pool", listings3[[5]])]<-1
listings3$Deck[grepl("roof|deck", listings3[[5]])]<-1
listings3$Wheelchair[grepl("wheelchair", listings3[[5]])]<-1
listings3$Fireplace[grepl("fireplace", listings3[[5]])]<-1
listings3$Furnished[grepl("furnished", listings3[[5]])]<-1
listings3$HighCeiling[grepl("high ceiling", listings3[[5]])]<-1
listings3$Green[grepl("green building", listings3[[5]])]<-1
listings3$Stainless[grepl("stainless", listings3[[5]])]<-1
listings3$Granite[grepl("granite", listings3[[5]])]<-1
listings3$Brick[grepl("brick", listings3[[5]])]<-1
listings3$Marble[grepl("marble", listings3[[5]])]<-1
listings3$Valet[grepl("valet", listings3[[5]])]<-1
listings3$EatIn[grepl("eat.*in", listings3[[5]])]<-1
listings3$Lounge[grepl("lounge", listings3[[5]])]<-1
listings3$ShortTerm[grepl("short", listings3[[5]])]<-1
listings3$PlayRoom[grepl("play.*room", listings3[[5]])]<-1
listings3$Luxury[grepl("luxury", listings3[[5]])]<-1
listings3$Brownstone[grepl("brownstone", listings3[[5]])]<-1
listings3$Sauna[grepl("sauna", listings3[[5]])]<-1
listings3$Postwar[grepl("post.*war", listings3[[5]])]<-1
listings3$Backyard[grepl("backyard", listings3[[5]])]<-1
listings3$UtilitiesInc[grepl("utilities", listings3[[5]])]<-1
listings3$Deck[grepl("roof|sundeck", listings3[[5]])]<-1
listings3$Storage[grepl("storage", listings3[[5]])]<-1
listings3$HighSpeed[grepl("high.*speed", listings3[[5]])]<-1
listings3$Loft[grepl("loft", listings3[[5]])]<-1
listings3$WalkInClos[grepl("walk.*in ", listings3[[5]])]<-1
listings3$Sklight[grepl("skylight", listings3[[5]])]<-1
listings3$Garden[grepl("garden", listings3[[5]])]<-1

listings3$Doorman[grepl("doorman|concierge|attended", listings3[[5]])]<-1
listings3$Gym[grepl("fitness|gym|health", listings3[[5]])]<-1
listings3$Renovate[grepl("renovat.*|new construction", listings3[[5]])]<-1
listings3$Parking[grepl("garage|parking", listings3[[5]])]<-1
listings3$Super[grepl("live.*in|on.*site super|superintendent", listings3[[5]])]<-1
listings3$Bike[grepl("bike|bicycle", listings3[[5]])]<-1
listings3$Subway[grepl("subway|transit", listings3[[5]])]<-1
listings3$AC[grepl("a/c|air condition", listings3[[5]])]<-1
listings3$Light[grepl("sunlight| light ", listings3[[5]])]<-1

listings3$Cat[grepl("cats|pets|pet friendly", listings3[[5]])]<-1
listings3$Cat[grepl("no pets", listings3[[5]])]<-0
listings3$Dog[grepl("dog|pets|pet friendly", listings3[[5]])]<-1
listings3$Dog[grepl("no pets", listings3[[5]])]<-0

#listings3[,14:57][is.na(listings3[,14:57])]<-0
listings3[,13:56][is.na(listings3[,13:56])]<-0

listings3$Outdoor<-factor(NA, levels=c("None", "Common", "Private"))
listings3$Outdoor[grepl("outdoor space|publicoutdoor", listings3[[5]])]<-"Common"
listings3$Outdoor[grepl("balcon|terrace|patio|private.*outdoor", listings3[[5]])]<-"Private"
listings3$Outdoor[is.na(listings3$Outdoor)]<-"None"

listings3$Levels<-factor(NA, levels=c("None", "Simplex", "Duplex", "Triplex"))
listings3$Levels[grepl("simplex", listings3[[5]])]<-"Simplex"
listings3$Levels[grepl("duplex|multi.*level", listings3[[5]])]<-"Duplex"
listings3$Levels[grepl("triplex", listings3[[5]])]<-"Triplex"
listings3$Levels[is.na(listings3$Levels)]<-"None"

listings3$Rise<-factor(NA, levels=c("None", "High", "Low", "Mid"))
listings3$Rise[grepl("highrise|hi.*rise|", listings3[[5]])]<-"High"
listings3$Rise[grepl("low.*rise|", listings3[[5]])]<-"Low"
listings3$Rise[grepl("mid.*rise", listings3[[5]])]<-"Mid"
listings3$Rise[is.na(listings3$Rise)]<-"None"

listings3$Fee<-factor(NA, levels=c("No", "Low", "Fee"))
listings3$Fee[grepl("no .*fee", listings3[[5]])]<-"No"
listings3$Fee[grepl("reduced fee|low fee", listings3[[5]])]<-"Low"
listings3$Fee[is.na(listings3$Fee)]<-"Fee"

listings3$Laundry<-factor(NA, levels=c("None", "Building", "Unit"))
listings3$Laundry[grepl("laundry", listings3[[5]])]<-"Building"
listings3$Laundry[grepl("laundry in unit", listings3[[5]])]<-"Unit"
listings3$Laundry[is.na(listings3$Laundry)]<-"None"

#write.csv(listings3[,14:62], "features.csv")
write.csv(listings3[,13:61], "features_test.csv")

boost.rent<-gmb(interest_level ~ . -listing_id, data=best.list, subset=train, distribution=, interaction.depth=4)
