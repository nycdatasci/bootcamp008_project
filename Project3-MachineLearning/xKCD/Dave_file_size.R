library(RCurl)

file.size<-function(url){
  xx = getURL(url, nobody=1L, header=1L)
  info = unlist(strsplit(xx, "\r\n"))
  size<-unlist(strsplit(info[grepl("Content-Length", info)], split=" "))[2]
  return(as.numeric(size))
}

avg.size<-function(x){
  sizes<-sapply(x,file.size)
  print("Finished another")
  return(sizes)
}
new.photos<-lapply(photos, unlist(avg.size))
avg.photo<-sapply(sapply(new.photos, as.numeric), mean)

new.photos<-list()
new.photos[1:1000]<-lapply(photos[1:1000], unlist(avg.size))



#avg.photos<-rep(0, length(photos))
#for (i in 1:length(photos)){
#  size<-as.numeric(sapply(unlist(photos[i]), file.size))
#  avg.size<-sum(size)/length(photos[i])
#  avg.photos[i]<-avg.size
#  print(paste("Finished listing", i))
#}

