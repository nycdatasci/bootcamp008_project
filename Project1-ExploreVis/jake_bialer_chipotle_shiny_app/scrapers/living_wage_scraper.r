library("rvest")
library(noncensus)
library("RSQLite")

# http://livingwage.mit.edu/counties/4003
data(zip_codes)
data(counties)
db = dbConnect(SQLite(), dbname="CostOfLiving.sqlite")

dbSendQuery(conn = db,
            "CREATE TABLE WAGES
       (Hourly_Wages TEXT,
        One_Adult REAL,
        One_Adult_One_Child REAL,
        One_Adult_Two_Children REAL,
        One_Adult_Three_Children REAL,
        Two_Adults_One_Working REAL,
        Two_Adults_One_Working_One_Child REAL,
        Two_Adults_One_Working_Two_Children REAL,
        Two_Adults_One_Working_Three_Children REAL,
        Two_Adults_One_Working_Part_Time_One_Child REAL,
        Two_Adults REAL, 
        Two_Adults_One_Child REAL,
        Two_Adults_Two_Children REAL,
        Two_Adults_Three_Children REAL,
        flips INTEGER)")


dbSendQuery(conn = db,
            "CREATE TABLE EXPENSES
       (Annual_Expenses TEXT,
        One_Adult REAL,
        One_Adult_One_Child REAL,
        One_Adult_Two_Children REAL,
        One_Adult_Three_Children REAL,
        Two_Adults_One_Working REAL,
        Two_Adults_One_Working_One_Child REAL,
        Two_Adults_One_Working_Two_Children REAL,
        Two_Adults_One_Working_Three_Children REAL,
        Two_Adults_One_Working_Part_Time_One_Child REAL,
        Two_Adults REAL, 
        Two_Adults_One_Child REAL,
        Two_Adults_Two_Children REAL,
        Two_Adults_Three_Children REAL,
        flips INTEGER)")

dbSendQuery(conn = db,
            "CREATE TABLE OCCUPATIONS
       (Occupational_Area TEXT,
        Typical_Annual_Salary REAL,
        flips INTEGER)")

state_fips  = as.numeric(as.character(counties$state_fips))
county_fips = as.numeric(as.character(counties$county_fips))
counties$fips = state_fips*1000+county_fips
county_fips = as.numeric(as.character(counties$county_fips))
counties$fips = state_fips*1000+county_fips

countys_to_scrape = counties$fips


parse_page = function(id){
  require("rvest")
  print(id)
  living_wage <- tryCatch({read_html(paste0("http://livingwage.mit.edu/counties/",id))},
                          error = function(e) {
                            living_wage = NULL
                          })
  if(is.null(living_wage)){
    return(NA)
  }
  data = living_wage %>% html_nodes(xpath='//table') %>%
    html_table()
  wages = cbind(as.data.frame(data[[1]]), id= rep(id, nrow(data[[1]])))
  expenses = cbind(as.data.frame(data[[2]]), id= rep(id, nrow(data[[2]])))
  occupations = cbind(as.data.frame(data[[3]]), id= rep(id, nrow(data[[3]])))
  return(list(wages,expenses,occupations))
}




wages = NULL
expenses =  NULL
occupations =  NULL

remove_dollar_commas = function(x){
  x = sub(",","",x)
  x = sub("\\$","",x)
  return(as.numeric(x))
}
for(county in countys_to_scrape[1:length(countys_to_scrape)]){
    data = parse_page(county)
    wages = data[1][[1]] 
    wages_names = c("Hourly_Wages","One_Adult","One_Adult_One_Child","One_Adult_Two_Children","One_Adult_Three_Children","Two_Adults_One_Working","Two_Adults_One_Working_One_Child","Two_Adults_One_Working_Two_Children","Two_Adults_One_Working_Three_Children","Two_Adults_One_Working_Part_Time_One_Child","Two_Adults","Two_Adults_One_Child","Two_Adults_Two_Children","Two_Adults_Three_Children","flips")
    if(length(names(wages)) == length(wages_names)){
      names(wages) = wages_names
  
    dol_columns = names(wages)[!names(wages) %in% c('Hourly_Wages','flips')]
    wages[dol_columns] <- sapply(wages[dol_columns],remove_dollar_commas)
    
    expenses = data[2][[1]]
    names(expenses) = c("Annual_Expenses","One_Adult","One_Adult_One_Child","One_Adult_Two_Children","One_Adult_Three_Children","Two_Adults_One_Working","Two_Adults_One_Working_One_Child","Two_Adults_One_Working_Two_Children","Two_Adults_One_Working_Three_Children","Two_Adults_One_Working_Part_Time_One_Child","Two_Adults","Two_Adults_One_Child","Two_Adults_Two_Children","Two_Adults_Three_Children","flips")
    dol_columns = names(expenses)[!names(expenses) %in% c('Annual_Expenses','flips')]
    expenses[dol_columns] <- sapply(expenses[dol_columns],remove_dollar_commas)
    
    occupations = data[3][[1]]
    dol_columns = "Typical Annual Salary"
    occupations[dol_columns] <- sapply(occupations[dol_columns],remove_dollar_commas)
    names(occupations) = c("Occupational_Area","Typical_Annual_Salary","flips")
    
    dbWriteTable(conn=db, name="WAGES", value=wages , append=T, row.names=F,overwrite=FALSE)
    dbWriteTable(conn=db, name="EXPENSES",value=expenses  , append=T, row.names=F,overwrite=FALSE)
    dbWriteTable(conn=db, name="OCCUPATIONS",value=occupations, append=T, row.names=F,overwrite=FALSE)
    }
    
}



