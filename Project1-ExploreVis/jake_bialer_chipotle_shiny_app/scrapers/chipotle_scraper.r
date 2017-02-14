library(httr)
library(XML)
library(dplyr)

get_chip_location_info= function(num){
    data = GET(paste0("https://svc.chipotle.com/Order.svc/Restaurant/",num,"/en"),
        add_headers(Host="svc.chipotle.com",
            "Proxy-Connection"="keep-alive",
            "Accept-Encoding"="gzip, deflate",
            "Accept-Language"="en-us",
            Connection="keep-alive",
            ChipClientToken="46514EE8-9892-4AC5-B403-761E3B8EA935",
            User_Agent="Chipotle/4.4.1 (iPhone; iOS 9.2.1; Scale/3.00)",
            Accept="*/*",
            Authorization="ChipHK 401648F6-0E49-4CF4-8396-F01733C786CC:xpf6JeAMw41OAtjiZnqclYwdznx5NnkzTG0dN02+Rbk="))
    doc = content(data, as='parse', type='text/xml')
    parse = xmlParse(doc)
    root = xmlRoot(parse)
    address = xpathApply(root, "//chip:Data//chip:Restaurant//chip:Address//chip:Address1/text()", namespaces = c(chip = "http://chipotle.com/ChipService/2011/10"))[[1]]
    city = xpathApply(root, "//chip:Data//chip:Restaurant//chip:Address//chip:City/text()", namespaces = c(chip = "http://chipotle.com/ChipService/2011/10"))[[1]]
    state = xpathApply(root, "//chip:Data//chip:Restaurant//chip:Address//chip:State/text()", namespaces = c(chip = "http://chipotle.com/ChipService/2011/10"))[[1]]
    country = xpathApply(root, "//chip:Data//chip:Restaurant//chip:Address//chip:Country/text()", namespaces = c(chip = "http://chipotle.com/ChipService/2011/10"))[[1]]
    zipcode = xpathApply(root, "//chip:Data//chip:Restaurant//chip:Address//chip:Zip/text()", namespaces = c(chip = "http://chipotle.com/ChipService/2011/10"))[[1]]
    lat = xpathApply(root, "//chip:Data//chip:Restaurant//chip:Cordinates//chip:Latitude/text()", namespaces = c(chip = "http://chipotle.com/ChipService/2011/10"))[[1]]
    long = xpathApply(root, "//chip:Data//chip:Restaurant//chip:Cordinates//chip:Longitude/text()", namespaces = c(chip = "http://chipotle.com/ChipService/2011/10"))[[1]]
    bus_hour = xpathApply(root, "//chip:Data//chip:Restaurant//chip:BusinessHourText/text()", namespaces = c(chip = "http://chipotle.com/ChipService/2011/10"))[[1]]
    data=c(address,city,state,country,zipcode,lat,long,bus_hour)
    if(!is.null(data)){
        data = sapply(data, xmlValue)
        data = data.frame(matrix(unlist(data),ncol=8))
        data = cbind(num, data)
    }
    return(data)
}

chip_locations = NULL
for(i in 1:3000){
    print(i)
    data = get_chip_location_info(i)
    if(!is.null(data)){
        chip_locations = rbind(chip_locations,data)
    }
    else{
        print(paste0(i,"error"))
    }
    
}
names(chip_locations) = c("num","address","city","state","country","zipcode","lat","long","hours")


get_chip_menu_info= function(num){
    data = GET(paste0("https://svc.chipotle.com/Order.svc/Menu/Regular/",num,"/en"),add_headers(Host="svc.chipotle.com","Proxy-Connection"="keep-alive","Accept-Encoding"="gzip, deflate","Accept-Language"="en-us",Connection="keep-alive",ChipClientToken="46514EE8-9892-4AC5-B403-761E3B8EA935",User_Agent="Chipotle/70 CFNetwork/672.1.15 Darwin/14.0.0",Accept="*/*"))
    doc = content(data, as='parse', type='text/xml')
    parse = xmlParse(doc)
    root = xmlRoot(parse)

    menu_items =sapply(xpathApply(root, "//chip:MenuItem/chip:BagItemName/text()", namespaces = c(chip = "http://chipotle.com/ChipServiceWeb/2011/10")), xmlValue)
    item_types =sapply(xpathApply(root, "//chip:MenuItem/chip:ItemTypeName/text()", namespaces = c(chip = "http://chipotle.com/ChipServiceWeb/2011/10")), xmlValue)
    is_base = sapply(xpathApply(root, "//chip:MenuItem/chip1:IsBaseMenu/text()", namespaces = c(chip = "http://chipotle.com/ChipServiceWeb/2011/10",chip1="http://chipotle.com/ChipService/2011/10")), xmlValue)
    is_display_only = sapply(xpathApply(root, "//chip:MenuItem/chip1:IsDisplayOnly/text()", namespaces = c(chip = "http://chipotle.com/ChipServiceWeb/2011/10",chip1="http://chipotle.com/ChipService/2011/10")), xmlValue)
    item_display = sapply(xpathApply(root, "//chip:MenuItem/chip1:ItemDisplayOrder/text()", namespaces = c(chip = "http://chipotle.com/ChipServiceWeb/2011/10",chip1="http://chipotle.com/ChipService/2011/10")), xmlValue)
    item_price = sapply(xpathApply(root, "//chip:MenuItem/chip1:ItemPrice/text()", namespaces = c(chip = "http://chipotle.com/ChipServiceWeb/2011/10",chip1="http://chipotle.com/ChipService/2011/10")), xmlValue)
    item_ws_order = sapply(xpathApply(root, "//chip:MenuItem/chip1:ItemWsOrder/text()", namespaces = c(chip = "http://chipotle.com/ChipServiceWeb/2011/10",chip1="http://chipotle.com/ChipService/2011/10")), xmlValue)
    max_count = sapply(xpathApply(root, "//chip:MenuItem/chip1:MaxCount/text()", namespaces = c(chip = "http://chipotle.com/ChipServiceWeb/2011/10",chip1="http://chipotle.com/ChipService/2011/10")), xmlValue)
    menu_item_name = sapply(xpathApply(root, "//chip:MenuItem/chip:MenuItemName/text()", namespaces = c(chip = "http://chipotle.com/ChipServiceWeb/2011/10",chip1="http://chipotle.com/ChipService/2011/10")), xmlValue)
    
    
    menu_data = cbind(num,data.frame(menu_items,item_types,is_base,is_display_only,item_display,item_price,item_ws_order,max_count,menu_item_name))
    
    return(menu_data)
}


chip_menu = NULL
for(i in 1:3500){
    print(i)
    data = get_chip_menu_info(i)
    if(!is.null(data)){
        chip_menu = rbind.fill(chip_menu,data)
    }
    else{
        print(paste0(i,"error"))
    }
    
}

# chip_menu$item_price  = as.numeric(as.character(chip_menu$item_price))
# 
# 
# 
# 
# super_chipotle = join(chip_locations, chip_menu)
# super_chipotle = subset(super_chipotle, num!=3500)
# # min, max, median chipotle by state
# menu_item_breakdown= ddply(super_chipotle,.(state,menu_item_name,menu_items),summarise, max=max(item_price),min=min(item_price),num=length(item_price),mean=mean(item_price), median=median(item_price))